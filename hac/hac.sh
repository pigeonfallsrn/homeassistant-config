#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# HAC v7.3 - Home Assistant Context Manager
# Token-efficient | Secret Gist | Auto-backup | Privacy-first | Safe editing
# ═══════════════════════════════════════════════════════════════════════════════
set -e

# === CONFIG ===
HAC_VERSION="8.0"
HAC_DIR="/config/hac"
OUTPUT_DIR="$HAC_DIR/gist_output"
PACKAGES_DIR="/config/packages"
DB_PATH="/config/home-assistant_v2.db"
LEARNINGS_DIR="$HAC_DIR/learnings"
TABLED_FILE="$HAC_DIR/tabled_projects.md"
GITHUB_TOKEN_FILE="$HAC_DIR/.github_token"
GIST_ID_FILE="$HAC_DIR/.gist_id"
BACKUP_DIR="$HAC_DIR/backups"
SESSION_FILE="$HAC_DIR/session_$(date +%Y%m%d).md"
LAST_PUSH_MARKER="$HAC_DIR/.last_push"

# === PRIVACY: Sanitization patterns ===
SANITIZE_PATTERNS=(
    's/40062 Hwy 53/[ADDRESS]/g'
    's/40154 US Hwy 53/[ADDRESS]/g'
    's/Strum, WI/[TOWN]/g'
    's/Pigeon Falls/[TOWN]/g'
    's/[A-Za-z0-9._%+-]\+@[A-Za-z0-9.-]\+\.[A-Za-z]\{2,\}/[EMAIL]/g'
    's/\b[0-9]\{3\}[-.]\?[0-9]\{3\}[-.]\?[0-9]\{4\}\b/[PHONE]/g'
    's/\b\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\b/[IP]/g'
    's/\b\([0-9A-Fa-f]\{2\}[:-]\)\{5\}[0-9A-Fa-f]\{2\}\b/[MAC]/g'
    's/[a-z0-9]\{20,\}@group\.calendar\.google\.com/[CALENDAR_ID]/g'
    's/-\?[0-9]\{1,3\}\.[0-9]\{5,\},-\?[0-9]\{1,3\}\.[0-9]\{5,\}/[GPS]/g'
    's/[a-z0-9-]\+\.cloudflare[a-z]*\.\(com\|dev\)/[TUNNEL]/g'
    's/\b[a-z0-9-]\+\.local\b/[LOCAL]/gi'
)

# === FORBIDDEN PATTERNS (block push if found) ===
FORBIDDEN_PATTERNS=(
    'ghp_[A-Za-z0-9_]\{36\}'
    'gho_[A-Za-z0-9_]\{36\}'
    'github_pat_[A-Za-z0-9_]\{22,\}'
    'AKIA[A-Z0-9]\{16\}'
    'sk-[A-Za-z0-9]\{48\}'
    'xoxb-[0-9]\+-[A-Za-z0-9]\+'
)

# === HELPERS ===
log_ok() { echo "✓ $1"; }
log_warn() { echo "⚠ $1"; }
log_err() { echo "✗ $1"; }

ensure_dirs() { 
    mkdir -p "$OUTPUT_DIR" "$LEARNINGS_DIR" "$BACKUP_DIR" 2>/dev/null || true
}

get_gist_id() {
    [ -f "$GIST_ID_FILE" ] && cat "$GIST_ID_FILE" || echo ""
}

get_gh_token() {
    [ -f "$GITHUB_TOKEN_FILE" ] && cat "$GITHUB_TOKEN_FILE" || { log_err "No GitHub token in $GITHUB_TOKEN_FILE"; exit 1; }
}

get_ha_version() {
    curl -s "http://supervisor/core/api/config" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | \
    python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown"
}

sanitize_output() {
    # v7.2: Python sanitizer for reliable regex
    echo "$1" | python3 /config/hac/hac_sanitize.py sanitize
}

backup_before_edit() {
    local file="$1"
    local backup_name="$BACKUP_DIR/$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
    cp "$file" "$backup_name" 2>/dev/null && echo "$backup_name"
}

# === SAFE SED (v7.1: preview + match-count gating) ===
safe_sed() {
    local preview=false
    local force=false
    local pattern=""
    local file=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --preview|-p) preview=true; shift ;;
            --force|-f) force=true; shift ;;
            *) 
                if [[ -z "$pattern" ]]; then
                    pattern="$1"
                else
                    file="$1"
                fi
                shift ;;
        esac
    done
    
    [[ -z "$pattern" || -z "$file" ]] && { echo "Usage: hac sed [--preview] [--force] 'pattern' <file>"; return 1; }
    [ ! -f "$file" ] && log_err "File not found: $file" && return 1
    
    local search_part=$(echo "$pattern" | sed -n 's|^s[/|]\([^/|]*\)[/|].*|\1|p')
    [[ -z "$search_part" ]] && search_part="$pattern"
    
    local match_count=$(grep -c "$search_part" "$file" 2>/dev/null || echo 0)
    
    echo "═══ HAC SED ═══"
    echo "File: $(basename "$file")"
    echo "Pattern: $pattern"
    echo "Matches: $match_count"
    
    if [[ $match_count -eq 0 ]]; then
        log_err "No matches found - aborting"
        return 1
    fi
    
    if [[ $match_count -gt 1 && "$force" != true ]]; then
        log_warn "Multiple matches ($match_count) - showing context:"
        grep -n "$search_part" "$file" | head -5
        [[ $match_count -gt 5 ]] && echo "  ... and $((match_count - 5)) more"
        echo ""
        echo "Use --force to proceed anyway, or be more specific"
        return 1
    fi
    
    if [[ "$preview" == true ]]; then
        echo ""
        echo "═══ PREVIEW (no changes made) ═══"
        local tmp=$(mktemp)
        sed "$pattern" "$file" > "$tmp"
        diff -u "$file" "$tmp" | head -40 || echo "(no visible diff)"
        rm "$tmp"
        return 0
    fi
    
    local backup=$(backup_before_edit "$file")
    [ -z "$backup" ] && log_err "Backup failed" && return 1
    log_ok "Backup: $backup"
    
    if sed -i "$pattern" "$file"; then
        log_ok "Edit applied"
        echo "Verify: hac diff $(basename "$file")"
    else
        log_err "sed failed, restoring"
        cp "$backup" "$file"
        return 1
    fi
}

# === SECRET GIST MANAGEMENT ===
create_secret_gist() {
    local token=$(get_gh_token)
    local response=$(curl -s -X POST "https://api.github.com/gists" \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        -d '{
            "description": "HAC v7 - Home Assistant Context (PRIVATE)",
            "public": false,
            "files": {"00_init.md": {"content": "# HAC v7 Initialized\n"}}
        }')
    local new_id=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
    [ -n "$new_id" ] && echo "$new_id" > "$GIST_ID_FILE" && log_ok "Created secret gist: $new_id" || log_err "Failed to create gist"
}

