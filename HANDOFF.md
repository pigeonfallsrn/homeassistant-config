# HANDOFF — Session S47

## Last Session: S47 (2026-04-20)
## Last Commit: 3a6613c (HANDOFF/LEARNINGS), entity renames in .storage (not git-tracked)
## Baseline: 76 automations, 88 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S47

### VZM36 Fan/Light Module — Complete Configuration (all 4 modules)

#### Physical Work
- IEEE-to-room mapping confirmed via fan toggle + dashboard verification
- Blue/red wires swapped at upstairs hallway and master bedroom canopy modules (EP1↔EP2 load reversal)

#### Entity Cleanup (87 total renames)
- 6 main entities (fan/light/light_2) swapped between master bedroom ↔ upstairs hallway via 3-round temp rename (MCP)
- 44 diagnostic entities renamed for hallway+bedroom via websocket bulk script
- 43 entities renamed for living room+kitchen lounge via websocket bulk script
- All 4 modules now follow clean convention: fan.{area}_fan, light.{area}_ceiling, *.{area}_vzm36_*
- 4 EP2 light entities disabled (redundant with fan entities)
- Device names standardized: "{Area} Fan Light Combo"

#### Parameter Standardization (all 4 modules, both EPs)
- On/off transition time: 0 (instant, eliminates hum)
- Power-on behavior: PreviousValue (prevents blast-on at breaker restore)
- Smart Bulb Mode: ON for hallway + kitchen lounge (Hue), OFF for master bedroom + living room (dumb bulbs)

#### vzm36-test Dashboard
- Storage-mode, sidebar visible, url_path: vzm36-test
- All 4 modules: fan speed, light (on/off for Smart Bulb, dimmer for dumb), Smart Bulb toggles
- URL: http://192.168.1.10:8123/vzm36-test/0

#### Technical Discoveries
- REST API returns 404 for entity registry renames — must use websocket (config/entity_registry/update)
- aiohttp not available in HAOS — use pip3 install websockets --break-system-packages
- Entity registry changes (.storage/) are gitignored — persistent but not version-tracked
- ZHA cluster attribute writes: manufacturer must be integer (4655) not hex string ("0x122F")

---

## VZM36 REFERENCE TABLE

| Room | IEEE | Smart Bulb | Bulbs | Fan | Light |
|------|------|-----------|-------|-----|-------|
| Upstairs Hallway | f2:dd:b8 | ON | Hue | fan.upstairs_hallway_fan | light.upstairs_hallway_ceiling |
| Master Bedroom | aa:1b:4d | OFF | Dumb (Hue Wed/Thu) | fan.master_bedroom_fan | light.master_bedroom_ceiling |
| Living Room | f2:87:02 | OFF | Dumb LED | fan.living_room_fan | light.living_room_ceiling |
| Kitchen Lounge | 41:e7:46 | ON | Hue | fan.kitchen_lounge_fan | light.kitchen_lounge_ceiling |

All: firmware 0x04010102, transition=0, power-on=PreviousValue, EP2 lights disabled

---

## TABLED / REMAINING WORK

### S48 Priority:
1. MASTER BEDROOM HUE BULBS — Wed/Thu. Set P52=1 + P258=1 on IEEE aa:1b:4d, flip smart bulb toggle
2. LIVING ROOM — confirm bulb type, set Smart Bulb if Hue added
3. NEXT AREA GROUP REVIEW — pick next area (living room or master bedroom automations)

### Kitchen Tablet Enhancements (tabled):
- Calendar Card Pro, master calendar parsing, doorbell camera view
- Away/home screen control (blocked by house_occupied), FKB screensaver, battery management

### Blocked:
- binary_sensor.house_occupied — unavailable (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative — unavailable
- Music Assistant — setup_error
- Michelle person tracker (MAC: 6a:9a:25:dd:82:f1)

### Ongoing:
- Security hardening session (~30 min)
- AndroidTV 192.168.1.17 — DO NOT DELETE
- NordPass cleanup backlog
- Discovered integrations: Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast
- Orphaned helpers: input_boolean.kitchen_tablet_doorbell_popup, input_boolean.kitchen_tablet_screen_control
- Ella companion app: 20 entity_ids still iphone_40_* (cosmetic)
- Ratgdo north obstruction sensor stuck ON
- Governance review due S50

---

## BENCHMARK

| Metric | S46 | S47 |
|--------|-----|-----|
| Automations | 76 | 76 |
| Helpers | 88 | 88 |
| Ghosts | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 1 | 1 |
| Calendars | 19 | 19 |
| Tablet dashboards | 1 | 1 |
| Test dashboards | 0 | 1 (vzm36-test) |
| VZM36 entities renamed | 0 | 87 |
| EP2 lights disabled | 0 | 4 |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- VZM36 dashboard: http://192.168.1.10:8123/vzm36-test/0
- Kitchen tablet: device_id 86870b5d8b01f345f5d5dd9c2ac06d2b, FKB http://192.168.21.50:2323
