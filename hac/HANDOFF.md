# HAC Handoff — 2026-03-26 11:11

## Last 3 commits
  b48d4d9 fix(kitchen): motion trigger covers both kitchen + lounge sensors
  55be03a docs: add session backups and learnings from entry room audit
  7d2ce0b docs: update learnings, session log, and HANDOFF for entry room audit 2026-03-26

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
