# HANDOFF.md — Session S43
## Last updated: 2026-04-18
## Last session: S43 — YAML Automation Migration (17 YAML → UI, include line removed)

## What Happened in S43
- Migrated all 17 YAML automations from 6 files to UI storage
- Audited each YAML automation against existing UI automations: found 7 already had UI replacements (duplicate-firing), 10 needed creation
- Created 10 new UI automations via MCP
- Deleted all 6 YAML files from automations/ directory
- Removed `automation manual: !include_dir_merge_list automations/` from configuration.yaml line 51
- Removed empty automations/ directory
- Purged 17 ghost entity registry entries from old YAML unique_ids
- Renamed 10 `_2` suffixed entities to clean names
- **Result: 78 UI automations, 0 YAML automations, 0 ghosts, 0 `_2` suffixes**
- **All automations are now 100% UI-managed** — milestone achieved

## Duplicate Resolution Detail
These 7 YAML automations were firing simultaneously with their UI replacements (same Inovelli switch events):
- Kitchen Chandelier time-based → replaced by kitchen_chandelier_inovelli_controls_hue_lights
- Kitchen Lounge dimmer time-based → replaced by kitchen_lounge_inovelli_controls_hue_ceiling
- Kitchen Table override reset → replaced by kitchen_manual_override_clear_timer_or_2x_tap_down (combined)
- Kitchen Lounge override reset → replaced by same combined automation above
- 1st Floor Bath ceiling → replaced by 1st_floor_bathroom_inovelli_controls_hue_ceiling
- 2nd Floor Bath ceiling → replaced by 2nd_floor_bathroom_inovelli_vzm30_sn_controls_hue_lights
- 2nd Floor Bath vanity → replaced by same automation above (combined)

## Current System State
- **78 automations** — all in UI storage (automations.yaml)
- **90 helpers** — all UI
- **0 YAML automation files** — automations/ dir removed
- **14 template packages** — legitimate spine, no automations
- **0 ghosts**
- **configuration.yaml** — only `automation ui:` include remains

## S43 Benchmark
- Automations: 78 (was 85 = 68 UI + 17 YAML; net -7 from removing duplicates)
- Helpers: 90
- Ghosts: 0
- Tag: pending (commit this session)

## Next Priorities
1. Review Entry Room — Ceiling Motion Lighting (disabled, reason unknown) — re-enable or delete
2. 2nd Floor Bathroom — simplify 12 automations (most complex room, apply S42 review pattern)
3. Kitchen tablet — 5/6 never fired, quick review
4. Kids bedrooms — blueprint standardization opportunity (Alaina + Ella dimmer switches)
5. Scenes/Scripts/Dashboard audit

## Tabled (carried forward)
- Person trackers: Ella (unknown), Michelle (MAC: 6a:9a:25:dd:82:f1)
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
