# HAC Handoff — 2026-04-07 S6 Close

## Last 4 commits
  6463635 chore: yamaha_ynca auto-update via HACS
  e3ad05d chore: S6 audit — remove 7 dead automations + fix CRITICAL_RULES refs
  e3281a3 chore: gitignore runtime noise files (ha_run.lock, ip_bans.yaml)
  581d3fa chore: add fix_pkg_unique_id.py to git — permanent unique_id repair tool

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.1 — current
  27 packages / ~132 active automations / git clean / pushed
  Repairs: 0 ✅
  Tier 2: automation.kitchen_tier_2_dimmers_on/off — ON ✅ (fired during boot)
  Entity rename: light.kitchen_under_cabinet_lights_inovelli ✅ confirmed live
  Backup: Pre_S5_2026-04-07 (0a4a97ce) — S6 backup skipped (manager busy at session start)

## S6 completed work
  [✅] Start sequence: Tier 2 verified ON, entity rename confirmed, Repairs=0
  [✅] Full automation audit: 161 total (131 on, 9 off, 21 unavailable)
  [✅] CRITICAL_RULES: AL instances updated (kids_rooms removed, entry_room_lamp_adaptive
       + master_bedroom_wall_lamp added) — commit e3ad05d
  [✅] CRITICAL_RULES: Inovelli vzm31_sn_4 rename reflected — same commit
  [✅] unique_id injection check: CLEAN
  [✅] Yamaha YNCA HACS auto-update committed — commit 6463635
  [✅] Ghost automation investigation: 9 "off" automations confirmed not in packages/
       or automations.yaml — pre-deleted from source, stale registry entries only

## Automation audit findings (S6 — authoritative)
  161 in registry: 131 ON ✅ | 9 OFF (ghosts) | 21 UNAVAILABLE (ghosts)
  All 9 "off": confirmed absent from packages/ and automations.yaml
    → pre-deleted from source, registry preserves last known state, no action needed
  All 21 "unavailable": RESOURCE_NOT_FOUND, Repairs=0 → no load failures, ghosts only
  Kitchen ceiling motion conflict: NOT present — ghost only, no conflict with Tier 2 ✅

## NEW LEARNING (S6) — added to CRITICAL_RULES
  automations.yaml uses `- id:` at column 0 (no indent), NOT `  - id:` like packages/
  Future grep: use both `^- id:` (automations.yaml) and `^  - id:` (packages/)
  "off" ghost entries = automation disabled then source-deleted; registry preserves
    last state. Not harmful, clears on next restart cycle.

## AL instances — current (confirmed S6)
  living_spaces ✅ | entry_room_ceiling ✅ | entry_room_lamp_adaptive ✅
  kitchen_table ✅ | master_bedroom_wall_lamp ✅ | upstairs_hallway ✅

## Known backlog (carry forward)
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Driveway approach lights: rebuild with Inovelli local override
  - Living room motion: rebuild with Apollo R-PRO mmWave
    LD2450 Zone-1: X1:-4000, X2:4000, Y1:500, Y2:6000
  - Security: SSH password auth enabled, Cloudflare Zero Trust not configured
  - Mini PC migration runbook: deferred, ready when wanted
  - TR nightlight naming: 12 sensors affected
  - VZM36 living room: 2 instances (_3 + _4) — investigate why duplicates
  - Rohan unified blueprint: evaluate + install for Inovelli switch events
  - Ghost "off" registry entries (9): will self-clear on next restart — no urgency

## Start next session
  1. ha_call_service(shell_command, mcp_session_init, return_response=True)
  2. ha_call_service(shell_command, read_critical_rules, return_response=True)
  3. ha_call_service(shell_command, read_handoff, return_response=True)
  4. ha_backup_create("Pre_S7_YYYY-MM-DD")
  5. Verify Repairs = 0
