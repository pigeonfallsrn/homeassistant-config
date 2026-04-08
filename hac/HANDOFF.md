# HAC Handoff — 2026-04-08 S5 Close

## Last commits
  9d4b64e feat: hue_switches.yaml — 5 switch automations (S5 2026-04-08)
  bdabf65 docs: S4 wrap — AL/Tier2 fix, transition:0 learning, Hue standardization project spec

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.2 — current
  28 packages / 137 active automations (+5 new) / git clean / pushed to origin
  Repairs: 0 ✅
  Notifications: 0 ✅
  Backup: Pre_S5_2026-04-08 (03d69881)

## S5 completed work
  [✅] Phase 1 — Full Hue V2 API audit: 17 rooms mapped, all light RIDs, all zones confirmed
       Key finding: hue_dimmer_switch_4 = Garage (not "spare") — HANDOFF numbering was wrong
       Key finding: Hue switches on bridge, NOT ZHA — Rohan blueprint does NOT apply
  [✅] Phase 2 — 24 scenes created via Hue V2 API (0 failures)
       Kitchen: E/R/D/N | Kitchen Lounge: E/R/D/N | Entry Room: R/D/N
       Ella's Bedroom: R/D | Alaina's Bedroom: D | 2nd Floor Bathroom: R/D/N
       Basement: R/D/N | Back Patio: D | Garage: D | Upstairs Hallway: D | Living Room Lounge: D
  [✅] Phase 3 — HA scene entity naming audit: all 24 new scenes have clean entity_ids
       Pre-existing zone-level scenes (kitchen_chandelier_*, etc.) = cosmetic backlog only
  [✅] Phase 4 — hue_switches.yaml created (336 lines, 5 automations, all on)
       Uses native HA event entities (event.hue_*), NOT ZHA/blueprint
       event_type: short_release for buttons, clock_wise/counter_clock_wise for rotary
       Entry Room Tap Dial (hue_tap_dial_switch_1): E/R/D/Off + rotary brightness
       Master Bedroom Tap Dial (hue_tap_dial_switch_3): E/R/D/Off + rotary brightness
       Alaina's Bedroom Dimmer (hue_dimmer_switch_3): E/R/D/Off
       Ella's Bedroom Dimmer (hue_dimmer_switch_2): E/R/D/Off (standard; customize with her customs)
       Garage Dimmer (hue_dimmer_switch_4): E/R/D/Off ⚠️ battery swap still needed

## S5 new learnings → CRITICAL_RULES
  - Hue bridge switches use native event entities (event.hue_*), NOT ZHA/Rohan blueprint
  - Rotary: event_type=clock_wise/counter_clock_wise, action=repeat, steps=cumulative
  - Button press: event_type=short_release (most reliable for single-fire)
  - hue_dimmer_switch_4 = Garage (numbering ≠ HANDOFF assumed order — always verify via friendly name)
  - Phase 3 scene sync: HA picks up new Hue bridge scenes automatically on next Hue poll (no restart needed)
  - Hue V2 API scene create: POST to /clip/v2/resource/scene, group rtype must be "room" not "zone"

## FOH SWITCHES — POST-IT (build next dedicated session)
  Living Room Hue Switch (device:09c74744, FOHSWITCH)
    → Target: Living Room
    → Design question: AL living_spaces is running there. Should FOH override AL or work with it?
    → Suggested: B1=Energize, B2=Relax, B3=Dimmed, B4=Off (AL will reclaim on next motion)
  Living Room Lounge Click FoH (device:bee97efe, FOHSWITCH)
    → Target: Living Room Lounge (light.living_room_lounge)
    → Suggested: B1=Energize, B2=Relax, B3=Dimmed, B4=Off
  Ella's Bedroom Hue Light Switch (device:859416eb, FOHSWITCH)
    → Target: Ella's Bedroom
    → Suggested: B1=Volleyball Hype, B2=Chill Purple, B3=Nightlight, B4=Off
  NOTE: FOH event entities are already in HA (event domain). Same trigger pattern as dimmers.
  Check event_type values before building — may differ from RWL022.

