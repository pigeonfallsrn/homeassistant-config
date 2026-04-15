# Home Automation Operating System
## Pigeon Falls, WI | John Spencer | EQ14 Beelink
### Version 1.0 — 2026-04-15 | Synthesized from S1–S19

> **This document is the single canonical reference for operating, maintaining, and evolving
> this smart home system with AI assistance. It lives at `/homeassistant/hac/HAOS.md`
> and is git-tracked alongside the configuration.**

---

## PART 1 — SYSTEM ARCHITECTURE

### 1.1 Hardware Inventory

| Device | Role | IP | Notes |
|--------|------|----|-------|
| Beelink EQ14 (N150, 16GB, 1TB NVMe) | Primary HA host | 192.168.1.10 | Bare metal HAOS 17.2 |
| HA Green | Cold spare + TV kiosk | 192.168.1.3 | Disabled after migration |
| Synology DS224+ NAS | Backup destination + Docker host | 192.168.1.52 | Backups share → HomeAssistant/ |
| Sonoff Zigbee 3.0 USB Dongle Plus | ZHA coordinator | USB on EQ14 | 52 devices paired |
| Hue Bridge | Hue bulbs + FOH PTM215Z switches | Main LAN | hue_event only — never mix with zha_event |
| UDM Pro SE | Gateway + UniFi Protect NVR | 192.168.1.1 | 4+ cameras, G4/G5/G6 |
| USW Pro Max 16 PoE | Main switch | — | PoE for APs + devices |

