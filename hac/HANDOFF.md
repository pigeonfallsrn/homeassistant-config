# HAC Handoff — 2026-03-24 17:50

## Last 3 commits
  1a3e3b2 hac: update automations.yaml hac/hac.sh
  294748c hac: update .HA_VERSION .ha_run.lock automations.yaml custom_components/tuya_local/__init__.py custom_components/tuya_local/config_flow.py custom_components/tuya_local/devices/README.md custom_components/tuya_local/devices/apricus_heat_pump_water_heater.yaml custom_components/tuya_local/devices/arknoah_aquarium_lights.yaml
  f52c0eb hac: add workflow cheatsheet

## Active tasks
  TASK: next: notify migration (20 UI automations + 3 scripts → s26_ultra), Inovelli blueprint consolidation, Bubble Card popup (test kiosk_mode:{} hypothesis)
  NEXT: (define next step)
  BLOCKED: None

## Top backlog items
  - [x] Music popup: RESOLVED — more-info on media_player.kitchen_2. Confirmed 2026-03-17.
  - [ ] Calendar: verify fills full right column with dense_section_placement:false — check on tablet after next reload.
  - [ ] Doorbell popup: automation on event.front_driveway_door_doorbell triggers browser_mod.popup on tablet showing camera feed. Guard with input_boolean.kitchen_tablet_doorbell_popup_active. Needs browser_mod installed first.

## Start next session
  cat /homeassistant/hac/HANDOFF.md   ← read this first
  hac status                           ← who is home, last triggers
  hac health                           ← check for errors
