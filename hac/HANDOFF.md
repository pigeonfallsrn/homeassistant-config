# HANDOFF — S18 ready | 2026-04-14

## Completed this session (S17 + transition)
- MCP confirmed on EQ14 (192.168.1.10, amd64, HAOS 17.2) ✅
- Roku Kitchen Lounge fixed (was unplugged) ✅
- Full config audit: 27 packages, 55 YAML helpers, 141 UI automations ✅
- Fixed external_url → ha.myhomehub13.xyz ✅
- Fixed shell_command paths (learned: /config/ in container, /homeassistant/ in terminal) ✅
- Upgraded mcp_session_init to include HANDOFF on load ✅
- Updated SYSTEM_KNOWLEDGE.md for EQ14 ✅
- Added PATH RULE to CRITICAL_RULES_CORE ✅
- 5 commits pushed to GitHub ✅

## Critical rule learned this session
HAOS bare metal has TWO path contexts:
  Terminal/SSH → /homeassistant/hac/
  shell_commands (HA container) → /config/hac/
Never mix them. Already in CRITICAL_RULES_CORE.md.

## S18 — ONE GOAL
Migrate all ~55 helpers from YAML to UI storage via MCP.
Work through EQ14_MIGRATION_INVENTORY.md top to bottom.
Order: input_boolean → input_select → input_number → input_datetime → timer → counter
After each type confirmed in UI → remove YAML include from configuration.yaml.
End state: zero helper YAML files, all helpers visible and editable in UI.

## Tabled (do not forget)
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE, identity unknown
- Music Assistant — setup_error, needs add-on restart
- 4 repairs: Calendar automations + Garage popup + Arrival John (browser_mod missing)
- Green HAC system — old workflow scripts need review/archive/migrate to EQ14
- Person trackers: Alaina, Ella, Michelle have none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1

## Session start command
ha_call_service shell_command mcp_session_init
Then read_critical_rules and read_handoff via MCP.
