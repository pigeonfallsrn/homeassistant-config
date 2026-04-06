# HAC Handoff — 2026-04-06 Triage S1 Close

## Last 3 commits
  00c8354 triage: lighting first floor — 2 MCP deleted, 2 lamp chain files deleted (686 lines)
  56f872f triage: garage — 6 deleted (MCP), 6 blocks removed (YAML), 7 kept
  8a5410f docs: hac wrap session 2026-04-06

## Active tasks
  TASK: Triage Session 2 — continue full automation audit
  NEXT: adaptive_lighting_entry_lamp.yaml surgery — 14 automations all failing, source of ~14 repairs
  BLOCKED: None

## Triage status
  [✅] 1. Garage: 24 → 7 automations (71% reduction)
  [✅] 2. Presence/Arrival: all ghosts, self-cleared on restart
  [✅] 3. Notifications: YAML working, ghosts self-clear
  [🔄] 4. Lighting 1st floor: adaptive_lighting_entry_lamp.yaml remaining (14 autos, all broken)
  [ ]  5. Lighting upstairs + kids rooms
  [ ]  6. Occupancy/context system (9 automations + tablet deferred)
  [ ]  7. Safety/lights-off (3 automations)
  [ ]  8. Bedtime/scheduling (kids_bedroom_automation.yaml — ella/alaina school night blocks)
  [ ]  9. Google Sheets sync (3 automations — still used?)
  [ ]  10. HAC/utility

## S2 first task — adaptive_lighting_entry_lamp.yaml
  Read before touching:
    sed -n '1,90p' /homeassistant/packages/adaptive_lighting_entry_lamp.yaml

  14 automations, all failing to set up. Contains TWO systems mixed:
    SYSTEM 1 — Hot Tub Mode (lines 125-189, 531-580): KEEP candidates
      hot_tub_mode_auto_reset (3am reset)
      hot_tub_mode_auto_off_when_done (back inside)
      hot_tub_mode_living_room_lamp (lamp off)
      hot_tub_mode_notification (reminder)
      hot_tub_mode_notification_actions (button handler)
    SYSTEM 2 — Entry Lamp Chain (lines 256-499): DELETE candidates
      entry_room_lamp_adaptive_control
      entry_room_lamp_activity_boost
      entry_room_lamp_no_motion_dim
      entry_room_lamp_no_motion_off
      entry_room_lamp_hard_off
    SYSTEM 3 — Extended Evening (lines 87-124): INVESTIGATE
      extended_evening_auto_set (weekends/holidays)
      extended_evening_auto_clear (clears at 4am)
    OTHERS:
      arrival_adaptive_lighting_on (line 205) — likely DELETE, AL runs continuously
      adaptive_lighting_global_off (line 507) — KEEP candidate, nobody home lights off

## Backlog items surfaced this session
  - Driveway approach lights: dead, rebuild with Inovelli local override first
  - Walk-in door quick-open notification: dead, rebuild optional (G2 handles lights)
  - Ella/Alaina arrival notifications: never existed properly, rebuild needed
  - Living room motion: DELETED — rebuild with Apollo R-PRO mmWave sensor
  - kitchen_manual_override_auto_clear_on_no_motion: unavailable, SET half active — bug

## Persistent backlog
  - [ ] Calendar: verify full right column with dense_section_placement:false — check on tablet
  - [ ] Doorbell popup: browser_mod needed first
  - [ ] Mini PC migration runbook: dedicated session after triage completes

## System state after S1
  HA 2026.4.1 / HAOS 17.1 — current
  29 packages (was 31, deleted adaptive_lighting_kitchen_lounge_lamp + adaptive_lighting_living_room)
  ~140 automations (was 163)
  Repairs: ~14 remaining after restart (all from adaptive_lighting_entry_lamp.yaml)
  Backup: 852dc561 (Pre_Triage_Session_2026-04-06)
  Git: pushed to origin/main, clean

## Start S2
  1. ha_call_service(shell_command, mcp_session_init, return_response=True)
  2. ha_call_service(shell_command, read_critical_rules, return_response=True)
  3. ha_call_service(shell_command, read_handoff, return_response=True)
  4. Check Repairs count — should be ~14, not 89
  5. ha_backup_create("Pre_Triage_S2_YYYY-MM-DD")
  6. sed -n '1,90p' /homeassistant/packages/adaptive_lighting_entry_lamp.yaml
