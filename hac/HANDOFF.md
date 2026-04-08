# HAC Handoff — 2026-04-08 S4 Close

## Last commits
  ee4473a fix: Tier 2 ceiling cans transition:0 — prevent flicker on motion restart
  9239f87 hac wrap: S3 complete + hac.sh restored (previous session)

## System state RIGHT NOW
  HA 2026.4.1 / HAOS 17.2 — current
  27 packages / ~132 active automations / git clean / pushed
  Repairs: 0 ✅
  Backup: Pre_S4_2026-04-08 (ade0a9db)

## S4 completed work
  [✅] Kitchen Table AL violation fixed — ceiling cans + bar pendants removed from AL
       (UI pencil edit — now contains only Tier 1 Hue lights)
  [✅] Tier 2 ceiling can flicker fixed — transition:0 on all 3 brightness levels
       File: lighting_motion_firstfloor.yaml | Commit: ee4473a
  [✅] Inovelli upstairs hallway diagnosed — switch NOT in ZHA (not paired/not installed)
       Hue EP2 binding architecture limitation documented in CRITICAL_RULES
  [✅] Upstairs hallway AL fight identified — motion automation sends explicit
       brightness_pct+color_temp to Hue group, fights AL (deferred fix)
  [✅] Scene inventory pulled — 124+ scenes, gaps and naming inconsistency mapped

## S4 new learnings → CRITICAL_RULES
  - AL vs Tier 2 live detection via parent_id clustering in ha_get_states
  - transition:0 mandatory on all Inovelli dumb-load motion automations
  - Hue bridge bulbs ≠ ZHA — EP2 binding impossible, HA automation path only
  - Upstairs hallway explicit params fight AL (same pattern as kitchen Tier 2)

## KNOWN OPEN ITEMS (carry forward)
  - Alaina arrival notification: notifications_system.yaml:55 # DISABLED
  - Upstairs hallway motion automation: remove explicit brightness/color_temp, use scenes
  - Upstairs hallway Inovelli: pair to ZHA if switch is on wall, then build automation
  - Driveway approach lights: rebuild with Inovelli local override
  - Living room motion: rebuild with Apollo R-PRO mmWave (LD2450 Zone-1 coords in CRITICAL_RULES)
  - Security backlog: SSH password auth, Cloudflare Zero Trust, Git PAT rotation
  - Mini PC migration runbook: Friday 2026-04-11 (3 days away — HIGH PRIORITY)
  - TR nightlight naming: 12 sensors affected
  - VZM36 living room: 2 instances (_3 + _4) — investigate duplicates
  - Room blink audit rooms 7-16: not completed this session
  - hue_dimmer_switch_4: room unidentified (needs Hue V2 API query)
  - Hue API key rotation: still pending (appeared in S3 transcript)

## ═══════════════════════════════════════════════════════════
## NEXT BIG PROJECT: HUE STANDARDIZATION (NEW SESSION)
## ═══════════════════════════════════════════════════════════

### GOAL
Complete Hue ecosystem audit + standardization across all rooms:
- Every room: confirmed entity_ids, Hue group/room/zone structure, bulb count
- Standard 4-scene set per room (created via Hue V2 API where missing)
- Consistent naming optimized for MCP + voice control
- Inovelli switch automations for all rooms with Hue bulbs
- AL instances verified/corrected for all Tier 1 rooms

### STANDARD SCENE SET (best practice, 4 per room)
Hue V2 API scene names and values — create these in every applicable room:

  Energize   → 6500K, 100%  — morning, cooking, active tasks
  Relax      → 2237K,  56%  — evening wind-down, TV
  Dimmed     → 2700K,  25%  — late evening, casual, pre-sleep transition
  Nightlight → 2000K,   1%  — sleeping hours, wayfinding only

Scene entity_id pattern: scene.[area_snake_case]_[scene_type]
  e.g. scene.kitchen_energize, scene.master_bedroom_relax

