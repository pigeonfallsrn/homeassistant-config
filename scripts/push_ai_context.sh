#!/bin/bash
OUT="/tmp/ha_context_$(date +%Y%m%d_%H%M).txt"
echo "# HA Context $(date)" > $OUT
echo "Version: $(ha core info 2>/dev/null|grep -oP 'version: \K.*')" >> $OUT
echo "Entities: $(find /config/.storage -name 'core.entity_registry' -exec grep -c entity_id {} \;)" >> $OUT
echo -e "\n## Packages" >> $OUT
ls /config/packages/*.yaml 2>/dev/null >> $OUT
echo -e "\n## Automations" >> $OUT
grep -h "alias:" /config/automations.yaml /config/packages/*.yaml 2>/dev/null >> $OUT
echo -e "\n## Recent Errors" >> $OUT
ha core logs --level error 2>/dev/null | tail -20 >> $OUT
# Upload via rclone (if configured) or Google Drive addon
rclone copy "$OUT" gdrive:HomeAssistant/AIContext/ 2>/dev/null || \
cp "$OUT" /backup/google_drive/AIContext/
echo "Pushed: $OUT"
