# HA Migration Master Project Plan
## Green → EQ14 Beelink | John Spencer | Pigeon Falls, WI
### Version 1.0 — 2026-04-13 | Session S12

---

## 0. HOW TO USE THIS DOCUMENT

This is the single source of truth for the entire migration project.
It lives at: /homeassistant/hac/MASTER_PLAN.md (git-tracked)

Every session starts here. Every decision is recorded here.
When context runs out, paste the Claude Project starter prompt and reference this file.

---

## 1. PROJECT MANAGEMENT

### Use a Claude Project (STRONGLY RECOMMENDED)

Create a Claude Project called "HA Migration — EQ14" at claude.ai/projects.
Upload this file + CRITICAL_RULES_CORE.md as Project Knowledge.

Benefits over regular sessions:
- Context persists across sessions (no more 2000-token startup prompts)
- Architectural decisions stay loaded
- No re-explaining your hardware setup each time
- Session starts: "Let's work on Group 2 — Kitchen automations"

Session discipline:
- One session = one migration group or one infrastructure phase
- Every session ends: HANDOFF.md update + git commit + git push
- Clear stopping points — never mid-automation

### AI Tool Division of Labor

CLAUDE (Project):
- Architecture decisions and research
- YAML/blueprint code generation
- MCP actions directly on HA (ha_* tools)
- Session-by-session execution
- Code review and debugging

GEMINI 2.5 PRO (one-shot bulk tasks):
- Pre-migration: paste entire automation dump → get Keep/Rebuild/Delete triage list
- Post-migration: paste entity registry → identify inconsistent naming
- Large JSON analysis (>50 items at once)
- Use for: "Here are 163 automations. Categorize them by group and rate quality 1-5."

PERPLEXITY:
- Real-time HA community research
- "What is the current best practice for X in HA 2026.4?"
- Quick spec lookups (blueprint parameters, integration options)

---

## 2. HARDWARE INVENTORY & DECISIONS

### Primary: EQ14 Beelink Mini PC
- Intel N150, 16GB DDR4, 1TB NVMe
- Role: Primary HAOS bare metal host
- IP: Reserve 192.168.1.10 (static DHCP reservation in UniFi)
- Method: Bare metal HAOS (NOT Proxmox — NAS handles secondary services)
- Why not Proxmox: Adds complexity, DS224+ already handles containerized services