sync_to_gist() {
    local token=$(get_gh_token)
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist ID, creating new secret gist..." && create_secret_gist && gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_err "Still no gist ID" && return 1
    
    local files_json=$(python3 << PYEOF
import json, os
files = {}
output_dir = "$OUTPUT_DIR"
for fn in ["00_README.md", "01_status.md", "02_index.md", "03_knowledge.md", "04_delta.md"]:
    path = os.path.join(output_dir, fn)
    if os.path.exists(path):
        with open(path) as f:
            files[fn] = {"content": f.read()}
print(json.dumps({"files": files}))
PYEOF
)
    
    local response=$(curl -s -X PATCH "https://api.github.com/gists/$gist_id" \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$files_json")
    
    if echo "$response" | grep -q '"id"'; then
        log_ok "Gist synced"
        date > "$LAST_PUSH_MARKER"
    else
        log_err "Gist sync failed"
        echo "$response" | head -3
    fi
}

# === GENERATORS ===
generate_readme() {
    cat > "$OUTPUT_DIR/00_README.md" << 'INNER'
# HAC Context Files

1. **01_status.md** - Live state, errors, triggers (always fetch)
2. **02_index.md** - Automation summary + IDs (fetch for automation work)
3. **03_knowledge.md** - Architecture + learnings (fetch for deep questions)
4. **04_delta.md** - Changes since last push (quick catch-up)
5. **Full YAML** - Use `hac pkg <file>` on-demand (don't pre-fetch)
INNER
}

generate_status() {
    local content=$(cat << INNER
# HA Status - $(date '+%Y-%m-%d %H:%M %Z')
Version: $(get_ha_version) | HAC: v$HAC_VERSION

## People
$(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | python3 -c "
import json,sys
for e in json.load(sys.stdin):
    if e['entity_id'].startswith('person.'): print(f\"{e['entity_id'].split('.')[1]}: {e['state']}\")" 2>/dev/null || echo "API unavailable")

## Modes
$(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | python3 -c "
import json,sys
for e in json.load(sys.stdin):
    if e['entity_id'].startswith('input_boolean.'):
        n=e['entity_id'].split('.')[1]
        if any(x in n for x in ['_home','_mode','_override','school_tomorrow','guest_present','extended_evening','girls_home']):
            print(f\"{n}: {e['state']}\")" 2>/dev/null || echo "API unavailable")

## Recent Triggers (last 10)
$(sqlite3 "$DB_PATH" "SELECT DISTINCT datetime(s.last_changed_ts,'unixepoch','localtime')||' '||replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_changed_ts DESC LIMIT 10;" 2>/dev/null || echo "DB unavailable")

## Errors (last 5)
$(tail -500 /config/home-assistant.log 2>/dev/null | grep -iE "error|exception" | grep -v "DEBUG\|aiohttp\|httpx\|async_timeout" | tail -5 || echo "None")

## Double-Fires (last hour)
$(sqlite3 "$DB_PATH" "SELECT replace(m.entity_id,'automation.',''),COUNT(*) FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' AND s.last_changed_ts>strftime('%s','now','-1 hours') GROUP BY m.entity_id HAVING COUNT(*)>3 ORDER BY COUNT(*) DESC LIMIT 5;" 2>/dev/null | while IFS='|' read a c; do echo "⚠ $a: ${c}x"; done)
INNER
)
    sanitize_output "$content" > "$OUTPUT_DIR/01_status.md"
}

generate_index() {
    cat > "$OUTPUT_DIR/02_index.md" << INNER
# Automation Index - $(date '+%Y-%m-%d %H:%M')
Fetch full YAML: \`hac pkg <filename>\`

## Package Files
$(for f in "$PACKAGES_DIR"/*.yaml; do
    [ -f "$f" ] || continue
    bn=$(basename "$f")
    count=$(grep -c "^  - id:\|^- id:" "$f" 2>/dev/null || echo "0")
    echo "- **$bn** ($count automations)"
done)

## All Automation IDs
$(for f in "$PACKAGES_DIR"/*.yaml; do
    [ -f "$f" ] || continue
    echo ""
    echo "### $(basename $f)"
    grep -n "^  - id:\|^- id:" "$f" 2>/dev/null | sed 's/:  - id: /: /;s/:- id: /: /' | head -30
done)

$([ -f "/config/automations.yaml" ] && echo "" && echo "### automations.yaml" && grep -n "^- id:" "/config/automations.yaml" 2>/dev/null | sed 's/:- id: /: /' | head -20)
INNER
}

generate_knowledge() {
    local content=$(cat << INNER
# System Knowledge - $(date '+%Y-%m-%d %H:%M')

## Architecture Quick Ref
- **Packages:** /config/packages/*.yaml
- **Presence:** input_boolean.john_home (NOT binary_sensor)
- **North garage door:** cover.ratgdo32disco_fd8d8c_door
- **South garage door:** cover.ratgdo32disco_5735e8_door  
- **Walk-in door sensor:** binary_sensor.aqara_door_and_window_sensor_door_3
- **Motion aggregation:** /config/packages/motion_aggregation.yaml
- **Automations:** /homeassistant/automations/ (NOT automations.yaml) - uses include_dir_merge_list
- **Config paths:** /homeassistant/ (not /config/), storage at /homeassistant/.storage/

## Critical Rules (from past disasters)
- NEVER use raw sed on YAML without backup
- ALWAYS use \`hac sed\` or \`hac backup\` first
- Check \`ha core check\` before restart
- Inovelli+Hue: Smart Bulb Mode must be ON
- ZSH: escape ! in strings, dont chain after python3 -c on same line
- HA CLI: ha command doesnt support services - use REST API, websocket, or UI

## Tabled Projects
$(cat "$TABLED_FILE" 2>/dev/null || echo "None")

## Recent Session Learnings
$(cat "$LEARNINGS_DIR/$(date +%Y%m%d).md" 2>/dev/null | tail -20 || echo "None today")

## Historical Learnings (last 30 lines)
$(find "$LEARNINGS_DIR" -name "2026*.md" -type f | sort -r | head -5 | xargs cat 2>/dev/null | grep "^-" | tail -30 || echo "None")
INNER
)
    sanitize_output "$content" > "$OUTPUT_DIR/03_knowledge.md"
}

generate_delta() {
    cat > "$OUTPUT_DIR/04_delta.md" << INNER
# Delta - $(date '+%Y-%m-%d %H:%M')

## Changed Since Last Push
$(if [ -f "$LAST_PUSH_MARKER" ]; then
    changed=$(find "$PACKAGES_DIR" -name "*.yaml" -newer "$LAST_PUSH_MARKER" 2>/dev/null | xargs -n1 basename 2>/dev/null)
    [ -n "$changed" ] && echo "$changed" | sed 's/^/- /' || echo "_None_"
else
    echo "_No previous push marker_"
fi)

## Recent Errors (last 3)
$(tail -300 /config/home-assistant.log 2>/dev/null | grep -iE "error|exception" | grep -v "DEBUG\|aiohttp\|httpx" | tail -3 || echo "_None_")

## Quick Next Steps
- Errors? → \`hac pkg <file>\` for context
- Double-fires? → Check trigger conditions  
- All clear? → Ready for work
INNER
}

# === v7.1 NEW COMMANDS ===
cmd_audit() {
    local exit_code=0
    echo "═══ HAC AUDIT ═══"
    echo "Scanning for forbidden patterns..."
    echo ""
    
    for file in "$OUTPUT_DIR"/*.md; do
        [ -f "$file" ] || continue
        local fname=$(basename "$file")
        local ln=0
        
        while IFS= read -r line; do
            ((ln++))
            for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
                if echo "$line" | grep -qE "$pattern" 2>/dev/null; then
                    echo "❌ $fname:$ln → matches forbidden pattern"
                    echo "   ${line:0:60}..."
                    exit_code=1
                fi
            done
        done < "$file"
    done
    
    if [[ $exit_code -eq 0 ]]; then
        log_ok "Audit passed - no forbidden patterns"
    else
        echo ""
        log_err "AUDIT FAILED - fix issues before push"
    fi
    return $exit_code
}

cmd_diff() {
    local file="$1"
    [ -z "$file" ] && { echo "Usage: hac diff <file>"; echo ""; echo "Recent backups:"; ls -lt "$BACKUP_DIR" 2>/dev/null | head -10; return 1; }
    
    local bn=$(basename "$file")
    local latest=$(ls -t "$BACKUP_DIR/${bn}."* 2>/dev/null | head -1)
    
    if [ -z "$latest" ]; then
        log_err "No backup found for $bn"
        return 1
    fi
    
    local f="$PACKAGES_DIR/$file"
    [ ! -f "$f" ] && f="/config/$file"
    [ ! -f "$f" ] && { log_err "Current file not found: $file"; return 1; }
    
    echo "═══ Diff: $bn ═══"
    echo "Current: $f"
    echo "Backup:  $latest"
    echo ""
    diff -u "$latest" "$f" || echo "(files are identical)"
}

cmd_restore() {
    local file="$1"
    local timestamp="$2"
    
    if [ -z "$file" ]; then
        echo "Usage: hac restore <file> [timestamp-fragment]"
        echo ""
        echo "Recent backups:"
        ls -lt "$BACKUP_DIR" 2>/dev/null | head -15
        return 1
    fi
    
    local bn=$(basename "$file")
    local backup=""
    
    if [ -n "$timestamp" ]; then
        backup=$(ls "$BACKUP_DIR/${bn}."*"$timestamp"* 2>/dev/null | head -1)
    else
        backup=$(ls -t "$BACKUP_DIR/${bn}."* 2>/dev/null | head -1)
    fi
    
    if [ -z "$backup" ] || [ ! -f "$backup" ]; then
        log_err "No matching backup found"
        echo "Available for $bn:"
        ls "$BACKUP_DIR/${bn}."* 2>/dev/null | head -10
        return 1
    fi
    
    local f="$PACKAGES_DIR/$file"
    [ ! -f "$f" ] && f="/config/$file"
    [ ! -f "$f" ] && { log_err "Target file not found: $file"; return 1; }
    
    echo "═══ Restore Preview ═══"
    echo "From: $backup"
    echo "To:   $f"
    echo ""
    diff -u "$f" "$backup" | head -30 || echo "(files are identical)"
    echo ""
    read -p "Proceed with restore? [y/N] " confirm
    
    if [[ "$confirm" =~ ^[Yy] ]]; then
        cp "$backup" "$f"
        log_ok "Restored from $(basename "$backup")"
    else
        echo "Cancelled"
    fi
}

cmd_check() {
    echo "═══ HA Config Check ═══"
    if ha core check; then
        log_ok "Configuration valid"
        echo ""
        confirm="y"
        if [[ "$confirm" =~ ^[Yy] ]]; then
            ha core restart
            log_ok "Restart initiated"
        fi
    else
        log_err "Configuration invalid - fix errors before restart"
        return 1
    fi
}

cmd_hygiene() {
    echo "═══ Security Hygiene Check ═══"
    
    if [ -f "$GITHUB_TOKEN_FILE" ]; then
        local perms=$(stat -c '%a' "$GITHUB_TOKEN_FILE" 2>/dev/null || stat -f '%Lp' "$GITHUB_TOKEN_FILE" 2>/dev/null)
        if [ "$perms" = "600" ]; then
            log_ok "Token permissions: 600 (correct)"
        else
            log_warn "Token permissions: $perms (should be 600)"
            echo "   Fix: chmod 600 $GITHUB_TOKEN_FILE"
        fi
    else
        log_warn "No token file found"
    fi
    
    local gist_id=$(get_gist_id)
    if [ -n "$gist_id" ]; then
        log_ok "Gist ID configured: ${gist_id:0:8}..."
    fi
    
    echo ""
    echo "Quick scan of gist output..."
    local issues=0
    for file in "$OUTPUT_DIR"/*.md; do
        [ -f "$file" ] || continue
        if grep -qiE "(password|secret|token|api.?key)" "$file" 2>/dev/null; then
            log_warn "$(basename "$file") may contain sensitive keywords"
            ((issues++))
        fi
    done
    [ $issues -eq 0 ] && log_ok "No obvious sensitive keywords found"
}

# === MAIN COMMANDS ===
cmd_push() {
    ensure_dirs
    log_ok "Generating context files..."
    generate_readme
    generate_status
    generate_index
    generate_knowledge
    generate_delta
    
    if ! cmd_audit; then
        log_err "Push aborted - fix audit issues first"
        return 1
    fi
    
    sync_to_gist
    
    local gist_id=$(get_gist_id)
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    cat << PROMPT
═══════════════════════════════════════════════════════════════════════════════
HAC v$HAC_VERSION - NEW LLM SESSION
═══════════════════════════════════════════════════════════════════════════════

Fetch these URLs (in order):
  1. $gist_url/01_status.md  (current state - ALWAYS fetch)
  2. $gist_url/02_index.md   (automation IDs - fetch for automation work)

On-demand (don't pre-fetch):
  - \`hac pkg <file>\` → Full YAML with line numbers
  - \`hac ids <file>\` → Just automation IDs

## RULES (non-negotiable)
1. Terminal commands only - NO GUI
2. Chain with && - one response block
3. \`hac backup <file>\` BEFORE any edit
4. Propose command → wait for approval → execute
5. Use \`hac learn "insight"\` to log solutions

## Session Notes
$(cat "$SESSION_FILE" 2>/dev/null | tail -10 || echo "New session - no notes yet")

═══════════════════════════════════════════════════════════════════════════════
PROMPT
}

cmd_q() {
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist - run 'hac push' first" && return
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "HAC v$HAC_VERSION - CONTINUE SESSION"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "Fetch: $gist_url/01_status.md"
    echo "       $gist_url/02_index.md"
    echo "Rules: Terminal | && chain | hac backup before edit | propose→approve"
    echo "On-demand: hac pkg <file> | hac ids <file>"
    if [ -f "$HAC_DIR/tabled_projects.md" ] && [ -s "$HAC_DIR/tabled_projects.md" ]; then
        echo "───────────────────────────────────────────────────────────────────────────────"
        echo "Tabled Projects (recent 3):"
        tail -3 "$HAC_DIR/tabled_projects.md" | while read line; do echo "  $line"; done
    fi
    echo "═══════════════════════════════════════════════════════════════════════════════"
}

cmd_status() {
    echo "=== HA $(get_ha_version) | HAC v$HAC_VERSION ===" 
    curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | \
        python3 -c "import json,sys;[print(f\"{e['entity_id'].split('.')[1]}: {e['state']}\") for e in json.load(sys.stdin) if e['entity_id'].startswith('person.')]" 2>/dev/null
    echo ""
    echo "Last 5 triggers:"
    sqlite3 "$DB_PATH" "SELECT datetime(s.last_changed_ts,'unixepoch','localtime'),replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_changed_ts DESC LIMIT 5;" 2>/dev/null
}

cmd_pkg() {
    [ -z "$1" ] && echo "Available packages:" && ls -1 "$PACKAGES_DIR"/*.yaml 2>/dev/null | xargs -n1 basename && return
    local f="$PACKAGES_DIR/$1"
    [ ! -f "$f" ] && f="/config/$1"
    [ ! -f "$f" ] && log_err "Not found: $1" && return 1
    echo "# $1 ($(wc -l < "$f") lines)"
    echo "# Backup: hac backup $1"
    echo ""
    cat -n "$f"
}

cmd_ids() {
    if [ -z "$1" ]; then
        for f in "$PACKAGES_DIR"/*.yaml; do
            [ -f "$f" ] && echo "## $(basename $f)" && grep -n "^  - id:\|^- id:" "$f" 2>/dev/null | sed 's/:  - id: /: /;s/:- id: /: /' && echo ""
        done
    else
        local f="$PACKAGES_DIR/$1"
        [ ! -f "$f" ] && f="/config/$1"
        [ ! -f "$f" ] && log_err "Not found: $1" && return 1
        grep -n "^  - id:\|^- id:" "$f" 2>/dev/null | sed 's/:  - id: /: /;s/:- id: /: /'
    fi
}

cmd_backup() {
    [ -z "$1" ] && echo "Usage: hac backup <file>" && echo "Recent backups:" && ls -lt "$BACKUP_DIR" 2>/dev/null | head -10 && return
    local f="$PACKAGES_DIR/$1"
    [ ! -f "$f" ] && f="/config/$1"
    [ ! -f "$f" ] && log_err "Not found: $1" && return 1
    local backup=$(backup_before_edit "$f")
    log_ok "Created: $backup"
}

cmd_sed() {
    local args=()
    for arg in "$@"; do
        args+=("$arg")
    done
    
    local last_arg="${args[-1]}"
    local f="$PACKAGES_DIR/$last_arg"
    [ ! -f "$f" ] && f="/config/$last_arg"
    
    if [ -f "$f" ]; then
        args[-1]="$f"
    fi
    
    safe_sed "${args[@]}"
}

cmd_active() {
    local active_file="$HAC_DIR/ACTIVE.md"
    if [ -z "$1" ]; then
        cat "$active_file" 2>/dev/null || echo "No active task. Usage: hac active 'task description'"
        return
    fi
    cat > "$active_file" << ACTIVEEOF
# Active Work
TASK: $1
NEXT: (define next step)
BLOCKED: None
UPDATED: $(date +%Y-%m-%d)

## Quick Context
(add context here)
ACTIVEEOF
    echo "✓ Active task set: $1"
}

cmd_learn() {
    [ -z "$1" ] && echo "Usage: hac learn \"insight\"" && return
    ensure_dirs
    echo "- $(date '+%H:%M'): $1" >> "$SESSION_FILE"
    echo "- $(date '+%H:%M'): $1" >> "$LEARNINGS_DIR/$(date +%Y%m%d).md"
    log_ok "Logged to session + learnings"
}

cmd_recall() {
    local TOPIC="$1"
    [[ -z "$TOPIC" ]] && { echo "Usage: hac recall <topic>"; return 1; }
    echo "=== Learnings matching: $TOPIC ==="
    grep -rhi --color=always "$TOPIC" /homeassistant/hac/learnings/*.md 2>/dev/null | head -30
    echo ""
    echo "=== In SYSTEM_KNOWLEDGE.md ==="
    grep -i --color=always "$TOPIC" /homeassistant/hac/SYSTEM_KNOWLEDGE.md 2>/dev/null | head -10
}

cmd_review() {
    local days="${1:-7}"
    local kb_file="$HAC_DIR/gist_output/03_knowledge.md"
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  HAC LEARNING REVIEW — Last $days days"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Count what we're working with
    local files=$(find "$LEARNINGS_DIR" -name "*.md" -mtime -${days} -type f 2>/dev/null | sort)
    local file_count=$(echo "$files" | grep -c "." 2>/dev/null || echo 0)
    echo ""
    echo "📁 Found $file_count learning files from last $days days"
    echo ""
    
    if [ "$file_count" -eq 0 ]; then
        echo "No recent learnings found."
        return
    fi
    
    # Show files being reviewed
    echo "Files:"
    echo "$files" | while read f; do
        local size=$(wc -c < "$f" 2>/dev/null)
        local name=$(basename "$f")
        echo "  $name (${size}b)"
    done
    echo ""
    
    # Extract key patterns by category
    echo "═══ ARCHITECTURE DECISIONS ═══"
    echo "$files" | xargs grep -hi "discovery:\|decision:\|architecture\|use this.*not this\|important" 2>/dev/null | sed 's/^[[:space:]]*/  /' | head -10
    echo ""
    
    echo "═══ CRITICAL RULES (mistakes/disasters) ═══"
    echo "$files" | xargs grep -hi "never\|always\|critical\|broke\|disaster\|fix.*required\|root.cause\|lesson:" 2>/dev/null | sed 's/^[[:space:]]*/  /' | head -10
    echo ""
    
    echo "═══ TOOLS & COMMANDS CREATED ═══"
    echo "$files" | xargs grep -hi "created:\|script.*created\|new.*command\|tool:" 2>/dev/null | sed 's/^[[:space:]]*/  /' | head -10
    echo ""
    
    echo "═══ TABLED / TODO ═══"
    echo "$files" | xargs grep -hi "tabled\|todo\|next.session\|priority\|\[ \]" 2>/dev/null | sed 's/^[[:space:]]*/  /' | head -10
    echo ""
    
    echo "═══ RESOLVED / COMPLETED ═══"
    echo "$files" | xargs grep -hi "resolved\|completed\|fixed\|done\|\[x\]\|✅" 2>/dev/null | sed 's/^[[:space:]]*/  /' | head -10
    echo ""
    
    # Show current knowledge file stats
    local kb_lines=$(wc -l < "$kb_file" 2>/dev/null || echo 0)
    local kb_size=$(wc -c < "$kb_file" 2>/dev/null || echo 0)
    echo "═══════════════════════════════════════════════════════════════"
    echo "📊 Current 03_knowledge.md: ${kb_lines} lines, ${kb_size} bytes"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Review patterns above"
    echo "   2. Run: hac promote \"pattern to add to knowledge base\""
    echo "   3. Run: hac cleanup to archive old resolved items"
    echo "═══════════════════════════════════════════════════════════════"
}

cmd_promote() {
    [ -z "$1" ] && echo "Usage: hac promote \"learning to add to knowledge base\"" && return
    local kb_file="$HAC_DIR/gist_output/03_knowledge.md"
    local section="## Recent Session Learnings"
    
    # Add learning above the "Recent Session Learnings" section
    if grep -q "$section" "$kb_file" 2>/dev/null; then
        sed -i "/$section/a - $(date '+%Y-%m-%d'): $1" "$kb_file"
        log_ok "Promoted to 03_knowledge.md"
    else
        echo "" >> "$kb_file"
        echo "$section" >> "$kb_file"
        echo "- $(date '+%Y-%m-%d'): $1" >> "$kb_file"
        log_ok "Added new section + promoted to 03_knowledge.md"
    fi
}

cmd_table() {
    [ -z "$1" ] && echo "## Tabled Projects" && cat "$TABLED_FILE" 2>/dev/null && return
    ensure_dirs
    echo "- $(date '+%Y-%m-%d'): $1" >> "$TABLED_FILE"
    log_ok "Tabled: $1"
}

cmd_errors() {
    local n="${1:-20}"
    tail -1000 /config/home-assistant.log 2>/dev/null | grep -iE "error|exception|fail" | grep -v "DEBUG\|aiohttp\|httpx" | tail -"$n"
}

cmd_triggers() {
    local n="${1:-20}"
    sqlite3 "$DB_PATH" "SELECT datetime(s.last_changed_ts,'unixepoch','localtime'),replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT $n;" 2>/dev/null
}


# === IGNORE PATTERNS FOR DOUBLE-FIRES ===
IGNORE_DOUBLE_FIRES=(
    "calendar_refresh_school_tomorrow"
    "calendar_refresh_school_in_session_now"
)
cmd_health() {
    echo "=== Health Check ===" 
    echo "HA: $(get_ha_version) | HAC: v$HAC_VERSION"
    echo ""
    echo "Integration Status:"
    curl -s "http://supervisor/core/api/config/config_entries/entry" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | \
        python3 -c "import json,sys;d=json.load(sys.stdin);f=[e for e in d if e.get('state') not in ['loaded','not_loaded',None]];print('  Issues: '+str(len(f)) if f else '  All OK')" 2>/dev/null
    echo ""
    echo "Double-fires (1hr):"
    sqlite3 "$DB_PATH" "SELECT replace(m.entity_id,'automation.',''),COUNT(*) FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' AND s.last_changed_ts>strftime('%s','now','-1 hours') GROUP BY m.entity_id HAVING COUNT(*)>3 ORDER BY COUNT(*) DESC;" 2>/dev/null | while IFS='|' read a c; do echo "  ⚠ $a: ${c}x"; done || echo "  None"
    echo ""
    echo "Config Check:"
    ha core check 2>&1 | head -3
}

cmd_init() {
    ensure_dirs
    log_ok "Creating secret gist..."
    create_secret_gist
    log_ok "HAC v$HAC_VERSION initialized"
    echo "Gist ID: $(get_gist_id)"
    echo "Run 'hac push' to sync"
}

cmd_migrate() {
    local old_gist="b8a59919b8f0b71942fc21c10398f9a7"
    log_warn "This will create a NEW secret gist (old public gist remains)"
    read -p "Continue? [y/N] " confirm
    [ "$confirm" != "y" ] && echo "Aborted" && return
    create_secret_gist
    log_ok "New secret gist created: $(get_gist_id)"
    log_ok "Run 'hac push' to populate it"
    echo ""
    echo "Old public gist (consider deleting manually):"
    echo "  https://gist.github.com/pigeonfallsrn/$old_gist"
}


cmd_ui_automations() {
    echo "=== UI-Created Automations ==="
    echo "(Automations in HA database but not in YAML files)"
    echo ""
    
    curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" > /tmp/ha_states.json 2>/dev/null
    
    python3 << 'PYEOF'
import json, glob, re

try:
    with open('/tmp/ha_states.json') as f:
        states = json.load(f)
except:
    print("Error: Could not read HA states")
    exit(1)

ha_automations = {s['entity_id'].replace('automation.', ''): s['attributes'].get('friendly_name', '') 
                  for s in states if s['entity_id'].startswith('automation.')}

yaml_ids = set()
for pattern in ['/config/packages/*.yaml', '/config/automations/*.yaml', '/config/automations.yaml']:
    for filepath in glob.glob(pattern):
        try:
            with open(filepath) as f:
                yaml_ids.update(re.findall(r"id:\s*['\"]?([a-zA-Z0-9_-]+)['\"]?", f.read()))
        except: 
            pass

ui_only = {k: v for k, v in ha_automations.items() if k not in yaml_ids}

if ui_only:
    print(f"Found {len(ui_only)} UI-created automations:\n")
    for auto_id, name in sorted(ui_only.items()):
        print(f"  • {auto_id}")
        if name: 
            print(f"    '{name}'")
else:
    print("No UI-created automations found")
    print("(All automations are defined in YAML)")
PYEOF
    rm -f /tmp/ha_states.json
}
cmd_doctor() {
    echo "╔════════════════════════════════════════╗"
    echo "║   HAC Doctor - System Diagnostics      ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    cmd_health
    echo ""
    echo "=== UI Automations Check ==="
    cmd_ui_automations | head -10
    echo ""
    echo "=== Recent Errors ==="
    cmd_errors 5 2>/dev/null || echo "  No recent errors"
    echo ""
    echo "=== Git Status ==="
    cd /config && git status --short | head -10 || echo "  Clean"
    echo ""
    echo "=== Disk Usage ==="
    df -h /config | tail -1 | awk '{print "  Config: "$3" used / "$2" total ("$5" full)"}'
    echo ""
    echo "=== Recommendations ==="
    [ -n "$(cd /config && git status --short)" ] && echo "  ⚠ Uncommitted changes - run 'hac push'"
    [ -d "$BACKUP_DIR" ] && echo "  ✓ Last backup: $(ls -t "$BACKUP_DIR" | head -1)"
}
cmd_help() {
    cat << HELP
HAC v$HAC_VERSION - Home Assistant Context Manager

SYNC & SESSION
  push          Generate + audit + sync + session prompt
  q             Quick session prompt (no sync)
  gpt           ChatGPT session prompt
  gem           Gemini session prompt
  gdrive        Sync to Google Drive via Synology
  export        Master Context Excel export + sync
  sheets        Direct Google Sheets export (both workbooks)
  mcp           Claude Desktop + MCP (rich context)
  project       Claude Project workflow (browser)
  research      Deep research mode (full history)
  init          Initialize new secret gist
  migrate       Migrate from v6 public → v7 secret gist

CONTEXT
  status        Quick system status
  pkg [file]    Full YAML with line numbers
  ids [file]    Automation IDs + line numbers
  health        Integration + double-fire check
  ui-automations UI-created automation detector
  doctor        Comprehensive system diagnostics

EDITING (safe)
  backup <file>           Create timestamped backup
  sed [-p] [-f] 'pat' f   Safe sed (--preview, --force)
  diff <file>             Compare against latest backup
  restore <file> [ts]     Rollback to backup
  check                   Run ha core check + optional restart

SECURITY
  audit         Scan gist output for forbidden patterns
  hygiene       Check token perms + sensitive data

LOGGING
  learn "note"  Log to session + learnings
  review [days]  Review learnings (default 7 days)
  promote "txt"  Promote learning to knowledge base
  table "proj"  Add to tabled projects
  errors [n]    Last n errors (default 20)
  triggers [n]  Last n triggers (default 20)
HELP
}

# ═══════════════════════════════════════════════════════════════════════════════
# HAC v7.3 - Multi-LLM Output Commands
# ═══════════════════════════════════════════════════════════════════════════════

cmd_gpt() {
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist - run 'hac push' first" && return
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    cat << PROMPT
═══════════════════════════════════════════════════════════════════════════════
HOME ASSISTANT CONTEXT - ChatGPT Session
═══════════════════════════════════════════════════════════════════════════════
You're helping with Home Assistant automation. Use web search for HA docs.

**Context URLs (fetch these):**
- $gist_url/01_status.md
- $gist_url/02_index.md

## Quick Status
$(cmd_status 2>/dev/null | head -12)

## Rules
- Terminal commands only via SSH
- Propose changes, wait for approval
- Backup before edits: cp file file.bak.\$(date +%Y%m%d_%H%M%S)

## Recent Notes
$(cat "$SESSION_FILE" 2>/dev/null | tail -5 || echo "None")
═══════════════════════════════════════════════════════════════════════════════
PROMPT
}

cmd_gem() {
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist - run 'hac push' first" && return
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    cat << PROMPT
═══════════════════════════════════════════════════════════════════════════════
HOME ASSISTANT CONTEXT - Gemini Session
═══════════════════════════════════════════════════════════════════════════════
Help with Home Assistant automation.

**Fetch:** $gist_url/01_status.md and $gist_url/02_index.md

## Status
$(cmd_status 2>/dev/null | head -12)

## Workflow
1. Describe need → 2. You propose → 3. I approve → 4. Verify

## Notes
$(cat "$SESSION_FILE" 2>/dev/null | tail -5 || echo "New session")
═══════════════════════════════════════════════════════════════════════════════
PROMPT
}

cmd_prompt() {
    cat /homeassistant/hac/optimized_session_prompt_v3.md
}

cmd_mcp() {
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist - run 'hac push' first" && return
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    cat << PROMPT
═══════════════════════════════════════════════════════════════════════════════
HAC v$HAC_VERSION - CLAUDE DESKTOP + MCP SESSION
═══════════════════════════════════════════════════════════════════════════════
MCP HA server connected - query entities directly.

**URLs:** $gist_url/01_status.md | 02_index.md | 03_knowledge.md

## MCP Actions Available
- Query entity states directly
- Call services (careful)
- Read configs via terminal

## Live Status
$(cmd_status 2>/dev/null)

## Rules
1. MCP for live state, gist for structure
2. hac backup <file> before edits
3. hac learn "insight" to persist

## Session
$(cat "$SESSION_FILE" 2>/dev/null | tail -5 || echo "New")

## Active Work
$(cat "$HAC_DIR/ACTIVE.md" 2>/dev/null | grep -v "^#" | head -8 || echo "None - run: echo 'TASK: xxx' > $HAC_DIR/ACTIVE.md")

## Handoffs
$(for f in "$HAC_DIR"/handoffs/*.md; do [ -f "$f" ] && echo "- $(basename "$f")"; done 2>/dev/null || echo "None")
**Status:** IN PROGRESS

## Today (last 3)
$(tail -10 "$LEARNINGS_DIR/$(date +%Y%m%d).md" 2>/dev/null | grep "^-" | tail -3 || echo "None")
═══════════════════════════════════════════════════════════════════════════════
PROMPT
}

cmd_research() {
    local gist_id=$(get_gist_id)
    [ -z "$gist_id" ] && log_warn "No gist - run 'hac push' first" && return
    local gist_url="https://gist.githubusercontent.com/pigeonfallsrn/$gist_id/raw"
    
    cat << PROMPT
═══════════════════════════════════════════════════════════════════════════════
HAC RESEARCH MODE - Deep Dive
═══════════════════════════════════════════════════════════════════════════════
Complex problem - use web search extensively for HA docs/community.

**Full Context:**
- $gist_url/01_status.md (state)
- $gist_url/02_index.md (automations)
- $gist_url/03_knowledge.md (learnings)
- $gist_url/04_delta.md (changes)

## Overview
HA $(get_ha_version) | $(ls -1 "$PACKAGES_DIR"/*.yaml 2>/dev/null | wc -l) packages | $(grep -r "^  - id:" "$PACKAGES_DIR"/*.yaml 2>/dev/null | wc -l) automations

## Status
$(cmd_status 2>/dev/null)

## Recent Learnings (7 days)
$(find "$LEARNINGS_DIR" -name "*.md" -mtime -7 -exec cat {} \; 2>/dev/null | tail -20 || echo "None")

## Tabled Projects
$(cat "$HAC_DIR/tabled_projects.md" 2>/dev/null || echo "None")
═══════════════════════════════════════════════════════════════════════════════
PROMPT
}

# =============================================================================
# DIAGNOSTICS & WORKFLOW COMMANDS (v7.3+)
# =============================================================================

cmd_diag() {
    local pattern="${1:?Usage: hac diag <pattern>}"
    local p=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
    echo "═══ DIAG: $pattern ═══"
    curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
        http://supervisor/core/api/states | python3 -c "
import json,sys
p='$p'
results=[]
for s in json.load(sys.stdin):
    eid=s['entity_id']
    fn=s.get('attributes',{}).get('friendly_name','')
    if p in eid.lower() or p in fn.lower():
        uom=s.get('attributes',{}).get('unit_of_measurement','')
        st=s['state']
        mark='⚠ ' if st=='unavailable' else '  '
        results.append(f'{mark}{eid}: {st} {uom}')
results.sort()
for r in results: print(r)
print(f'\n  Total: {len(results)} entities')
"
}

cmd_fix() {
    echo "═══ HAC FIX ═══"
    echo "[1/3] Config check..."
    local check_out
    check_out=$(ha core check 2>&1)
    if ! echo "$check_out" | grep -q "Command completed successfully"; then
        echo "✗ Config invalid — fix errors before reloading"
        return 1
    fi
    echo "  ✓ Valid"
    echo "[2/3] Reloading automations..."
    curl -s -X POST -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
        -H "Content-Type: application/json" \
        http://supervisor/core/api/services/automation/reload > /dev/null
    sleep 3
    echo "  ✓ Reloaded"
    echo "[3/3] Health..."
    cmd_health
}

cmd_reload() {
    local domain="${1:-automation}"
    echo "═══ RELOAD: $domain ═══"
    local check_out
    check_out=$(ha core check 2>&1)
    if ! echo "$check_out" | grep -q "Command completed successfully"; then
        echo "✗ Config invalid — not reloading"
        return 1
    fi
    if [ "$domain" = "all" ]; then
        for d in automation scene script input_boolean template group; do
            curl -s -X POST -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
                -H "Content-Type: application/json" \
                "http://supervisor/core/api/services/${d}/reload" > /dev/null 2>&1
            echo "  ✓ $d"
        done
    else
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
            -H "Content-Type: application/json" \
            "http://supervisor/core/api/services/${domain}/reload")
        [ "$code" = "200" ] && echo "  ✓ $domain reloaded" || echo "  ✗ Failed (HTTP $code)"
    fi
}

cmd_do_restart() {
    echo "═══ HAC RESTART ═══"
    echo "[1/4] Config check..."
    local check_out
    check_out=$(ha core check 2>&1)
    if ! echo "$check_out" | grep -q "Command completed successfully"; then
        echo "✗ Config invalid — NOT restarting"
        return 1
    fi
    echo "  ✓ Valid"
    confirm="y"
    [ "$confirm" != "y" ] && echo "Aborted" && return 0
    echo "[2/4] Restarting..."
    ha core restart 2>&1 | grep -v "Processing"
    echo "[3/4] Waiting 90s..."
    sleep 90
    echo "[4/4] Health..."
    cmd_health
}

cmd_ghosts() {
    echo "═══ UNAVAILABLE ENTITIES ═══"
    curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
        http://supervisor/core/api/states | python3 -c "
import json,sys
states=json.load(sys.stdin)
unavail=[s['entity_id'] for s in states if s['state']=='unavailable']
if not unavail:
    print('  ✓ None found')
    sys.exit(0)
print(f'Total unavailable: {len(unavail)}')
print()
by_domain={}
for e in sorted(unavail):
    d=e.split('.')[0]
    by_domain.setdefault(d,[]).append(e)
for d,ents in sorted(by_domain.items(), key=lambda x: -len(x[1])):
    print(f'  {d}: {len(ents)}')
    show=ents if len(ents)<=8 else ents[:5]
    for e in show:
        print(f'    {e}')
    if len(ents)>8:
        print(f'    ... +{len(ents)-5} more')
    print()
"
}

cmd_purge() {
    echo "═══ PURGE GHOST AUTOMATIONS ═══"
    local ghosts
    ghosts=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
        http://supervisor/core/api/states | python3 -c "
import json,sys
for s in json.load(sys.stdin):
    if s['state']=='unavailable' and s['entity_id'].startswith('automation.'):
        print(s['entity_id'])
")
    if [ -z "$ghosts" ]; then
        echo "  ✓ No ghost automations found"
        return 0
    fi
    local count
    count=$(echo "$ghosts" | wc -l)
    echo "Found $count unavailable automations:"
    echo "$ghosts" | while read -r g; do echo "  $g"; done
    echo ""
    read -p "Remove from entity registry? [y/N] " confirm
    [ "$confirm" != "y" ] && echo "Aborted" && return 0
    local reg="/homeassistant/.storage/core.entity_registry"
    cp "$reg" "${reg}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Registry backed up"
    python3 -c "
import json
ghosts_str='''$ghosts'''
ghosts=set(ghosts_str.strip().split('\n'))
with open('$reg','r') as f:
    d=json.load(f)
before=len(d['data']['entities'])
d['data']['entities']=[e for e in d['data']['entities'] if e.get('entity_id') not in ghosts]
after=len(d['data']['entities'])
with open('$reg','w') as f:
    json.dump(d,f,indent=2)
print(f'✓ Removed {before-after} entities ({before}→{after})')
"
    echo "Restart to apply: hac restart"
}

cmd_issues() {
    echo "═══ INTEGRATION ISSUES ═══"
    curl -s "http://supervisor/core/api/config/config_entries/entry" \
        -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
except:
    print('  ✗ Could not fetch — check Settings > System > Repairs')
    sys.exit(1)
issues=[e for e in d if e.get('state') not in ['loaded','not_loaded',None,'']]
print(f'  Loaded: {len(d)-len(issues)} | Issues: {len(issues)}')
if issues:
    print()
    for e in sorted(issues, key=lambda x: x['domain']):
        print(f'    {e[\"domain\"]}: {e[\"state\"]} | {e.get(\"title\",\"?\")}')
" 2>/dev/null
}

cmd_apply() {
    local msg="${*:-session changes}"
    echo "═══ HAC APPLY ═══"
    echo "[1/5] Config check..."
    local check_out
    check_out=$(ha core check 2>&1)
    if ! echo "$check_out" | grep -q "Command completed successfully"; then
        echo "✗ Config invalid — fix errors first"
        return 1
    fi
    echo "  ✓ Valid"
    echo "[2/5] Reloading all..."
    for d in automation scene script input_boolean template group; do
        curl -s -X POST -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
            -H "Content-Type: application/json" \
            "http://supervisor/core/api/services/${d}/reload" > /dev/null 2>&1
    done
    sleep 5
    echo "  ✓ All reloaded"
    echo "[3/5] Health..."
    cmd_health
    echo ""
    echo "[4/5] Logging..."
    cmd_learn "$msg"
    echo ""
    echo "[5/5] Git..."
    cd /homeassistant || return 1
    local changes
    changes=$(git status --porcelain | wc -l)
    if [ "$changes" -eq 0 ]; then
        echo "  No changes to commit"
        return 0
    fi
    echo "  $changes file(s) changed:"
    git status --porcelain | head -10
    echo ""
    read -p "Commit & push? [y/N] " confirm
    if [ "$confirm" = "y" ]; then
        git add -A && git reset HEAD zigbee.db* > /dev/null 2>&1
        git commit -m "$msg" && git push 2>/dev/null
        echo "  ✓ Committed: $msg"
    fi
}

cmd_pre() {
    if [ $# -eq 0 ]; then
        echo "Usage: hac pre <file1> [file2] ..."
        return 1
    fi
    echo "═══ PRE-EDIT BACKUPS ═══"
    for f in "$@"; do
        cmd_backup "$f"
    done
    echo ""
    echo "Safe to edit."
}

# === MAIN ===

# Google Drive sync via Synology
cmd_export() {
    echo "═══════════════════════════════════════════════════════"
    echo "HAC EXPORT - Generating Master Context Excel Files"
    echo "═══════════════════════════════════════════════════════"
    bash /homeassistant/hac/scripts/export_master_context.sh
    log_ok "Syncing to Google Drive..."
    sync_master_context_excel
    echo "═══════════════════════════════════════════════════════"
    echo "✅ Export complete! Files available:"
    echo "   Local: /homeassistant/hac/exports/"
    echo "   Samba: \\\\homeassistant.local\\\\config\\\\hac\\\\exports\\\\"
    echo "   GDrive: HAC/MasterContext/"
    echo "═══════════════════════════════════════════════════════"
}

sync_master_context_excel() {
    local SYNOLOGY_USER="admin"
    local SYNOLOGY_HOST="192.168.1.52"
    local SYNOLOGY_KEY="$HOME/.ssh/ha_to_synology"
    local GDRIVE_EXCEL="/volume1/GoogleDrive/HAC/MasterContext"
    local EXPORTS_DIR="/homeassistant/hac/exports"
    
    # Create remote directory if needed
    ssh -i "$SYNOLOGY_KEY" "$SYNOLOGY_USER@$SYNOLOGY_HOST" "mkdir -p $GDRIVE_EXCEL" 2>/dev/null
    
    # Sync latest AI_SAFE Excel file
    local latest_safe=$(ls -t "$EXPORTS_DIR"/*_AI_SAFE.xlsx 2>/dev/null | head -1)
    if [ -f "$latest_safe" ]; then
        cat "$latest_safe" | ssh -i "$SYNOLOGY_KEY" "$SYNOLOGY_USER@$SYNOLOGY_HOST" \
            "cat > $GDRIVE_EXCEL/HA_Master_Context_Latest_AI_SAFE.xlsx" 2>/dev/null
        log_ok "Synced Master Context Excel to Google Drive"
    fi
}


sync_to_gdrive() {
    local SYNOLOGY_USER="admin"
    local SYNOLOGY_HOST="192.168.1.52"
    local SYNOLOGY_KEY="$HOME/.ssh/ha_to_synology"
    local GDRIVE_BASE="/volume1/GoogleDrive/HAC"
    log_ok "Syncing to Google Drive via Synology..."
    for f in "$OUTPUT_DIR"/*.md; do
        [ -f "$f" ] && cat "$f" | ssh -i "$SYNOLOGY_KEY" "$SYNOLOGY_USER@$SYNOLOGY_HOST" "cat > $GDRIVE_BASE/context/$(basename $f)" 2>/dev/null
    done
    local today=$(date +%Y%m%d)
    [ -f "$HAC_DIR/session_$today.md" ] && cat "$HAC_DIR/session_$today.md" | ssh -i "$SYNOLOGY_KEY" "$SYNOLOGY_USER@$SYNOLOGY_HOST" "cat > $GDRIVE_BASE/sessions/$(date +%Y-%m-%d).md" 2>/dev/null
    [ -f "$LEARNINGS_DIR/$today.md" ] && cat "$LEARNINGS_DIR/$today.md" | ssh -i "$SYNOLOGY_KEY" "$SYNOLOGY_USER@$SYNOLOGY_HOST" "cat > $GDRIVE_BASE/learnings/$today.md" 2>/dev/null
    log_ok "Google Drive sync complete"
}
cmd_sheets() {
    echo "Exporting to Google Sheets..."
    /config/python_scripts/venv/bin/python /config/python_scripts/export_to_sheets.py
    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Export complete!"
        echo "  Master: https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w"
        echo "  LLM Index: https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk"
    else
        echo "✗ Export failed"
    fi
}

cmd_gdrive() {
    ensure_dirs
    generate_readme
    generate_status
    generate_index
    generate_knowledge
    generate_delta
    sync_to_gdrive
}
project() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "CLAUDE PROJECT WORKFLOW"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "1. Open: https://claude.ai/project/019c58d3-c0da-71fc-bb21-6b1f4d7a3a12"
    echo "2. Start chatting - context is already loaded"
    echo "3. Use Sonnet 4.5 (default) or switch to Opus for complex work"
    echo ""
    echo "Knowledge base: /homeassistant/hac/SYSTEM_KNOWLEDGE.md"
    echo "To update: edit file, re-upload to Project"
    echo ""
    echo "For ChatGPT/Gemini: still use hac push or hac gpt/hac gem"
    echo "═══════════════════════════════════════════════════════════════"
}

cmd_menu() {
    cat << 'MENUEOF'
===============================================================================
HAC v8.0 - Home Assistant Context Manager
===============================================================================

START A SESSION - Which AI, where?
-------------------------------------------------------------------------------
  hac project   | Claude in BROWSER (recommended)
                | -> Opens Project with persistent knowledge base
                | -> No context paste needed, just chat
                | -> Use Sonnet 4.5 (default) or Opus for complex work

  hac mcp       | Claude DESKTOP app + MCP
                | -> Live entity queries via MCP server
                | -> Best for: real-time state debugging

  hac gpt       | ChatGPT session
                | -> Generates context + gist URLs to paste

  hac gem       | Gemini session
                | -> Generates context + gist URLs to paste

DURING SESSION - Useful commands
-------------------------------------------------------------------------------
  hac status    | Quick system overview (presence, recent triggers)
  hac pkg FILE  | View YAML with line numbers (e.g., hac pkg lighting)
  hac ids FILE  | List automation IDs + line numbers
  hac health    | Check integrations + double-fire issues
  hac doctor    | Full system diagnostics

EDITING - Safe workflow
-------------------------------------------------------------------------------
  hac backup FILE        | ALWAYS DO THIS FIRST: hac backup automations.yaml
  hac sed 'pattern' FILE | Safe sed with auto-backup (use -p to preview)
  hac diff FILE          | Compare current vs backup
  hac restore FILE [ts]  | Rollback if needed
  hac check              | Validate config + optional restart

END SESSION - Capture learnings
-------------------------------------------------------------------------------
  hac learn "insight"    | Log key insight to daily learnings
  hac promote "text"     | Move insight to permanent knowledge base
  hac table "project"    | Add to tabled/future projects list

QUICK REFERENCE
-------------------------------------------------------------------------------
  Full command list:     hac help
  View learnings:        hac review [days]

===============================================================================
TERMINAL RULES (hardwired)
===============================================================================
  BACKUP FIRST:        hac backup <file> before ANY edit
  ZSH ESCAPE:          Use single quotes or escape ! in strings
  CHAIN COMMANDS:      cmd1 && cmd2 (token efficient)
  HA PATHS:            /homeassistant/ (not /config/)
  AFTER EDITS:         hac check -> restart if valid
===============================================================================
MENUEOF
}
case "${1:-}" in
    push) cmd_push;;
    q) cmd_q;;
    gpt) cmd_gpt;;
    gem) cmd_gem;;
    gdrive) cmd_gdrive;;
    sheets) cmd_sheets;;
    export) cmd_export;;
    prompt) cmd_prompt;;
    mcp) cmd_mcp;;
    project) project;;
    research) cmd_research;;
    status) cmd_status;;
    pkg) cmd_pkg "$2";;
    ids) cmd_ids "$2";;
    backup) cmd_backup "$2";;
    sed) shift; cmd_sed "$@";;
    diff) cmd_diff "$2";;
    restore) cmd_restore "$2" "$3";;
    check) cmd_check;;
    audit) cmd_audit;;
    sanitize-test) python3 /config/hac/hac_sanitize.py test;;
    hygiene) cmd_hygiene;;
    active) shift; cmd_active "$*";;
    learn) shift; cmd_learn "$*";;
    review) cmd_review "$2";;
    recall) cmd_recall "$2";;
    promote) shift; cmd_promote "$*";;
    table) shift; cmd_table "$*";;
    errors) cmd_errors "$2";;
    triggers) cmd_triggers "$2";;
    health) cmd_health;;
    ui-automations) cmd_ui_automations;;
    doctor) cmd_doctor;;
    init) cmd_init;;
    migrate) cmd_migrate;;
    diag)    cmd_diag "$2";;
    fix)     cmd_fix;;
    reload)  cmd_reload "$2";;
    restart) cmd_do_restart;;
    ghosts)  cmd_ghosts;;
    purge)   cmd_purge;;
    apply)   shift; cmd_apply "$*";;
    issues)  cmd_issues;;
    pre)     shift; cmd_pre "$@";;
    help|--help|-h) cmd_help;;
    *) cmd_menu;;
esac



# AI Insight Tracking
hac_track_insight() {
    if [ $# -lt 3 ]; then
        echo "Usage: hac track 'Query Type' 'Question' 'Response'"
        return 1
    fi
    
    python3 /config/python_scripts/track_ai_insight.py "$1" "$2" "$3"
}

# Alias
alias hac_track='hac_track_insight'
