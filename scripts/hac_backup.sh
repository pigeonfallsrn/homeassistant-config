#!/bin/bash
ARCHIVE_SCRIPT="/config/scripts/archive_backups.sh"

show_help() {
    cat << 'HELP'
HAC Backup Archive - HAC 4.2 Extension

USAGE:
    hac-backup archive [--dry-run]
    hac-backup list
    hac-backup stats
    hac-backup cleanup [YEAR]

EXAMPLES:
    hac-backup archive --dry-run
    hac-backup archive
    hac-backup stats
HELP
}

list_backups() {
    echo "════════════════════════════════════════"
    echo "  Active Backup Files"
    echo "════════════════════════════════════════"
    find /config -type f \( -name "*.backup" -o -name "*.backup.*" \) \
        -not -path "*/backups/archive/*" -exec ls -lh {} \; 2>/dev/null | \
        awk '{printf "%-10s %s\n", $5, $9}' | sort -k2
    echo ""
    total=$(find /config -type f -name "*.backup*" -not -path "*/backups/archive/*" 2>/dev/null | wc -l)
    echo "Total: $total files"
}

show_stats() {
    echo "════════════════════════════════════════"
    echo "  Backup Statistics"
    echo "════════════════════════════════════════"
    echo ""
    echo "Active Backups:"
    for year in 2023 2024 2025 2026; do
        count=$(find /config -type f -name "*backup*$year*" -not -path "*/backups/archive/*" 2>/dev/null | wc -l)
        [[ $count -gt 0 ]] && echo "  $year: $count files"
    done
    
    if [[ -d /config/backups/archive ]]; then
        echo ""
        echo "Archived Backups:"
        for year in 2023 2024 2025 2026; do
            if [[ -d "/config/backups/archive/$year" ]]; then
                count=$(find "/config/backups/archive/$year" -type f 2>/dev/null | wc -l)
                size=$(du -sh "/config/backups/archive/$year" 2>/dev/null | awk '{print $1}')
                echo "  $year: $count files ($size)"
            fi
        done
    fi
}

cleanup_archives() {
    local year=$1
    [[ -z "$year" ]] && { echo "Usage: hac-backup cleanup YYYY"; exit 1; }
    archive_dir="/config/backups/archive/$year"
    [[ ! -d "$archive_dir" ]] && { echo "No archives for $year"; exit 0; }
    file_count=$(find "$archive_dir" -type f | wc -l)
    echo "Warning: Delete $file_count files from $year?"
    read -p "Type 'yes' to confirm: " confirm
    [[ "$confirm" == "yes" ]] && rm -rf "$archive_dir" && echo "✓ Removed $year"
}

case "${1:-}" in
    archive) shift; bash "$ARCHIVE_SCRIPT" "$@" ;;
    list) list_backups ;;
    stats) show_stats ;;
    cleanup) cleanup_archives "$2" ;;
    *) show_help ;;
esac
