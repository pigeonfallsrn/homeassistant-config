# HAC Handoff — 2026-04-06 Triage S2 Close

## Last 3 commits
  f15bb36 fix: strip input_boolean sub-fields (entry_lamp), remove empty humidity stub
  00c8354 triage: lighting first floor — 2 MCP deleted, 2 lamp chain files deleted (686 lines)
  56f872f triage: garage — 6 deleted (MCP), 6 blocks removed (YAML), 7 kept

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.1 — current
  29 packages / ~140 automations / git clean / pushed
  Repairs: ~0 expected (all fixes applied, restart completed)
  Backup: 852dc561 (Pre_Triage_Session_2026-04-06)

## Triage status
  [✅] 1. Garage: 24 → 7 automations (71% reduction)
  [✅] 2. Presence/Arrival: working — arrival_john, arrival_ella, arrival_notification_actions all confirmed YAML-loaded
  [✅] 3. Notifications: working — battery digest, bedtime prompt, humidity all confirmed
  [✅] 4. Lighting 1st floor: adaptive_lighting_entry_lamp.yaml fixed (input_boolean sub-fields stripped)
             All 14 automations restored. Lamp chain + hot tub + extended evening + arrival AL all live.
  [ ]  5. Lighting upstairs + kids rooms (upstairs_hallway v2 confirmed working, bathroom night disabled)
  [ ]  6. Occupancy/context system (update_mode, apply_context_* confirmed working — deep audit remaining)
  [ ]  7. Safety/lights-off (3 safety automations confirmed working from config dump — verify + keep)
  [ ]  8. Bedtime/scheduling (ella/alaina school night confirmed in YAML + working gentle_wake + hard_off)
  [ ]  9. Google Sheets sync (3 automations confirmed working from config dump — verify shell_command exists)
  [ ]  10. HAC/utility (HAC export auto at 3am confirmed in config dump)

## Key insight from S2 config dump
  The system is MUCH more functional than MCP "unavailable" count suggested.
  Most unavailables were ghost registry entries, not broken automations.
  Remaining triage categories are mostly VERIFY+KEEP, not DELETE sessions.
  Estimate: 20-30 more deletions max across remaining 6 categories.

## S3 first tasks (in order)
  1. ha_backup_create("Pre_Triage_S3_YYYY-MM-DD")
  2. Verify Repairs = 0 in HA UI
  3. Safety category — confirm 3 automations, likely all KEEP:
       grep -n '^\s*- id:' /homeassistant/packages/lights_auto_off_safety.yaml
  4. Google Sheets — verify shell_command.export_to_google_sheets exists:
       grep -n 'export_to_google_sheets' /homeassistant/configuration.yaml
  5. HAC/utility — check hac_export shell command, session_log automation
  6. Occupancy deep-dive — family_activities.yaml has complex system (calendar refresh,
     school_tomorrow, school_in_session_now, family context tracking). Likely all KEEP.
  7. Kids bedroom — ella/alaina automations confirmed working. Audit kids_bedroom_automation.yaml
     for any remaining dead blocks.

## Backlog (carry forward)
  - Hot tub mode entity ID mismatch: turn_off/turn_on refs `entry_room_lamp_dim_after_15min_no_motion`
    but entity alias says "5min" → `automation.entry_room_lamp_dim_after_5min_no_motion`
    Silent fail when hot tub mode activates. Fix: update entity_id refs in entry_lamp YAML.
  - Driveway approach lights: dead, rebuild with Inovelli local override consideration
  - Ella/Alaina arrival notifications to John's phone: working (arrival_ella confirmed)
    Alaina arrival: check if arrival_notification_alaina exists (not seen in dump)
  - Living room motion: DELETED — rebuild with Apollo R-PRO mmWave sensor
  - kids_rooms + upstairs_hallway AL instances: missing from 16-switch count (only 4 showing)
    Investigate: were these AL instances deleted? Should be 5 per CRITICAL_RULES.
  - 2nd_floor_bathroom_night_lighting: DISABLED_20260126 — confirm intentional, candidate for deletion
  - Security: SSH password auth still enabled, Cloudflare Zero Trust not configured (from S1 audit)

## Start S3
  1. ha_call_service(shell_command, mcp_session_init, return_response=True)
  2. ha_call_service(shell_command, read_critical_rules, return_response=True)
  3. ha_call_service(shell_command, read_handoff, return_response=True)
  4. Verify Repairs count (should be 0)
  5. ha_backup_create("Pre_Triage_S3_YYYY-MM-DD")
  6. grep -n '^\s*- id:' /homeassistant/packages/lights_auto_off_safety.yaml
