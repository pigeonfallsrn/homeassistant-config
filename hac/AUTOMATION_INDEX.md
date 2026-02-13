# Automation Index & Package Structure
*Generated: 2026-02-13*

## Package Files & Automation IDs

## adaptive_lighting_entry_lamp.yaml
87: extended_evening_auto_set
109: extended_evening_auto_clear
123: hot_tub_mode_auto_reset
138: hot_tub_mode_auto_off_when_done
183: arrival_adaptive_lighting_on
233: entry_room_lamp_adaptive_control
336: entry_room_lamp_activity_boost
372: entry_room_lamp_no_motion_dim
406: entry_room_lamp_no_motion_off
432: entry_room_lamp_hard_off
455: adaptive_lighting_global_off
478: hot_tub_mode_notification
501: hot_tub_mode_notification_actions

## adaptive_lighting_kitchen_lounge_lamp.yaml
31: kitchen_lounge_lamp_adaptive_control
134: kitchen_lounge_lamp_activity_boost
170: kitchen_lounge_lamp_no_motion_dim
204: kitchen_lounge_lamp_no_motion_off
230: kitchen_lounge_lamp_hard_off

## adaptive_lighting_living_room.yaml
32: living_room_lamps_adaptive_control
144: living_room_lamps_activity_boost
181: living_room_lamps_no_motion_dim
222: living_room_lamps_no_motion_off
255: living_room_lamps_hard_off
285: global_everyone_left_lamps_off

## ap_presence_hybrid.yaml

## aqara_sensor_names.yaml

## climate_analytics.yaml

## ella_bedroom.yaml

## entry_room_ceiling_motion.yaml
12: entry_room_ceiling_motion_lighting

## family_activities.yaml
278: family_ella_arrived_home
292: family_alaina_arrived_home
306: family_ella_left_for_activity
318: family_alaina_left_for_activity
330: family_daily_reset
345: family_increment_grades

## garage_arrival_optimized.yaml
11: garage_arrival_smart_popup
94: garage_arrival_action_handler
194: garage_arrival_autoclear

## garage_door_alerts.yaml
98: garage_door_alert_actions
223: garage_door_reset_snooze_on_close

## garage_lighting_automation_fixed.yaml
18: garage_master_lights_on_fixed
77: garage_master_lights_off_fixed

## garage_notifications_consolidated.yaml
8: garage_door_opened_close_option
48: garage_door_close_action_handler
83: garage_door_notifications_autoclear

## garage_quick_open.yaml
11: garage_quick_open_walkin
49: garage_auto_close_departure
149: garage_quick_open_action_handler
188: garage_quick_open_clear
212: arrival_lights_approaching

## google_sheets_sync.yaml
25: 'google_sheets_export_daily'
36: 'google_sheets_export_startup'
48: 'google_sheets_export_manual'

## hac_session_log.yaml

## humidity_smart_alerts.yaml
63: humidity_smart_shower_alert
108: humidity_smart_actions
224: humidity_fan_unpause
245: humidity_fan_block_when_paused

## john_proximity.yaml

## kids_bedroom_automation.yaml
207: ella_gentle_wake_automation
235: alaina_gentle_wake_automation
263: ella_school_night_bedtime
298: alaina_school_night_bedtime
329: ella_lights_hard_off_school
348: alaina_lights_hard_off_school
367: ella_lights_off_when_leaving
386: alaina_lights_off_when_leaving
405: kids_lights_off_everyone_away
419: kids_bedroom_override_reset
435: alaina_lights_auto_off_midnight_weekend
468: ella_lights_auto_off_midnight_weekend

## kitchen_tablet_dashboard.yaml
236: kitchen_tablet_brightness_schedule
277: kitchen_tablet_doorbell_popup
310: kitchen_tablet_motion_wake
331: kitchen_tablet_sleep_inactivity
354: kitchen_tablet_wake_on_presence
377: kitchen_tablet_sleep_when_away

## lights_auto_off_safety.yaml
15: safety_all_lights_off_nobody_home
67: safety_main_areas_no_motion_off
100: safety_midnight_all_lights_off

## motion_aggregation.yaml

## notifications_system.yaml
10: arrival_notification_john
51: arrival_notification_ella
69: arrival_notification_actions
114: low_battery_daily_digest
150: low_battery_notification_actions
190: critical_battery_alert
237: bedtime_first_floor_lights_off_prompt
281: bedtime_lights_notification_actions

## occupancy_system.yaml
374: update_occupancy_mode
397: apply_context_on_occupancy_change
408: apply_context_on_time_change
420: apply_context_on_overlay_change
436: refresh_school_tomorrow
468: refresh_school_in_session_now
505: upstairs_hallway_motion_lighting_OLD_DISABLED
570: 2nd_floor_bathroom_night_lighting_DISABLED_20260126_DISABLED_20260126
611: morning_wake_master_bedroom

## presence_display.yaml

## presence_system.yaml
136: john_home_detection
149: john_away_detection
168: alaina_home_detection
180: alaina_away_detection
198: ella_home_detection
210: ella_away_detection
229: michelle_home_detection
243: michelle_away_detection
261: update_girls_home_status
305: update_occupancy_combinations
369: update_someone_home
407: recent_motion_detected

## upstairs_lighting.yaml
39: upstairs_hallway_motion_lighting_v2

---

## Architecture Notes

# Automation Architecture

## Structure (151 total)
- packages/ (121) - Feature-based organization
- automations/ (25) - Room-specific Inovelli controls  
- automations.yaml (4) - UI-created
- configuration.yaml (1) - HAC export

## Major Systems
- Adaptive Lighting: 24 automations across 3 packages
- Garage: 15 automations (arrival, alerts, quick-open)
- Kids: 18 automations (bedrooms, schedules)
- Presence: 23 automations (occupancy, tracking)
- Kitchen Tablet: 12 automations

All version-controlled in Git, fully searchable, excellent organization.
