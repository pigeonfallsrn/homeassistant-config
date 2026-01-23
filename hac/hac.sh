#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# HAC v7.3 - Home Assistant Context Manager
# Token-efficient | Secret Gist | Auto-backup | Privacy-first | Safe editing
# ═══════════════════════════════════════════════════════════════════════════════
set -e

# === CONFIG ===
HAC_VERSION="7.3"
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

## Critical Rules (from past disasters)
- NEVER use raw sed on YAML without backup
- ALWAYS use \`hac sed\` or \`hac backup\` first
- Check \`ha core check\` before restart
- Inovelli+Hue: Smart Bulb Mode must be ON

## Tabled Projects
$(cat "$TABLED_FILE" 2>/dev/null || echo "None")

## Recent Session Learnings
$(cat "$LEARNINGS_DIR/$(date +%Y%m%d).md" 2>/dev/null | tail -20 || echo "None today")

## Historical Learnings (last 30 lines)
$(find "$LEARNINGS_DIR" -name "*.md" -type f | xargs cat 2>/dev/null | grep "^-" | tail -30 || echo "None")
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
        read -p "Restart Home Assistant? [y/N] " confirm
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

cmd_learn() {
    [ -z "$1" ] && echo "Usage: hac learn \"insight\"" && return
    ensure_dirs
    echo "- $(date '+%H:%M'): $1" >> "$SESSION_FILE"
    echo "- $(date '+%H:%M'): $1" >> "$LEARNINGS_DIR/$(date +%Y%m%d).md"
    log_ok "Logged to session + learnings"
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

cmd_help() {
    cat << HELP
HAC v$HAC_VERSION - Home Assistant Context Manager

SYNC & SESSION
  push          Generate + audit + sync + session prompt
  q             Quick session prompt (no sync)
  init          Initialize new secret gist
  migrate       Migrate from v6 public → v7 secret gist

CONTEXT
  status        Quick system status
  pkg [file]    Full YAML with line numbers
  ids [file]    Automation IDs + line numbers
  health        Integration + double-fire check

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
  table "proj"  Add to tabled projects
  errors [n]    Last n errors (default 20)
  triggers [n]  Last n triggers (default 20)
HELP
}

# === MAIN ===
case "${1:-}" in
    push) cmd_push;;
    q) cmd_q;;
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
    learn) shift; cmd_learn "$*";;
    table) shift; cmd_table "$*";;
    errors) cmd_errors "$2";;
    triggers) cmd_triggers "$2";;
    health) cmd_health;;
    init) cmd_init;;
    migrate) cmd_migrate;;
    help|--help|-h) cmd_help;;
    *) cmd_help;;
esac
