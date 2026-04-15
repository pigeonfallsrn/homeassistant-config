# HANDOFF — S18 complete | 2026-04-15

## Completed this session (S18)

### Helper migration — input_boolean
- All input_boolean YAML stripped from 6 package files + input_boolean.yaml + configuration.yaml ✅
- HA restarted — 15 helpers auto-migrated to UI storage ✅
- 26 additional helpers created via MCP ✅
- Total in UI storage: 41 of 50 input_boolean helpers
- Calendar repair fix: templated service names replaced with if/then/else in occupancy_system.yaml ✅
- Commit pushed: c6ca91d ✅

### Critical learnings added to CRITICAL_RULES
- MCP boundary rule: ha_config_list_helpers = UI storage ONLY, YAML helpers invisible
- ha_config_set_helper without helper_id = create new (name drives entity_id)
- ha_config_set_helper with helper_id = update existing storage helper only
- HA entity count ≠ UI storage count — never conflate
- ~84 package YAML automations exist across 19 files (MCP cannot see them)
- Templated service names (service.{{ }}) deprecated HA 2026 → use if/then/else
- BusyBox grep: NO --include flag → use grep -rn "pattern" /path/
- YAML automations in packages show in HA automation list but RESOURCE_NOT_FOUND via MCP

### Automation audit completed
- 141 total automation entities
- ~57 confirmed UI storage
- ~84 in package YAML across 19 files (full map in session prompt S19)
- Garage/Arrival repairs: STALE — dismiss from UI (not browser_mod, just stale load errors)

## S19 — START HERE

### Step 1: Finish input_boolean (8 remaining creates)
Create these via MCP (no helper_id, name drives entity_id):
- "Kitchen Tablet Doorbell Popup" → input_boolean.kitchen_tablet_doorbell_popup
- "Kitchen Tablet Screen Control" → input_boolean.kitchen_tablet_screen_control
- "School Tomorrow" → input_boolean.school_tomorrow
- "School In Session Now" → input_boolean.school_in_session_now
- "Kids Expected Away Now" → input_boolean.kids_expected_away_now
- "Preserve Night Vision" → input_boolean.preserve_night_vision
- "Guest Present" → input_boolean.guest_present
- "Kids Bedtime Override" → input_boolean.kids_bedtime_override

### Step 2: Restore 6 "on" states
Turn these on via input_boolean.turn_on:
  garage_auto_close_enabled, garage_auto_open_enabled,
  water_valve_auto_shutoff, security_alerts_enabled,
  door_open_alerts_enabled, kids_wake_lights_enabled

### Step 3: Verify total = 50 via ha_config_list_helpers

### Step 4: Dismiss stale repairs from UI
Settings → Repairs → dismiss "Garage - Clear Arrival Dashboard" and "Arrival - John Home"

### Step 5: Migrate input_select helpers
Terminal first: grep -rn "input_select:" /homeassistant/packages/
Then strip YAML, reload, create via MCP

### Step 6: Migrate input_number, input_datetime, timer, counter (same pattern)

### Step 7: After ALL helpers confirmed in UI
- Comment out any remaining helper includes in configuration.yaml
- ha core check → verify clean
- Commit: "feat: S19 — all helpers migrated to UI storage"

### Step 8: S20 — Group 0 automation migration
Start with occupancy_system.yaml + family_activities.yaml (12 automations)
These are the foundation — migrate first before any other groups

## Tabled (do not forget)
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE, identity unknown
- Music Assistant — setup_error, needs add-on restart
- Person trackers: Alaina, Ella, Michelle have none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- Green HAC system — old workflow scripts need review/archive

## Session start command
ha_call_service shell_command mcp_session_init
ha_call_service shell_command read_critical_rules
ha_call_service shell_command read_handoff
