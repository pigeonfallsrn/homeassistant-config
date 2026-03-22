# CRITICAL RULES - READ FIRST
*Hard-won lessons from 2000+ lines of learnings. Don't repeat them.*

## ⚠️ BEFORE ANY EDIT
```
hac backup <filename>   # NON-NEGOTIABLE
```

## TERMINAL (ZSH)
- **Git errors** (`confused by unstable object`): Run `git gc --prune=now` twice (HA Green/SD card limitation)
- **Escape `!`** or use single quotes: `echo 'Hello!'` not `echo "Hello!"`
- **Never chain after `python3 -c`** on same line
- **BusyBox grep** (HA Green): NO `--include`, NO long options. Use `-rEl` for recursive+extended+filenames. Never `--include=*.yaml` — use `grep -rEl 'pattern' /path/` instead
- **BusyBox sed** (HA Green): NO multi-line, NO complex scripts. Use `python3` heredoc for non-trivial file edits
- **Paths**: `/homeassistant/` (not `/config/`)

## MOTION AUTOMATIONS (Times Hit: 15+)
- **Always `mode: restart`** for motion-triggered lights
- **Combined sensors need `delay_off`**: 60s minimum to prevent double-fires
- **Use combined binary_sensor**, not OR-ing individual sensors (race condition)
- **Dual trigger pattern**: motion ON starts, motion OFF with wait turns off
- **Timeout by room type**: transition 5-10min, active 8-20min, relaxation 15-45min
- **Double-fire fix**: Check for orphan automation entities with same unique_id

## INOVELLI SWITCHES (Times Hit: 15+)
- **Smart Bulb Mode**: Param 52=1 + LED bar params 95-98 for Hue bulbs
- **Config button cycling**: Use input_number + modulo, not input_select
- **Parameters require toggle OFF→ON** in ZHA UI then air gap to write
- **fxlt blueprint fires ALL zha_events** - filter by device_id or use unified blueprint
- **VZM35-SN fans**: Param 12 (auto-off) = 2700s for hardware safety backup

## ADAPTIVE LIGHTING (Times Hit: 10+)
- **Create/delete via UI ONLY** - no API exists
- **Hue bulbs require ALL THREE**:
  - `separate_turn_on_commands: true`
  - `take_over_control: true`
  - `detect_non_ha_changes: false`
- **Same make/model bulbs** per AL instance
- **Sleep mode**: 1-5%, 2200K, 10pm-6am for bedrooms
- **Current instances**: living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway

## ENTITY NAMING
- **ZHA gives generic entity_ids** (e.g., `inovelli_vzm35_sn_fan`)
- **Rename via `ha_rename_entity`** to location-based IDs
- **Device names are separate** from entity IDs

## MATTER/AQARA (Times Hit: 5+)
- **Recommission fix**: Remove stale fabric from BOTH HA Matter AND Aqara app
- **Use BOTH Matter + HomeKit** integrations (different devices exposed)
- **M3 IR blaster**: Does NOT expose to HA
- **Locks**: Matter only. Some sensors: HomeKit only.

## DOUBLE-FIRE PREVENTION CHECKLIST
1. Motion aggregation sensors have `delay_off`? (60s/60s/90s)
2. Using combined sensor, not individual sensors?
3. Check `hac health` for orphan automations with duplicate unique_ids?
4. Check for automations disabled in UI but still registered?

## NEVER EDIT DIRECTLY
- `.storage/core.config_entries`
- `.storage/core.entity_registry`
- `.storage/core.device_registry`
- Any `.storage/*.json`

## UI-ONLY (No API/CLI)
Adaptive Lighting, ZHA pairing, Hue linking, Matter commissioning

## SAFE VIA API
Automations, Scripts, Helpers, Services, Entity settings, Dashboards

## Storage-Mode Dashboard Backup (NON-NEGOTIABLE)
Before ANY kitchen-wall-v2 edit:
  cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
hac backup does NOT work for storage-mode dashboards. Never attempt it.

## Dashboard Transform Rules (hard-won)
- ALWAYS force_reload:True before any transform to get current hash
- NEVER do piecemeal index-based transforms across multiple calls — indices shift silently
- For section[0] edits: do ONE comprehensive rebuild, not multiple surgical edits
- After ANY transform: reload tablet + verify before next edit
- python_transform list comprehension on root cards[] can silently wipe sections — always use direct index ops

## Sections View Gutter — CONFIRMED FIX (2026-03-19)
WORKING: card-mod-view-yaml in kitchen_wall theme. Confirmed by user 2026-03-19.

/homeassistant/themes/kitchen_wall.yaml MUST contain exactly:
  ha-view-sections-column-max-width: 2000px
  ha-view-sections-column-min-width: 300px
  ha-view-sections-column-gap: 8px
  card-mod-view-yaml: |
    hui-sections-view:
      $: |
        :host {
          --ha-view-sections-column-max-width: 2000px !important;
        }

