# System Knowledge - 2026-03-24 19:47

## Architecture Quick Ref
- **Packages:** /config/packages/*.yaml
- **Presence:** input_boolean.john_home (NOT binary_sensor)
- **North garage door:** cover.ratgdo32disco_fd8d8c_door
- **South garage door:** cover.ratgdo32disco_5735e8_door  
- **Walk-in door sensor:** binary_sensor.aqara_door_and_window_sensor_door_3
- **Motion aggregation:** /config/packages/motion_aggregation.yaml
- **Automations:** /homeassistant/automations/ (NOT automations.yaml) - uses include_dir_merge_list
- **Config paths:** /homeassistant/ (not /config/), storage at /homeassistant/.storage/

## Critical Rules (from past disasters)
- NEVER use raw sed on YAML without backup
- ALWAYS use `hac sed` or `hac backup` first
- Check `ha core check` before restart
- Inovelli+Hue: Smart Bulb Mode must be ON
- ZSH: escape ! in strings, dont chain after python3 -c on same line
- HA CLI: ha command doesnt support services - use REST API, websocket, or UI

## Tabled Projects
# Tabled Projects
*Updated: 2026-02-21*

## Infrastructure
- [ ] SSH key auth to Synology for gdrive sync (ha_to_synology.pub → admin@[IP])
- [ ] UniFi Protect motion events to HA

## Cleanup (Low Priority)
- [ ] Delete orphan garage automations: garage_all_lights_off_2, garage_door_handle_notification_actions, garage_door_opened_close_option, garage_door_opened_close_prompt, garage_door_opened_handle_actions
- [ ] Cleanup duplicate garage automations (north_door vs generic overlap)

## Future Enhancements  
- [ ] Phase 2 family_activities: Connect winddown sensors, add WAYA softball calendars
- [ ] Inovelli blueprint migration: fxlt → MasterDevwi unified (root cause found 2/21 - per-device triggers)

## Completed (Archive)
- [x] 2026-02-21: Add 3 lights to Living Spaces AL (expanded 4→7)
- [x] 2026-02-21: HA MCP Server Integration (active)
- [x] 2026-02-21: HAC v8.0→v8.1 (ACTIVE.md task tracking)
- [x] 2026-02-21: Double-trigger root cause (fxlt blueprint design)

## Recent Ideas (Mobile Capture)
- [x] Hot tub mode: dim/off living room lounge lamp when activated (blinding from patio)

## Living Room Mobile Dashboard (S24 Ultra)

**Status**: Tabled for future session
**Priority**: Medium
**Created**: 2026-02-23

### Requirements
1. **A/V Controls**
   - Fire TV power on/off
   - AVR volume slider + mute
   - Quick source buttons (Netflix, YouTube, Prime Video)
   - Movie Mode script button

2. **Lighting Controls**
   - Inovelli VZM36 Fan/Light module:
     - Light toggle with brightness
     - Fan speed: Off / Low / Medium / High
   - TP-Link behind-TV light strip (RGB control)
   - Floor Lamps (L/R of TV): `light.living_room_east_floor_lamp`, `light.living_room_west_floor_lamp`
   - Table Lamps: `light.living_room_lamp_1_of_2`, `light.living_room_lamp_2_of_2`
   - Hue group: `light.living_room_floor_lamps`, `light.living_room_table_lamps`

3. **Hue Scene Research Needed**
   - Movie/TV watching scenes (bias lighting concepts)
   - Ambient/relaxed scenes
   - Consider complementary colors for Hue Color bulbs
   - Behind-TV bias lighting best practices (6500K vs warm)

### Entity Reference
| Control | Entity |
|---------|--------|
| Fire TV | `media_player.living_room_fire_tv_192_168_1_17` |
| Fire TV Remote | `remote.living_room_fire_tv_192_168_1_17` |
| AVR | `media_player.basement_yamaha_av_receiver_rx_v671_main` |
| Subwoofer | `switch.living_room_subwoofer_plug` |
| Ceiling Fan/Light | `light.inovelli_vzm36_light_3` or `_4`, `fan.xxx` |
| Behind TV Strip | TBD - find TP-Link entity |
| East Floor Lamp | `light.living_room_east_floor_lamp` |
| West Floor Lamp | `light.living_room_west_floor_lamp` |
| Table Lamp 1 | `light.living_room_lamp_1_of_2` |
| Table Lamp 2 | `light.living_room_lamp_2_of_2` |
| Floor Lamps Group | `light.living_room_floor_lamps` |
| Table Lamps Group | `light.living_room_table_lamps` |

### ADB Commands for App Launch
```yaml
# Netflix
service: media_player.select_source
target:
  entity_id: media_player.living_room_fire_tv_192_168_1_17
data:
  source: "com.netflix.ninja"

# Prime Video
source: "com.amazon.avod"

# YouTube  
source: "com.amazon.firetv.youtube"
```

### Dashboard Type
- Mobile-optimized (S24 Ultra: 3088 x 1440)
- Consider: Mushroom cards, Bubble card, or custom grid layout
- Prioritize touch targets for one-handed use
- 2026-03-14: [PERSON] companion app on iPhone 17 - install when she's home, update person.ella_spencer tracker source, rename iPad entity to avoid confusion
- 2026-03-14: Set automatic backup retention policy - HA Green accumulates supervisor backups silently. Options: (A) Settings->System->Backups->Configure->set keep to 3, or (B) cloud backup integration to Google Drive + keep 2 local. Also table: remove python_scripts/venv/ if not referenced by export_to_sheets.py

## Recent Session Learnings
- [2026-03-24 16:22] GENERAL: FIRETV/YAMAHA AVR dropout fix 2026-03-24: Fire TV 4K ADB integration chatters idle/playing/unavailable constantly during Hulu — normal ADB polling behavior, not actual power state changes. Root causes: (1) AVR-on automation was triggering mid-session on idle->playing transitions, sending turn_on+source+volume to an already-on AVR, interrupting YNCA TCP connection causing brief unavailable blips. Fix: added from:[off,standby,unavailable] + for:10s debounce to on-triggers. (2) AVR-off 10min timer too short, firing during long Hulu ad breaks. Fix: extended to 20min. (3) Added not-unavailable condition to off automation to ignore ADB reconnect events. Backup: fae184df. Auto Power Standby on RX-V671 still needs physical fix via remote — requires TV + remote simultaneously.
- [2026-03-24 16:49] HAC: Google Doc at docs.google.com/1AEjE0V5 is RETIRED — predates HAC v9, contains stale entity names (S24 Ultra notify target, /config/ paths). Do not reference. Authority is CRITICAL_RULES.md
- [2026-03-24 19:47] GENERAL: YAMAHA RX-V671 Auto Power Down fix: Menu path is Setup → Function (wrench, page 1/4) → Auto Power Down — NOT Setup → Option as Yamaha docs suggest. Was set to 12 Hours, changed to Off. Setting persistent in receiver memory. Combined with HA automation fixes (from: guard + 10s debounce + 20min off-timer) this fully resolves AVR dropout during Hulu.

## Historical Learnings (last 30 lines)
- [2026-03-17 20:26] YAML: Dashboard backup command: cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json — run before any dashboard editing session to preserve last known good state.
- [2026-03-17 20:26] YAML: Doorbell popup plan: automation triggers on event.front_driveway_door_doorbell, calls browser_mod.popup on kitchen tablet showing camera.front_driveway_door_high_resolution_channel live feed. Uses input_boolean.kitchen_tablet_doorbell_popup_active as guard. Next session: implement with browser_mod.
- [2026-03-17 20:26] YAML: Music popup FINAL diagnosis: Bubble Card popup hash trigger does not work from inside sections-view section cards. Definitive fix next session: add a Bubble Card button card_type:button at view root cards[] level (alongside the pop-up card) that uses tap_action:action:fire-dom-event with browser_mod, OR restructure music button as a native Bubble Card horizontal-buttons-stack at view root level.
- [2026-03-17 20:30] YAML: DASHBOARD DRIFT CRITICAL: python_transform ha_config_set_dashboard causes silent card corruption across multiple session edits. Dim button, Front Door camera tap_action, and scene grid repeatedly corrupted. ROOT CAUSE: index-based card replacement shifts indices after each transform. FIX: Always do full section[0] rebuild in single transform, never piecemeal index edits. Start every session with force_reload + backup before any dashboard edit.
- [2026-03-17 20:30] YAML: atomic-calendar-revive: compactMode:true causes events to collapse and card to only fill half the column height — DO NOT USE on wall tablet. Best settings for full-column fill: maxDaysToShow:5, maxEventCount:15, dateSize:140, titleSize:140, timeSize:115, showColors:true, showProgressBar:false, showCurrentEventLine:false, showLocation:false, showDescription:false, showWeekNumber:false. These were the best-working settings before compactMode regression.
- [2026-03-17 20:30] YAML: Weather popup plan: tap clock-weather-card opens Bubble Card popup with (1) weather tile with 7-day forecast detail + (2) Weather Radar Card (HACS id:487680971). Install radar card next session. clock-weather-card tap_action needs to be set to fire the #weather popup hash.
- [2026-03-17 20:30] YAML: Active lights notification chip: Mushroom Template chip, conditional on template counting lights on in key areas. Shows count + icon, tap calls light.turn_off with area_id targets. Only visible when lights unexpectedly on. IMPORTANT: exclude SBM switches (kitchen_above_table_chandelier_inovelli, above_kitchen_sink_inovelli_switch, kitchen_lounge_inovelli_smart_dimmer) from off logic — they must stay powered for Hue.
- [2026-03-17 20:30] YAML: Next session START protocol: (1) cp dashboard storage to backup, (2) force_reload dashboard to get current hash, (3) do single comprehensive section[0] rebuild to fix all accumulated corruption, (4) verify on tablet before proceeding. Dashboard has recurring drift from piecemeal index-based transforms.
- [2026-03-17 20:50] YAML: kitchen-wall-v2 is storage-mode: hac backup does not work for it. Use hassio.backup_partial via MCP before any dashboard edits.
- [2026-03-17 20:50] YAML: CSS variable --ha-view-sections-column-max-width via /local/wall-tablet.css file resource does NOT fix sections gutter. Confirmed broken in all CSS resource approaches. The black side bars on sections view are unfixable via CSS - this is a known HA frontend limitation for sections layout on tablets.
- [2026-03-17 20:50] YAML: Bubble Card popup hash navigation: navigate tap_action to #music does not work in FKB. hash property on button inside a section does not work either. browser_mod fire-dom-event does not work. Root-level trigger button approach not yet confirmed working. Music popup remains unresolved after multiple attempts.
- [2026-03-17 20:50] YAML: atomic-calendar-revive column_span:1 on both sections + max_columns:2 makes calendar fill right half correctly. Regresses if max_columns or column_span values change.
- [2026-03-17 20:53] YAML: storage-mode dashboard backup: use hassio.backup_partial via MCP (ha_call_service domain=hassio service=backup_partial). hac backup only works for YAML package files, not storage-mode dashboards.
- [2026-03-17 20:53] YAML: sections layout calendar fill: column_span:1 on both sections + max_columns:2 assigns columns correctly but atomic-calendar-revive card itself may not stretch to fill container height. CSS fix via wall-tablet.css resource confirmed non-functional - CSS vars load too late. Accept gutter bars as unfixable in sections view.
- [2026-03-17 20:53] YAML: Bubble Card popup music button: ALL approaches failed in FKB - navigate tap_action to hash, hash property on section button, browser_mod fire-dom-event, root-level hidden trigger button. Must confirm FKB Plus version before any further attempts - hash navigation may be blocked by FKB version.
- [2026-03-17 21:16] DASHBOARD: Bubble Card popup in sections-type view: root cards[] does NOT reliably register popups regardless of kiosk_mode, FKB version, or trigger button approach. Confirmed via kiosk_mode disabled test — music button still dead. Workaround: use more-info tap_action on media_player.kitchen_2 for music controls. Popup approach needs dedicated investigation outside sections view.
- [2026-03-17 21:16] DASHBOARD: Music button working solution: tap_action more-info on media_player.kitchen_2 opens native HA media player panel with full MA controls. No popup needed.
- [2026-03-17 21:18] DASHBOARD: CONFIRMED WORKING: Music button = tap_action more-info on media_player.kitchen_2. Opens native MA media player panel with full controls. No popup/hash navigation needed. Bubble Card popup approach in sections view is a confirmed dead end.
- [2026-03-17 21:18] DASHBOARD: Session start alias: hac-dash runs backup + shows blocking backlog items + key reminders. Script at hac/bin/hac-dash-start.sh. Alias in ~/.zshrc.
- [2026-03-17 21:18] DASHBOARD: Sections layout working config: max_columns:2, dense_section_placement:false, column_span:1 on both sections. Left=cards, Right=calendar only.
- [2026-03-17 21:25] DASHBOARD: maxi-media-player: conditional card works for now-playing display. Config: artwork:full-cover, info:scroll, hide source+power+icon:true. Wrap in conditional card with state playing OR paused. Appears automatically when music active, disappears when idle.
- [2026-03-17 21:28] DASHBOARD: maxi-media-player entity config incompatible with media_player.kitchen_2 (Music Assistant player) — shows 'no players found'. Use mass-player-card instead which is MA-native and confirmed working. maxi-media-player may work for Sonos direct but not MA virtual players.
- [2026-03-17 21:29] DASHBOARD: mass-player-card and maxi-media-player both fail with media_player.kitchen_2 when used as standalone section cards — show errors/no players found. These cards only work inside the more-info panel (tapped). For glanceable now-playing in sections: use native tile card with media-player-playback + media-player-volume-slider features. Native tile is guaranteed, no custom JS required.
- [2026-03-17 21:32] DASHBOARD: Now Playing tile: use template condition value_template state in ['playing','paused'] — NOT two separate state conditions. Single state condition misses paused state and card disappears on pause.
- [2026-03-17 23:08] DASHBOARD: CRITICAL: Black bar gutter fix lives in kitchen_wall THEME file via card-mod-root-yaml, NOT in dashboard config or CSS resource files. Theme path: /homeassistant/themes/kitchen_wall.yaml. Target: hui-sections-view shadow DOM div.sections-container max-width:100%. This is why it keeps regressing — dashboard edits never touch the theme.
- [2026-03-17 23:09] DASHBOARD: CRITICAL CORRECTION: Black bar gutter fix lives in /homeassistant/themes/kitchen_wall.yaml via card-mod-root-yaml targeting hui-sections-view shadow DOM div.sections-container max-width:100%. NOT a CSS resource file issue. Previous dead-end declaration was WRONG. After theme changes: frontend.reload_themes THEN clear cache + reload URL on tablet. This is why gutter kept regressing — dashboard edits never touched the theme file.
- [2026-03-17 23:13] DASHBOARD: Now Playing display: Mushroom Template Card with primary=media_title, secondary=media_artist, icon_color green/orange/grey by state. Hold action = play_pause toggle. Always visible (not conditional). Tap = more-info for full player. This is the correct pattern.
- [2026-03-17 23:19] DASHBOARD: CRITICAL: Mushroom template card drifted into scene button grid due to piecemeal index transforms — caused dashboard crash/HA logo stuck. Root cause: multiple transforms across session caused index shift. Fix: full grid rebuild (cards[2] and cards[3] replaced entirely) in single transform. This is why single comprehensive transform rule exists.
- [2026-03-17 23:21] DASHBOARD: mass-player-card REQUIRES custom integration mass_queue from github.com/droans/mass_queue — without it, card shows red error. Config uses entities: [list] not entity:. Install mass_queue integration first, then use: type: custom:mass-player-card, entities: [media_player.kitchen_2]. Full album art, queue, media browser, swipe gestures all work once dependency installed.
- [2026-03-17 23:26] DASHBOARD: Complete section 0 rebuild pattern: always replace cards[] list entirely in single transform to prevent drift. Never use .append() or index-based insertion across multiple transforms in same session. Two shopping list rows appeared due to accumulated drift — full rebuild fixed it.
