#!/bin/bash
GDRIVE="/mnt/gdrive"
SUPERVISOR_TOKEN="${SUPERVISOR_TOKEN}"

ensure_mount() {
    mountpoint -q "$GDRIVE" 2>/dev/null || \
    mount -t cifs //192.168.1.52/GoogleDrive/HAContext "$GDRIVE" \
        -o username=admin,password='F00tb@ll123!',vers=3.0 2>/dev/null
}

sanitize() {
    sed -E 's/(password|token|api_key|secret)["\s:=]+["\s]*[^"\s,}]+/\1: [REDACTED]/gi'
}

generate_readme() {
cat << 'INDEX'
# Home Assistant Context - John Spencer
**Location:** 40154 US Hwy 53, Strum, WI

## File Index
| File | When to Read |
|------|--------------|
| ha_state.md | Status, who's home, modes |
| ha_config.md | Config debugging only |
| ha_history.md | Recent triggers, errors |
| RULES.md | LLM command rules |

## Rules for Claude
1. Read README first, then only files needed
2. Propose changes → wait for "yes" → ONE command block
3. Use && chaining, never GUI actions
4. Never output secrets/tokens
INDEX
}

generate_state() {
echo "# HA State - $(date '+%Y-%m-%d %H:%M')"
echo "Version: $(ha core info 2>/dev/null | grep 'version:' | cut -d' ' -f2)"
echo ""
echo "## People"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
    grep -oE '"entity_id":"person\.[^"]*","state":"[^"]*"' | \
    sed 's/"entity_id":"person\.//;s/","state":"/: /;s/"$//'
echo ""
echo "## Modes"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
    grep -oE '"entity_id":"input_boolean\.[^"]*","state":"[^"]*"' | \
    grep -E 'home|mode|override' | \
    sed 's/"entity_id":"input_boolean\.//;s/","state":"/: /;s/"$//'
echo ""
echo "## Errors (last 5)"
grep -i "error" /config/home-assistant.log 2>/dev/null | tail -5 | sanitize || echo "None"
}

generate_config() {
echo "# HA Config - $(date '+%Y-%m-%d %H:%M')"
for f in /config/packages/*.yaml; do
    echo -e "\n## $(basename $f)\n\`\`\`yaml"
    cat "$f" | sanitize
    echo '```'
done
echo -e "\n## automations.yaml\n\`\`\`yaml"
cat /config/automations.yaml | sanitize
echo '```'
}

generate_history() {
echo "# HA History - $(date '+%Y-%m-%d %H:%M')"
echo "## Recent Triggers"
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT 20;" 2>/dev/null
echo -e "\n## Errors (last 15)"
grep -i "error" /config/home-assistant.log 2>/dev/null | tail -15 | sanitize || echo "None"
}

sync_all() {
    ensure_mount
    generate_readme > "$GDRIVE/README.md"
    generate_state > "$GDRIVE/ha_state.md"
    generate_config > "$GDRIVE/ha_config.md"
    generate_history > "$GDRIVE/ha_history.md"
    cp /config/hac/HAC_LLM_RULES.md "$GDRIVE/RULES.md" 2>/dev/null
    mkdir -p "$GDRIVE/session_notes"
    cp /config/hac/contexts/session_*.md "$GDRIVE/session_notes/" 2>/dev/null
    echo "$(date '+%H:%M') synced" >> "$GDRIVE/sync_log.txt"
}

sync_all
echo "Synced"
