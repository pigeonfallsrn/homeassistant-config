# HAC Handoff — 2026-03-27 20:49

## Last 3 commits
  110cf6f hac: session 2026-03-27
  fdd4aad fix: john_proximity - GPS accuracy gate to prevent teleport false fires
  423ef9e recorder: add purge_keep_days:7, commit_interval:30, exclude noisy entities (update domain, battery/LQI/RSSI/signal sensors, number config, sun)

## Active tasks
  TASK: notify migration (20 UI automations + 3 scripts → s26_ultra)
  NEXT: run hac ids + grep for sm_s928u across all packages
  BLOCKED: None

## Top backlog items
  - [x] Music popup: RESOLVED — more-info on media_player.kitchen_2. Confirmed 2026-03-17.
  - [ ] Calendar: verify fills full right column with dense_section_placement:false — check on tablet after next reload.
  - [ ] Doorbell popup: automation on event.front_driveway_door_doorbell triggers browser_mod.popup on tablet showing camera feed. Guard with input_boolean.kitchen_tablet_doorbell_popup_active. Needs browser_mod installed first.

## Start next session
  cat /homeassistant/hac/HANDOFF.md   ← read this first
  hac status                           ← who is home, last triggers
  hac health                           ← check for errors
