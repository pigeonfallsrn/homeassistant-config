# HAC Handoff — 2026-03-24 19:29

## Last 3 commits
  c8bc5a5 hac: session 2026-03-24
  6bdb759 hac: promote AVR fix, archive stale files, update ACTIVE.md priorities
  f4bcb0a hac: update hac/hac.sh

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
