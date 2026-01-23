#!/bin/bash
VERSION="6.0"
CONTEXTS_DIR="/config/hac/contexts"
LEARNINGS_DIR="/config/hac/learnings"
DB="/config/home-assistant_v2.db"
mkdir -p "$CONTEXTS_DIR" "$LEARNINGS_DIR"
G='\033[0;32m';C='\033[0;36m';Y='\033[1;33m';R='\033[0;31m';N='\033[0m'

get_entities() { grep '"entity_id"' /config/.storage/core.entity_registry | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | sort; }

show_help() {
    echo -e "${C}HAC v${VERSION} - Home Assistant Command & AI Context${N}"
    echo -e "\n${Y}AI CONTEXT${N}"
    echo "  push           Sync full context to Gist + Google Drive"
    echo "  ai             Compact context for Claude"
    echo "  learn \"note\"   Add learning to today's session"
    echo "  session \"name\" Start new named session file"
    echo -e "\n${Y}DIAGNOSTICS${N}"
    echo "  s, status      System health overview"
    echo "  e, errors [N]  Recent errors (default 20)"
    echo -e "\n${Y}AUTOMATIONS${N}"
    echo "  a, auto        Automation inventory"
    echo "  t, triggers N  Recent triggers"
    echo -e "\n${Y}ENTITIES${N}"
    echo "  count          Entity counts"
    echo "  search TERM    Search entities"
    echo "  u, unavail     Unavailable entities"
    echo -e "\n${Y}DATABASE${N}"
    echo "  db             Database info"
    echo "  h, history X   Entity history"
    echo -e "\n${Y}MAINTENANCE${N}"
    echo "  check          Config validation"
    echo "  r, reload      Reload automations"
    echo "  b, backup      Backup configs"
    echo -e "\n${Y}HAC${N}"
    echo "  list           Context files"
    echo "  rules          LLM rules"
}

cmd_ai() {
    echo "# HA $(ha core info 2>/dev/null | grep 'version:' | cut -d' ' -f2) | $(date '+%Y-%m-%d %H:%M') | Strum, WI"
    echo "E:$(get_entities | wc -l) U:$(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -o '"state":"unavailable"' | wc -l)"
    echo "## People"
    curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | grep -oE '"entity_id":"person\.[^"]*","state":"[^"]*"' | sed 's/"entity_id":"person\.//;s/","state":"/: /;s/"$//'
}

cmd_push() { /config/scripts/hac_gist_sync.sh; }

cmd_learn() {
    if [[ -z "$1" ]]; then
        echo -e "${R}Usage: hac learn \"your learning note\"${N}"
        return 1
    fi
    SESSION_FILE="$CONTEXTS_DIR/session_$(date +%Y%m%d).md"
    TIMESTAMP=$(date '+%H:%M')
    if [[ ! -f "$SESSION_FILE" ]]; then
        echo "# Session $(date '+%Y-%m-%d')" > "$SESSION_FILE"
        echo "" >> "$SESSION_FILE"
    fi
    echo "- [$TIMESTAMP] $*" >> "$SESSION_FILE"
    echo -e "${G}✓ Added to $(basename $SESSION_FILE)${N}"
}

cmd_session() {
    if [[ -z "$1" ]]; then
        echo -e "${R}Usage: hac session \"session title\"${N}"
        return 1
    fi
    SAFE_NAME=$(echo "$1" | tr ' ' '_' | tr -cd '[:alnum:]_')
    SESSION_FILE="$CONTEXTS_DIR/session_$(date +%Y%m%d)_${SAFE_NAME}.md"
    echo "# Session: $1" > "$SESSION_FILE"
    echo "**Date:** $(date '+%Y-%m-%d %H:%M')" >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
    echo "## Notes" >> "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
    echo -e "${G}✓ Created: $SESSION_FILE${N}"
}

cmd_status() {
    echo -e "${C}=== STATUS ===${N}"
    echo "HA: $(ha core info 2>/dev/null | grep '^version' | cut -d: -f2)"
    echo "Entities: $(get_entities | wc -l)"
    echo "Unavailable: $(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -o '"state":"unavailable"' | wc -l)"
    echo "Packages: $(ls /config/packages/*.yaml 2>/dev/null | wc -l)"
    echo ""
    echo -e "${C}=== RECENT TRIGGERS ===${N}"
    sqlite3 "$DB" "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT 5;" 2>/dev/null
}

cmd_errors() { grep -i error /config/home-assistant.log 2>/dev/null | tail -${1:-20}; }

cmd_auto() { 
    for f in /config/automations.yaml /config/main.yaml /config/packages/*.yaml; do 
        [ -f "$f" ] && echo -e "${Y}$(basename $f):${N}" && grep -E '^\s*alias:' "$f" 2>/dev/null | sed 's/.*alias:/  /'
    done
}

cmd_triggers() { 
    sqlite3 "$DB" "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),m.entity_id FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT ${1:-30};" 2>/dev/null
}

cmd_count() { get_entities | cut -d. -f1 | sort | uniq -c | sort -rn; }
cmd_search() { get_entities | grep -i "$1"; }
cmd_unavail() { curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -o '"entity_id":"[^"]*","state":"unavailable"' | cut -d'"' -f4 | sort; }
cmd_db() { echo "Size: $(ls -lh $DB | awk '{print $5}')"; sqlite3 "$DB" "SELECT 'states:'||COUNT(*) FROM states;SELECT 'events:'||COUNT(*) FROM events;" 2>/dev/null; }
cmd_history() { sqlite3 "$DB" "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),s.state FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id='$1' ORDER BY s.last_updated_ts DESC LIMIT 30;" 2>/dev/null; }
cmd_check() { ha core check 2>&1; }
cmd_reload() { curl -s -X POST http://supervisor/core/api/services/automation/reload -H "Authorization: Bearer $SUPERVISOR_TOKEN" && echo "Reloaded"; }

cmd_backup() { 
    D="/config/backups/hac_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$D"
    cp /config/automations.yaml /config/main.yaml "$D/" 2>/dev/null
    cp -r /config/packages "$D/"
    echo -e "${G}Saved: $D${N}"
}

cmd_list() { 
    echo -e "${C}=== SESSION FILES ===${N}"
    ls -lth "$CONTEXTS_DIR" 2>/dev/null | head -10
    echo -e "\n${C}=== LEARNINGS ===${N}"
    ls -lth "$LEARNINGS_DIR" 2>/dev/null | head -5
}

cmd_rules() { cat /config/hac/HAC_LLM_RULES.md 2>/dev/null; }

case "$1" in
    ai) cmd_ai;;
    push) cmd_push;;
    learn) shift; cmd_learn "$*";;
    session) shift; cmd_session "$*";;
    s|status) cmd_status;;
    e|errors) cmd_errors "$2";;
    a|auto) cmd_auto;;
    t|triggers) cmd_triggers "$2";;
    count) cmd_count;;
    search) cmd_search "$2";;
    u|unavail) cmd_unavail;;
    db) cmd_db;;
    h|history) cmd_history "$2";;
    check) cmd_check;;
    r|reload) cmd_reload;;
    b|backup) cmd_backup;;
    list) cmd_list;;
    rules) cmd_rules;;
    *) show_help;;
esac
