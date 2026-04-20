# HANDOFF — Session S46

## Last Session: S46 (2026-04-20)
## Last Commit: (see git log)
## Baseline: 76 automations, 88 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S46

### Quick Wins
- Govee lamp reassigned: light.kitchen_floor_lamp → light.master_bedroom_floor_lamp (area, name, entity_id all updated, zero refs to fix)
- Ella companion app device renamed to "Ella's iPhone" (fixes friendly names in UI; entity_ids still iphone_40_* — cosmetic backlog)

### Garage Review (6 → 4 automations, 13 broken refs → 0)
- Fixed: Auto Close North on Departure — 1 cover ref swapped to ratgdo new name
- Rebuilt: "All Lights ON Fixed" → "Garage — Motion Lights ON" — 7 ratgdo refs fixed, dead aqara trigger removed, entity_id renamed to automation.garage_motion_lights_on
- Fixed: Dimmer Switch — 4 Hue event refs swapped (hue_dimmer_switch_4 → garage_dimmer_switch)
- Created: "Garage — Motion Lights OFF" — consolidated old All Lights OFF + Auto Off After No Motion into single automation using garage_motion_combined + input_number.garage_light_timeout + both-covers-closed condition
- Deleted: All Lights OFF (Fixed) — replaced by consolidated OFF
- Deleted: Auto Off After No Motion — replaced by consolidated OFF
- Deleted: Walk-in Door Opens — dead sensor (binary_sensor.garage_walk_in_door doesn't exist)
- Labeled all 4 surviving automations: garage + lighting (or security for auto-close)

### Observations
- North ratgdo obstruction sensor stuck ON (binary_sensor.garage_north_garage_door_ratgdo32disco_obstruction) — needs physical toggle
- Orphaned helpers from S44 (kitchen_tablet_doorbell_popup, kitchen_tablet_screen_control) already cleaned — confirmed not in registry

---

## LEARNINGS (S46)

### ESPHome reflash rename pattern (NEW — 1st occurrence)
- ESPHome devices reflashed with new device names change ALL entity IDs
- ratgdo: ratgdo32disco_fd8d8c → garage_north_garage_door_ratgdo32disco (9 of 13 broken refs)
- Analogous to Hue Migration Rule but for ESPHome devices
- When reviewing any area with ESPHome devices, proactively check if entity IDs shifted after reflash

### Entity Ref Rule — 4th independent occurrence
- S42 Entry Room, S44 Bathroom+Tablet, S45 Kids (6/11), S46 Garage (13/27)
- Nearly half of all garage entity refs were broken
- Batch ha_get_state verification continues to be the right pattern

### Hue Migration Rule — 2nd independent occurrence
- Garage dimmer switch: hue_dimmer_switch_4_button_N → garage_dimmer_switch_button_N
- Confirmed pattern from S45 kids dimmer switches

### python_transform limitation
- isinstance() not available in ha_config_set_automation python_transform
- For multi-ref fixes, full config replacement is cleaner anyway — go straight to it

### Consolidation pattern for motion lights
- When an area has separate ON/OFF automations with overlapping triggers and targets, consolidate into matched ON/OFF pair
- Use combined motion sensor + helper timeout for OFF side
- Garage went from 3 overlapping automations → 1 clean OFF automation

---

## TABLED / REMAINING WORK

### Next Priority:
1. North ratgdo obstruction toggle — physical task, next time in garage
2. Living Room review — 6 automations (3 AVR, 1 scene cycling, 1 hot tub lamp, 1 TV-off)
3. Master Bedroom review — 1 automation (tap dial) + new floor lamp

### Ella Companion App (cosmetic backlog):
- 20 entity_ids still iphone_40_* — device renamed but entity_ids unchanged
- 1 automation ref (Girls → Bedtime Winddown Lighting)
- Low priority unless it causes confusion

### Kitchen Tablet Enhancements (tabled):
- Calendar Card Pro (HACS) for per-calendar colors/emojis
- Master Calendar parsing (grade-specific events)
- Doorbell camera view + fully_kiosk.load_url
- Away/home screen control (blocked by house_occupied)
- FKB screensaver (family photos / ambient clock)
- Battery management automation (20-80% charge cycle)

### Blocked / Dependency Items:
- binary_sensor.house_occupied — unavailable (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative — unavailable
- Music Assistant — setup_error state
- Michelle person tracker (MAC: 6a:9a:25:dd:82:f1)

### Ongoing:
- Security hardening session (~30 min: SSH password auth, Cloudflare Zero Trust, plaintext PAT, recorder PII)
- AndroidTV at 192.168.1.17 — real ADB device, do not delete
- NordPass cleanup backlog
- Discovered integrations: 2nd Floor Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast
- Governance review due at S50

---

## BENCHMARK

| Metric | S44 | S45 | S46 |
|--------|-----|-----|-----|
| Automations | 80 | 78 | 76 |
| Helpers | 90 | 88 | 88 |
| Ghosts | 0 | 0 | 0 |
| YAML auto files | 0 | 0 | 0 |
| Template packages | 14 | 14 | 14 |
| HACS cards | 1 | 1 | 1 |
| Calendars | 19 | 19 | 19 |
| Tablet dashboards | 1 | 1 | 1 |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Kitchen tablet device_id: `86870b5d8b01f345f5d5dd9c2ac06d2b`
- Kitchen tablet FKB startURL: `http://192.168.1.10:8123/kitchen-tablet/home`
- Kitchen tablet FKB Remote Admin: `http://192.168.21.50:2323`
- Kitchen tablet HA user: `tablet` (non-admin, local-only)
- Tablet dashboard url_path: `kitchen-tablet` (storage-mode, kiosk_mode enabled)
