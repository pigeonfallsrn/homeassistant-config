# HANDOFF.md — Session S53
## Last updated: 2026-04-22 | Last commit: pending

## CURRENT STATE
- 76 automations (all UI) | 24 scripts | 91 helpers | 0 ghosts
- 14 template packages (legit spine) | 19 calendars
- 3 storage-mode dashboards: map, kitchen-tablet, arriving-home
- 5 HACS cards: Kiosk Mode, Mushroom, auto-entities, card-mod, mini-graph-card

## S53 COMPLETED
1. **Tablet context fix:** Removed `script.apply_tablet_context` from occupancy change automation and deleted the script. It referenced 5 non-existent dashboard URLs and used wrong target format (entity_id vs device_id for FKB). Error cascade on every occupancy change eliminated.
2. **Master Bedroom entity cleanup:**
   - Renamed `light.hue_color_candle_1` → `light.master_bedroom_ceiling_1_of_2` (area + labels)
   - Renamed `light.hue_color_candle_2` → `light.master_bedroom_ceiling_2_of_2` (area + labels)
   - Assigned area + labels to `light.master_bedroom_wall_light` and `light.master_bedroom` (Hue group)
   - Hidden `light.master_bedroom_ceiling` (ZHA SBM relay entity — not useful)
   - Assigned Tap Dial device to master_bedroom area
3. **Tap Dial automation rebuilt:** Found 100% dead entity refs (all 5 triggers referencing `event.hue_tap_dial_switch_3_*`). Rebuilt with correct entities: B1=Relax, B2=Read, B3=Nightlight, B4=Fan Toggle, Rotary=Brightness±10%. Mode=restart.
4. **VZM36 SBM confirmed correct:** EP1=ON (Hue ceiling bulbs), EP2=OFF (fan motor), EP2 light entity disabled.

## MANUAL ACTION NEEDED
- **AL update (UI only):** Add `light.master_bedroom_ceiling_1_of_2` and `light.master_bedroom_ceiling_2_of_2` to existing Master Bedroom Wall Lamp AL instance via Settings → Integrations → Adaptive Lighting.

## IMMEDIATE NEXT WORK (priority order)
1. **FOH CLICK SWITCH** — Build automation when physically installed (planned: top-left=Room ON/AL, top-right=Energize, bottom-left=All OFF, bottom-right=Nightlight)
2. **GOVEE LAMP** → Reassign `light.kitchen_floor_lamp` area when physically moved to master bedroom and plugged in
3. **ELLA COMPANION APP** — Rename device to get descriptive sensor names (sensor.iphone_40_* → sensor.ella_s_*)
4. **NEXT AREA GROUP REVIEW** — Garage, living room, or master bedroom full review

## KITCHEN TABLET ENHANCEMENTS (tabled)
- Calendar Card Pro (HACS) for per-calendar colors/emojis
- Master Calendar parsing (grade-specific events only)
- Doorbell camera view + fully_kiosk.load_url
- Away/home screen control (blocked by house_occupied template fix)
- FKB screensaver (family photos / ambient clock)
- Battery management automation (20-80% charge cycle)
- Context-specific dashboards (kitchen-guest, kitchen-away, etc.) — rebuild apply_tablet_context when dashboards exist

## BLOCKED
- binary_sensor.house_occupied (unavailable, template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

## DISCOVERED INTEGRATIONS TO REVIEW
- 2nd Floor Roomba (192.168.1.48), DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast

## VZM36 COSMETIC CLEANUP (low priority)
- 22 diagnostic entities with stale `upstairs_hallway_vzm36_*` prefix in master bedroom
- Duplicate ghost registrations at `master_bedroom_vzm36_*` (from device rename)
- Functional — SBM correct, fan works — just naming mess

## S53 BENCHMARK
76 automations | 24 scripts | 91 helpers | 0 ghosts | 14 template packages | 19 calendars | 5 HACS cards | 3 dashboards
