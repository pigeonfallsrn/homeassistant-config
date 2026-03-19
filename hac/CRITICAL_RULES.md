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
WORKING FIX: card-mod-view-yaml in kitchen_wall theme targeting hui-sections-view host.

Theme file /homeassistant/themes/kitchen_wall.yaml must contain:
  ha-view-sections-column-max-width: 2000px
  ha-view-sections-column-min-width: 300px
  ha-view-sections-column-gap: 8px
  card-mod-view-yaml: |
    hui-sections-view:
      $: |
        :host {
          --ha-view-sections-column-max-width: 2000px !important;
        }

WHY IT WORKS: card-mod-view-yaml runs AFTER the component initializes,
overriding the CSS variable at the shadow DOM host level. card-mod-root-yaml
runs too early. CSS resource files lose the specificity race.

After any theme change: frontend.reload_themes then clear cache + reload URL.
DO NOT use card-mod-root-yaml, CSS resource files, or FKB customCSS for this.
PHYSICAL BEZEL NOTE: Remaining ~8mm each side is physical tablet bezel, not CSS.

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

## Sections View Gutter — FINAL STATUS
Column width fix: ha-view-sections-column-max-width: 2000px in kitchen_wall theme
Container padding: injected via fully_kiosk.set_config customCSS
CSS injected: hui-sections-view { --ha-view-sections-column-max-width: 2000px; padding-left: 0; padding-right: 0; }
Verify on tablet — may need browser restart to apply.

## FKB customCSS — Broader Selector Approach for Gutter
Key: customCSS
Broader CSS targeting all HA container elements:
ha-panel-lovelace, .lovelace-container, ha-app-layout, hui-sections-view { padding: 0; margin: 0; }
Note: HA sections view padding lives inside shadow DOM — document-level CSS
may not reach it. If FKB customCSS does not eliminate bars, this is a
shadow DOM isolation issue that cannot be solved from document-level CSS.
True fix requires card-mod shadow DOM traversal with correct selectors.

## Sections View Gutter — RESOLVED (Physical Bezel)
CONFIRMED 2026-03-19: Black bars on left/right of kitchen tablet are the PHYSICAL BEZEL
of the Samsung Galaxy Tab A9+, NOT CSS padding or sections view layout issues.
Verified by opening FKB menu — dashboard content visible going edge-to-edge behind menu.
ha-view-sections-column-max-width: 2000px in theme is correct and sufficient.
DO NOT attempt further CSS fixes for this — it is hardware, not software.
