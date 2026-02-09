#!/bin/bash
# HA Master Context Exporter v2.0
# Enhanced with action items and smart metrics

set -e

DATE=$(date +%Y%m%d_%H%M%S)
STORAGE="/homeassistant/.storage"
OUTPUT="/homeassistant/hac/exports"
TEMP="$OUTPUT/temp_$DATE"

mkdir -p "$TEMP"

echo "═══════════════════════════════════════════════════════"
echo "HA Master Context Export v3.0 - $DATE"
echo "═══════════════════════════════════════════════════════"

# 1. Entity Registry
echo "[1/9] Extracting entities..."
jq -r '.data.entities[] | [
  .entity_id,
  .platform,
  .area_id // "UNASSIGNED",
  .device_id // "NO_DEVICE",
  .disabled_by // "ENABLED",
  .original_name,
  .unique_id,
  (.entity_id | split(".")[0])
] | @csv' "$STORAGE/core.entity_registry" > "$TEMP/entities.csv"

# 2. Device Registry
echo "[2/9] Extracting devices..."
jq -r '.data.devices[] | [
  .id,
  .name,
  .manufacturer // "Unknown",
  .model // "Unknown",
  .sw_version // "Unknown",
  .area_id // "UNASSIGNED",
  (.identifiers | tostring),
  (if .manufacturer == "Official add-ons" or .manufacturer == "Home Assistant Community Apps" or .manufacturer == "Home Assistant Community Store" then "ADDON" else "DEVICE" end)
] | @csv' "$STORAGE/core.device_registry" > "$TEMP/devices.csv"

# 3. Area Registry
echo "[3/9] Extracting areas..."
jq -r '.data.areas[] | [
  .id,
  .name,
  .floor_id // "NO_FLOOR",
  (.aliases | join(";"))
] | @csv' "$STORAGE/core.area_registry" > "$TEMP/areas.csv"

# 4. Integration Config Entries
echo "[4/9] Extracting integrations..."
jq -r '.data.entries[] | [
  .entry_id,
  .domain,
  .title,
  .source,
  .version,
  (.data | keys | join(";"))
] | @csv' "$STORAGE/core.config_entries" > "$TEMP/integrations.csv"

# 5. Automations
echo "[5/9] Parsing automations..."
python3 /homeassistant/hac/scripts/parse_automations.py > "$TEMP/automations.csv"

# 6. HAC Learnings
echo "[6/9] Extracting HAC learnings..."
python3 /homeassistant/hac/scripts/parse_learnings.py > "$TEMP/learnings.csv"

# 7. Action Items (NEW!)
echo "[7/9] Generating action items..."
python3 /homeassistant/hac/scripts/generate_action_items.py > "$TEMP/action_items.csv"

# 8. Stats Summary (NEW!)
echo "[8/9] Generating statistics..."
python3 /homeassistant/hac/scripts/generate_stats.py "$TEMP" > "$TEMP/stats.json"

# 9. Generate Excel files
echo "[9/9] Creating Excel files..."
python3 /homeassistant/hac/scripts/merge_to_excel.py "$TEMP" "$OUTPUT" "$DATE"

# Cleanup
rm -rf "$TEMP"

echo "✅ Export complete!"
echo "   FULL: $OUTPUT/HA_Master_Context_${DATE}_FULL.xlsx"
echo "   SAFE: $OUTPUT/HA_Master_Context_${DATE}_AI_SAFE.xlsx"
