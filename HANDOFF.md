# HANDOFF — Session S48

## Last Session: S48 (2026-04-20)
## Last Commit: pending
## Baseline: 76 automations, 89 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S48

### Front Driveway VZM30-SN Fix (original bug report)
- Diagnosed: switch not controlling lights due to 6 broken entity refs (Hue migration _2 suffix)
- Fixed 4 automations: inovelli_controls_hue_lights, lights_on_when_motion_dark, auto_off_after_no_motion, lights_on_when_motion_dark_2
- Refs fixed: light.front_driveway → light.front_driveway_2, scene.front_driveway_energize → scene.front_driveway_energize_2
- Created input_number.front_driveway_scene_index (0-2, labeled lighting)
- Renamed device: "Front Drivay..." → "Front Driveway Inovelli VZM30-SN (Smart Bulb Mode)"
- Flagged: 2 duplicate motion lighting automations (triple-fire candidate, consolidate later)

### Entry Room Ceiling VZM31-SN Rebuild
- Researched community best practice: SBM + Hue Bridge = HA automation approach (not ZHA binding), ceiling-only control via Hue zone
- Rebuilt automation on VZM31-SN blueprint — targets light.entry_room_ceiling_light (Hue zone, 2 bulbs) only, lamp untouched
- Config press: 3-scene cycle (Energize 100%/6500K → Relax 56%/2200K → Nightlight 10%/2000K)
- Config hold: ultra-dim nightlight shortcut (5%, 2000K)
- 2xUP=Relax, 2xDOWN=Nightlight shortcuts
- Hold UP/DOWN: brightness step ±10%
- Updated input_number.entry_room_scene_index range to 0-2
- Disabled ceiling Adaptive Lighting (lamp AL stays active — community best practice: don't mix AL with scene cycling on same lights)

### Entry Room AUX Switch Fix
- Diagnosed: scene.entry_room_arctic_aurora didn't exist (broken entity ref in night branch)
- Simplified automation to match main paddle: UP=Energize ceiling, DOWN=Off ceiling (instant)
- Added AUX config button (button_6_press) with same 3-scene cycling, shared scene index helper
- Removed 2-second transition on off for instant response

### Speed Optimization (Entry Room Ceiling VZM31-SN)
- on_off_transition_time: 25 → 0 (instant LED bar)
- local_ramp_rate_off_to_on: 127 → 0
- local_ramp_rate_on_to_off: 89 → 0
- All action transitions removed (instant Hue response)

### LED Normalization (3-gang Entry Room)
- Ceiling VZM31-SN: off_intensity 100 → 1 (was the bright outlier)
- All 3 switches now matched: on=33, off=1, color=170 (blue)
- Switches: ceiling VZM31-SN, driveway VZM30-SN, back patio VZM30-SN

---

## TABLED / REMAINING WORK

### Immediate:
1. Front driveway duplicate motion automations — consolidate 2 into 1 (triple-fire risk)
2. Govee lamp → Master Bedroom — reassign light.kitchen_floor_lamp area
3. Ella companion app — 20 entity_ids still iphone_40_* (cosmetic backlog)

### Kitchen Tablet Enhancements (future):
- Calendar Card Pro (HACS) for per-calendar colors/emojis
- Master Calendar parsing (grade-specific events only)
- Doorbell camera view + fully_kiosk.load_url
- Away/home screen control (blocked by house_occupied template fix)
- FKB screensaver (family photos / ambient clock)
- Battery management automation (20-80% charge cycle)

### Blocked:
- binary_sensor.house_occupied — unavailable (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative — unavailable
- Music Assistant — setup_error state
- Michelle person tracker (MAC: 6a:9a:25:dd:82:f1)

### Ongoing:
- Security hardening session (~30 min)
- AndroidTV at 192.168.1.17 — real ADB device, DO NOT DELETE
- NordPass cleanup backlog
- Discovered integrations: Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast
- Ratgdo north obstruction sensor stuck ON — needs physical toggle
- Governance review due S50

---

## BENCHMARK

| Metric | S47 | S48 |
|--------|-----|-----|
| Automations | 76 | 76 |
| Helpers | 88 | 89 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 1 | 1 |
| Calendars | 19 | 19 |
| Tablet dashboards | 1 | 1 |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Kitchen tablet device_id: `86870b5d8b01f345f5d5dd9c2ac06d2b`
- Kitchen tablet FKB Remote Admin: `http://192.168.21.50:2323`
- Tablet dashboard url_path: `kitchen-tablet` (storage-mode, kiosk_mode enabled)