### ROOM-BY-ROOM SCENE SPEC (what to create/verify)

  Kitchen (group: light.kitchen_chandelier + light.kitchen_above_sink_light):
    Need: Energize ✅exists, Relax ✅exists, Dimmed → CREATE, Nightlight → CREATE

  Kitchen Lounge (group: light.kitchen_lounge):
    Need: Energize → CREATE, Relax → CREATE, Dimmed → CREATE, Nightlight → CREATE

  Entry Room (group via light.entry_room_ceiling_light... Hue group):
    Need: Energize ✅exists (scene.entry_room_energize), Relax → CREATE,
          Dimmed → CREATE, Nightlight → CREATE

  Living Room (groups: lounge ceiling + table lamps + floor lamps):
    Has: per-group scenes (Relax, Energize, etc.) — consolidate to room-level
    Need: unified room scenes OR use light.living_room_lounge as primary group
    Standard: Concentrate (better than Energize for living room), Relax, Dimmed, Nightlight

  Master Bedroom:
    Has: Energize, Concentrate, Read, Relax, Rest, Dimmed ✅ mostly complete
    Need: Nightlight → verify/create | Standardize to: Read, Relax, Dimmed, Nightlight

  Upstairs Hallway:
    Has: Relax, Rest, Nightlight — scene.upstairs_hallway_*
    Need: Energize ✅exists (scene.upstairs_hallway_energize), verify Dimmed

  2nd Floor Bathroom:
    Has: Energize, Vanity Energize/Relax/Read/Nightlight (separate group)
    Need: full room set + verify Dimmed/Nightlight for main group

  Alaina's Bedroom:
    Has: Energize, Concentrate, Read, Bright, Bedside Lamp Nightlight/Read, Ceiling Energize
    Need: Relax → CREATE, Dimmed → CREATE, Nightlight (room-level) → CREATE
    Keep: custom Bright scene

  Ella's Bedroom:
    Has: Energize, Concentrate, Nightlight, custom (Volleyball Hype, Chill Purple,
         Reading, Bedtime Glow) — ceiling + wall/bedside separate groups
    Need: Relax → CREATE, Dimmed → CREATE
    Keep: ALL custom scenes — Ella's customs are intentional

  Garage:
    Has: Energize, Concentrate, Relax, Nightlight ✅ complete
    Need: Dimmed → CREATE

  Back Patio:
    Has: Energize, Relax, Concentrate, Read
    Need: Dimmed → CREATE, Nightlight → CREATE

  Front Driveway / Very Front Door:
    Has: many outdoor-specific scenes (Golden Hours, Arise, Shine, Sleepy, Nighttime, etc.)
    These are outdoor accent lights — keep outdoor-specific scenes, add Nightlight if missing

  Basement:
    Has: Energize only
    Need: Relax → CREATE, Dimmed → CREATE, Nightlight → CREATE

### NAMING CONVENTION — ENFORCED STANDARD
  Hue room name   → matches HA area name exactly (already mostly true)
  Scene entity_id → scene.[area_snake_case]_[energize|relax|dimmed|nightlight]
  Group entity_id → light.[area_snake_case] (room-level group, not sub-group)
  Switch alias    → "[Area] — [Switch Type]" e.g. "Master Bedroom — Tap Dial"

  AVOID: per-group scenes like scene.kitchen_chandelier_relax (confusing, not addressable by voice)
  PREFER: room-level scenes like scene.kitchen_relax (addressable: "turn on kitchen relax")

### VOICE CONTROL PREP (future — tablet/Assist)
  HA Assist voice commands work best when:
  - Scene names are natural language: "kitchen relax" not "kitchen chandelier relax"
  - Area names match colloquial usage: "bedroom" vs "master bedroom"
  - Scene names are consistent across rooms (same 4 words used everywhere)
  - Entity aliases set in HA for alternate phrasings (UI: entity → aliases field)
  Aliases to add: "kitchen lights" → light.kitchen_chandelier group alias
                  "bedroom lights" → light.master_bedroom alias

### HUE V2 API — SCENE CREATION (no key rotation done yet)
  Bridge: 192.168.1.68
  ⚠️ ROTATE KEY BEFORE USE (appeared in S3 transcript)
  Endpoint: PUT https://192.168.1.68/clip/v2/resource/scene
  Scene create body:
    { "actions": [{"target": {"rid": "<light_rid>","rtype":"light"},
                   "action": {"color_temperature": {"mirek": 153},
                              "dimming": {"brightness": 100.0}}}],
      "metadata": {"name": "Energize"},
      "group": {"rid": "<room_rid>", "rtype": "room"} }
  Mirek values: 6500K=153, 4000K=250, 2700K=370, 2237K=447, 2000K=500
  Brightness: 100.0, 56.0, 25.0, 1.0

### INOVELLI SWITCH AUTOMATION TEMPLATE (one per switch, all rooms)
  Trigger: zha_event, device_id: [switch_device_id], command: toggle / step / etc.
  Use Rohan unified blueprint (supports VZM31-SN + VZM35-SN + VZM30-SN)
  URL: https://community.home-assistant.io/t/627953
  File: /homeassistant/packages/hue_switches.yaml (create new)
  Button design (Option A — S4 decision):
    Button 1: scene.[room]_energize
    Button 2: scene.[room]_relax
    Button 3: scene.[room]_nightlight
    Button 4: light.turn_off
    Rotate:   brightness up/down (Tap Dial only)

### SWITCHES NEEDING AUTOMATIONS (0 exist for any of these)
  hue_tap_dial_switch_1  → Entry Room (device_id: find via ZHA)
  hue_tap_dial_switch_3  → Master Bedroom (device_id: find via ZHA)
  hue_dimmer_switch_1    → Alaina's Bedroom
  hue_dimmer_switch_2    → Ella's Bedroom
  hue_dimmer_switch_3    → Garage ⚠️ swap battery first
  hue_dimmer_switch_4    → UNKNOWN room (identify via Hue V2 API)
  Ella's Hue Light Switch → needs HA automation
  Upstairs Hallway Inovelli → needs ZHA pairing first

## Start next session
  1. ha_call_service(shell_command, mcp_session_init)
  2. ha_call_service(shell_command, read_critical_rules)
  3. ha_call_service(shell_command, read_handoff)
  4. ha_backup_create("Pre_S5_2026-04-08") or Pre_S1_2026-04-09
  5. Verify Repairs = 0
  6. DECISION: Mini PC migration (Friday!) vs Hue standardization project
     Mini PC = Friday deadline, should be session priority by Thursday at latest
