# HANDOFF — Session S63

## Last Session: S63 (2026-04-27)
## Last Commit: (set after this session's commit)
## Baseline: 72 automations, 51 input_booleans, 0 repairs, HA 2026.4.4

---

## WHAT HAPPENED IN S63

### Goal
Front_drivay typo rename — 43 child entities + device on ZHA Inovelli VZM30-SN (IEEE c0:9b:9e:ff:fe:d1:2d:4e, device_id 16a22c25ead6b47a6b9666c539ff2509). S45 carry-forward.

### Pre-rename scope check
- Registry: 43 entities with `front_drivay_*` slug
- YAML refs: 0 (re-confirmed S62 finding)
- Automation/script/helper/dashboard refs: 0 (`ha_deep_search` clean)
- Collision check vs existing `front_driveway_*` (109 entities, mostly doorbell/camera): no overlap
- House convention for Inovelli SBM switches: `{area}_{fixture}_inovelli_smart_bulb_mode_*` (matches 2nd_floor_bathroom_ceiling_lights_inovelli_smart_bulb_mode, 2nd_floor_bathroom_vanity_lights_inovelli_smart_bulb_mode)

### Rename map
Old prefix: `front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode`
New prefix: `front_driveway_inovelli_smart_bulb_mode`

Strategy abandoned the literal "fix the typo only" path (would have produced redundant `front_driveway_..._front_driveway_...` slugs ~90 chars). Adopted house convention instead — same effort, cleaner long-term, friendly names already carry the human-readable label.

### Execution
- 43 individual `ha_set_entity` MCP calls with `new_entity_id`
- First call also passed `new_device_name="Front Driveway Inovelli VZM30-SN (Smart Bulb Mode)"` — device renamed in same op
- All 43 succeeded, no rollbacks needed
- States preserved (e.g., Power-on level 255, Smart bulb mode `on`, On level 181)
- **No SSH script needed.** S45 promoted rule is now obsolete: MCP `ha_set_entity` wraps the websocket `config/entity_registry/update` internally.

### Verify
- `ha_search_entities("drivay")` → 0 hits ✓
- `ha_search_entities("front_driveway_inovelli_smart_bulb_mode")` → 43 hits, all healthy ✓
- Friendly names intact ✓

### Bonus cleanup (HANDOFF queue item 2)
- Removed: `packages/adaptive_lighting_entry_lamp.yaml.s62.bak`, `packages/adaptive_lighting_entry_lamp.yaml.s62.corrupted`
- Added to .gitignore: `*.bak`, `*.corrupted`

---

## NEXT SESSION (S64) — RECOMMENDED PRIORITY ORDER

1. **Google Calendar re-auth** if still showing in repairs (1-click)
2. **VZM30-SN area assignment** — renamed device's `area_id` is null. Assign to Front Driveway area for proper grouping. ~2 min.
3. **Deferred from S57**: Front Driveway + Very Front Door unification, Hue Bridge duplicate zone cleanup (All Exterior x2, Garage Ceiling x2), curated outdoor scene library
4. **HANDOFF regen test #2**: S62 close + S63 close are now two consecutive heredoc-paste tests. If S64 reads back S63 content, the read-path fix from S62 LEARNINGS holds.

---

## CARRIED FORWARD

- Ella companion app rename (sensor.iphone_40_* → sensor.ella_s_*)
- Garage opener Hue bulbs unreachable (power circuit, not software)
- Very Front Door Hallway: disconnected pending rewire + 2 new A19s
- Kitchen tablet enhancements (Calendar Card Pro, doorbell camera, screensaver, battery mgmt)
- Govee lamp area reassignment when physically moved to master bedroom
- 2nd Floor Roomba, DS224plus NAS, Roku 4620X, Tuya, Vizio SmartCast — discovered integrations to review

## BLOCKED

- binary_sensor.house_occupied (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

---

## BENCHMARK

| Metric | S62 | S63 |
|---|---|---|
| Automations | 72 | 72 |
| Input booleans | 51 | 51 |
| `drivay` entities | 43 | 0 |
| `front_driveway_inovelli_smart_bulb_mode_*` | 0 | 43 |
| Backup file pollution | 2 | 0 |
| .gitignore patterns | (n) | (n+2) |
| Repair count | 0 | 0 |
| HA version | 2026.4.4 | 2026.4.4 |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- Token in NordPass: "HA EQ14 — LLAT for export_to_sheets (john)"
