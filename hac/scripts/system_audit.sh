#!/bin/bash

# System Audit Script - Check organization and consistency
# Date: $(date)

AUDIT_FILE="/config/hac/learnings/system_audit_$(date +%Y%m%d_%H%M%S).md"

{
echo "# Home Assistant System Audit"
echo "Date: $(date)"
echo ""
echo "## Directory Structure Review"
echo ""
echo "### Main Config Directory"
tree -L 2 /config -I '__pycache__|*.pyc|.git' 2>/dev/null || find /config -maxdepth 2 -type d | sort
echo ""

echo "## File Organization"
echo ""
echo "### Automation Files"
ls -lh /config/automations/*.yaml 2>/dev/null
echo ""
echo "Count: $(ls /config/automations/*.yaml 2>/dev/null | wc -l) files"
echo ""

echo "### Dashboard Files"
ls -lh /config/dashboards/*.yaml 2>/dev/null
echo ""

echo "### Custom Components"
ls -1 /config/custom_components/ 2>/dev/null
echo ""

echo "## Entity Analysis"
echo ""
echo "### Total Entities by Domain"
grep '"entity_id"' /config/.storage/core.entity_registry | \
  grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | \
  awk -F'.' '{print $1}' | sort | uniq -c | sort -rn
echo ""

echo "### Duplicate Check - Entities with 'old' or 'backup' in name"
grep '"entity_id"' /config/.storage/core.entity_registry | \
  grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | \
  grep -iE 'old|backup|test|deprecated|_2$|_3$' | sort
echo ""

echo "### Disabled Entities Count"
grep '"disabled_by"' /config/.storage/core.entity_registry | \
  grep -v '"disabled_by":null' | wc -l
echo ""

echo "## Area Configuration"
echo ""
grep '"name"' /config/.storage/core.area_registry | \
  grep -o '"name":"[^"]*"' | cut -d'"' -f4 | sort
echo ""

echo "## Zone Configuration"
echo ""
grep '"name"' /config/.storage/core.zone_storage 2>/dev/null | \
  grep -o '"name":"[^"]*"' | cut -d'"' -f4 | sort
echo ""

echo "## Integration Status"
echo ""
echo "### Custom Integrations"
for dir in /config/custom_components/*/; do
  if [ -d "$dir" ]; then
    name=$(basename "$dir")
    manifest="$dir/manifest.json"
    if [ -f "$manifest" ]; then
      version=$(grep '"version"' "$manifest" | cut -d'"' -f4)
      echo "- $name: v$version"
    else
      echo "- $name: (no manifest)"
    fi
  fi
done
echo ""

echo "## Backup Files Check"
echo ""
echo "### Automation Backups"
ls -lh /config/automations.yaml.backup* 2>/dev/null | wc -l
echo " backup files found"
echo ""

echo "### Configuration Backups"  
ls -lh /config/*.backup* 2>/dev/null | head -10
echo ""

echo "## Storage File Sizes"
echo ""
du -h /config/.storage/*.json 2>/dev/null | sort -hr | head -20
echo ""

echo "## Potential Cleanup Candidates"
echo ""
echo "### Old Backup Files (>30 days)"
find /config -name "*.backup*" -mtime +30 2>/dev/null
echo ""

echo "### Unused YAML files"
find /config -name "*.yaml.disabled" -o -name "*.yaml.old" 2>/dev/null
echo ""

echo "## HAC System Files"
echo ""
ls -lh /config/hac/
echo ""
echo "### Generated Contexts"
ls -lth /config/hac/contexts/ | head -10
echo ""

echo "## Recommendations"
echo ""
echo "Based on this audit, consider:"
echo "1. Review disabled entities - re-enable or remove"
echo "2. Clean up backup files older than 30 days"
echo "3. Remove test/old/deprecated entities"
echo "4. Verify all areas are properly assigned"
echo "5. Check for duplicate automation files"
echo ""

} > "$AUDIT_FILE"

cat "$AUDIT_FILE"
echo ""
echo "✓ Audit saved to: $AUDIT_FILE"
