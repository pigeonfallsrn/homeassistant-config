# HANDOFF — S22 complete | 2026-04-15

## Session Goal
Green decommission review — systematic audit before wipe.
Green stopped (ha core stop). EQ14 confirmed sole primary.

## Completed this session (S22)

### Green decommission review — COMPLETE
All 20 package files, automations/ folder (20 automations), customize.yaml,
.storage, themes, blueprints, hac/ folder audited. Nothing lost.

### Ghost entities removed from EQ14
- binary_sensor.anyone_home_2 removed
- light.ella_s_ceiling_lights_2 removed

### Entity names applied (from Green customize.yaml)
- switch.kitchen_lounge_tv_dual_smart_plug_switch: "Kitchen Lounge Roku Plug"
- switch.kitchen_lounge_tv_dual_smart_plug_switch_2: "Kitchen Lounge TV Plug"

## Key findings

### automations/ folder — ALL 20 on EQ14
Green had 9 files with 20 automations loaded via automation manual:.
All confirmed in EQ14 UI storage.

### Package files — Green-only files resolved
- motion_aggregation, wifi_floor_presence, john_proximity,
  garage_motion_combined, climate_analytics: already on EQ14
- aqara_sensor_names.yaml: SKIP (entity IDs Green-specific)
- ella_bedroom.yaml: scripts OK, 6 scenes missing (Group 6 backlog)

### Aqara sensor gap
6 door sensors + 4 P1 motion sensors from Green customize.yaml missing on EQ14.
Green entity IDs: aqara_door_and_window_sensor_door_* (don't exist on EQ14).
Need to find actual EQ14 entity IDs and rename in future session.
Friendly names needed:
  Back Patio Door, Very Front Door, Garage Walk-in Door,
  Front Driveway Walk-in Door, Garage South Bay Door, Garage North Bay Door,
  Kitchen Lounge P1 Motion, Upstairs Hallway P1 Motion,
  1st Floor Bathroom Hallway P1 Motion, Front Door Hallway P1 Motion

## S23 — START HERE

### Priority 1: Group 2 — Kitchen (3 files)
grep -n "alias:" /homeassistant/packages/kitchen_tablet_dashboard.yaml
Migration order: strip YAML first -> ha core restart -> create in UI -> no _2 suffix

### Priority 2: Group 4 — Garage (5 files, high daily use)
Review CRITICAL_RULES garage section first.

## Group 6 backlog additions
6 Ella bedroom scenes missing from EQ14 — create during Group 6:
  Ella Dim Red, Ella Reading, Ella Bedtime Glow,
  Ella Chill Purple, Ella Volleyball Hype, Ella Bright
  Entities: ella_s_ceiling_lights, ella_s_wall_light,
            ella_s_bedside_lamp, ella_s_led_lights
Bug: ella scripts have ella_s_ceiling_lights listed 3x in targets. Clean in Group 6.

## Automation package files remaining (15)
Group 2: kitchen_tablet_dashboard.yaml, lighting_motion_firstfloor.yaml, lights_auto_off_safety.yaml
Group 3: hue_switches.yaml
Group 4: garage_arrival_optimized.yaml, garage_door_alerts.yaml, garage_quick_open.yaml,
         garage_lighting_automation_fixed.yaml, garage_notifications_consolidated.yaml
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml

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
