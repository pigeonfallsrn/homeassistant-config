# HAC Handoff — 2026-03-30 12:37

## Last 3 commits
  e9f22ef hac: session 2026-03-30
  a8d7d54 hac: session learnings 2026-03-30 tooling build
  620089f hac: fix health untriggered section, add health_automations.py helper

## Active tasks
  TASK: NEXT SESSION: notification audit — inventory all active notifications, which automation fires each, what buttons do, which open overview (fix clickAction), which are ghost/dead. Also: relocate garage_north_door + garage_south_door Aqara sensors to useful locations. Resume room audit: Alaina, Ella, Basement, Master Bedroom after notification audit.
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
