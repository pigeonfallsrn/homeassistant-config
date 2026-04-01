# Automation Index & Package Structure
*Generated: 2026-03-31 — replaces stale 2026-02-13 version*

## Quick Reference
- **Total automations (MCP count):** 156
- **Package files:** 30 (in /homeassistant/packages/)
- **Standalone automation files:** 9 (in /homeassistant/automations/)
- **Notify target (active):** notify.mobile_app_john_s_s26_ultra
- **Notify target (DEAD - never use):** notify.mobile_app_sm_s928u

---

## Standalone Automations (/homeassistant/automations/)

### 1st_floor_bathroom_inovelli.yaml
- L14: 1st Floor Bathroom - Ceiling Switch Controls All Lights
- L71: 1st Floor Bathroom - Reset Light Override (30 min)

### 2nd_floor_bathroom_inovelli.yaml
- L17: 2nd Floor Bathroom - Ceiling Lights Inovelli Control
- L82: 2nd Floor Bathroom - Vanity Lights Inovelli Control
- L139: 2nd Floor Bathroom - Reset Fan Override (30 min)
- L153: 2nd Floor Bathroom - Reset Light Override (30 min)
- L170: 2nd Floor Bathroom - Fan Pre-trigger (Hot Water Flow)

### alaina_wake_echo_alarm.yaml
- L2: Alaina - Wake With Echo Alarm

### entry_room_aux.yaml
- L14: Entry Room - AUX Switch Time-Based Control
- L80: Entry Room - Reset Light Override (30 min)

### exterior_lights_auto_off.yaml
- L2:  Front Driveway - Lights On When Motion (Dark)
- L35: Front Driveway - Auto Off After No Motion
- L56: Garage - Auto Off After No Motion
- L77: Garage - Lights On When Walk-in Door Opens

### first_person_home.yaml
- L3: First Person Home After Dark → Entry Lights On

### kitchen_inovelli.yaml
- L16:  Kitchen - Chandelier Time-Based Control
- L73:  Kitchen Lounge - Dimmer Time-Based Control
- L168: Kitchen Table - Reset Light Override (30 min)
- L182: Kitchen Lounge - Reset Light Override (30 min)

### living_room_av.yaml
- L3: Living Room TV OFF → Full AV System OFF

---

## Package Automations (/homeassistant/packages/)
*Note: Packages use alias: not id: at top level. Line numbers = automation start.*

### adaptive_lighting_entry_lamp.yaml (626 lines)
⚠️ Contains 6 notify calls — unusual for an AL package, review
- Entry lamp adaptive control, activity boost, dim, off, hard-off sequences
- Hot tub mode notification + action handler
- Trigger IDs: door_closed, periodic_check, nobody_home, person_arrived,
  garage_opened, front_door_opened, motion, hot_tub_toggle, bedtime_on,
  turn_off, snooze_30, snooze_60

### adaptive_lighting_kitchen_lounge_lamp.yaml (248 lines)
- Kitchen lounge lamp adaptive control, activity boost, dim, off, hard-off
- Trigger IDs: motion, hot_tub_toggle, bedtime_on

### adaptive_lighting_living_room.yaml (303 lines)
- Living room lamps adaptive control, activity boost, dim, off, hard-off
- Trigger IDs: motion, hot_tub_toggle, bedtime_on

### ap_presence_hybrid.yaml (237 lines)
- AP-based presence detection (WiFi/BT hybrid)
- No top-level automation IDs (template sensors only)

### aqara_sensor_names.yaml
- Sensor rename/alias definitions only, no automations

### climate_analytics.yaml (141 lines) — last modified Mar 14
- Climate data collection/logging automations
- No top-level automation IDs

### ella_bedroom.yaml (238 lines)
- Ella bedroom lighting automations
- Aliases: Ella - Gentle Wake Before Alarm, Ella - Lights Auto Off Midnight,
  Ella - Lights Off 10:30 PM, Ella - Lights Off When Leaving,
  Ella - School Night Bedtime, Ella - Night Path On/Off,
  Ella - Sleep Timer Set/Cancel, Ella - Wind-down Override

### ella_living_room.yaml (137 lines)
- Ella living room context automations

### entry_room_ceiling_motion.yaml (package)
- Trigger IDs: motion_on, motion_off

### family_activities.yaml (378 lines)
- Aliases: Arrival - Ella Home, Arrival - Alaina Home,
  family_ella_left_for_activity, family_alaina_left_for_activity,
  family_daily_reset, family_increment_grades
- Calendar → Refresh School In Session Now / School Tomorrow

### garage_arrival_optimized.yaml
- Aliases: Arrival - Driveway & Garage Lights When Approaching,
  Arrival - Handle Notification Actions, Arrival - John Home
- Action trigger IDs: north, south, both, dismiss

### garage_door_alerts.yaml (254 lines)
- Aliases: Departure - Garage Open Alert, Departure - Handle Garage Actions,
  Departure - Clear Alert on Return
- Action trigger IDs: close_north/south, snooze_15/60_north/south

