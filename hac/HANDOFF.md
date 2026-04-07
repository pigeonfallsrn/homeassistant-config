# HAC Handoff — 2026-04-07 S4 Close

## Last 4 commits
  52ea200 docs: add unique_id: auto_ injection rule (HA 2026.4.x schema violation)
  f374b8f fix: strip unique_id: auto_ from 17 package files (76 lines removed)
  062a5dc docs: hac wrap triage S3 2026-04-06 — all 10 categories complete, handoff + rules
  a0b34bb triage: occupancy bathroom stub deleted, hac_session_log deleted

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.1 — current
  27 packages / ~130 automations / git clean / pushed
  Repairs: 0 (cleared this session)
  Backup: 8a5c0101 (Pre_S4_2026-04-06)
  Disk: 20.6 GB / 28 GB (73%)

## S4 completed work
  [✅] Kitchen lounge motion confirmed live — fired at 11:07 PM CDT, lux 1 lux
  [✅] Repairs 73 → 0 — stale load ghosts cleared by restart
  [✅] AL instance audit — 4 confirmed active (living_spaces, entry_room_ceiling,
       entry_room_lamp_adaptive, kitchen_table)
  [✅] unique_id: auto_ schema fix — 76 lines stripped from 17 package files,
       committed f374b8f, pushed. Root cause: ha_config_set_automation injects
       unique_id into package YAML; HA 2026.4.x rejects it. Fix script permanent
       at /homeassistant/hac/fix_pkg_unique_id.py
  [✅] CRITICAL_RULES updated with unique_id injection lesson (52ea200)

## AL instances — confirmed state
  living_spaces ✅ on | entry_room_ceiling ✅ on
  entry_room_lamp_adaptive ✅ off (motion-controlled, correct)
  kitchen_table ✅ on
  kids_rooms ❌ MISSING — needs UI recreation
  upstairs_hallway ❌ MISSING — needs UI recreation
  upstairs hallway ceiling lights (1of3/2of3/3of3) confirmed state=off (NOT unavailable)
    — safe to create upstairs_hallway AL instance now

## AL recreation config (UI only — Settings > Devices & Services > Adaptive Lighting > Add Entry)
  kids_rooms:
    Lights: light.alaina_s_bedroom, light.ella_s_bedroom (Hue groups)
    separate_turn_on_commands: true | take_over_control: true | detect_non_ha_changes: false
    Sleep mode: 1% / 2200K / 22:00–06:00
  upstairs_hallway:
    Lights: light.upstairs_hallway (Hue group)
    separate_turn_on_commands: true | take_over_control: true | detect_non_ha_changes: false
    Sleep mode: not needed

## Known backlog (carry forward)
  - AL recreation: kids_rooms + upstairs_hallway (UI only, config above)
  - Kitchen Tier 2: add light.kitchen_ceiling_can_led_lights_inovelli +
      light.kitchen_bar_pendant_lights_inovelli_vzm31_sn to motion zone
      Pattern: explicit brightness_pct (80% day, 40% night), same lux gate + motion trigger
      File: lighting_motion_firstfloor.yaml
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Driveway approach lights: dead, rebuild with Inovelli local override
  - Living room motion: deleted, rebuild with Apollo R-PRO mmWave
    Apollo R-PRO-1 in entry room — LD2450 Zone-1: X1:-4000, X2:4000, Y1:500, Y2:6000
  - Security: SSH password auth enabled, Cloudflare Zero Trust not configured
  - Mini PC migration runbook: deferred, ready when wanted
  - TR nightlight friendly name mismatches: 12 sensors affected (Option D)
  - WRAP RULE: After any session using ha_config_set_automation on package files,
    run: grep -rEl 'unique_id: auto_' /homeassistant/packages/ before commit

## Start next session
  1. ha_call_service(shell_command, mcp_session_init, return_response=True)
  2. ha_call_service(shell_command, read_critical_rules, return_response=True)
  3. ha_call_service(shell_command, read_handoff, return_response=True)
  4. Verify Repairs = 0
  5. AL recreation in UI (kids_rooms + upstairs_hallway per config above)
  6. Kitchen Tier 2 YAML work in lighting_motion_firstfloor.yaml