### HA Green (existing)
- Role: Cold spare + TV dashboard display
- Keep updated alongside EQ14 (same HAOS version, passive)
- Connect HDMI → any TV → Chromium kiosk → ha.myhomehub13.xyz
- Cold spare activation: plug ethernet back in, takes 60 seconds to become primary
- IP: Keep 192.168.1.3 but DISABLE after migration (don't let it fight EQ14)

### DS224+ NAS (192.168.1.52)
- Role: Backup destination + Docker service host
- Backup: Backups share → HomeAssistant subfolder (DONE — NAS_Backups connected)
- Docker services to run (via Container Manager):
  - Phase 2: MariaDB (external HA recorder, after 1 week stable)
  - Optional: AdGuard Home (DNS ad-blocking, local DNS resolution)
  - Optional: Uptime Kuma (service monitoring dashboard)
  - NOT: Frigate (CPU too slow without GPU, UniFi Protect already covers cameras)

### Sonoff Zigbee 3.0 USB Dongle Plus
- Carry from Green to EQ14 physically
- ZHA config migrates via .storage file copy (no re-pairing needed)
- 49 devices stay paired

### Hue Bridge (existing, keep as-is)
- All Hue bulbs + FOH click switches + Hue dimmer remotes stay on bridge
- FOH (EnOcean PTM215Z) use Zigbee Green Power — ZHA does NOT support this protocol
- Bridge fires hue_event to HA via Hue v2 API — rock-solid, designed for this
- 12 accessory limit on bridge: monitor as FOH switches are added
  - Solution if hit: second Hue Bridge (HA supports multiple simultaneously)

### FRIGATE DECISION: NO — Keep UniFi Protect
Rationale:
- UDM Pro SE already running Protect with 4+ cameras
- Protect has rock-solid HA integration (per-camera entities, smart detection, live view)
- Best mobile app of any NVR system for event viewing/playback
- Protect handles person/vehicle/animal detection natively on G4/G5/G6 cameras
- Frigate adds value ONLY for: non-UniFi cameras or custom AI models
- Adding Frigate would create duplicate NVR with no benefit
- N150 CPU has no GPU acceleration — Frigate would be CPU-bound and hot
- VERDICT: Keep Protect. Use UniFi Protect HA integration for automations.

---

## 3. NETWORK ARCHITECTURE (UniFi)

### Current State
- UDM Pro SE (gateway + Protect NVR)
- USW Pro Max 16 PoE (main switch)
- Multiple UniFi APs
- Main LAN: 192.168.1.x (trusted devices)
- IoT VLAN: 192.168.21.x (smart devices, ESPHome)

### Device Placement by Network

MAIN LAN (192.168.1.x) — Trusted:
- EQ14 (HA primary) reserve 192.168.1.10
- HA Green (cold spare) keep 192.168.1.3
- DS224+ NAS keep 192.168.1.52
- Hue Bridge keep on Main LAN (it is a trusted hub, not a cloud IoT device)
- UniFi gear (APs, switches, cameras) Main LAN
- Personal computers, phones, tablets Main LAN
- Sonos speakers Main LAN (Sonos is notorious for breaking on IoT VLAN)

IOT VLAN (192.168.21.x) — Sandboxed:
- ESPHome devices (Apollo R-PRO-1 sensors, ratgdo controllers)
- TP-Link Kasa smart plugs
- Govee/other Wi-Fi smart devices
- Any new cloud-dependent IoT devices

CAMERA VLAN (optional, future):
- UniFi cameras are managed by Protect via UDM, already effectively isolated
- If adding non-UniFi cameras later, create dedicated camera VLAN

### Firewall Rules (Terry White Stateful Method — 2026 best practice)

Delete any port-specific IoT rules you have. Matter uses dynamic ports.
Replace with these stateful rules (Settings -> Security -> Firewall and Security):

Rule 1 — "Allow Established Return Traffic" (MOST IMPORTANT)
  Action: Accept
  Source: All Local Networks
  Destination: All Local Networks
  Match State: Established + Related
  Position: TOP of list

Rule 2 — "Allow Main LAN to IoT" (HA controls IoT devices)
  Action: Accept
  Source: Main LAN (192.168.1.0/24)
  Destination: IoT VLAN (192.168.21.0/24)

Rule 3 — "Allow IoT to HA only" (ESPHome devices report back to HA)
  Action: Accept
  Source: IoT VLAN (192.168.21.0/24)
  Destination: HA IP (192.168.1.10)

Rule 4 — "Block IoT to Main LAN" (IoT devices cannot initiate to trusted network)
  Action: Drop
  Source: IoT VLAN
  Destination: Main LAN

Rule 5 — "Allow IoT Internet" (firmware updates, cloud check-ins)
  Action: Accept
  Source: IoT VLAN
  Destination: WAN

mDNS: Enable UniFi mDNS reflector (Settings -> Networks -> enable mDNS)
This allows ESPHome devices on IoT VLAN to be discovered by HA on Main LAN.

### SSH Access (secure remote terminal)
- EQ14 SSH: port 2222 (HAOS default), user: hassio
- SSH keys only — no password auth (already set up from S7 security session)
- Access from Main LAN: direct
- Access from outside: via Cloudflare Tunnel (already configured at ha.myhomehub13.xyz)
  Do NOT open port 2222 to WAN — use Cloudflare Access for remote SSH if needed

### DHCP Reservations to Create in UniFi
- EQ14: MAC -> 192.168.1.10 (set after HAOS install, get MAC from HAOS network page)
- Green stays at 192.168.1.3 (keep reservation, just disable after migration)
- NAS stays at 192.168.1.52 (already reserved)

---

## 4. HA ARCHITECTURE DECISIONS (FINAL)

### Configuration Philosophy: UI-First

What stays in YAML (minimal spine only):
  configuration.yaml    -- recorder, homeassistant block, http, logger only
  themes/               -- kitchen_wall.yaml (working, do not touch)
  blueprints/           -- custom blueprint YAML files

What moves to HA storage (UI + MCP managed, zero YAML):
  All automations       -- no package files
  All helpers           -- UI Template Helpers, not templates.yaml
  All scripts
  All scenes
  All dashboards

Why this eliminates your recurring bugs:
  - unique_id auto_* injection -> GONE (only happens in package YAML)
  - RESOURCE_NOT_FOUND from MCP -> GONE (only happens for package automations)
  - Dual-source conflicts -> GONE (single source of truth: HA storage)
  - Ghost registry entries on restart -> GONE (no package file vs registry race)

### Adaptive Lighting: Override Pattern (Confirmed)

Per AL instance settings (Hue color bulbs):
  take_over_control: true            # essential
  detect_non_ha_changes: false       # CRITICAL — Hue bulbs give false positives
  separate_turn_on_commands: true    # required for Hue color bulbs
  autoreset_control_seconds:
    bedrooms: 0                      # stays manual until off/on
    kitchen/living: 3600             # 1 hour then AL resumes
    hallways/baths: 1800             # 30 min then AL resumes

Button behavior:
  ON press (no params): -> AL takes over immediately (circadian)
  DIM press (explicit brightness): -> AL marks manual, backs off
  SCENE press: -> AL marks manual, backs off, autoreset restores
  OFF press: -> manual flag cleared, next ON gets AL

"Reset to adaptive" script (one per room, optional long-press):
  adaptive_lighting.set_manual_control: manual: false

---

## 5. NAMING CONVENTION (COMPLETE SPEC)

This is the single naming standard. Everything in the new system follows this.
Enforce before building Group 0. Do not deviate.

### Entity IDs (MCP/YAML/automation references)
Format: domain.area_descriptor  or  domain.area_device_function

Examples:
  light.kitchen_chandelier
  light.kitchen_above_sink
  light.entry_room_ceiling
  light.living_room_lamp_left
  light.living_room_lamp_right
  binary_sensor.kitchen_motion
  binary_sensor.kitchen_occupancy
  binary_sensor.garage_south_door
  binary_sensor.first_floor_main_motion    (aggregated template)
  input_boolean.hot_tub_mode               (global — no area prefix)
  input_boolean.house_sleep_mode           (global)
  input_boolean.kitchen_manual_override    (area-specific)
  input_number.kitchen_lounge_scene_index  (scene cycling)
  timer.kitchen_override                   (area override timer)
  switch.adaptive_lighting_kitchen_table   (AL instance naming)

Rules:
  - Lowercase, underscores only
  - Area prefix always first (except global modes)
  - No redundant words: NOT light.kitchen_ceiling_light -> light.kitchen_ceiling
  - Inovelli SBM switches: switch.area_inovelli_sbm or light.area_inovelli (if set as light)

### Device Names (friendly names in UI)
Format: [Area] [Device Description]  — Title Case

  Kitchen Chandelier
  Kitchen Above Sink Light
  Entry Room Ceiling Light
  Living Room Lamp Left
  Kitchen Motion Sensor (Apollo R-PRO-1)
  Garage South Door

### Automation Aliases
Format: [Area] — [Function]  or  [System] — [Function]

  Kitchen — Motion Lighting
  Kitchen — Manual Override (Double-tap Up)
  Entry Room — Scene Cycling (Config Press)
  Entry Room — Hot Tub Mode (Scene On)
  Garage — Auto Close on Departure
  Garage — Arrival Scene (North Door)
  Girls — Bedtime Winddown
  System — Occupancy Mode Update
  System — House Sleep Mode (10pm)
  Notifications — Garage Door Left Open

### Labels (cross-cutting, multi-assign allowed)
Create these in Settings -> Areas and Zones -> Labels:

  lighting       (all light automations + light entities)
  presence       (occupancy, arrival, departure)
  security       (locks, cameras, alarm, garage)
  climate        (Nest, Kumo, mini-splits)
  kids           (Alaina, Ella routines, bedtime, school)
  garage         (garage-specific)
  av             (media players, Yamaha, Roku, Plex)
  notifications  (all notify.* automations)
  override       (manual override helpers + automations)
  utilities      (HAC export, Google Sheets, system tasks)
  ha_system      (HA infrastructure, backup, watchdog)
  adaptive       (AL instances and related)

### Categories (per-table, UI only)
Automations table:
  Active | Review Needed | Disabled | Template Instance

Helpers table:
  Modes | Scene Indexes | Timers | Presence | Kids | Overrides | System

### Area and Floor Structure

Floor: Outdoors
  Very Front Door, Front Driveway, Back Patio, Back Yard Tower,
  Pigeon Falls Properties

Floor: 1st Floor
  Entry Room, Kitchen, Kitchen Lounge, Living Room, Living Room Lounge,
  1st Floor Bathroom, Stairway Cubby, Smart Home AV, Garage

Floor: 2nd Floor
  Master Bedroom, Alainas Bedroom, Ellas Bedroom,
  Upstairs Hallway, Upstairs Bathroom, Attic

Floor: Basement
  Basement, Basement Hallway, Laundry Area, Boiler Room, Workout Area

DELETE (0-entity areas): Yard Sheds, Bedroom, Entry Way, Cloud,
                          Cloud wifi sync module, Basement stairs

---

## 6. BLUEPRINT LIBRARY (build before automation groups)

All blueprints live in: /homeassistant/blueprints/automation/

### BP-1: Rohan Unified (EXISTING — keep, update if needed)
File: rohan_inovelli_vzm.yaml
Handles: ZHA zha_event for all Inovelli VZM31/30/35/36
Use for: Every Inovelli switch automation

### BP-2: FOH Scene Cycling (BUILD FIRST in Group 0)
File: foh_scene_cycling.yaml
Trigger: hue_event from device_id
Inputs:
  - device_id (the FOH switch or Hue dimmer)
  - scene_list (list of Hue scene names)
  - scene_index_helper (input_number entity)
  - lights_target (Hue group or light entity)
  - al_instance (switch.adaptive_lighting_xxx — for manual control reset)
Use for: All FOH click switches, Hue dimmer remotes

### BP-3: Room Motion Lighting (BUILD EARLY)
File: motion_lighting.yaml
Trigger: binary_sensor state change
Inputs:
  - motion_sensor (aggregated binary_sensor)
  - lux_sensor (optional threshold gating)
  - lux_threshold (number)
  - lights_target (light group or Hue group)
  - timeout_minutes (number)
  - al_instance (AL switch to enable on motion)
  - override_boolean (input_boolean — skip if manual override active)
  - light_type: hue | inovelli (determines turn_on params)
Use for: Every motion-triggered room

### BP-4: VZM30 Bathroom (BUILD IN GROUP 5)
File: vzm30_bathroom.yaml
Trigger: zha_event config_1x from VZM30-SN
Inputs:
  - switch_ieee
  - ceiling_light
  - vanity_light
  - scene_index_helper
Handles: button_2_press single-string command pattern

---

## 7. MIGRATION SEQUENCE (BOTTOM-UP)

### Pre-Migration (before touching EQ14) — 1-2 Sessions

STEP A: Gemini Bulk Audit on Green (SESSION S13)
1. From HA terminal: ha_call_service shell_command cat_automations > /homeassistant/hac/automation_dump.yaml
2. Paste entire file into Gemini 2.5 Pro with this prompt:
   "You are auditing a Home Assistant system. Review these 163 automations.
    For each: provide alias, area, function, quality score 1-5, and recommendation:
    KEEP (migrate as-is) / REBUILD (migrate but rewrite cleaner) / DELETE (dead/duplicate/unused).
    Output as a markdown table."
3. Save Gemini output to /homeassistant/hac/audit/gemini_audit_S13.md
4. This triage list drives every subsequent migration group

STEP B: NAS Reference Backup (can do now)
Extract 53ef3d09.tar from the NAS Backups share using 7-Zip on PC.
Create folder structure on the NAS:
  reference/extracted_backup_53ef3d09/    full extracted tar
  reference/dashboards/                   copy .storage/lovelace.* files here
  reference/automation_audit/             Gemini output goes here
  migration/                              per-group session notes
  backups/                                automated HA backups

---

### Phase 1: EQ14 Hardware (SESSION S14) — ~2 hours

PC Prep (do BEFORE session):
  1. Download Ubuntu 24.04 LTS ISO
  2. Download haos_generic-x86-64-17.2.img.xz from github.com/home-assistant/operating-system/releases
  3. Flash Ubuntu to USB with Rufus (NOT directly flash HAOS — need Ubuntu to write to internal NVMe)

EQ14 Setup:
  1. Connect keyboard, monitor to EQ14
  2. Boot from Ubuntu USB (F7 or Del for boot menu)
  3. "Try Ubuntu" (NOT install)
  4. Open Gnome Disks -> select 1TB NVMe -> Restore Disk Image -> select haos image
  5. Wait ~10 minutes for write
  6. Remove USB -> reboot -> HAOS boots
  7. BIOS check (Del key): Disable Secure Boot, confirm UEFI, enable WOL

Initial HAOS:
  1. Navigate to homeassistant.local:8123 from PC
  2. Complete onboarding (create fresh user — do NOT restore backup)
  3. Give EQ14 a DHCP reservation in UniFi for its MAC address -> 192.168.1.10
  4. Confirm SSH works: ssh hassio@192.168.1.10 -p 2222

Verify: Can log in, empty HA dashboard shows.

---

### Phase 2: NAS + Git (same session or S14B)

1. Add NAS_Backups network storage (Settings -> System -> Storage -> Add)
   192.168.1.52 / Backups / HA_Synology / (NordPass password)

2. SSH into EQ14, run:
   cd /homeassistant
   git clone the repo using the PAT in the URL
   ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac

3. ha core restart (loads configuration.yaml, themes, blueprints)

4. Configure backup: daily, keep 7, NAS_Backups destination

Verify: HA loads themes, blueprint folder exists, git push works.

---

### Phase 3: ZHA Migration (SESSION S15) — CRITICAL, do carefully

BEFORE starting: ha core stop

1. On Green, extract from backup 53ef3d09:
   homeassistant/.storage/zha.storage.json
   homeassistant/.storage/core.config_entries

2. Copy to EQ14:
   scp -P 2222 zha.storage.json hassio@192.168.1.10:/homeassistant/.storage/
   scp -P 2222 core.config_entries hassio@192.168.1.10:/homeassistant/.storage/

3. Physically move Sonoff USB dongle from Green to EQ14

4. ha core start

5. Settings -> Integrations -> ZHA -> Configure -> assign /dev/ttyUSB0 or /dev/serial/...

Verify: 49 devices appear in ZHA within 10 minutes.
If any missing: they will check in within 30 min as routers wake up.

---

### Phase 4: Entity + Device Registry (same session)

BEFORE: ha core stop

Copy from extracted backup 53ef3d09:
  core.entity_registry
  core.device_registry

scp both to EQ14 /homeassistant/.storage/

ha core start

Verify: Entity friendly names correct, areas assigned, no massive unavailable count.

---

### Phase 5: Helpers (SESSION S15B)

Option A — Copy from backup (fast, brings stale helpers too):
  Copy .storage/input_boolean.json, input_number.json, input_select.json,
  input_datetime.json, timer.json, counter.json to EQ14

Option B — Recreate via MCP (cleaner, drops 18 months of accumulation):
  Use ha_set_config_entry_helper for each helper
  Recommended: rebuild fresh — the helper inventory from S12 audit is complete

Decision: REBUILD FRESH. The audit identified all helpers. Building fresh
means clean names, clean categories, no orphans.

---

### Phase 6: Integrations (SESSION S16) — add via UI one by one

Priority order (verify each before next):
  1. Hue Bridge (3-second button press on bridge)
  2. ESPHome ratgdo North (fd8d8c), ratgdo South (5735e8)
  3. ESPHome Apollo Entry Room (748020) — re-adopt only, config preserved
  4. ESPHome Apollo Kitchen (192.168.21.233) — flash new amd64 binary first, then adopt
  5. UniFi + UniFi Protect
  6. Google Calendar (pigeonfallsrn at gmail)
  7. Nest (pigeonfallsrn at gmail)
  8. Spotify, Plex, Roku x2, Yamaha AV Receiver
  9. Alexa Media Player
  10. Kumo Cloud (Mitsubishi mini-splits)
  11. Navien (water heater)
  12. TP-Link Kasa (6 smart plugs)
  13. Sonos
  14. Music Assistant
  15. Mobile app — re-register on each device (HA app)
  16. Fully Kiosk Browser (kitchen tablet)
  17. NordVPN (if policy routing needed)

---

### Phase 7: Adaptive Lighting (6 instances — UI only)

Settings -> Integrations -> Add -> Adaptive Lighting
Create in this order:
  1. living_spaces
  2. entry_room_ceiling
  3. entry_room_lamp_adaptive
  4. kitchen_table
  5. master_bedroom_wall_lamp
  6. upstairs_hallway

For each, configure:
  take_over_control: true
  detect_non_ha_changes: false
  separate_turn_on_commands: true
  autoreset_control_seconds: (per room per spec above)

Verify: All 6 enabled, circadian changes visible.

---

### Phase 8: Blueprint Library (SESSION S17)

Build in this order (each must be tested before next group uses it):
  1. Test Rohan blueprint with one known Inovelli switch
  2. Build and test FOH Scene Cycling blueprint
  3. Build and test Room Motion Lighting blueprint
  4. (BP-4 VZM30 Bathroom — build when doing Group 5)

---

### Phases 9-20: Automation Groups (1-2 sessions each)

For each group:
  A. Pull triage list from Gemini audit output
  B. Review what existed on Green (cat /homeassistant/automations/*.yaml | grep alias)
  C. Delete all groups automations on Green from MCP (cleanup)
  D. Rebuild each automation in UI on EQ14
  E. Test against real devices
  F. Apply labels + categories
  G. Commit session notes to /hac/migration/group_XX.md
  H. git push

GROUP 0 — Infrastructure (~1 session)
  Presence sensors (person.*, zone.*)
  Occupancy mode helper (input_select.occupancy_mode)
  House sleep mode
  Floors + Areas + Labels setup
  person.john_spencer tracker swap to galaxy_s26_ultra

GROUP 1 — Entry Room (~1 session)
  Motion lighting (Apollo R-PRO-1 to entry_room_ceiling AL)
  FOH scene cycling
  Hot tub mode (deep red 5% + disable motion)
  Back door night entry scene

GROUP 2 — Kitchen (~2 sessions)
  Motion lighting (Tier 1 Hue chandelier, Tier 2 inovelli above sink)
  Kitchen manual override (double-tap UP, 30 min timer)
  Scene cycling (config press)
  Apollo Kitchen commissioning (zone coords + occupancy wiring)
  Roomba automation

GROUP 3 — Living Room (~1 session)
  Lamp automations (FOH switches)
  Scene cycling
  VZM36 fan+light module
  Movie mode

GROUP 4 — Garage (~1 session)
  Arrival scene (BT HFL trigger, mode:restart, 120s recency template)
  Auto-close on departure
  North ratgdo: obstruction toggle fix post-OTA
  Alerts (door left open)

GROUP 5 — Upstairs (~1 session)
  Hallway motion + AL
  2nd floor bathroom (VZM30-SN SBM: ceiling + vanity, scene cycling)
  1st floor bathroom

GROUP 6 — Kids (~1 session)
  Alaina + Ella bedtime routines
  School morning automations
  at_mom_s presence (rebuild after entity registry migration)
  LED strip controls

GROUP 7 — Climate (~1 session)
  Nest thermostats (2x)
  Kumo Cloud / Mitsubishi mini-splits
  Humidity smart alerts (fix the unpause bug here)

GROUP 8 — Security & Cameras (~1 session)
  UniFi Protect person detection automations
  Door/window binary sensors
  Notification routing for camera events

GROUP 9 — AV & Media (~1 session)
  Yamaha AV Receiver scenes
  Roku x2 automations
  Plex/Music Assistant
  Basement media setup

GROUP 10 — Notifications (~1 session)
  Consolidate ALL notify.* automations
  Standardize: mobile_app_galaxy_s26_ultra as primary
  Garage door left open, doorbell, arrival

GROUP 11 — Utilities & HAC (~1 session)
  HAC daily export automation
  Google Sheets sync
  Backup schedule verification
  Uptime monitoring

---

### Phase 21: Dashboard Rebuild (after all groups stable)

Copy from NAS reference share dashboards subfolder.

Start with: lovelace-kitchen-tablet.yaml (most complex, reference it)
Fresh build for: all other dashboards using 2026.1 mobile-first approach

New dashboard structure:
  Home (default mobile)  summary cards, presence, quick actions
  Rooms view             per-floor area cards
  Kitchen Wall Tablet    dedicated kiosk dashboard
  Garage                 cover + sensor status
  Climate                thermostat + mini-split controls
  Security               Protect camera feeds + alerts

Green TV Dashboard:
  New minimal dashboard, full-screen kiosk on Greens HDMI output
  Chromium kiosk URL: ha.myhomehub13.xyz/tv-dashboard

---

### Phase 22: MariaDB on NAS (after 1 week stable)

DSM Package Center -> install MariaDB 10
Create: database homeassistant, user ha_db, strong password (NordPass)

configuration.yaml:
  recorder:
    db_url: mysql url with ha_db user and password to NAS host homeassistant DB
    purge_keep_days: 30
    exclude:
      domains: [media_player, update]

Verify: History loads, recorder.purge works, DB growing on NAS.

---

## 8. SESSION STARTER CHECKLIST

For every session working on EQ14:
  - hac mcp  (paste session context)
  - ha core check (ignore KeyError — known 2026.4 bug)
  - df -h (confirm disk headroom)
  - git status (confirm clean working tree)
  - hac backup before any file edits

For every session close:
  - ha core check (no new errors)
  - git add -A and git commit -m "type: S## — description"
  - ha_call_service shell_command git_push (via MCP)
  - Update HANDOFF.md with session summary
  - Note any new CRITICAL_RULES learnings

---

## 9. CREDENTIALS & QUICK REFERENCE

SSH Green:  ssh hassio@192.168.1.3 -p 2222
SSH EQ14:   ssh hassio@192.168.1.10 -p 2222 (after migration)
NAS:        192.168.1.52 / share: Backups / user: HA_Synology (NordPass)
NAS DSM:    192.168.1.52:5001 / user: admin (NordPass)
HA External: ha.myhomehub13.xyz
Git repo:   pigeonfallsrn/homeassistant-config (PAT in git remote URL)
Hue Bridge: Press button 3 seconds to re-pair

DHCP Reservations needed in UniFi:
  EQ14: [MAC after HAOS install] -> 192.168.1.10
  Green: [existing] -> 192.168.1.3 (keep, disable after migration)
  NAS: [existing] -> 192.168.1.52

---

## 10. KNOWN ISSUES & WATCH LIST

Green system (do not fix, will not migrate):
  - sensor.navien_water_flow: unavailable (Navien integration offline)
  - ha core check KeyError: known HA 2026.4 bug, ignore
  - Ghost automations (22 unavailable): s11_ghost_registry_cleanup.py handles on EQ14
  - humidity_smart_alerts: unpause bug -> fix in Group 7
  - North ratgdo: Status obstruction must be toggled OFF after any OTA flash
  - Apollo Kitchen (192.168.21.233): OTA flash pending (move to stronger AP first)

EQ14 system (new):
  - person.john_spencer: swap to galaxy_s26_ultra in Group 0
  - Michelle new iPhone MAC 6a:9a:25:dd:82:f1: add to presence in Group 0
  - AP MACs: 1st Floor 1c:0b:8b:76:fa:65 / Garage 1c:0b:8b:76:fc:ae

---

## 11. BACKLOG (items deferred from previous sessions)

S12/1: Vanity slow fade — LOCAL_RAMP_RATE VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 -> Group 5
S12/2: humidity_smart_alerts unpause bug -> Group 7
S12/3: FoH switch automations (need button 1-4 spec from John) -> Group 1-3
S12/4: Gemini bulk audit -> Pre-Migration Step A
S12/5: Apollo Kitchen zone config + occupancy wiring -> Group 2

FUTURE/OPTIONAL:
  - Ratoka blueprint for smooth continuous dimming
  - HA Calendar entity naming standardization
  - AdGuard Home on NAS (local DNS + ad-blocking)
  - Uptime Kuma on NAS (service monitoring)
  - Voice (Assist + Piper/Whisper) — N150 has enough CPU for local TTS/STT
  - Energy monitoring dashboard (Protect + smart plugs)

---

## ARCHIVAL NOTE (S58, 2026-04-27)

This document was originally the full migration plan, kept in the Claude project Files slot to load every conversation turn. As of S58, with migration largely complete (S58 is 46 sessions past authoring), the document is being archived to git only. The Claude project Files slot is being cleared to reduce per-turn token cost.

For active session state, see HANDOFF.md.
For accumulated learnings, see LEARNINGS.md.
For project rules and protocols, see Claude Project Instructions.

This file remains in git as historical record of the original migration plan.
