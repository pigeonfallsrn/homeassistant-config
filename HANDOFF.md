# HANDOFF — Session S55

## Last Session: S55 (2026-04-22)
## Last Commit: (pending)
## Baseline: 77 automations, 93 helpers, 0 ghosts, 115 scenes

---

## WHAT HAPPENED IN S55 (MEGA SESSION)

### Phase B — Hue Bridge Scene/Zone Cleanup
- Created MB Ceiling zone (2 candle bulbs) + 3 scenes
- Added Relax+Nightlight to Alaina's + Ella's Ceiling zones
- Deleted 19 stale scenes from S54 leftovers
- Scene count: 101 → 89 (mid-session, grew to 115 after audit)

### Phase C — HA Automation Updates
- 4 dead entity refs fixed (Alaina dimmer, MB tap dial, FD Inovelli, FD motion)
- FD motion rebuilt: Hue sensor + UniFi person/vehicle → Energize, auto-off
- Back Patio motion created (new Hue outdoor sensor)
- Outdoor sunset schedule: sunset→Relax, 11pm→Nightlight, sunrise→Off
- Entry Room tap dial automation deleted (tap dial moved to Living Room)

### FOH Switch Infrastructure (new capability)
- 2 new FOH click switches configured (MB + VFD)
- LR Hue Switch repurposed from broken lamp cycling → VZM36 fan+light
- Hybrid architecture: bridge-direct for Hue, HA for ZHA/non-Hue

**Current FOH/Switch Config:**

| Switch | Bridge Behavior | HA Automation | What It Controls |
|--------|----------------|---------------|-----------------|
| LR Lounge FOH | 4 buttons | None | LR Lounge zone + LR room (all Hue) |
| LR Hue Switch | None | 4 buttons | VZM36 fan+ceiling (ZHA), B4 long=all LR off |
| LR Tap Dial | 4 buttons (FOHSWITCH) | Rotary+TV strip | Hue lamps (bridge) + Kasa strip + dimming (HA) |
| MB FOH | 2 buttons (right) | 3 triggers (left+B4 long) | MB Ceiling (bridge) + fan (HA) + whole-home-off |
| VFD FOH | 2 buttons (right) | None | VFD exterior (bridge-only) |

**Bridge behaviors: 5 total** (LR Lounge, LR Tap Dial, MB FOH, VFD FOH + FD zone recreated)

### Hue Outdoor Motion Sensors (2 new)
- Front Driveway + Back Patio, renamed, area-assigned

### LR Tap Dial — Scene-Based Room Control
- B1=Relax (all 4 lamps), B2=Table Relax, B3=Floor Nightlight, B4=All off
- Rotary=dim all lamps via HA (bridge FOHSWITCH model lacks rotary)
- TV backlight (Kasa strip) follows buttons at warm 2700K
- Hue scenes → bridge-direct (snappy), TV strip+rotary → HA companion

### Full Hue Ecosystem Audit
**Device renames (7):** Generic names → proper naming convention
**Room rename:** Very Front Door Hallway → Front Hallway
**Room reassignments:** Tap dial→LR, FOH1→MB, FOH2→VFD
**Zones created (3):** Front Hallway, Garage Ceiling, All Exterior
**Zones deleted (3):** Garage & Front Driveway, Alaina's Bedside Lamp, Front Driveway (recreated)
**Scenes created (22+):** Standardized Energize/Relax/Nightlight across new zones
**LR Lounge ceiling names:** "LR Lounge Ceiling N of 3" kept — Hue 32-char limit blocks longer names

### MB Tap Dial Updates
- B2: dead ref Read → Energize
- B4: added long_release → All Off (lights + fan)

---

## NEEDS VERIFICATION

1. MB FOH: B1 fan cycle, B3 ceiling Energize, B4 long whole-home-off
2. VFD FOH: B3 exterior Energize, B4 off
3. LR FOH: B1 fan cycle, B3 ceiling on, B4 long all-LR-off
4. LR Tap Dial: B1-B4 scenes, rotary dimming, TV strip follows
5. Outdoor motion sensors: walk test FD vs BP
6. Sunset schedule: fires at next sunset
7. Front Hallway: verify 3 bulbs respond to room scenes

## CARRIED FORWARD

- Ella companion app rename (sensor.iphone_40_* → sensor.ella_s_*)
- Garage opener Hue bulbs showing unreachable (power circuit)
- Kitchen tablet enhancements (Calendar Card Pro, doorbell camera, etc.)
- Orphaned LR scene index helpers (3): delete next session
- VFD FOH left side: unassigned
- Back Patio: new lamp being installed (add to bridge when ready)
- HA entity cleanup: rename new Hue entities from bridge renames
- LR Tap Dial rotary: slight latency (HA-routed, bridge FOHSWITCH workaround)

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
| Scenes (Hue) | 101 | 115 |
| Dead refs fixed | — | 4 |
| Hue zones | 14 | 14 (3 created, 3 deleted) |
| FOH/switches configured | 1 | 5 |
| Bridge behaviors | 1 | 5 |
| Outdoor automations | 0 | 3 |
| Motion sensors | 0 | 2 |
| Devices renamed (bridge) | — | 7 |
| Rooms renamed | — | 1 |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
