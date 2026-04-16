# HANDOFF — S24 complete | 2026-04-16

## Completed this session (S24)

### Group 4 — Garage COMPLETE
5 package files fully resolved:
- garage_arrival_optimized.yaml: DELETED (automation-only)
- garage_quick_open.yaml: DELETED (automation-only)
- garage_lighting_automation_fixed.yaml: DELETED (automation-only)
- garage_notifications_consolidated.yaml: DELETED (automation-only)
- garage_door_alerts.yaml: automation block stripped (template: + alert: kept)

### 5 automations migrated to UI storage (ghost cleanup required)
All 5 were YAML-only (never previously in UI). Ghost pattern hit again.
Procedure used: create → ha_remove_entity ghost → ha_set_entity rename _2
  automation.garage_clear_arrival_dashboard_on_arrival
  automation.garage_door_alert_action_handler
  automation.garage_door_reset_snooze_on_close
  automation.garage_all_lights_on_fixed
  automation.garage_all_lights_off_fixed

All 5 verified state: on with clean entity IDs post-rename.
8 other garage automations were already in UI storage — untouched.

### Commits
3f9f2df feat: S24 — Group 4 garage YAML stripped (4 deleted, 1 automation block removed)

### Known issues this session
- HA Green terminal (192.168.1.3) still accessible — ran git show on wrong terminal.
  Fix applied: git -C /homeassistant flag works from any directory.
  TODO: add `cd /homeassistant` to ~/.zshrc on EQ14 (one-time fix).
- CRITICAL_RULES has duplicate entries + contradictions — needs restructure session.

## S25 — START HERE

### Priority 1: Group 3 — hue_switches.yaml (1 file)
Start: grep -n "^  - id:\|^  alias:\|^    alias:" /homeassistant/packages/hue_switches.yaml

### Priority 2: ~/.zshrc fix (30 seconds)
grep -q 'cd /homeassistant' ~/.zshrc || echo 'cd /homeassistant' >> ~/.zshrc && echo "Done"

### Priority 3: CRITICAL_RULES restructure (dedicated session)
- Split into CORE / GARAGE / HISTORY files
- Remove duplicates (HAC CLI PATH FIX appears twice)
- Resolve stop/start vs restart contradiction (stop/start wins)

## Package files remaining (7)
Group 3: hue_switches.yaml
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml
(template-only stubs: kitchen_tablet_dashboard.yaml, lighting_motion_firstfloor.yaml)

## Tabled (carried forward)
- Person trackers: Alaina, Ella, Michelle — none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen (192.168.21.233): OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 → Group 5
- humidity_smart_alerts unpause bug → Group 7
- input_text: alaina/ella WAYA softball calendar IDs → Group 6
- Aqara sensor gap: 6 door + 4 P1 motion sensors need EQ14 entity ID hunt
- first_floor_hallway_motion delay_off bug in lighting_motion_firstfloor.yaml
- 6 Ella bedroom scenes missing → Group 6
- HA Green full config audit + deprecation (Green terminal still live at 192.168.1.3)
- CRITICAL_RULES restructure into CORE/GARAGE/HISTORY split
