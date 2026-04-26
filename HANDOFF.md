# HA Migration HANDOFF — S56
**Date:** 2026-04-25
**Last commit:** (this session) | Previous: 5533cab (S55)

## S56 Goal
Best-practice scorecard + duplicate/orphan cleanup ("Option C" → folded into "Option B" unavailable triage).

## What S56 did
Targeted registry cleanup of 7 redundant entities + 1 duplicate config entry. Zero risk to live automations or running devices. All changes verified post-action.

| # | Action | Result |
|---|---|---|
| 1 | Disabled `update.master_bedroom_vzm36_firmware_2` (EP2 redundant) | ✅ |
| 2 | Disabled `update.kitchen_lounge_vzm36_firmware_2` (EP2 redundant) | ✅ |
| 3 | Disabled `update.living_room_vzm36_firmware_2` (EP2 redundant) | ✅ |
| 4 | Disabled `update.upstairs_hallway_vzm36_firmware_2` (EP2 redundant) | ✅ |
| 5 | Removed orphan `tts.google_translate_en_com` (stale Green→EQ14 unique_id 01KP4*) | ✅ |
| 6 | Renamed `tts.google_translate_en_com_2` → `tts.google_translate_en_com` | ✅ |
| 7 | Removed orphan `todo.shopping_list` (stale Green→EQ14 unique_id 01KP4*) | ✅ |
| 8 | Renamed `todo.shopping_list_2` → `todo.shopping_list` | ✅ |
| 9 | Deleted duplicate Met.no config entry `01K41S8Z8F74NC72SG49APACGY` (user-added) | ✅ |
| 10 | Verified single canonical `weather.forecast_home` (state: cloudy) | ✅ |

**Net registry impact:** -7 redundant entities, -1 duplicate config entry, +0 orphans, all canonical names preserved.

## S56 Benchmark
- 2785 entities (was 2792, delta -7)
- 75 automations (was 78 reported, actually 75 measured)
- 89 helpers
- 0 ghosts, 0 repairs, 0 persistent notifications
- 14 template packages (legit spine)
- 19 calendars
- 5 HACS resources
- 4 storage dashboards
- HAOS 17.2 / Core 2026.4.3 / Python 3.14.2 / Supervisor 2026.04.0
- Disk: 22.9 / 916 GB (3% used)
- Recorder: SQLite, 234 MiB, ~4 days history (Phase 22 MariaDB-on-NAS still pending)

## Best-practice scorecard
- ✅ Platform currency (HAOS 17.2, Core 2026.4.3 all current)
- ✅ Architecture (UI-first intact, 0 ghosts)
- ✅ System health (0 repairs, 0 notifications)
- ✅ Disk headroom (3% used)
- ✅ Git hygiene (clean tree)
- ⚠️ Recorder on SQLite, only 4 days history — Phase 22 MariaDB never ran
- ⚠️ ~283 unavailable entities (down from ~290) — mostly device-offline clusters, see triage below
- ⚠️ 3 empty/underpopulated areas: boiler_room (0), attic (1), workout_area (1)
- ⚠️ 3 integrations not loaded: tplink garage_receiver_HS100 (setup_retry), androidtv 192.168.1.17 (setup_retry, DO NOT DELETE), music_assistant (setup_error)

## Device-offline triage (~283 unavailable entities)
**For John to triage** — these are device-level, not registry pollution. Verify each cluster and decide keep/fix/remove.

### Cluster 1: G4 Bullet camera (~28 entities, all unavailable)
- Real device, MAC 70:a7:41:0c:53:19, located at Pigeon Falls Properties (remote site)
- Status: device offline. Likely network or power at PFP.
- **Action: Keep registry entry; fix when at PFP**

### Cluster 2: Garage opener Hue bulb entities (~24 entities)
- `garage_*_lift_master_*` numbers/selects/lights all unavailable
- Status: known power circuit issue per HANDOFF history
- **Action: Already on backlog**

### Cluster 3: Stairwell_Night_Light (~6 entities, ZHA Third Reality 3RSNL02043Z)
- Real Zigbee device, paired (LQI 162) but not responding
- **Action: Check if physically plugged in / power restored**

### Cluster 4: Living_Room_Dual_Smart_Plug (~7 entities, ZHA Third Reality 3RDP01072Z)
- No LQI/RSSI = gone from Zigbee mesh (likely unplugged or removed)
- **Action: Confirm if still in service. If retired, remove device from registry**

### Cluster 5: Kitchen_Lounge_TV_Dual_Smart_Plug (~6 entities)
- Same pattern as Cluster 4 — Zigbee plug not responding
- **Action: Confirm if still in service**

### Cluster 6: Upstairs_Hallway_East_Wall_Night_Light (~5 entities)
- ZHA device offline
- **Action: Check power / physical presence**

### Cluster 7: Yamaha RX-V671 MAIN + zone_2 (~9 entities)
- Number/select unavailable when receiver in standby (normal)
- **Action: No action — expected behavior**

### Cluster 8: Alexa Echo shuffle/repeat (~18 entities)
- All unavailable when no media playing (normal Alexa Media Player behavior)
- **Action: No action — expected behavior**

### Cluster 9: UniFi switch port_power_cycle (~30 buttons)
- Mixed unavailable/unknown for empty/unpowered ports (normal)
- **Action: No action — expected behavior**

### Cluster 10: PFP West climate (1 entity)
- Mini-split offline at remote site
- **Action: Diagnose at PFP**

### Cluster 11: Very Front Door — chime/IR/motion (~4 entities)
- Subset unavailable — likely feature-not-active states from UniFi Protect
- **Action: Verify camera config in Protect UI**

### Cluster 12: Music Assistant (setup_error) — known blocker

## Tabled (no progress this session)
- GOVEE LAMP → MASTER BEDROOM (waiting on physical move)
- ELLA COMPANION APP rename (sensor.iphone_40_* → sensor.ella_s_*)
- Phase 22: MariaDB recorder migration to NAS
- Empty area cleanup (boiler_room, attic, workout_area — merge or populate)
- house_occupied template fix
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)
- Discovered integrations to review: 2nd Floor Roomba, DS224plus, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast
- HACS Calendar Card Pro for kitchen tablet

## Recommended next priorities
1. **Phase 22 — MariaDB on NAS** (biggest long-term win, 1 session). Adds real history retention, reduces SQLite contention.
2. **Device-offline triage walk-through** with John (one cluster at a time)
3. **Continue from S55 Phase C list** — LR FOH redesign for VZM36, Master Bedroom "All Off" hold, Alaina dimmer B3 → Malibu pink, disable the 4 bridge automations
4. **Empty area cleanup** (small but satisfying — half session)

## Blocked
- binary_sensor.house_occupied (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker
