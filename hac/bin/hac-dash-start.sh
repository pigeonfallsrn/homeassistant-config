#!/bin/bash
# Kitchen dashboard session start — run at beginning of every dashboard session
set -e
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   KITCHEN DASHBOARD SESSION START        ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 1. Backup
echo "▶ Creating dashboard backup..."
mkdir -p /homeassistant/hac/backups
BACKUP_FILE="/homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json"
cp /homeassistant/.storage/lovelace.kitchen_wall_v2 "$BACKUP_FILE"
echo "  ✓ Saved: $BACKUP_FILE"
echo ""

# 2. Review today's learnings for repeat patterns
echo "▶ Checking today's learnings for promotable insights..."
TODAY=$(date +%Y%m%d)
LEARNING_FILE="/homeassistant/hac/learnings/${TODAY}.md"
if [ -f "$LEARNING_FILE" ]; then
    COUNT=$(grep -c '^\-' "$LEARNING_FILE" 2>/dev/null || echo 0)
    echo "  Found $COUNT learning(s) today. Scanning for DASHBOARD entries..."
    grep "DASHBOARD" "$LEARNING_FILE" | tail -5 | sed 's/^/  /'
else
    echo "  No learnings yet today."
fi
echo ""

# 3. Dead-ends reminder
echo "▶ CONFIRMED DEAD ENDS (do not retry):"
echo "  - CSS gutter fix (sections view black bars) — unfixable, accept it"
echo "  - Bubble Card popup in sections view root cards[] — does not register"
echo "  - hac backup on storage-mode dashboards — always fails silently"
echo "  - navigate/hash from section buttons for popups — blocked"
echo ""

# 4. Blocking items from backlog
echo "▶ BLOCKING items:"
if [ -f "/homeassistant/hac/BACKLOG_kitchen_dashboard.md" ]; then
    grep -A 20 '## BLOCKING' /homeassistant/hac/BACKLOG_kitchen_dashboard.md | grep '^\- \[ \]' | sed 's/^/  /'
else
    echo "  No backlog file found."
fi
echo ""

# 5. Key Tier 1 files
echo "▶ Read these before editing:"
echo "  hac/CRITICAL_RULES.md"
echo "  hac/KITCHEN_DASHBOARD_REFERENCE.md"
echo ""

# 6. Transform reminders
echo "▶ Transform rules:"
echo "  - force_reload:True before EVERY transform"
echo "  - ONE comprehensive transform per section — never piecemeal"
echo "  - Direct index only: config['views'][0]['sections'][0]['cards'][2]"
echo "  - No enumerate, isinstance, str(), any(), all(), next(), try/except"
echo "  - Verify on tablet after EVERY change before proceeding"
echo "  - hac learn = new discoveries only — check Tier 1 files first"
echo ""
echo "✓ Ready. Run: ha_config_get_dashboard force_reload:True to get current hash."
echo ""
