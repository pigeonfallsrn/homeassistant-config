# HAC Handoff — 2026-03-30

## Last 3 commits (run: GIT_PAGER=cat git -C /homeassistant log --oneline -5)

## What was done this session
- Recorder purge+repack fired (DB was 612MB)
- motion_aggregation.yaml FIXED: kitchen_motion = P1-only (ceiling), kitchen_lounge_motion = west TR only — were identical for months
- CRITICAL_RULES.md: promoted 3 patterns (ghost entity stop/edit/start, ip_bans self-ban, REST DELETE curl format)
- knowledge.yaml: notification_target_migration marked COMPLETE, bubble_card dead_end marked resolved
- ip_bans.yaml: removed 192.168.1.3 and ::1 self-bans, HA restarted
- automation.safety_midnight_all_main_lights_off: ghost entity surgery performed — removed from core.entity_registry, will be fully gone after HA finishes booting
- Room audit Alaina + Ella: COMPLETE — no motion sensors in either area, no motion automation gap, existing schedule/presence coverage is sufficient
- Keep REST token "HAC REST 2026-03-30" for future REST DELETE work

## Active tasks
  TASK: Basement room audit (only remaining room before Master Bedroom)
  NEXT: read basement packages, check sensors, build motion automation if gap found
  BLOCKED: Master Bedroom — needs motion sensor hardware + Govee floor lamp commissioning

## Top backlog items (priority order)
  - [ ] Basement room audit — binary_sensor.basement_hallway_motion_sensor_occupancy confirmed working
  - [ ] Doorbell popup — requires browser_mod install first, then automation on event.front_driveway_door_doorbell → browser_mod.popup on tablet showing camera feed, guard with input_boolean.kitchen_tablet_doorbell_popup_active
  - [ ] Advanced Camera Card (HACS id:394082552) — replace 4 picture-entity camera cards on kitchen-wall-v2
  - [ ] Weather popup — tap clock-weather-card → Bubble Card popup with 7-day forecast + Weather Radar Card (HACS id:487680971)
  - [ ] Apollo R-PRO-1 entry room zone calibration — LD2450 zones, 12 number.set_value calls
  - [ ] Inovelli blueprint consolidation — 9 near-identical automations → 1 blueprint
  - [ ] mass_queue install → replace now-playing card with mass-player-card
  - [ ] Verify DB size reduced after purge+repack (was 612MB)

## Known system state
  - automation.midnight_all_lights_off (id:1774577899551) = ACTIVE, fires nightly ✅
  - automation.safety_midnight_all_main_lights_off = DELETED from entity registry
  - binary_sensor.kitchen_motion = P1 ceiling only (fixed this session)
  - binary_sensor.kitchen_lounge_motion = west TR only (fixed this session)
  - ip_bans: 31 external scanner entries remain (normal), self-bans cleared
  - REST token "HAC REST 2026-03-30" is valid — keep it

## Session startup sequence
  cat /homeassistant/hac/HANDOFF.md
  hac status
  ha core check
  du -sh /config/home-assistant_v2.db
  GIT_PAGER=cat git -C /homeassistant log --oneline -5
