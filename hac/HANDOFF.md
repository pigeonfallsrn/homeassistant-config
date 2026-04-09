# HAC Handoff — 2026-04-08 S6 Close

## Last commits
  0d78086 fix: S6 entity renames — fan entity, vzm31_sn_4 → under_cabinet
  2b4cee2 docs: S5 wrap — Hue audit, 24 scenes, 5 switch automations, migration runbook prep

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.2 — current
  28 packages / ~145 active automations / git clean / pushed
  Repairs: 0 ✅ (run verification if uncertain)
  Backup: Pre_S6_2026-04-08 (4aea8bfa)

## S6 completed work — Inovelli ZHA Audit + Local Override Standardization

  [✅] Inovelli full audit: 13 ZHA switch devices confirmed, all healthy
  [✅] fxlt blueprint confirmed at correct path, queued variant in place
  [✅] 2nd Floor Bathroom VZM30-SN — root cause identified: stale entity IDs
       ceiling_1of2 / ceiling_2of2 → light.2nd_floor_bathroom (Hue room group)
       Fixed + upgraded to scene-based: E/R/D/N + brightness hold + queued
  [✅] 1st Floor Bathroom — 4 missing Hue scenes created (E/R/D/N)
       Note: curl ran twice → _2 duplicate scenes in Hue (harmless)
       Automation upgraded to scene-based + queued
  [✅] Kitchen Chandelier — upgraded: scenes + queued (was raw brightness + single)
  [✅] Kitchen Above Sink — upgraded: kitchen scenes + queued
  [✅] Kitchen Lounge — upgraded: kitchen_lounge scenes + queued
  [✅] Entry Room — upgraded: entry_room scenes + queued
  [✅] Back Patio — scene cycle expanded: 4 scenes (added Dimmed), queued
       input_number.back_patio_scene_index max updated: 2→3
  [✅] Front Driveway — upgraded: old "on"/"off" command format → scene cycling + queued
       input_number.front_driveway_scene_index created (0–2)
  [✅] humidity_smart_alerts.yaml — fan.inovelli_vzm35_sn_fan → fan.2nd_floor_bathroom_exhaust_fan (6 refs)
  [✅] kitchen_tablet_dashboard.yaml — light.inovelli_vzm31_sn_4 → light.kitchen_under_cabinet_lights_inovelli (2 refs)
  [✅] Injection check: CLEAN

## CRITICAL RULES CORRECTIONS (update CRITICAL_RULES next session)
  OLD: "Use Rohan unified blueprint for ZHA Inovelli switches"
  NEW: "Use fxlt blueprint (HA community t/479148) for ZHA Inovelli switches"
       Rohan confirmed Sept 2025 he no longer uses ZHA; t/627953 ZHA is community-maintained
       fxlt at blueprints/automation/fxlt/zha-inovelli-vzm31-sn-blue-series-2-1-switch.yaml
  
  PATTERN: fxlt mode:queued, filters device_id, all multi-tap/hold/release events
  AUX switch presses = same zha_event as main paddle — no distinction, no special handling needed
  
  NEW FIRMWARE: VZM31-SN v3.06 available (2026-03-09), adds P27 Dimming Algorithm param
  Current CRITICAL_RULES documents v3.04 as latest — update this

## S6 new learnings for CRITICAL_RULES
  - fxlt blueprint is correct for ZHA (not Rohan, who uses Z2M)
  - Always check device_id in existing fxlt automations — stale device_ids cause silent failures
  - When upgrading to scene-based: target the HUE ROOM GROUP entity (light.ROOM),
    not individual bulb entities or the ZHA switch entity itself
  - VZM30-SN (on/off) fires same zha_event commands as VZM31-SN (dimmer) — fxlt works for both
  - front_driveway automation used OLD zha_event command format ("on"/"off") — updated to button_N_press
  - input_number scene index max must match modulo value (4 scenes = max 3, modulo 4)

