#!/bin/bash

echo "Home Assistant Cleanup Script"
echo "=============================="
echo ""

# Backup before cleaning
BACKUP_DIR="/config/backups/cleanup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "1. Cleaning old automation backups (keeping last 5)..."
cd /config
ls -t automations.yaml.backup* 2>/dev/null | tail -n +6 | xargs -r rm -v
echo "   Kept 5 most recent automation backups"
echo ""

echo "2. Cleaning old HAC versions..."
cd /config/hac
rm -v hac.sh.broken hac.sh.menu_version hac.sh.v4.0.backup 2>/dev/null
echo "   Kept only hac.sh.v4.1 as backup"
echo ""

echo "3. Analyzing disabled entities..."
DISABLED_COUNT=$(grep '"disabled_by"' /config/.storage/core.entity_registry | grep -v '"disabled_by":null' | wc -l)
echo "   Found: $DISABLED_COUNT disabled entities"
echo "   Review manually: grep 'disabled_by' /config/.storage/core.entity_registry | grep -v null"
echo ""

echo "4. Checking for duplicate entities..."
echo "   UniFi duplicates (_2, _3 suffixes):"
grep '"entity_id"' /config/.storage/core.entity_registry | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | grep -E '_[23]$' | head -20
echo ""

echo "5. Dashboard backups..."
ls -lh /config/*.backup* 2>/dev/null | wc -l
echo "   backup files found"
echo ""

echo "✓ Cleanup recommendations generated"
echo ""
echo "MANUAL STEPS NEEDED:"
echo "==================="
echo "1. Review Areas: Settings > Areas > Create areas for rooms"
echo "2. Review Zones: Settings > Zones > Create zones for locations"  
echo "3. Disable check: Review disabled entities and delete unused ones"
echo "4. UniFi duplicates: May need to remove/re-add UniFi integration"
