#!/bin/bash
# HAC Full Export - Generates comprehensive context for Claude
# Outputs to: /config/www/ha_context.md (then sync to gist)

OUTPUT="/config/www/ha_context.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

cat > "$OUTPUT" << HEADER
# HA Context - $TIMESTAMP
Location: Strum, WI | User: John Spencer
Version: $(cat /config/.HA_VERSION 2>/dev/null || echo "unknown")

HEADER

# --- Status Section (existing hac push content) ---
echo "## People" >> "$OUTPUT"
sqlite3 /config/home-assistant_v2.db "SELECT entity_id, state FROM states_meta sm JOIN states s ON sm.metadata_id = s.metadata_id WHERE entity_id LIKE 'person.%' ORDER BY entity_id" 2>/dev/null | while read line; do
  entity=$(echo "$line" | cut -d'|' -f1 | sed 's/person.//')
  state=$(echo "$line" | cut -d'|' -f2)
  echo "$entity: $state" >> "$OUTPUT"
done

echo -e "\n## Modes" >> "$OUTPUT"
for ib in entry_room_manual_override bathroom_manual_override kitchen_lounge_manual_override hot_tub_mode living_room_manual_override kids_bedtime_override john_home alaina_home ella_home michelle_home someone_home girls_home both_girls_home dad_bedtime_mode party_mode kitchen_table_manual_override; do
  state=$(sqlite3 /config/home-assistant_v2.db "SELECT s.state FROM states_meta sm JOIN states s ON sm.metadata_id = s.metadata_id WHERE sm.entity_id = 'input_boolean.$ib' ORDER BY s.last_updated_ts DESC LIMIT 1" 2>/dev/null)
  echo "$ib: ${state:-unavailable}" >> "$OUTPUT"
done

echo -e "\n## Triggers (last 10)" >> "$OUTPUT"
sqlite3 /config/home-assistant_v2.db "SELECT datetime(last_triggered, 'localtime'), entity_id FROM automation_trigger_log ORDER BY last_triggered DESC LIMIT 10" 2>/dev/null | sed 's/automation.//' >> "$OUTPUT"

echo -e "\n## Errors" >> "$OUTPUT"
grep -i "error\|warning" /config/home-assistant.log 2>/dev/null | tail -10 >> "$OUTPUT"

# --- NEW: Full Package Contents ---
echo -e "\n\n# ═══════════════════════════════════════════════════════" >> "$OUTPUT"
echo "# PACKAGE FILES" >> "$OUTPUT"
echo "# ═══════════════════════════════════════════════════════" >> "$OUTPUT"

for pkg in /config/packages/*.yaml; do
  filename=$(basename "$pkg")
  echo -e "\n## $filename" >> "$OUTPUT"
  echo '```yaml' >> "$OUTPUT"
  cat "$pkg" >> "$OUTPUT"
  echo -e '\n```' >> "$OUTPUT"
done

# --- Automation States ---
echo -e "\n\n# ═══════════════════════════════════════════════════════" >> "$OUTPUT"
echo "# AUTOMATION STATES" >> "$OUTPUT"
echo "# ═══════════════════════════════════════════════════════" >> "$OUTPUT"
echo '```' >> "$OUTPUT"
sqlite3 /config/home-assistant_v2.db "
SELECT 
  REPLACE(sm.entity_id, 'automation.', '') as name,
  s.state,
  datetime(json_extract(s.attributes, '$.last_triggered'), 'localtime') as last_triggered
FROM states_meta sm 
JOIN states s ON sm.metadata_id = s.metadata_id 
WHERE sm.entity_id LIKE 'automation.%'
ORDER BY sm.entity_id" 2>/dev/null >> "$OUTPUT"
echo '```' >> "$OUTPUT"

echo "Export complete: $OUTPUT"
echo "Size: $(wc -c < "$OUTPUT") bytes"
