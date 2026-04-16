# HANDOFF — S23 complete | 2026-04-15

## Completed this session (S23)

### Group 2 — Kitchen COMPLETE
All 3 package files resolved:
- lights_auto_off_safety.yaml: DELETED (all 3 automations already on EQ14)
- lighting_motion_firstfloor.yaml: automation block stripped, template-only remains
- kitchen_tablet_dashboard.yaml: automation + script blocks stripped, template-only remains

### Migrated to UI storage
6 automations:
  automation.kitchen_tablet_brightness_schedule
  automation.kitchen_tablet_doorbell_camera_popup
  automation.kitchen_tablet_wake_on_kitchen_motion
  automation.kitchen_tablet_sleep_after_inactivity
  automation.kitchen_tablet_wake_on_presence
  automation.kitchen_tablet_sleep_when_away

5 scripts:
  script.kitchen_scene_all_off
  script.kitchen_scene_bright
  script.kitchen_scene_dim
  script.kitchen_scene_nightlight
  script.kitchen_scene_select

### CRITICAL_RULES promoted
Ghost registry from YAML id: fields causes _2 on create.
Pattern: ha_get_entity ALL target entity_ids BEFORE creating after YAML strip.

### Commits
5cb47f6 feat: S23 — Group 2 kitchen_tablet_dashboard migrated

## Known issues flagged (not fixed)
- first_floor_hallway_motion: delay_off inside state: > block scalar (bug in lighting_motion_firstfloor.yaml)
  The delay_off is treated as template text, not a sensor parameter. Sensor works but has no debounce.
  Fix in future session: rewrite as proper template sensor with delay_off at correct indent level.

## S24 — START HERE

### Priority 1: Group 4 — Garage (5 files, high daily use)
Read CRITICAL_RULES garage section first (shell_command.read_critical_rules_full)
Files:
  garage_arrival_optimized.yaml
  garage_door_alerts.yaml
  garage_quick_open.yaml
  garage_lighting_automation_fixed.yaml
  garage_notifications_consolidated.yaml

Start: for f in garage_arrival_optimized garage_door_alerts garage_quick_open garage_lighting_automation_fixed garage_notifications_consolidated; do echo "=== $f ===" && grep -n "alias:" /homeassistant/packages/${f}.yaml; done

### Priority 2: Group 3 — hue_switches.yaml (1 file)

## Automation package files remaining (12)
Group 3: hue_switches.yaml
Group 4: garage_arrival_optimized.yaml, garage_door_alerts.yaml, garage_quick_open.yaml,
         garage_lighting_automation_fixed.yaml, garage_notifications_consolidated.yaml
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml
(Note: kitchen_tablet_dashboard.yaml and lighting_motion_firstfloor.yaml
 remain as template-only holders — not pending migration)

## Tabled (carried forward)
- Person trackers: Alaina, Ella, Michelle — none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen (192.168.21.233): OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 -> Group 5
- humidity_smart_alerts unpause bug -> Group 7
- input_text: alaina/ella WAYA softball calendar IDs -> Group 6
- Aqara sensor gap: 6 door + 4 P1 motion sensors need EQ14 entity ID hunt
- first_floor_hallway_motion delay_off bug in lighting_motion_firstfloor.yaml
- 6 Ella bedroom scenes missing -> Group 6
