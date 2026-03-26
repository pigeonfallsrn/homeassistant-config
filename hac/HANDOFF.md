# HAC Handoff — 2026-03-26 09:26

## Last 3 commits
  5b4db4e hac: session 2026-03-26
  3a209b6 feat: add basement hallway ceiling switch to 1st floor hallway motion
  ae0f02a fix: 1st floor bathroom hallway motion uses basement_hallway_motion_sensor_occupancy

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
