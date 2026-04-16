# HANDOFF — S21 complete | 2026-04-15

## Completed this session (S21)

### Scripts migrated to UI storage
- script.apply_lighting_context → UI storage ✅
- script.apply_tablet_context → UI storage, IP fixed 192.168.1.3 → 192.168.1.10 ✅
- occupancy_system.yaml script block stripped ✅

### Automation migrations
- family_activities.yaml: automation block stripped, 6 ghosts removed, entity IDs renamed clean ✅
- entry_room_ceiling_motion.yaml: file deleted (automation only), 1 automation in UI storage ✅
- adaptive_lighting_entry_lamp.yaml: 14 automations migrated, template block preserved ✅
- All _2 ghost entities removed and renamed ✅

### Learnings promoted
- 5 new entries added to CRITICAL_RULES.md ✅
- Commit: 6e4f77b pushed ✅

## Automation package files remaining (15)

Group 2: kitchen_tablet_dashboard.yaml, lighting_motion_firstfloor.yaml, lights_auto_off_safety.yaml
Group 3: hue_switches.yaml
Group 4: garage_arrival_optimized.yaml, garage_door_alerts.yaml, garage_quick_open.yaml,
         garage_lighting_automation_fixed.yaml, garage_notifications_consolidated.yaml
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml

## S22 — START HERE

### Step 1: Stop HA on Green (URGENT — double-firing risk)
On Green's terminal: ha core stop
Green is decommissioned — EQ14 is primary. Green should not be running automations.

### Step 2: Continue Group 2 — Kitchen
Start with: grep -n "alias:" /homeassistant/packages/kitchen_tablet_dashboard.yaml
Use CORRECT migration order: strip YAML first → restart → create in UI → no _2 suffix

### Step 3: Group 4 — Garage (high priority, daily use)
5 files, complex notification architecture — review garage rules in CRITICAL_RULES first

## Tabled (do not forget)
- Person trackers: Alaina, Ella, Michelle — none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen (192.168.21.233): OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 → Group 5
- humidity_smart_alerts unpause bug → Group 7
- input_text: alaina/ella WAYA softball calendar IDs → Group 6
