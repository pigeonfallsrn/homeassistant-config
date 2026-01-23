#!/bin/bash
# Auto-sync HA context to Google Drive for Claude
GDRIVE="/mnt/gdrive"
SUPERVISOR_TOKEN="${SUPERVISOR_TOKEN:-$(cat /config/.storage/core.config 2>/dev/null | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)}"

# Ensure mount
mountpoint -q "$GDRIVE" 2>/dev/null || mount -t cifs //192.168.1.52/GoogleDrive/HAContext "$GDRIVE" -o username=admin,password='F00tb@ll123!',vers=3.0 2>/dev/null

{
  echo "# HA Context - $(date '+%Y-%m-%d %H:%M')"
  echo "Location: Strum, WI | User: John Spencer"
  echo "Version: $(ha core info 2>/dev/null | grep 'version:' | cut -d' ' -f2)"
  
  echo -e "\n## Key States"
  curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -oE '"entity_id":"(input_boolean|person|device_tracker|binary_sensor)\.[^"]*","state":"[^"]*"' | head -50
  
  echo -e "\n## Zones"
  curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -oE '"entity_id":"zone\.[^"]*"[^}]*'
  
  echo -e "\n## Recent Automation Triggers"
  sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),m.entity_id FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state='on' ORDER BY s.last_updated_ts DESC LIMIT 15;" 2>/dev/null
  
  echo -e "\n## Errors (last 10)"
  grep -i error /config/home-assistant.log 2>/dev/null | tail -10
  
  echo -e "\n## Package Configs"
  for f in /config/packages/*.yaml; do
    echo -e "\n### $(basename $f)"
    head -100 "$f"
  done
  
} > "$GDRIVE/ha_context_latest.md"

# Also copy session learnings
cp /config/hac/contexts/session_*.md "$GDRIVE/" 2>/dev/null
cp /config/hac/HAC_LLM_RULES.md "$GDRIVE/" 2>/dev/null

echo "Synced: $(date)" >> "$GDRIVE/sync_log.txt"