Future NAS Docker services (after system stable):
- MariaDB — external HA recorder (db_url: mysql://ha_db@192.168.1.52/homeassistant)
- AdGuard Home — local DNS + ad blocking (optional)
- Uptime Kuma — service monitoring (optional)

NOT running Frigate — UniFi Protect covers all cameras. N150 has no GPU. No benefit.

### 1.2 Network Architecture

Main LAN (192.168.1.x) — Trusted:
EQ14, Green, NAS, Hue Bridge, UniFi gear, Sonos, personal devices

IoT VLAN (192.168.21.x) — Sandboxed:
ESPHome devices, TP-Link Kasa, Govee, Apollo sensors, ratgdo, kitchen tablet (FKB)

Firewall rules (Terry White stateful method):
1. Allow Established Return Traffic — TOP, match state: established+related
2. Allow Main LAN → IoT (HA controls devices)
3. Allow IoT → HA only (ESPHome reports back)
4. Block IoT → Main LAN
5. Allow IoT → Internet (firmware updates)

mDNS: UniFi mDNS reflector enabled — allows ESPHome discovery cross-VLAN.

### 1.3 Configuration Philosophy: UI-First

What stays in YAML forever (minimal spine):
  configuration.yaml    ← recorder, http, logger, homeassistant block ONLY
  themes/               ← kitchen_wall.yaml (working — do not touch)
  blueprints/           ← custom blueprint YAML files

What lives in HA UI storage (MCP-managed, zero YAML):
  All automations, all helpers, all scripts, all scenes, all dashboards

Why this matters — bugs this eliminates:
- unique_id: auto_* injection → GONE (only happens in package YAML)
- RESOURCE_NOT_FOUND from MCP → GONE (only happens for package automations)
- Dual-source conflicts → GONE (single source of truth)
- Ghost registry entries on restart → GONE

MCP boundary rules:
- ha_config_list_helpers = UI storage ONLY — YAML helpers invisible
- ha_config_get_automation returning RESOURCE_NOT_FOUND = it's a package YAML automation
- HA entity count ≠ UI storage count — never conflate
- ha_config_set_helper(name, no helper_id) = CREATE new
- ha_config_set_helper(helper_id=X) = UPDATE existing only

### 1.4 Event System Boundaries — NEVER MIX

| System | Source | Event | Use For |
|--------|--------|-------|---------|
| ZHA | Sonoff USB dongle | zha_event | Inovelli VZM switches (all models) |
| Hue | Hue Bridge | hue_event | FOH PTM215Z click switches, Hue dimmers |

FOH switches use Zigbee Green Power — ZHA does NOT support this protocol.

### 1.5 Adaptive Lighting (6 instances)

| Instance | Room | autoreset_control_seconds |
|----------|------|--------------------------|
| living_spaces | Living Room | 3600 |
| entry_room_ceiling | Entry Room ceiling | 3600 |
| entry_room_lamp_adaptive | Entry Room lamp | 3600 |
| kitchen_table | Kitchen | 3600 |
| master_bedroom_wall_lamp | Master Bedroom | 0 (stays manual) |
| upstairs_hallway | Upstairs Hallway | 1800 |

Required for ALL instances (especially Hue color bulbs):
  take_over_control: true
  detect_non_ha_changes: false     # CRITICAL — Hue bulbs give false positives
  separate_turn_on_commands: true  # Required for Hue color bulbs

Create/delete AL instances via UI ONLY — no API exists.

---

## PART 2 — GOVERNANCE RULES

### 2.1 Local-First Rules
1. Prefer local integrations over cloud. If a local API exists, use it.
2. No polling integrations unless unavoidable.
3. ESPHome over proprietary firmware for any ESP device you control.
4. UniFi Protect over Frigate — already local, GPU-accelerated, rock-solid.
5. NAS over cloud backup. Backups go to DS224+.
6. Cloudflare Tunnel for remote access — no open ports on WAN.

### 2.2 UI-First Rules
1. All automations created through UI (MCP ha_config_set_automation).
2. All helpers created through UI (MCP ha_config_set_helper).
3. All scenes, dashboards, scripts created through UI.
4. YAML automations are legacy — every package file must be migrated.
5. After any migration: ha core check must return clean before committing.

### 2.3 YAML-Only-When-Necessary
Permitted: configuration.yaml, themes/, blueprints/, ESPHome device YAML, template sensors
Not permitted: automations, helpers, scripts, scenes, dashboards

### 2.4 Naming Convention

Entity IDs — domain.area_descriptor:
  light.kitchen_chandelier
  binary_sensor.kitchen_motion
  input_boolean.hot_tub_mode          (global — no area prefix)
  input_boolean.kitchen_manual_override
  timer.garage_light
  counter.garage_opens_today

Rules:
- Lowercase, underscores only
- Area prefix always first (except globals: house_sleep_mode, hot_tub_mode)
- No redundant words: light.kitchen_ceiling not light.kitchen_ceiling_light

SLUG MATCHING RULE (learned S19):
  MCP entity_id derives from display name — use YAML key words as name, NOT the YAML
  friendly name. To get input_datetime.last_garage_open_time, use name
  "Last Garage Open Time" — NOT "Last Garage Opened".

Automation aliases — [Area] — [Function]:
  Kitchen — Motion Lighting
  Garage — Auto Close on Departure
  System — Occupancy Mode Update
  Notifications — Garage Door Left Open

Device names — Title Case, area first:
  Kitchen Chandelier
  Kitchen Motion Sensor (Apollo R-PRO-1)

### 2.5 Area & Floor Structure

Floor: Outdoors
  Very Front Door, Front Driveway, Back Patio, Back Yard Tower, Pigeon Falls Properties

Floor: 1st Floor
  Entry Room, Kitchen, Kitchen Lounge, Living Room, Living Room Lounge,
  1st Floor Bathroom, Stairway Cubby, Smart Home AV, Garage

Floor: 2nd Floor
  Master Bedroom, Alaina's Bedroom, Ella's Bedroom,
  Upstairs Hallway, Upstairs Bathroom, Attic

Floor: Basement
  Basement, Basement Hallway, Laundry Area, Boiler Room, Workout Area

DELETE (0-entity areas): Yard Sheds, Bedroom, Entry Way, Cloud, Cloud wifi sync module

### 2.6 Labels
lighting, presence, security, climate, kids, garage, av, notifications, override, utilities, ha_system, adaptive

### 2.7 Automation Design Rules
1. mode: restart for all motion-triggered automations.
2. Combined binary_sensor for multi-sensor rooms — never OR individual sensors.
3. delay_off minimum 60s on aggregated motion sensors.
4. No templated service names — service.turn_{{ }} deprecated HA 2026. Use if/then/else.
5. Prefer scene-driven automations over per-state automations.
6. One automation per logical function.
7. Timeouts: transition 5-10min, active 8-20min, relaxation 15-45min.

---

## PART 3 — AI-ASSISTED WORKFLOW

### 3.1 Tool Roles

Claude (this project) — Primary operator:
  Architecture decisions, YAML/blueprint generation, MCP actions on HA,
  session-by-session migration, code review, documentation

Gemini 2.5 Pro — Bulk analysis (one-shot):
  Paste entire automation dump → KEEP/REBUILD/DELETE triage
  Large JSON analysis (>50 items)
  Prompt: "Here are N automations. Categorize by group and rate quality 1-5."

Perplexity — Real-time research:
  Current HA community best practices
  "What is the current best practice for X in HA 2026.4?"

### 3.2 Session Discipline (Non-Negotiable)

Every session starts:
  1. ha_call_service shell_command mcp_session_init  → read output
  2. ha_call_service shell_command read_handoff       → read output
  3. ha_call_service shell_command read_critical_rules → read output
  Do not proceed until all three are read.

Every session ends:
  1. ha core check (no new errors)
  2. git add -A && git commit -m "type: S## — description"
  3. GIT_TERMINAL_PROMPT=0 git push
  4. Write HANDOFF.md with completed work, S(n+1) instructions, tabled items

One session = one migration group or one infrastructure phase.
Never leave a session mid-automation or with uncommitted work.

### 3.3 Terminal vs MCP Boundary

| Context | Path prefix | Use for |
|---------|-------------|---------|
| Terminal / SSH | /homeassistant/ | grep, python3, sed, cat, git |
| shell_commands / HA container | /config/ | shell_command.* services |

NEVER edit directly: .storage/core.*, any .storage/*.json

### 3.4 Shell Command Patterns

Always prefer one-shot && chains:
  hac backup name && python3 script.py && ha core restart

Known gotchas:
- grep returning no results exits code 1 — breaks && chains
  Run verify and restart as separate commands
- heredoc cannot be followed by && on same line — two pastes
- hac symlink doesn't survive power cycles:
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
- BusyBox grep: NO --include, NO long options → grep -rn "pattern" /path/

### 3.5 Git Discipline

Commit types:
  feat:  new functionality
  fix:   bug fix
  refac: restructure without behavior change
  docs:  documentation only
  chore: maintenance

Push always: GIT_TERMINAL_PROMPT=0 git push

---

## PART 4 — KNOWLEDGE MANAGEMENT

### 4.1 Documentation Structure

/homeassistant/
  configuration.yaml
  HANDOFF.md                       ← session continuity (rewritten every session end)
  hac/
    MASTER_PLAN.md                 ← migration roadmap and architecture decisions
    HAOS.md                        ← this document
    CRITICAL_RULES_CORE.md         ← hard-won lessons
    CRITICAL_RULES_HISTORY.md      ← dated session entries, archived learnings
    BACKLOG_kitchen_dashboard.md   ← dashboard-specific backlog
    backups/                       ← pre-edit dashboard backups
    migration/                     ← per-group session notes
  packages/                        ← legacy YAML automations (being migrated out)
  blueprints/automation/           ← custom blueprints (BP-1 through BP-4)
  themes/                          ← kitchen_wall.yaml

### 4.2 How Learnings Get Captured

During a session: any pattern hit twice → add to CRITICAL_RULES_CORE.md immediately.
At session end: HANDOFF.md "Critical learnings" captures session-specific discoveries.
Promoted to CRITICAL_RULES when: pattern is general enough to affect any future session.

Format for new CRITICAL_RULES entry:
  ## TOPIC NAME (Times Hit: N)
  - Root cause: ...
  - Fix: ...
  - Detection: ...
  - DO NOT: ...

### 4.3 Helper Inventory (as of S19 — all 82 in UI storage)

| Type | Count | Key entities |
|------|-------|-------------|
| input_boolean | 50 | house_sleep_mode, hot_tub_mode, room overrides, garage/security toggles, kids routines |
| input_select | 3 | occupancy_mode, ella_sleep_timer, kitchen_lighting_scene |
| input_number | 6 | entry_room_lux_threshold, grade helpers x4, garage_light_timeout |
| input_datetime | 16 | routine/garage/alert timestamps, wake overrides, snooze fields |
| timer | 3 | garage_light, guest_mode_auto_disable, manual_override_timeout |
| counter | 4 | garage/doorbell/motion/alert daily counters |

---

## PART 5 — SECURITY WORKFLOW

### 5.1 NordPass Convention

Title format: Device/Service — Purpose (user)

Examples:
  EQ14 Beelink — SSH Terminal (hassio)
  DS224+ NAS — DSM Admin (admin)
  DS224+ NAS — HA Backup Share (HA_Synology)
  GitHub — PAT homeassistant-config (pigeonfallsrn)

Never use: URLs as titles, "this one", device-only names without purpose.

NordPass backlog (rename these):
  "hassio adv ssh app this one"
  "http://192.168.1.3:8123" (x2)
  "ha_synology this one"
  "DS finder ha_synology this one"
  "http://192.168.1.52:5000" (x3)
  "http://192.168.1.52:32400"
  "Mobile App Temp Long-lived Token - HA"

### 5.2 Credential Block Format

When a new credential is created, output this block for NordPass:

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NORDPASS ENTRY
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Title:    [Device/Service — Purpose (user)]
  Username: [username or email]
  Password: [generate in NordPass]
  Website:  [URL if applicable]
  Note:     [context, expiry, rotation notes]
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.3 Token Management Rules

1. Long-lived tokens: HA → Profile → Security → store in NordPass immediately.
2. GitHub PAT: stored in git remote URL only. Never in YAML files.
3. API keys in config: use secrets.yaml → !secret key_name. Never hardcode.
4. Token rotation: any token older than 6 months → rotate. Note creation date in NordPass.
5. MCP token: if compromised, revoke in HA immediately and regenerate.

### 5.4 SSH Access

EQ14: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
SSH keys only — no password auth.
Remote access: Cloudflare Tunnel only — do NOT open port 2222 to WAN.

---

## PART 6 — SYSTEM AUDIT WORKFLOW

### 6.1 Audit Categories

| Category | Meaning |
|----------|---------|
| KEEP | Working, properly named, in UI storage |
| REBUILD | Logic correct but YAML, poorly named, or poorly structured |
| DEPRECATE | Partially functional, needs rethinking |
| DELETE | Dead, duplicate, or superseded |

### 6.2 Automation Audit Checklist

Before migrating any group:
  - Terminal: cat the package file(s)
  - Gemini triage if >10 automations: KEEP/REBUILD/DELETE + quality score 1-5
  - Check: does each automation reference real entities?
  - Check for duplicates: same trigger + same action in two automations
  - Check for deprecated patterns: service.turn_{{ }}, event: call_service
  - Migrate via ha_config_set_automation
  - Strip from package file
  - ha core check → reload → verify
  - Apply labels + categories
  - Commit

### 6.3 Integration Health Check

Settings → Devices & Services → check for:
  - setup_error (needs attention)
  - failed_unload (may need restart)
  - Any integration showing 0 entities (may be orphaned)

Known issues:
  - Music Assistant — setup_error (needs add-on restart)
  - AndroidTV 192.168.1.17 — real device, identity unknown, DO NOT DELETE

---

## PART 7 — MIGRATION STATUS & SEQUENCE

### 7.1 Current State (as of S19)

| Component | Status |
|-----------|--------|
| HAOS install (EQ14) | Complete |
| NAS backups | Connected |
| Git repo | Tracking |
| ZHA (52 devices) | Migrated |
| Entity/device registry | Migrated |
| All helpers (82) | In UI storage |
| Integrations | All active |
| Adaptive Lighting (6) | Configured |
| Blueprint library | BP-1 exists, BP-2/3/4 pending |
| Package YAML automations | ~84 remaining across 19 files |
| Dashboard rebuild | Post-automation-migration |
| MariaDB on NAS | After 1 week stable |

### 7.2 Package Files Remaining (19 files, ~84 automations)

  adaptive_lighting_entry_lamp.yaml    (13) — G1/G3
  notifications_system.yaml            (8)  — G10
  kids_bedroom_automation.yaml         (10) — G6
  kitchen_tablet_dashboard.yaml        (6)  — G2
  lighting_motion_firstfloor.yaml      (5)  — G2
  occupancy_system.yaml                (6)  — G0  NEXT
  family_activities.yaml               (6)  — G0  NEXT
  humidity_smart_alerts.yaml           (4)  — G7
  ella_living_room.yaml                (4)  — G6
  hue_switches.yaml                    (6)  — G1-G5
  lights_auto_off_safety.yaml          (3)  — G8
  ella_bedroom.yaml                    (3)  — G6
  garage_door_alerts.yaml              (2)  — G4
  garage_lighting_automation_fixed.yaml(2)  — G4
  garage_quick_open.yaml               (1)  — G4
  garage_arrival_optimized.yaml        (1)  — G4
  garage_notifications_consolidated.yaml(1) — G4
  entry_room_ceiling_motion.yaml       (1)  — G1
  upstairs_lighting.yaml               (1)  — G5

---

## PART 8 — DEVICE ONBOARDING WORKFLOW

### 8.1 Any New Device
1. Assign static DHCP reservation in UniFi first — document IP in NordPass note.
2. Decide entity_id and friendly name (naming convention) before adding to HA.
3. Assign area immediately on integration.
4. Test for 24h before building automations.

### 8.2 Zigbee Device (ZHA)
1. Settings → Devices → ZHA → Add Device
2. Rename entity_id via ha_set_entity to area_descriptor convention
3. Assign area
4. Note IEEE address in device notes (needed for Inovelli parameter work)
5. If Inovelli switch: configure Smart Bulb Mode params before first automation

### 8.3 ESPHome Device
1. Flash ESPHome firmware (amd64 binary for EQ14)
2. Adopt in Settings → ESPHome
3. Configure: name, area, device_class per sensor
4. Verify IoT VLAN → HA firewall rule allows reporting
5. Commit ESPHome YAML to git repo

Known ESPHome devices:
  ratgdo North (fd8d8c) — garage north door
  ratgdo South (5735e8) — garage south door
  Apollo Entry Room (748020) — mmWave + lux
  Apollo Kitchen (192.168.21.233) — mmWave + lux (OTA flash pending)

### 8.4 Hue / FOH Switch
FOH PTM215Z (EnOcean Zigbee Green Power):
  Must pair via Hue Bridge — ZHA cannot handle this protocol.
  Triggers hue_event with button/step_value.
  12 accessory limit per bridge — monitor headroom.

Hue Bulb:
  Add to Hue app room/zone first.
  Assign to AL instance matching room.
  Verify separate_turn_on_commands:true on that AL instance.

---

## PART 9 — QUICK REFERENCE

### 9.1 SSH & Access

  EQ14 SSH:     ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
  HA local:     http://192.168.1.10:8123
  HA external:  https://ha.myhomehub13.xyz
  NAS DSM:      http://192.168.1.52:5001
  Git repo:     https://github.com/pigeonfallsrn/homeassistant-config

### 9.2 After Every Power Cycle
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac && chmod +x /homeassistant/hac/hac.sh

### 9.3 Backup Commands
  ha backups new --name "description"
  # Dashboard backup (BEFORE any dashboard edit):
  cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json

### 9.4 Key Entity IDs
  input_select.occupancy_mode          ← foundation of all presence logic
  input_boolean.house_sleep_mode       ← global sleep state
  input_boolean.hot_tub_mode           ← overrides entry/living lighting
  input_boolean.school_tomorrow        ← gates kids bedtime automations
  input_boolean.school_in_session_now  ← gates daytime kids automations

### 9.5 Known Device IDs & MACs
  FKB tablet device_id:   86870b5d8b01f345f5d5dd9c2ac06d2b
  Michelle iPhone MAC:    6a:9a:25:dd:82:f1
  AP 1st Floor MAC:       1c:0b:8b:76:fa:65
  AP Garage MAC:          1c:0b:8b:76:fc:ae
  AndroidTV IP:           192.168.1.17  (REAL DEVICE — DO NOT DELETE)
  VZM30 vanity device_id: 602bdb2b
  VZM30 ceiling device_id: 0489781e

### 9.6 Tabled Items
  - Person trackers: Alaina, Ella, Michelle — none assigned (assign in Group 0)
  - Music Assistant — setup_error, needs add-on restart
  - input_text: alaina/ella WAYA softball calendar IDs — recreate in Group 6
  - North ratgdo: toggle obstruction OFF after any OTA flash
  - Apollo Kitchen (192.168.21.233): OTA flash pending (move to stronger AP first)
  - Vanity slow fade: LOCAL_RAMP_RATE VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 → Group 5
  - humidity_smart_alerts unpause bug → Group 7

---

## APPENDIX A — BLUEPRINT LIBRARY

| ID | File | Status | Purpose |
|----|------|--------|---------|
| BP-1 | rohan_inovelli_vzm.yaml | Exists | ZHA zha_event for all Inovelli VZM switches |
| BP-2 | foh_scene_cycling.yaml | Build in G0 | hue_event scene cycling for FOH switches |
| BP-3 | motion_lighting.yaml | Build early | Generic motion lighting with AL integration |
| BP-4 | vzm30_bathroom.yaml | Build in G5 | VZM30-SN SBM ceiling + vanity scene cycling |

---

## APPENDIX B — DASHBOARD STRUCTURE (post-migration target)

| Dashboard | Purpose |
|-----------|---------|
| Home (default mobile) | Summary cards, presence, quick actions |
| Rooms view | Per-floor area cards |
| Kitchen Wall Tablet | Dedicated kiosk — FKB (lovelace.kitchen_wall_v2) |
| Garage | Cover + sensor status |
| Climate | Thermostat + mini-split controls |
| Security | Protect camera feeds + alerts |
| TV (Green HDMI) | Minimal kiosk — Chromium --kiosk mode |

---

*Next scheduled update: after Group 0 automation migration (S20).*
