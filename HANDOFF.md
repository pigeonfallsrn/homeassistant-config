# HANDOFF — Session S52

## Last Session: S52 (2026-04-22)
## Last Commit: pending
## Baseline: 76 automations, 25 scripts, 90 helpers, 0 ghosts, 0 unavailable

---

## WHAT HAPPENED IN S52

### Full System Audit (2785 entities, 42 domains, 25 areas)
- Comprehensive MCP-based audit of all automations, scripts, entities, error logs, person trackers

### Ghost Cleanup (5 removed)
- 4 ghost scripts: ella_lights_off, ella_school_night, alaina_lights_off, alaina_school_night (all restored:true, no config)
- 1 ghost automation: entry_room_ceiling_motion_lighting (registered but RESOURCE_NOT_FOUND)

### Entity Ref Fixes — 7 automations repaired
- entry_room_lamp_motion_control: 3 broken refs fixed
- entry_room_lamp_mode_overrides: 4 broken refs fixed
- entry_room_lamp_hard_off_at_evening_end: 1 broken ref fixed
- entry_room_arrival_adaptive_lighting_welcome: 2 broken refs fixed
- system_adaptive_lighting_off_when_nobody_home_or_late_night: 1 broken ref fixed
- midnight_all_lights_off: 8 broken refs fixed (4 renamed, 4 removed as nonexistent)

### Key Entity Renames Discovered
- light.entry_room_hue_color_lamp → light.entry_room_desk_lamp (Hue migration rename)
- switch.adaptive_lighting_living_spaces → switch.living_spaces_adaptive_lighting_living_spaces
- switch.adaptive_lighting_entry_room_lamp_adaptive → switch.entry_room_lamp_adaptive_adaptive_lighting_entry_room_lamp_adaptive
- switch.adaptive_lighting_entry_room_ceiling → switch.entry_room_ceiling_adaptive_lighting_entry_room_ceiling
- light.kitchen_ceiling_inovelli_vzm31_sn → light.kitchen_ceiling_can_led_lights_inovelli
- light.kitchen_bar_pendant_lights → light.kitchen_bar_pendant_lights_inovelli_vzm31_sn
- light.kitchen_under_cabinet_aqara_t1_led_strip → light.kitchen_under_cabinet_lights_inovelli_switch
- light.living_room_tv_led_strip → light.living_room_behind_tv_tp_link_smart_light_strip

### Eliminated Errors
- Adaptive Lighting AssertionError (16 occurrences) — caused by broken AL switch ref in entry_room_lamp_motion_control. Fixed.

---

## DISCOVERED — NEEDS TERMINAL WORK

### Template Package Issues (browser terminal required)
- sensor.people_home_count — unavailable (restored:true). Working UI duplicate exists: sensor.people_home_count_2
- sensor.people_home_list — unavailable (restored:true)
- binary_sensor.house_occupied — unavailable (restored:true). Cascading blocker.
- sensor.house_occupancy_state icon template crashes: needs | int(0) default for people_home_count
- sensor.house_average_temperature, sensor.house_average_humidity, sensor.john_distance_to_home — all unknown
- Fix: find the template package YAML defining these, fix entity refs or add defaults

### configuration.yaml Issues (browser terminal required)
- auth: block with unsupported parameters generating error on every restart
- shell_command.hac_export calls hac.sh which doesn't exist on EQ14 (return code 127)

### Script Format Errors
- script.apply_tablet_context: "extra keys not allowed @ data['entity_id']" — service call format bug
- automation.context_apply_on_occupancy_change_2: same format error cascading from script

---

## TABLED / REMAINING WORK

### Priority Next:
1. Template package fixes (terminal session — fix people_home_count, house_occupied, add defaults)
2. configuration.yaml cleanup (remove auth block, fix hac_export shell_command)
3. apply_tablet_context script format fix
4. Ella companion app rename (20 entities iphone_40_* → ella_s_*)
5. Michelle person tracker (MAC 6a:9a:25:dd:82:f1 — person.michelle has no device_trackers)

### Duplicate Entities to Clean:
- todo.shopping_list + todo.shopping_list_2 (two shopping_list platform entries)
- weather.forecast_home + weather.forecast_home_2 (two Met integrations)
- tts.google_translate_en_com + tts.google_translate_en_com_2 (two Google Translate TTS)
- sensor.people_home_count (YAML) + sensor.people_home_count_2 (UI) — keep UI, remove YAML
- binary_sensor.anyone_home (unique_id: anyone_home_presence) + binary_sensor.anyone_home_2 (unique_id: anyone_home_hybrid)

### Person Entities Without Trackers:
- person.michelle — no device_trackers (needs MAC-based tracker)
- person.jarrett, person.owen, person.jean, person.traci — no trackers (are these needed?)

### Disabled Automations (4):
- upstairs_bathroom_motion_lighting (off)
- upstairs_hallway_motion_lighting_v2 (off)
- calendar_refresh_school_tomorrow (off)
- calendar_refresh_school_in_session_now (off)

### Kitchen Tablet Enhancements (tabled):
- Calendar Card Pro, master calendar parsing, doorbell camera view
- Away/home screen control (blocked by house_occupied fix)
- FKB screensaver, battery management automation

### Blocked:
- binary_sensor.house_occupied — unavailable (template package issue)
- Music Assistant — setup_error (expired token)
- Navien — connection error (creds harvested, not yet added to EQ14)
- AndroidTV 192.168.1.17 — do not delete

### Ongoing:
- Security hardening (SSH password auth, Cloudflare Zero Trust, plaintext PAT, recorder PII)
- NordPass cleanup backlog
- Discovered integrations: 2nd Floor Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast

---

## BENCHMARK

| Metric | S51 | S52 |
|--------|-----|-----|
| Automations | 77 | 76 |
| Scripts | 29 | 25 |
| Helpers | 91 | 90 |
| Ghosts | 0 | 0 |
| Unavailable auto/script | 5 | 0 |
| YAML dashboards | 0 | 0 |
| Storage dashboards | 3 | 3 |
| HACS cards | 5 | 5 |
| Template packages | 14 | 14 |
| Calendars | 19 | 19 |
| System errors (AL) | 16 | 0 |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- Kitchen tablet device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Kitchen tablet FKB startURL: http://192.168.1.10:8123/kitchen-tablet/home
- Kitchen tablet FKB Remote Admin: http://192.168.21.50:2323
- Tablet dashboard url_path: kitchen-tablet (storage-mode, kiosk_mode enabled)
