#!/bin/bash
# Full HA Context for Claude - Auto-synced to Google Drive
GDRIVE="/mnt/gdrive"
OUT="$GDRIVE/ha_full_context.md"

# Ensure mount
mountpoint -q "$GDRIVE" 2>/dev/null || mount -t cifs //192.168.1.52/GoogleDrive/HAContext "$GDRIVE" -o username=admin,password='F00tb@ll123!',vers=3.0 2>/dev/null

{
echo "# Home Assistant Full Context"
echo "Updated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Location: Strum, WI | User: John Spencer"
echo "Version: $(ha core info 2>/dev/null | grep 'version:' | cut -d' ' -f2)"
echo ""

echo "## People Status"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
  grep -oE '"entity_id":"person\.[^}]+' | \
  sed 's/"entity_id":"person\.//;s/","state":"/: /;s/".*state":"/: /' | \
  sed 's/_/ /g;s/\b\(.\)/\u\1/g'

echo ""
echo "## Zones (with occupants)"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
  grep -oE '"entity_id":"zone\.[^}]+friendly_name":"[^"]*"' | \
  sed 's/.*zone\.//;s/","state":"/|/;s/","attributes.*persons":\[/|/;s/\].*friendly_name":"/|/;s/"$//'

echo ""
echo "## Input Booleans (Presence/Mode)"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
  grep -oE '"entity_id":"input_boolean\.[^"]*","state":"[^"]*"' | grep -E 'home|mode|override' | \
  sed 's/"entity_id":"input_boolean\.//;s/","state":"/: /;s/"$//'

echo ""
echo "## Device Trackers"
curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | \
  grep -oE '"entity_id":"device_tracker\.[^"]*iphone[^}]*state":"[^"]*"' | \
  sed 's/"entity_id":"device_tracker\.//;s/".*state":"/: /;s/"$//'

echo ""
echo "## Recent Automation Triggers (last 20)"
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts,'unixepoch','localtime')||' '||replace(m.entity_id,'automation.','') FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT 20;" 2>/dev/null

echo ""
echo "## Errors (last 10)"
grep -i "error\|warning" /config/home-assistant.log 2>/dev/null | tail -10 || echo "None"

echo ""
echo "## Package Configs"
for f in /config/packages/*.yaml; do
  echo ""
  echo "### $(basename $f)"
  cat "$f"
done

echo ""
echo "## automations.yaml"
cat /config/automations.yaml

echo ""
echo "## main.yaml"  
cat /config/main.yaml 2>/dev/null || echo "Not found"

} > "$OUT"

# Copy to dated version too
cp "$OUT" "$GDRIVE/ha_context_$(date +%Y%m%d_%H%M).md"

# Sync session learnings
cp /config/hac/contexts/session_*.md "$GDRIVE/" 2>/dev/null
cp /config/hac/HAC_LLM_RULES.md "$GDRIVE/" 2>/dev/null

echo "Full context synced: $(date)"