### garage_lighting_automation_fixed.yaml (130 lines)
- Garage lighting automations (fixed version)

### garage_motion_combined.yaml (183 lines — motion_aggregation)
- Combined motion sensor aggregation for garage

### garage_notifications_consolidated.yaml
- Action trigger IDs: north, south (open/close notifications consolidated)

### garage_quick_open.yaml (239 lines)
- Aliases: garage_door_quick_open_north_door_notification
- Action trigger IDs: left_zone, wifi_disconnect, cancelled, close_now,
  returned, north, south

### google_sheets_sync.yaml — last modified Mar 14
⚠️ Confirm active use or archive — consuming API quota if running

### hac_session_log.yaml
- HAC session logging automation

### humidity_smart_alerts.yaml (259 lines)
- Aliases: humidity_alert_2nd_floor_low_or_high, humidity_handle_notification_actions
- Action trigger IDs: skip_10, skip_30, skip_12h, dismiss, pause_15,
  pause_12h_old

### john_proximity.yaml
- John proximity/BT HFL detection automations

### kids_bedroom_automation.yaml (499 lines)
- Aliases: Alaina - Gentle Wake Before Alarm, Alaina - Lights Auto Off Midnight,
  Alaina - Lights Off 10:30 PM, Alaina - Lights Off When Leaving,
  Alaina - School Night Bedtime, Alaina Gentle Wake, Alaina Lights Off,
  Alaina School Night, Ella Gentle Wake, Ella Lights Off, Ella School Night,
  Apply Lighting Context, Bedtime - Handle Light Actions,
  Bedtime - Prompt to Turn Off 1st Floor Lights

### kitchen_tablet_dashboard.yaml (509 lines)
- Aliases: Apply Tablet Context, kitchen_tablet_power_off_when_everyone_away,
  kitchen_tablet_wake_when_someone_arrives
- Action trigger IDs: front_door, driveway

### lights_auto_off_safety.yaml (131 lines)
- Global lights-off safety net automations

### motion_aggregation.yaml (183 lines)
- Combined motion binary_sensor templates

### notifications_system.yaml (773 lines) ⚠️ UNAUDITED TOP SECTION
- Battery alerts: Critical Battery - Immediate Alert
- Bedtime: Bedtime - Prompt to Turn Off 1st Floor Lights, Bedtime - Handle Light Actions
- Action trigger IDs: open_north/south, lights_on, disarm, dismiss, snooze,
  all_off, first_floor, outside, pause_15m, pause_12h, ac_on, close_all,
  snooze_30, ignore
⚠️ Top of file (battery + bedtime automations) NOT YET AUDITED

### occupancy_system.yaml (549 lines)
- Aliases: Context → Apply on Occupancy Change, Context → Apply on Overlay Change,
  Context → Apply on Time Change
- Core occupancy state machine

### presence_display.yaml
- Presence display/dashboard template sensors

### presence_system.yaml (229 lines)
- Core presence template binary_sensors
- Persons tracked: john_spencer, alaina_spencer, ella_spencer
- States checked: home, Traci's House, Whitehall School
- 39 template/trigger references

### upstairs_lighting.yaml
- Trigger IDs: motion_on, motion_off (upstairs hallway)

### wifi_floor_presence.yaml (237 lines)
- Per-floor WiFi AP presence detection

---

## Key Helpers In Use

### input_boolean (YAML-defined, active)
alaina_bedroom_override, alaina_had_activity_today, alaina_winddown_override,
bathroom_fan_paused, dad_bedtime_mode, ella_bedroom_override,
ella_had_activity_today, ella_winddown_override, entry_room_manual_override,
extended_evening, guest_present, hot_tub_mode, kids_bedtime_override,
kids_wake_lights_enabled, kitchen_lounge_manual_override,
kitchen_tablet_doorbell_popup, kitchen_tablet_screen_control,
living_room_manual_override, party_mode, preserve_night_vision,
school_in_session_now, school_tomorrow
⚠️ turn_on / turn_off / turn_ appear in grep — likely artifact of service calls, not real helpers

### Zones (all radii verified 2026-03-31)
- home: 41m | Michelle's: 34m | Jean's: 75m (bumped from 12m)
- Anderson St: 75m (bumped from 7m) | TCHCC: 197m
- Traci's: 150m (bumped 2026-03-30) | Whitehall School: 139m

---

## Known Issues / Open Items
- [ ] notifications_system.yaml top section (battery/bedtime) unaudited
- [ ] 6 notify calls in adaptive_lighting_entry_lamp.yaml — investigate
- [ ] Departure double-notification: North door auto-close + departure alert both fire on same event
- [ ] orphan_automations.txt (Feb 2026) is stale — needs fresh audit pass
- [ ] google_sheets_sync.yaml — confirm active use or archive
- [ ] browser_mod not installed — blocks doorbell popup + calendar dense_section_placement
- [ ] 92 device trackers — ghost/duplicate audit pending
- [ ] 3 persons with no device trackers: Jarrett, Owen, Jean
