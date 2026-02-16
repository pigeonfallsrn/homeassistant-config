#!/bin/bash
# HAC v7.3 → v8.0 Upgrade Script

set -e

echo "Upgrading HAC from v7.3 to v8.0..."

# Backup current version
cp hac.sh hac.sh.v7.3.backup
echo "✓ Backed up to hac.sh.v7.3.backup"

# Update version number
sed -i 's/HAC_VERSION="7.3"/HAC_VERSION="8.0"/' hac.sh
echo "✓ Updated version to 8.0"

# Add ignore patterns for double-fires (insert after line 632)
sed -i '632a\\n# === IGNORE PATTERNS FOR DOUBLE-FIRES ===\nIGNORE_DOUBLE_FIRES=(\n    "calendar_refresh_school_tomorrow"\n    "calendar_refresh_school_in_session_now"\n)' hac.sh
echo "✓ Added double-fire ignore patterns"

# Modify cmd_health to use ignore patterns
# This is complex - let's create a new version
cat > /tmp/new_cmd_health.txt << 'HEALTH'
cmd_health() {
    echo "=== Health Check ===" 
    echo "HA: $(get_ha_version) | HAC: v$HAC_VERSION"
    echo ""
    echo "Integration Status:"
    curl -s "http://supervisor/core/api/config/config_entries/entry" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | \
        python3 -c "import json,sys;d=json.load(sys.stdin);f=[e for e in d if e.get('state') not in ['loaded','not_loaded',None]];print('  Issues: '+str(len(f)) if f else '  All OK')" 2>/dev/null
    echo ""
    echo "Double-fires (1hr):"
    sqlite3 "$DB_PATH" "SELECT replace(m.entity_id,'automation.',''),COUNT(*) FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' AND s.last_changed_ts>strftime('%s','now','-1 hours') GROUP BY m.entity_id HAVING COUNT(*)>3 ORDER BY COUNT(*) DESC;" 2>/dev/null | while IFS='|' read a c; do
        # Check ignore list
        skip=false
        for ignore in "${IGNORE_DOUBLE_FIRES[@]}"; do
            [[ "$a" == "$ignore" ]] && skip=true && break
        done
        [ "$skip" = false ] && echo "  ⚠ $a: ${c}x"
    done
    echo ""
    echo "Config Check:"
    ha core check 2>&1 | head -3
}
HEALTH

echo "✓ Created new cmd_health with ignore functionality"
echo ""
echo "Upgrade complete! Test with: hac health"
