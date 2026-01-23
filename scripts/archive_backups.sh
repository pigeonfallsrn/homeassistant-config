#!/bin/bash
set -e
CONFIG_DIR="/config"
ARCHIVE_BASE="/config/backups/archive"
LOG_FILE="/config/backups/archive_log.txt"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log_msg() { echo -e "${GREEN}[INFO]${NC} $1"; echo "[INFO] $1" >> "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; echo "[WARN] $1" >> "$LOG_FILE"; }

create_archive_dirs() {
    log_msg "Creating archive directory structure..."
    for year in 2023 2024 2025 2026; do
        mkdir -p "$ARCHIVE_BASE/$year"/{automations,configuration,dashboards,scripts,other}
    done
}

find_backup_files() {
    find "$CONFIG_DIR" -type f \( -name "*.backup" -o -name "*.backup.*" -o -name "*backup_202*" \) \
        -not -path "*/backups/archive/*" 2>/dev/null
}

get_year_from_filename() {
    local filename="$1"
    [[ "$filename" =~ 202[3-6][0-1][0-9][0-3][0-9] ]] && echo "${BASH_REMATCH:0:4}" || echo "2025"
}

get_category() {
    local filepath="$1"
    [[ "$filepath" =~ /automations/ ]] && echo "automations" && return
    [[ "$filepath" =~ configuration\.yaml ]] && echo "configuration" && return
    [[ "$filepath" =~ dashboard ]] && echo "dashboards" && return
    [[ "$filepath" =~ /scripts/ ]] && echo "scripts" && return
    echo "other"
}

archive_files() {
    local dry_run=${1:-false} file_count=0 total_size=0
    while IFS= read -r filepath; do
        [[ ! -f "$filepath" ]] && continue
        filename=$(basename "$filepath")
        year=$(get_year_from_filename "$filename")
        category=$(get_category "$filepath")
        dest_path="$ARCHIVE_BASE/$year/$category/$filename"
        [[ -f "$dest_path" ]] && continue
        size=$(stat -c%s "$filepath" 2>/dev/null || echo 0)
        total_size=$((total_size + size))
        if [[ "$dry_run" == "true" ]]; then
            echo "  Would move: $filepath -> $dest_path"
        else
            mv "$filepath" "$dest_path"
            log_msg "Archived: $filename"
        fi
        ((file_count++))
    done < <(find_backup_files)
    echo "$file_count:$((total_size / 1024 / 1024))"
}

main() {
    local dry_run=false
    [[ "$1" == "--dry-run" || "$1" == "-n" ]] && dry_run=true
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  HA Backup Archive - HAC 4.2           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    [[ "$dry_run" == "true" ]] && log_warn "DRY RUN - No files moved"
    echo "$(date): Archive run started" >> "$LOG_FILE"
    create_archive_dirs
    stats=$(archive_files "$dry_run")
    file_count=$(echo "$stats" | cut -d: -f1)
    size_mb=$(echo "$stats" | cut -d: -f2)
    echo ""
    echo -e "${GREEN}Files: $file_count | Size: ${size_mb}MB${NC}"
    [[ "$dry_run" == "true" ]] && echo -e "\n${YELLOW}Run without --dry-run to move files${NC}"
}

main "$@"
