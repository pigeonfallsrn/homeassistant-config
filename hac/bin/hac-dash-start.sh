#!/bin/bash
# Run at start of every kitchen dashboard session
set -e
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   KITCHEN DASHBOARD SESSION START    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Backup
echo "▶ Creating dashboard backup..."
mkdir -p /homeassistant/hac/backups
BACKUP_FILE="/homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json"
cp /homeassistant/.storage/lovelace.kitchen_wall_v2 "$BACKUP_FILE"
echo "  ✓ Saved: $BACKUP_FILE"
echo ""

# 2. Blocking items
echo "▶ BLOCKING items (do these first):"
grep -A 30 '## BLOCKING' /homeassistant/hac/BACKLOG_kitchen_dashboard.md | grep '^\- \[ \]' | sed 's/^/  /'
echo ""

# 3. Rules reminder
echo "▶ Key reminders:"
echo "  - force_reload:True before any dashboard transform"
echo "  - Single comprehensive transform — never piecemeal"  
echo "  - Verify on tablet after EVERY change"
echo "  - Never retry a documented dead-end"
echo "  - hac learn = new discoveries only"
echo ""
echo "✓ Ready. Current hash: run ha_config_get_dashboard force_reload:True"
echo ""
