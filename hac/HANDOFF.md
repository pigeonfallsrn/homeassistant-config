# HAC Handoff — 2026-04-07 S5 Close

## Last 4 commits
  7c226d2 docs: pre-build audit rule + wrap ritual — hardwire knowledge capture 2026-04-07
  9c1e060 feat: Kitchen Tier 2 motion lighting — Inovelli ceiling cans + bar pendants (2026-04-07)
  c6602d6 docs: Inovelli ecosystem audit + blueprint + tier architecture rules 2026-04-07
  ea396d0 docs: hac wrap S4 2026-04-07 — Repairs 0, unique_id fix, AL audit

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.1 — current
  27 packages / ~132 automations / git clean / pushed
  Repairs: verify after restart (Tier 2 YAML + entity rename need restart to register)
  Backup: 0a4a97ce (Pre_S5_2026-04-07)

## ⚠️ REQUIRES RESTART BEFORE NEXT SESSION
  Two changes need ha core restart to take effect:
  1. lighting_motion_firstfloor.yaml — 2 new Tier 2 automations added
     (kitchen_tier2_motion_on, kitchen_tier2_motion_off)
  2. light.inovelli_vzm31_sn_4 renamed → light.kitchen_under_cabinet_lights_inovelli
     (CRITICAL_RULES still references old name — YAML search needed post-restart)

## S5 completed work
  [✅] AL: Master Bedroom Wall Lamp instance created (Hue, sleep 1%/2200K/22:00-06:00)
  [✅] AL: Upstairs Hallway instance created (Hue group, no sleep mode)
  [✅] AL: Kitchen Table cleaned up — removed 4 Tier 2/non-Hue lights, kept 5 correct
       Kept: chandelier, above sink, lounge, lounge lamp, Aqara T1 under-cabinet strip
       Removed: ceiling cans Inovelli, bar pendants Inovelli, unknown (renamed), Govee
       Fixed toggles: separate_turn_on_commands ON, detect_non_ha_changes OFF
  [✅] Entity rename: light.inovelli_vzm31_sn_4 → light.kitchen_under_cabinet_lights_inovelli
  [✅] Task 2: Kitchen Tier 2 motion lighting added to lighting_motion_firstfloor.yaml
       ceiling cans + bar pendants: 80% day (lux 50-200), 40% night (lux ≤50), 12min off
  [✅] Inovelli full ecosystem audit + blueprint recommendation committed to CRITICAL_RULES
  [✅] Pre-build automation audit rule added to CRITICAL_RULES (mandatory going forward)
  [✅] AL instances updated: 6 total (living_spaces, entry_room_ceiling, entry_room_lamp_adaptive,
       kitchen_table, master_bedroom_wall_lamp, upstairs_hallway)

## AL instances — current state (2026-04-07)
  living_spaces ✅ | entry_room_ceiling ✅ | entry_room_lamp_adaptive ✅ (motion-controlled)
  kitchen_table ✅ (cleaned up — 5 lights, correct toggles)
  master_bedroom_wall_lamp ✅ NEW (light.master_bedroom_wall_light, sleep 1%/2200K)
  upstairs_hallway ✅ NEW (light.upstairs_hallway, no sleep mode)

## CRITICAL_RULES — outdated entries to fix next session
  - AL section still lists: living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway
    CORRECT IS: living_spaces, entry_room_ceiling, entry_room_lamp_adaptive, kitchen_table,
                master_bedroom_wall_lamp, upstairs_hallway
  - Inovelli inventory still references light.inovelli_vzm31_sn_4 (now renamed)

## Kitchen automation landscape — known (2026-04-07)
  From UI audit — confirmed existing, no conflicts with Tier 2:
  - Kitchen Chandelier Time-Based Control (time-based, separate from motion)
  - Kitchen Above Sink / Chandelier / Lounge — Inovelli Controls Hue (button events, not motion)
  - Kitchen Lounge - Aux Switch Controls Hue + Fan (aux switch events)
  - Kitchen Lounge - Reset Light Override (30 min)
  - Several DISABLED lounge lamp automations (superseded by Tier 1)
  - Kitchen Manual Override — Auto-Clear on No Motion (package YAML, working)
  - Kitchen Manual Override — Inovelli 2x Tap Set (package YAML, working)
  Tier 2 targets (ceiling cans + bar pendants) had NO prior motion automations — clean build

## ⚠️ WORKFLOW RULE — HARDWIRED FROM S5
  Before ANY new automation build, run full pre-build audit:
    grep -rn 'entity_id' /homeassistant/packages/ | grep 'light.TARGET'
    ha_deep_search("TARGET_AREA", exact_match=False, limit=10)
    Check HA UI automation list filtered by keyword
  138 automations exist. MCP only sees UI-registered ones.
  Package YAML automations invisible to MCP without cat/grep.

## Known backlog (carry forward)
  - Restart needed: load Tier 2 + verify Repairs = 0
  - CRITICAL_RULES: update AL instances list + Inovelli rename
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Driveway approach lights: rebuild with Inovelli local override
  - Living room motion: rebuild with Apollo R-PRO mmWave
    LD2450 Zone-1: X1:-4000, X2:4000, Y1:500, Y2:6000
  - Security: SSH password auth enabled, Cloudflare Zero Trust not configured
  - Mini PC migration runbook: deferred, ready when wanted
  - TR nightlight naming: 12 sensors affected
  - Kitchen automation full audit: 138 total, some DISABLED — full review pending
  - VZM36 living room: 2 instances (_3 + _4) — investigate why duplicates
  - Rohan unified blueprint: evaluate + install for Inovelli switch events

## Start next session
  1. ha_call_service(shell_command, mcp_session_init, return_response=True)
  2. ha_call_service(shell_command, read_critical_rules, return_response=True)
  3. ha_call_service(shell_command, read_handoff, return_response=True)
  4. ha core restart (load Tier 2 + entity rename)
  5. Verify Repairs = 0
  6. Test Tier 2: walk into kitchen, verify ceiling cans + pendants fire with motion
