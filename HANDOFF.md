# HANDOFF — Session S47

## Last Session: S47 (2026-04-20)
## Last Commit: pending
## Baseline: 76 automations, 88 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S47

### VZM36 Fan/Light Module — Full Configuration (all 4 modules)

#### IEEE-to-Room Mapping (confirmed via physical fan toggle test)
- IEEE f2:dd:b8 → Upstairs Hallway (device_id acf23a59...)
- IEEE aa:1b:4d → Master Bedroom (device_id f565fb47...)
- IEEE f2:87:02 → Living Room (device_id 78023f89...)
- IEEE 41:e7:46 → Kitchen Lounge (device_id 608cdc81...)

#### Wire Swap (physical)
- Both upstairs hallway and master bedroom had blue (EP1/light) and red (EP2/fan) load wires reversed at canopy module
- John swapped wires at both canopy modules — EP1 now correctly drives lights, EP2 drives fan motors

#### Entity ID Swap (master bedroom ↔ upstairs hallway)
- Original entity IDs were swapped vs physical location
- Performed 3-round rename via temp entities to swap all 6 main entities:
  - fan.upstairs_hallway_fan, light.upstairs_hallway_ceiling, light.upstairs_hallway_fan_light
  - fan.master_bedroom_fan, light.master_bedroom_ceiling, light.master_bedroom_fan_light
- Set clean friendly names on all 6
- Device names and area assignments corrected on both devices
- ~16 diagnostic entities per device still have old prefixes (cosmetic backlog)

#### Smart Bulb Mode
- Upstairs Hallway (f2:dd:b8): P52=1, P258=1 (Smart Bulb ON, On/Off switch mode) — Hue bulbs
- Kitchen Lounge (41:e7:46): Smart Bulb ON via switch entity — Hue bulbs
- Master Bedroom (aa:1b:4d): P52=0, P258=0 (Smart Bulb OFF, Dimmer mode) — dumb bulbs for now
- Living Room (f2:87:02): unchanged (dimmer mode)

#### Standardized Settings (all 4 modules, both EPs)
- On/Off transition time: 0 (instant, was 10-25 causing hum)
- Power-on behavior: PreviousValue (was Toggle/On causing blast-on at breaker restore)
  - Exception: Kitchen Lounge was already Off, left as-is

#### Test Dashboard
- Created vzm36-test dashboard (storage-mode, sidebar visible)
- URL: http://192.168.1.10:8123/vzm36-test/0
- All 4 modules with fan speed, light on/off or dimmer, EP2 controls
- Smart Bulb Mode lights show on/off only (no dimmer slider)
- Settings section with Smart Bulb toggle for kitchen lounge

### HANDOFF.md Sync Issue
- HANDOFF.md on disk was stale (S44) when S47 started
- S45 and S46 heredocs were not pasted — last commit was 96881f5 (S46) but HANDOFF.md still showed S44
- This HANDOFF.md now reflects current state as of S47

---

## TABLED / REMAINING WORK

### S48 Priority:
1. MASTER BEDROOM HUE BULBS — John getting bulbs Wed/Thu. Set P52=1 + P258=1 on IEEE aa:1b:4d when installed
2. LIVING ROOM — confirm Hue vs dumb bulbs, set Smart Bulb Mode if Hue
3. VZM36 DIAGNOSTIC ENTITY RENAME — ~16 entities per device still have swapped prefixes (cosmetic)
4. NEXT AREA GROUP REVIEW — pick next area (living room or master bedroom)

### Kitchen Tablet Enhancements (tabled):
- Calendar Card Pro (HACS) for per-calendar colors/emojis
- Master Calendar parsing (grade-specific events only)
- Doorbell camera view + fully_kiosk.load_url
- Away/home screen control (blocked by house_occupied template fix)
- FKB screensaver (family photos / ambient clock)
- Battery management automation (20-80% charge cycle)

### Blocked:
- binary_sensor.house_occupied — unavailable (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative — unavailable
- Music Assistant — setup_error state
- Michelle person tracker (MAC: 6a:9a:25:dd:82:f1)

### Ongoing:
- Security hardening session (~30 min)
- AndroidTV at 192.168.1.17 — real ADB device, DO NOT DELETE
- NordPass cleanup backlog
- Discovered integrations: Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast
- Orphaned helpers: input_boolean.kitchen_tablet_doorbell_popup, input_boolean.kitchen_tablet_screen_control
- Ella companion app: device renamed but 20 entity_ids still iphone_40_* (cosmetic)
- Ratgdo north obstruction sensor stuck ON — needs physical toggle
- Governance review due S50

---

## VZM36 REFERENCE TABLE

| Room | IEEE | Smart Bulb | Bulb Type | Fan Entity | Light Entity |
|------|------|-----------|-----------|------------|-------------|
| Upstairs Hallway | f2:dd:b8 | ON | Hue | fan.upstairs_hallway_fan | light.upstairs_hallway_ceiling |
| Master Bedroom | aa:1b:4d | OFF (pending Hue) | Dumb | fan.master_bedroom_fan | light.master_bedroom_ceiling |
| Living Room | f2:87:02 | OFF | TBD | fan.living_room_light_and_fan_inovelli_module_fan | light.living_room_light_and_fan_inovelli_module_light |
| Kitchen Lounge | 41:e7:46 | ON | Hue | fan.kitchen_lounge_light_fan_inovelli_vzm36_fan | light.kitchen_lounge_light_fan_inovelli_vzm36_light |

All modules: firmware 0x04010102, on/off transition=0, power-on=PreviousValue

---

## BENCHMARK

| Metric | S46 | S47 |
|--------|-----|-----|
| Automations | 76 | 76 |
| Helpers | 88 | 88 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 1 | 1 |
| Calendars | 19 | 19 |
| Tablet dashboards | 1 | 1 |
| Test dashboards | 0 | 1 (vzm36-test) |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- VZM36 test dashboard: http://192.168.1.10:8123/vzm36-test/0
- Kitchen tablet device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Kitchen tablet FKB Remote Admin: http://192.168.21.50:2323
