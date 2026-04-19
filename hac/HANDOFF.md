# HANDOFF.md — Session S43
## Last updated: 2026-04-18 23:30 CDT
## Last session: S43 — YAML Automation Migration Complete + Entry Room Cleanup

## What Happened in S43

### YAML Automation Migration (MILESTONE)
- Audited all 17 YAML automations across 6 files against UI storage
- Found 7 already had UI replacements (double-firing on same Inovelli events!)
- Created 10 new UI automations via MCP for those without replacements
- Deleted all 6 YAML files: 1st_floor_bathroom_inovelli, 2nd_floor_bathroom_inovelli, alaina_wake_echo_alarm, exterior_lights_auto_off, kitchen_inovelli, living_room_av
- Removed `automation manual: !include_dir_merge_list automations/` from configuration.yaml
- Removed empty automations/ directory
- Purged 17 ghost entity registry entries (old YAML unique_ids squatting clean names)
- Renamed 10 `_2` suffixed entities to clean names
- **Result: 0 YAML automations remain. All automations 100% UI-managed.**

### Entry Room Ceiling Motion Lighting
- Investigated disabled automation — well-built but redundant with Lamp Motion Control
- Both triggered on same motion sensor but controlled different lights (ceiling vs lamp)
- John decided: DELETE — ceiling is switch-only, lamp handles motion
- Deleted, now at 77 automations

### Companion App Registrations
- Ella signed into HA companion app → device_tracker.ella_s_iphone (person.ella_spencer already existed)
- Alaina signed into HA companion app tonight → device tracker pending verification
- Only Michelle remains without companion app (MAC: 6a:9a:25:dd:82:f1)

### Kitchen Govee Floor Lamp
- Identified as light.kitchen_floor_lamp, MAC 98:88:e0:f2:32:48, IP 192.168.10.201
- NOT referenced in any automations/scripts/helpers — safe to reassign
- John plans to move to Master Bedroom physically, then we rename entity + area

## Duplicate Resolution Detail (for reference)
These 7 YAML automations were firing simultaneously with UI replacements:
- Kitchen Chandelier time-based → kitchen_chandelier_inovelli_controls_hue_lights
- Kitchen Lounge dimmer time-based → kitchen_lounge_inovelli_controls_hue_ceiling
- Kitchen Table override reset → kitchen_manual_override_clear_timer_or_2x_tap_down (combined)
- Kitchen Lounge override reset → same combined automation above
- 1st Floor Bath ceiling → 1st_floor_bathroom_inovelli_controls_hue_ceiling
- 2nd Floor Bath ceiling → 2nd_floor_bathroom_inovelli_vzm30_sn_controls_hue_lights
- 2nd Floor Bath vanity → same automation above (combined)

## Current System State
- **77 automations** — all in UI storage (automations.yaml)
- **90 helpers** — all UI
- **0 YAML automation files** — automations/ dir removed, include line removed
- **14 template packages** — legitimate spine, no automations
- **0 ghosts, 0 _2 suffixes**
- **configuration.yaml** — only `automation ui:` include remains

## S43 Benchmark
| Metric | S42 | S43 | Delta |
|--------|-----|-----|-------|
| Automations | 85 (68 UI + 17 YAML) | 77 (all UI) | -8 (7 dupes + 1 deleted) |
| YAML auto files | 6 | 0 | -6 ✅ |
| Helpers | 90 | 90 | — |
| Ghosts | 0 | 0 | — |

## Technical Learnings (S43)
- `ha core reload` is NOT a valid HAOS CLI command — use `curl -s -X POST http://supervisor/core/api/services/automation/reload -H "Authorization: Bearer $SUPERVISOR_TOKEN"` for automation reload
- Entity registry stores entities without a `domain` field — must parse domain from entity_id string (entity_id.split('.')[0])
- After YAML automation deletion, HA does NOT immediately orphan-flag the old entities — they persist in registry without orphaned_timestamp. Must manually remove with ha_remove_entity
- YAML automation `id:` fields create unique_id entries that survive file deletion — always check and purge before creating UI replacements to avoid `_2` collisions
- `rmdir` on non-empty dir silently fails (expected) — good for conditional cleanup

## Discoveries & Opportunities
- 7 Inovelli switch automations were DOUBLE-FIRING (YAML + UI responding to same zha_events) — now fixed by removing YAML versions. Watch for any behavioral changes in Kitchen/Bathroom switches
- Kitchen Govee Floor Lamp (light.kitchen_floor_lamp) — reassign to Master Bedroom when physically moved
- Michelle's devices visible on "Goetting" WiFi network in UniFi — relevant for future person tracker setup
- Alaina's companion app registration needs entity verification next session
- Entity registry has 3505 entities and 265 deleted entities — potential cleanup opportunity

## Next Priorities
1. 2nd Floor Bathroom — simplify 12 automations (most complex room, apply S42 review pattern)
2. Kitchen tablet — 5/6 never fired, quick review
3. Kids bedrooms — blueprint standardization opportunity (Alaina + Ella dimmer switches)
4. Verify Alaina companion app device_tracker entity
5. Kitchen Govee lamp → Master Bedroom reassignment (when physically moved)
6. Scenes/Scripts/Dashboard audit

## Tabled (carried forward)
- Person tracker: Michelle only (MAC: 6a:9a:25:dd:82:f1, devices on Goetting WiFi)
- Jarrett & Owen: grades tracked, person entities not configured
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error
- North ratgdo: toggle obstruction OFF after OTA
- Apollo Kitchen 192.168.21.233: OTA pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66
- humidity_smart_alerts: UI rebuild pending
- Aqara sensor gap: 6 door + 4 P1 motion
- 2 unnamed Aqara Temp/Humidity sensors
- first_floor_hallway_motion delay_off bug
- 6 Ella bedroom scenes missing
- HA Green full config audit before wipe
- Security session: Cloudflare ZT + PAT rotation
- 6 repair issues: http://192.168.1.10:8123/config/repairs