## Ella's Bedroom dimmer — CUSTOMIZE WHEN READY
  Current mapping: B1=Energize, B2=Relax, B3=Dimmed, B4=Off
  To swap custom scenes: edit /homeassistant/packages/hue_switches.yaml
    B1 → scene.ella_s_bedroom_volleyball_hype  (or keep Energize)
    B2 → scene.ella_chill_purple               (her chill scene — verify entity_id)
    Restart not needed: hue_switches.yaml changes load on ha core restart only

## ⚠️ ACTION ITEMS (do before testing)
  - Garage dimmer: swap battery in hue_dimmer_switch_4 before testing
  - Hue API key: ROTATE before next session using bridge V2 API
    POST https://192.168.1.68/api (button press required) → update core.config_entries api_key field
  - Ella's custom scene entity_ids: verify scene.ella_chill_purple, scene.ella_volleyball_hype
    (seen in S5 entity list as scene.ella_chill_purple, scene.ella_volleyball_hype — confirm)

## ═══════════════════════════════════════════════════════════
## THURSDAY SESSION (2026-04-10): MINI PC MIGRATION RUNBOOK
## ═══════════════════════════════════════════════════════════
Mini PC arrives Friday 2026-04-11. Thursday session = migration prep only.

### MIGRATION CHECKLIST (generate full runbook Thursday)
  Pre-migration:
    - New backup day-of (Pre_MiniPC_Migration_2026-04-10 or similar)
    - Export ZHA: Settings > Devices & Services > ZHA > ⋮ > Download backup
    - Note current HA IP: 192.168.1.3 (HA Green)
    - Document all integrations requiring re-auth post-migration
    - Verify github is fully pushed (git log --oneline -3)
    - Screenshot all custom UI dashboards (kitchen-wall-v2 especially)
  Migration day:
    - Install HAOS on Mini PC (x86-64 image)
    - Restore from Pre_MiniPC_Migration backup
    - Assign new Mini PC same IP (192.168.1.3) in UniFi DHCP reservations
    - Re-import ZHA backup on new coordinator
    - Re-auth: Hue, Spotify, Google, any OAuth integrations
    - Verify MCP tunnel: ha.myhomehub13.xyz still resolves
    - Verify /api/mcp bypass policy still active in Cloudflare
    - Test all 5 Hue switch automations
  Post-migration (2 weeks):
    - Keep HA Green powered on as cold standby
    - Verify DB is building normally on new hardware
    - Confirm all automations firing

## KNOWN OPEN ITEMS (carry forward)
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Upstairs hallway motion automation: remove explicit brightness/color_temp, use scenes
  - Upstairs hallway Inovelli: pair to ZHA if switch installed, build automation
  - Driveway approach lights: rebuild with Inovelli local override
  - Living room motion: rebuild with Apollo R-PRO mmWave
  - Security backlog: SSH password auth, Cloudflare Zero Trust, Git PAT rotation
  - TR nightlight naming: 12 sensors affected
  - VZM36 living room: 2 instances (_3 + _4) — investigate duplicates
  - FOH switch automations: 3 switches (see above)
  - Zone-level scene cleanup (cosmetic): kitchen_chandelier_*, living_room_lounge_ceiling_*
  - Ella's dimmer custom scene mapping (when she asks for it)

## Start next session (Thursday — Migration Runbook)
  1. ha_call_service(shell_command, mcp_session_init)
  2. ha_call_service(shell_command, read_critical_rules)
  3. ha_call_service(shell_command, read_handoff)
  4. ha_backup_create("Pre_S1_2026-04-10")
  5. Verify Repairs = 0
  6. Generate full Mini PC migration runbook
  7. If time: test Hue switch automations (tap Alaina dimmer, verify scene fires)
