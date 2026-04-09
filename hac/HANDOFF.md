# HAC Handoff — 2026-04-08 S7 Close

## Last commits
  f62ba8d fix: kitchen zone — revert to 3 P1s only, keep delay_off 10min
  ad4f619 fix: kitchen zone — add Apollo R-PRO-1 mmWave + delay_off 10min (then reverted)
  f6aef08 docs: S6 wrap — Inovelli audit, 8 automations upgraded, entity fixes

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.2 — current
  28 packages / ~145 automations / git clean / pushed
  Repairs: 0 ✅
  Backup: Pre_S6_2026-04-08 (4aea8bfa) — still valid same-day

## S7 completed work
  [✅] Kitchen zone root cause identified: P1 = PIR only, cannot detect Ella sitting still
  [✅] first_floor_main_motion: added delay_off 10min (was 0, relying only on 30s+60s stack)
       Zone now holds for 10min after last micro-movement — puzzle sessions survive
  [✅] Apollo R-PRO-1 LD2450 zones configured: X1=-4000, X2=4000, Y1=500, Y2=6000, timeout=60s
       Ready for future use (entry room — NOT in kitchen zone per John's direction)
  [✅] Confirmed: first_floor_main_motion = 3 P1s (kitchen + west kitchen/lounge + entry)
       Entry P1 catches walking kitchen↔living room, resets zone timer

## S7 key learnings
  - P1 is PIR-only: stationary occupancy REQUIRES mmWave OR long delay_off
  - delay_off on the TEMPLATE SENSOR is separate from the automation timeout
    Template: 0s before (cleared instantly when all PIRs cleared) → now 10min
    Automation: still waits 12min after zone clears before lights off
    Total hold: last movement + 10min (zone) + 12min (auto) = 22min max
  - Apollo LD2450 zone collapse: confirmed 0,0,0,0 = Detection mode sees nothing
    Fix: X1=-4000, X2=4000, Y1=500, Y2=6000 (CRITICAL_RULES confirmed)
    This is now permanently resolved for entry room
  - For kitchen table occupancy long-term: add dedicated mmWave (Apollo or LD2412 wall mount)

## ⚠️ KITCHEN MOTION GAP STILL EXISTS (next priority)
  The Tier 1 Hue lights (kitchen chandelier + above-sink) have switch automations (S6)
  BUT does motion turn them ON? Check:
    grep -n 'chandelier\|above.sink\|kitchen.*hue.*motion\|kitchen.*hue.*on' \
      /homeassistant/packages/lighting_motion_firstfloor.yaml
  Likely gap: kitchen_lounge_motion_on covers lounge only
  kitchen chandelier + above-sink may have NO motion-on automation → only switch control
  Fix next session: add kitchen_hue_motion_on/off to lighting_motion_firstfloor.yaml

## NEXT SESSION PRIORITY QUEUE (in order)

  1. KITCHEN HUE MOTION GAP (Phase 1 — audit + fix)
     Verify Tier 1 kitchen lights turn on with motion
     Add motion-on for chandelier + above-sink if missing

  2. KITCHEN LATE NIGHT MODE (Phase 2)
     After 22:00: Tier 2 should be OFF (not 15%), Tier 1 = scene.kitchen_nightlight
     Modify kitchen_tier2_motion_on default branch
     Add kitchen_hue_nightlight_motion_on automation (22:00-06:00 → nightlight scene)

  3. KITCHEN OVERRIDE TIMER UPGRADE (Phase 3)
     Create: timer.kitchen_override_timer, duration 30min
     Double-tap UP → starts timer + sets booleans
     Timer finish OR double-tap DOWN → clears booleans
     Override suppresses Tier 2 shutoff at night

  4. CRITICAL_RULES SPLIT — token efficiency
     Split into CORE (~50KB, rules only) + HISTORY (~200KB, dated entries)
     Update shell_command.read_critical_rules → CORE only
     Add shell_command.read_critical_rules_full → full file
     Saves ~80% context at every session start

  5. UPSTAIRS HALLWAY motion automation: replace explicit brightness/color_temp with scenes
     File: /homeassistant/packages/upstairs_lighting.yaml lines 45-80
     Fix: scene.upstairs_hallway_energize / relax / nightlight

  6. CRITICAL_RULES corrections
     OLD: "Use Rohan unified blueprint for ZHA Inovelli"
     NEW: "Use fxlt blueprint (HA community t/479148) for ZHA"
     ADD: VZM31-SN firmware v3.06 available (adds P27 Dimming Algorithm)
     ADD: Apollo LD2450 zone collapse = all zeros in Detection mode, fix = X1:-4000..Y2:6000

  7. FOH switch automations (3 switches, see S5 HANDOFF)

  8. VZM36 living room _3 + _4 duplicates: investigate

  9. Mini PC migration — deferred indefinitely per John

## Apollo R-PRO-1 STATE (confirmed S7)
  Zone-1: X1=-4000, X2=4000, Y1=500, Y2=6000 ✅
  Timeout: 60s ✅
  Zone Type: Detection ✅
  Location: Entry room wall, above Aqara P1
  NOT in kitchen zone — entry room only (correct per John)
  For kitchen table occupancy: future mmWave sensor in kitchen proper

## Start next session
  1. ha_call_service(shell_command, mcp_session_init)
  2. ha_call_service(shell_command, read_critical_rules)  ← after split, reads CORE only
  3. ha_call_service(shell_command, read_handoff)
  4. ha_backup_create("Pre_S8_YYYY-MM-DD")
  5. Verify Repairs = 0
  6. FIRST: grep check for kitchen Tier 1 motion gap
     grep -n "chandelier\|above.sink\|Tier 1" /homeassistant/packages/lighting_motion_firstfloor.yaml
