# HANDOFF — Session S55

## Last Session: S55 (2026-04-22)
## Last Commit: (pending)
## Baseline: 77 automations, 93 helpers, 0 ghosts, 89 scenes

---

## WHAT HAPPENED IN S55

### Phase B — Hue Bridge API Work (all via terminal CLIP v2)
- Created Master Bedroom Ceiling zone (2 candle bulbs) + Energize/Relax/Nightlight scenes
- Added Relax + Nightlight to Alaina's + Ella's Ceiling Lights zones
- Deleted 19 stale scenes from zones/rooms missed in S54 cleanup
- Scene count: 101 → 89

### Phase C — HA Automation Updates
- Alaina dimmer B3: dead ref → Malibu pink
- MB tap dial B2: dead ref → Energize, added B4 long=All Off
- Front Driveway Inovelli: dead ref sleepy → nighttime
- Duplicate FD motion automation deleted + auto-off merged into main
- Front Driveway motion rebuilt: Hue sensor + UniFi person/vehicle → Energize scene, auto-off
- Back Patio motion created: Hue sensor → Energize, same pattern
- Outdoor sunset schedule created: sunset→Relax, 11pm→Nightlight, sunrise→Off

### FOH Switch Infrastructure (major new capability)
- 2 Hue outdoor motion sensors: renamed, area-assigned, key entities renamed
- Living Room Hue Switch: repurposed from broken lamp scene cycling → VZM36 fan+light control
- 2 new FOH click switches added, configured hybrid bridge+HA:

**Master Bedroom FOH Switch (Switch 1):**
  - B1 left up: Fan cycle low→med→high (HA) | Long: fan high
  - B2 left down: Fan off (HA)
  - B3 right up: MB Ceiling Energize (bridge-direct)
  - B4 right down short: MB Ceiling off (bridge) | Long: whole home off (HA)

**Very Front Door FOH Switch (Switch 2):**
  - B3 right up: VFD Energize (bridge-direct)
  - B4 right down: VFD off (bridge-direct)
  - Left side: unassigned (John may use single rocker instead)

**Living Room FOH (repurposed):**
  - B1 left up: Fan cycle low→med→high (HA) | Long: fan high
  - B2 left down: Fan off (HA)
  - B3 right up: Ceiling light on (HA) | Long: 50% brightness
  - B4 right down: Ceiling light off (HA)

### Hybrid FOH Architecture (new pattern)
- Bridge-direct for Hue lights (fast, works when HA down)
- HA automation for non-Hue devices (fans, ZHA) and cross-system actions (whole home off)
- Bridge behaviors created via CLIP v2 API POST /behavior_instance
- No dual-fire: bridge handles short_release, HA handles long_release where needed

### Bridge Behaviors Inventory (4 total)
1. Living Room Lounge Hue Switch (existing, kept)
2. Master Bedroom FOH Switch (new, right side only)
3. Very Front Door FOH Switch (new, right side only)
4. (Living Room Hue Switch — no bridge behavior, HA-only for VZM36)

### Orphaned Helpers (from LR scene cycling repurpose)
- input_number.lr_hue_all_lamps_scene_index
- input_number.lr_hue_table_lamps_scene_index
- input_number.lr_hue_floor_lamps_scene_index
- Action: delete in next cleanup session

---

## NEEDS VERIFICATION

1. MB FOH: press B1 to cycle fan speeds, B3 for ceiling Energize, B4 long for whole-home-off
2. VFD FOH: press B3 for exterior Energize, B4 for off
3. LR FOH: press B1 to cycle fan, B3 for ceiling light
4. Walk past outdoor motion sensors to confirm FD vs BP assignment
5. Sunset schedule fires at next sunset

---

## CARRIED FORWARD

- Ella companion app rename (sensor.iphone_40_* → sensor.ella_s_*)
- VF Door Hallway: 2nd A19 needs pairing to bridge
- Garage opener Hue bulbs showing unreachable (power circuit)
- Kitchen tablet enhancements (Calendar Card Pro, doorbell camera, etc.)
- LR Floor Lamps zone: only Nightlight left — add Energize/Relax
- Orphaned LR scene index helpers: delete next session
- VFD FOH left side: unassigned (decide rocker vs FOH)

## BLOCKED

- binary_sensor.house_occupied (unavailable, template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

---

## BENCHMARK

| Metric | S54 | S55 |
|--------|-----|-----|
| Automations | 76 | 77 |
| Helpers | 93 | 93 |
| Ghosts | 0 | 0 |
| Scenes (Hue) | 101 | 89 |
| Dead refs fixed | — | 4 |
| Hue zones created | — | 1 (MB Ceiling) |
| FOH switches configured | 1 | 4 (LR Lounge, LR, MB, VFD) |
| Bridge behaviors | 1 | 4 |
| Outdoor automations | 0 | 3 (FD motion, BP motion, sunset) |
| Motion sensors added | 0 | 2 (FD + BP Hue outdoor) |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
