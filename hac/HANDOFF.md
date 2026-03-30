# HAC Handoff — 2026-03-30

## Last 3 commits
  6b2dfcc session: ghost entity surgery midnight auto, ip_bans self-ban cleared, write HANDOFF
  413c636 fix: split kitchen/lounge motion sensors, promote CRITICAL_RULES, fix knowledge.yaml
  c788840 session: re-enable living room motion lighting, remove activity_boost_2 YAML block, disable duplicate midnight auto + stale lamp autos

## What was done this session
  - Recorder purge+repack fired (DB was 612MB → 506MB ✅)
  - motion_aggregation.yaml FIXED: kitchen_motion = P1-only, kitchen_lounge_motion = west TR only (were identical for months)
  - CRITICAL_RULES.md: promoted 3 patterns (ghost entity stop/edit/start, ip_bans self-ban, REST DELETE curl)
  - knowledge.yaml: notify migration marked COMPLETE, bubble_card dead_end marked resolved
  - ip_bans.yaml: 192.168.1.3 + ::1 self-bans removed, HA restarted to flush
  - automation.safety_midnight_all_main_lights_off: COSMETIC GHOST — disabled, cannot fire, entity registry surgery attempted but HA restores from .bak on boot. Accept as cosmetic. REST token "HAC REST 2026-03-30" confirmed valid (HTTP 400 = token good, automation has no storage entry)
  - Room audit Alaina + Ella: COMPLETE — no motion sensors in either area, schedule/presence coverage is sufficient

## KNOWN COSMETIC ISSUE
  automation.safety_midnight_all_main_lights_off — state:off, cannot fire, no config backing
  Do NOT spend more time on this. It is harmless.

## Active tasks
  TASK: Basement room audit (final room before Master Bedroom)
  NEXT: read basement packages, inventory sensors, check for motion automation gaps
  BLOCKED: Master Bedroom — needs motion sensor hardware + Govee floor lamp commissioning

## Top backlog (priority order)
  - [ ] Basement room audit
  - [ ] Doorbell popup — install browser_mod first, then event.front_driveway_door_doorbell → browser_mod.popup on tablet, guard with input_boolean.kitchen_tablet_doorbell_popup_active
  - [ ] Advanced Camera Card (HACS id:394082552) — replace 4 picture-entity cards on kitchen-wall-v2
  - [ ] Weather popup — tap clock-weather-card → Bubble Card popup + Weather Radar Card (HACS id:487680971)
  - [ ] Apollo R-PRO-1 entry room zone calibration — LD2450 zones, 12 number.set_value calls
  - [ ] Inovelli blueprint consolidation — 9 near-identical UI automations → 1 blueprint
  - [ ] mass_queue install → replace now-playing card with mass-player-card
  - [ ] Verify DB continues to decrease (was 612MB → 506MB after purge)

## Known system state
  - automation.midnight_all_lights_off (id:1774577899551) = ACTIVE ✅
  - binary_sensor.kitchen_motion = P1 ceiling only ✅
  - binary_sensor.kitchen_lounge_motion = west TR only ✅
  - DB: 506MB (down from 612MB) — purge+repack worked
  - ip_bans: 31 external scanner entries (normal), self-bans cleared
  - REST token "HAC REST 2026-03-30" is valid — keep it

## Session startup sequence
  cat /homeassistant/hac/HANDOFF.md
  hac status
  ha core check
  du -sh /config/home-assistant_v2.db
  GIT_PAGER=cat git -C /homeassistant log --oneline -5
