# HANDOFF — S20 complete | 2026-04-15

## Completed this session (S20)

### Group 0 automation migration — COMPLETE ✅
- occupancy_system.yaml: 6 automations stripped, automation block removed ✅
- family_activities.yaml: 6 automations stripped, automation block removed ✅
- script/template/zone blocks preserved in both files ✅
- All 12 automations created in UI storage via MCP ✅
- jarrett_grade + owen_grade confirmed in UI storage ✅
- ha core check: clean ✅
- Commit: 12fb8cf pushed ✅

### HANDOFF.md correction
- S19 was completed but HANDOFF was never updated (still showed S18 state)
- S19 confirmed complete: 82 total helpers in UI storage, zero remaining in YAML
- helper breakdown: 50 input_boolean, 3 input_select, 6 input_number,
  16 input_datetime, 3 timer, 4 counter

### UI storage automation count (approximate)
- Was ~57 before S20
- Added 12 this session → ~69 in UI storage
- ~72 remaining in package YAML across 17 files (down from 84 across 19)

## S21 — START HERE

### Step 1: Migrate scripts from occupancy_system.yaml to UI storage
Two scripts still in YAML need to move to UI storage:
- script.apply_lighting_context (complex AL sleep mode logic)
- script.apply_tablet_context (FKB URL routing by occupancy)
⚠️  apply_tablet_context has stale IP: base_url: http://192.168.1.3:8123
    Must update to http://192.168.1.10:8123 when migrating

### Step 2: Continue Group 0 — next package files
After scripts are migrated, proceed to remaining Group 0 files:
- packages/presence_system.yaml (john_home, person trackers)
- packages/house_modes.yaml (sleep mode automation if exists)
Check with: grep -rln "^automation:" /homeassistant/packages/

### Step 3: Next automation groups
After Group 0 fully complete:
- Group 1: Entry Room (packages/entry_room.yaml or similar)
- Group 4: Garage (arrival + auto-close — high priority, often used)

### Automation package file map (from S19 audit)
17 files still have automation blocks. Verify current state with:
grep -rln "^automation:" /homeassistant/packages/

## Tabled (do not forget)
- Person trackers: Alaina, Ella, Michelle — none assigned (handle in Group 0 presence step)
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — ADB device, real, DO NOT DELETE, identity TBD
- Music Assistant — setup_error, needs add-on restart (tabled)
- input_text: alaina/ella WAYA softball calendar IDs — recreate in Group 6
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen (192.168.21.233): OTA flash pending
- Vanity slow fade: LOCAL_RAMP_RATE VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 → Group 5
- humidity_smart_alerts unpause bug → Group 7
- NordPass backlog: rename all messy entries
