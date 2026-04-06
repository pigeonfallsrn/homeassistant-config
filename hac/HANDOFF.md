# HAC Handoff — 2026-04-05 11:26

## Last 3 commits
  31d3279 hac: session 2026-04-05
  8a1824f docs: add hac CLI PATH fix to CRITICAL_RULES
  dffaba3 hac: session 2026-04-05

## Active tasks
  TASK: NEXT SESSION: Aqara sensor relocation — move garage_north_door + garage_south_door sensors to useful locations. Then room audit: Alaina, Ella, Basement, Master Bedroom. Backlog: read top of notifications_system.yaml (battery + bedtime automations unaudited), investigate 6 notify calls in adaptive_lighting_entry_lamp.yaml, review departure double-notification on North door (auto-close + departure alert both fire on same departure event)
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
