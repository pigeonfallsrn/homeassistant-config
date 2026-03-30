# HAC Improvement Spec — 2026-03-30
## Six deliverables, one session (~2 hours)

### FIX 1: hac sheets — broken Python path (5 min)
Line ~1329 in hac.sh:
FROM: /config/python_scripts/venv/bin/python /config/python_scripts/export_to_sheets.py
TO:   /usr/bin/python3 /homeassistant/python_scripts/export_to_sheets.py

### FIX 2: Extend cmd_health (line ~769) — add after existing checks (45 min)
Add three new sections:
A) Untriggered automations — query /api/states, bucket by last_triggered
B) Dead notify target scan — grep for sm_s928u in packages + automations.yaml
C) Unavailable entities count — query /api/states, filter unavailable/unknown
Save timestamp: echo "$(date +%Y-%m-%d)" > /homeassistant/hac/.last_health_check

### FIX 3: Extend cmd_mcp (line ~982) — add after core check block (20 min)
Add blocks:
- ## SYSTEM CONTEXT (van/network/notify/SBM/privacy hardwired)
- ## MCP CANNOT SEE (presence lag, YAML files, ESPHome, UniFi, ha_deep_search stale)
- ## ROUTING (MCP/Gemini/GPT/Claude.ai decision table)
- Health check nag if .last_health_check > 14 days old

### FIX 4: New cmd_route (15 min)
Static routing guide. Add to menu under new SYSTEM HEALTH section.
Add dispatch: route) cmd_route;;

### FIX 5: New cmd_update (20 min)
Fetch HA release notes, filter for relevant domains.
curl latest-version.json + blog, grep for esphome/notify/template/zha/matter/ratgdo
Add dispatch: update) cmd_update;;

### FIX 6: audit_history tab in export_to_sheets.py (30 min)
File: /homeassistant/python_scripts/export_to_sheets.py
After all other tab writes, append one row to audit_history sheet:
[date, ha_version, total_automations, entity_count, device_count, action_items, unassigned_count]
Creates sheet if not exists. Builds longitudinal trend data for Gemini analysis.

### Menu additions
Add to hac main menu under new "SYSTEM HEALTH" section:
  hac health  | Untriggered automations, dead refs, unavailable entities
  hac route   | Which AI for which task  
  hac update  | Check HA release notes for breaking changes

### Session startup command
cat /homeassistant/hac/HAC_IMPROVEMENT_SPEC.md && grep -n 'cmd_health\|cmd_sheets\|cmd_mcp\|cmd_route\|cmd_update' /homeassistant/hac/hac.sh | head -20