## DEVICE INVENTORY (complete, confirmed S6)
  Smart Bulb Mode (Hue via HA automation, fxlt blueprint):
    Entry Room VZM31-SN         device_id: d80c7fa6  → light.entry_room_ceiling_light
    Kitchen Lounge VZM31-SN     device_id: 5e2d477e  → light.kitchen_lounge
    Kitchen Chandelier VZM31-SN device_id: 17a59d3c  → light.kitchen_chandelier (3-way AUX)
    Kitchen Above Sink VZM31-SN device_id: 89ca030d  → light.kitchen_above_sink_light (3-way AUX)
    1st Floor Bathroom VZM31-SN device_id: 0600639e  → light.1st_floor_bathroom
    2nd Floor Bathroom VZM30-SN device_id: 0489781e  → light.2nd_floor_bathroom (OnOff, Smart Bulb)

  Dumb Load (direct dimmer control, no smart bulbs):
    Kitchen Ceiling Cans  VZM31-SN device_id: a3047d38  → light.kitchen_ceiling_inovelli_vzm31_sn
    Kitchen Bar Pendants  VZM31-SN device_id: da86388f  → light.kitchen_bar_pendant_lights
    Kitchen Under Cabinet VZM31-SN device_id: f671e66f  → light.kitchen_under_cabinet_lights_inovelli (3-way AUX confirmed)
    Back Patio VZM31-SN   device_id: 70c1c990  → light.back_patio (scene cycling)
    Front Driveway VZM31-SN device_id: 16a22c25  → light.front_driveway (scene cycling)

  Fan/Special:
    2nd Floor Bathroom Fan VZM35-SN  device_id: 3eed85f7
      → light.inovelli_vzm35_sn_light (ceiling light side, misnamed "2nd Floor Bathroom Fan")
      → fan.2nd_floor_bathroom_exhaust_fan (fan side)
    Kitchen Lounge VZM36 Canopy     → light.kitchen_lounge_light_fan_inovelli_vzm36_light + _2
                                       fan.kitchen_lounge_light_fan_inovelli_vzm36_fan
    Living Room VZM36 (x2)          → light.inovelli_vzm36_light_3 + _4 (investigate duplicates — deferred)

## STANDARD INOVELLI BUTTON MAPPING (now applied everywhere)
  UP press:        scene.[room]_energize
  UP double:       scene.[room]_relax
  DOWN press:      light.turn_off [room group]
  DOWN double:     scene.[room]_nightlight
  Config press:    scene.[room]_dimmed  OR  scene cycle (back patio, front driveway)
  Hold UP:         brightness_step_pct +10
  Hold DOWN:       brightness_step_pct -10
  mode: queued (all switches)

## KNOWN OPEN ITEMS (carry forward)
  - CRITICAL_RULES update: fxlt vs Rohan, v3.06 firmware
  - VZM36 living room _3 + _4 duplicates: investigate if 1 or 2 modules
  - light.inovelli_vzm35_sn_light: misnamed "2nd Floor Bathroom Fan" — rename to clearer name
  - 1st floor bathroom _2 duplicate scenes: harmless but cluttered in Hue app
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Upstairs hallway motion automation: use scenes instead of explicit brightness/color_temp
  - Security backlog: SSH password auth, Cloudflare Zero Trust, Git PAT rotation
  - FOH switch automations: 3 switches (see S5 HANDOFF)
  - Mini PC migration runbook: THURSDAY is prep day, FRIDAY is migration day

## ⚠️ THURSDAY SESSION (2026-04-10) — MIGRATION RUNBOOK PREP (PRIORITY)
  Mini PC arrives Friday 2026-04-11. Thursday = build full runbook before arrival.

  PRE-MIGRATION CHECKLIST TO BUILD:
    □ New backup day-of: Pre_MiniPC_Migration_2026-04-10
    □ ZHA export: Settings > Devices & Services > ZHA > ⋮ > Download backup
    □ Note current HA IP: 192.168.1.3
    □ List integrations needing re-auth post-migration:
        Hue (API key in .storage), Spotify, Google Calendar, Gmail, any OAuth flows
    □ Verify git fully pushed: git log --oneline -3 (confirm origin/main at HEAD)
    □ Screenshot kitchen-wall-v2 dashboard (storage-mode, not in git)
    □ Cloudflare tunnel: ha.myhomehub13.xyz — verify tunnel config before migration
    □ /api/mcp bypass policy — must stay active on new IP
  MIGRATION DAY STEPS:
    □ Install HAOS x86-64 on Mini PC
    □ Restore from backup (config-only, not DB)
    □ Assign 192.168.1.3 to Mini PC in UniFi DHCP reservations (swap MAC)
    □ Re-import ZHA backup on new hardware
    □ Re-auth: Hue, Spotify, Google integrations
    □ Test MCP tunnel: ha.myhomehub13.xyz resolves, /api/mcp works
    □ Test 2 Hue switch automations physically
    □ Test 1 motion automation
  POST-MIGRATION (2 weeks):
    □ Keep HA Green powered on cold standby
    □ Monitor DB growth, automations, presence

## Start next session (THURSDAY)
  1. ha_call_service(shell_command, mcp_session_init)
  2. ha_call_service(shell_command, read_critical_rules)
  3. ha_call_service(shell_command, read_handoff)
  4. ha_backup_create("Pre_MiniPC_Runbook_2026-04-10")
  5. Verify Repairs = 0
  6. BUILD MIGRATION RUNBOOK — full step-by-step with commands
  7. If time: CRITICAL_RULES corrections (fxlt, v3.06 firmware)