WHY: card-mod-view-yaml runs AFTER component init, sets CSS var at shadow DOM
host level before HA sections view applies its default. card-mod-root-yaml runs
too early and loses. CSS resource files lose specificity race. FKB customCSS
cannot pierce shadow DOM.

After theme change: frontend.reload_themes + clear cache + reload tablet.
DO NOT change this. DO NOT use any other approach.


## Bubble Card Popup — Music Button Root Cause (FKB 1.60.1 confirmed)
FKB 1.60.1 supports hash navigation — version is NOT the issue.
All failed approaches: navigate tap_action, hash on section button,
browser_mod fire-dom-event, root-level hidden trigger button + navigate.
NEXT HYPOTHESIS TO TEST: kiosk_mode non_admin_settings:kiosk:true intercepts
hash navigation before Bubble Card sees it.
TEST: temporarily set kiosk_mode:{} in dashboard, reload, test popup, then restore.

## atomic-calendar-revive — Confirmed Working Settings (wall tablet)
compactMode: false  ← NEVER use true, collapses card height
maxDaysToShow: 3-5, maxEventCount: 12-15
dateSize: 200+, titleSize: 190+, timeSize: 160+
column_span:1 on BOTH sections + max_columns:2 = correct 50/50 split
dense_section_placement: false  ← true fights column_span, causes regression

## Dashboard Session Start Protocol (NON-NEGOTIABLE)
1. cp .storage/lovelace.kitchen_wall_v2 hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
2. Read hac/BACKLOG_kitchen_dashboard.md — work from top of blocking items
3. ha_config_get_dashboard force_reload:True — capture current hash before ANY edit
4. Single comprehensive transform — never piecemeal
5. Reload + verify on tablet after EVERY transform before proceeding
6. Commit + log learnings before ending session

## FKB Auto-Update — DISABLE THIS
FKB auto-updates cause random browser restarts and dashboard stuck-on-logo issues.
Disable: FKB Settings > General Settings > Auto-Update Fully Kiosk Browser = OFF
Control updates manually during maintenance windows only.

## FKB Configuration via HA Service (PREFERRED METHOD)
Use fully_kiosk.set_config — works cross-VLAN, no port 2323 needed.
device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b

Key config keys:
  autoUpdateApp: false        # DISABLE — prevents random restarts
  customCSS: "css string"     # Inject CSS directly into FKB browser

FKB port 2323 blocked: tablet on IoT VLAN 192.168.21.x, PC on 192.168.1.x
UniFi firewall blocks LAN->IoT inbound. HA has cross-VLAN access already.

---

## ADAPTIVE LIGHTING — COLOR BEHAVIOR (Promoted 2026-03-22)
Times Hit: 10+

### Late-Night Red/Orange Lights
- **Root cause**: AL `living_spaces` pushes full circadian color to Hue color bulbs. At ~22:00 CST color reaches hue 10° / rgb(255,43,0) — deep red. This is correct AL behavior, not a scene bleed.
- **hot_tub_mode is NOT the cause** — always verify `input_boolean.hot_tub_mode` state before assuming scene bleed.
- **Manual override**: tap Hue switch or `light.turn_on` with explicit `color_temp_kelvin`. Holds until next on/off cycle (take_over_control:true).
- **Pending fixes**: (1) raise `min_color_temp_kelvin` floor on living_spaces AL instance; (2) disable adapt_color after time threshold via automation.

### hot_tub_mode Color Restore Gap
- Off automations (`auto_reset_at_3am`, `auto_off_when_back_inside`) do NOT explicitly restore light color.
- AL only corrects on next on/off cycle — lights can stay colored until then.
- **Fix needed**: add `adaptive_lighting.apply_to_lights` or explicit `light.turn_on color_temp_kelvin` in hot tub mode off actions.

---

## LIGHTING HYGIENE (Promoted 2026-03-22)

### Mode State Visibility Gap
- No dashboard indicator for active AL color mode or when special modes last ran.
- Backlog: Mushroom chips row on kitchen tablet — hot_tub_mode, sleep_mode, away state.

### Motion Lamp Automations — No Time Gate
- `automation.living_room_lamps_adaptive_control` fires on `binary_sensor.downstairs_motion` with no time-of-night condition.
- Color at turn-on = AL circadian value for that hour. Expected but can be surprising late at night.

### Unavailable Light Entities (audit 2026-03-22 — investigate)
- `light.upstairs_hallway_ceiling_1of3`, `2of3`, `3of3`
- `light.very_front_door_ceiling_hallway`
- `light.garage_opener_north_east`, `garage_opener_south_east`, `garage_opener_south_west`
- `light.upstairs_hallway_east_wall_night_light`

### Entity Naming Mismatches (audit 2026-03-22 — cleanup needed)
- `light.kitchen_west_wall_nightlight` friendly name → "Basement_Third Reality_Nightlight"
- `light.kitchen_counter_night_light` friendly name → "Stairwell_Night_Light"
