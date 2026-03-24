# System Knowledge - 2026-03-22 10:35

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
- [2026-03-22 09:36] LIGHTING: 2026-03-22 — Red lights at night: Living Room Lounge + floor lamp go deep red (rgb 255,43,0, hue 10°) late evening. Cause: Adaptive Lighting living_spaces circadian cycle pushing color to ~2000K on Hue color bulbs. hot_tub_mode was confirmed OFF. AL working as designed but aggressive. Fix options: (1) raise min_color_temp_kelvin floor on living_spaces AL instance, (2) disable adapt_color after a time threshold, (3) manual override holds until next on/off cycle due to take_over_control:true.
- [2026-03-22 09:36] AUTOMATION: 2026-03-22 — Lighting audit observations: (1) No mode-state visibility on dashboard — no indicator when AL is in nighttime color mode or when special modes were last active. (2) hot_tub_mode off path has no explicit color-restore — lights can stay colored if AL does not re-grab on next cycle. (3) Living Room Lamps Adaptive Control fires on downstairs motion with no time-of-night condition — color at turn-on time is whatever AL thinks is correct for that hour. (4) Multiple unavailable light entities: upstairs_hallway_ceiling 1-3of3, very_front_door_ceiling_hallway, both garage opener lights, upstairs_hallway_east_wall_night_light — investigate Zigbee/Hue drops. (5) Entity naming mismatches: kitchen_west_wall_nightlight friendly name says Basement, kitchen_counter_night_light says Stairwell — cleanup needed.

## Historical Learnings (last 30 lines)
- [2026-03-17 21:32] DASHBOARD: Now Playing tile: use template condition value_template state in ['playing','paused'] — NOT two separate state conditions. Single state condition misses paused state and card disappears on pause.
- [2026-03-17 23:08] DASHBOARD: CRITICAL: Black bar gutter fix lives in kitchen_wall THEME file via card-mod-root-yaml, NOT in dashboard config or CSS resource files. Theme path: /homeassistant/themes/kitchen_wall.yaml. Target: hui-sections-view shadow DOM div.sections-container max-width:100%. This is why it keeps regressing — dashboard edits never touch the theme.
- [2026-03-17 23:09] DASHBOARD: CRITICAL CORRECTION: Black bar gutter fix lives in /homeassistant/themes/kitchen_wall.yaml via card-mod-root-yaml targeting hui-sections-view shadow DOM div.sections-container max-width:100%. NOT a CSS resource file issue. Previous dead-end declaration was WRONG. After theme changes: frontend.reload_themes THEN clear cache + reload URL on tablet. This is why gutter kept regressing — dashboard edits never touched the theme file.
- [2026-03-17 23:13] DASHBOARD: Now Playing display: Mushroom Template Card with primary=media_title, secondary=media_artist, icon_color green/orange/grey by state. Hold action = play_pause toggle. Always visible (not conditional). Tap = more-info for full player. This is the correct pattern.
- [2026-03-17 23:19] DASHBOARD: CRITICAL: Mushroom template card drifted into scene button grid due to piecemeal index transforms — caused dashboard crash/HA logo stuck. Root cause: multiple transforms across session caused index shift. Fix: full grid rebuild (cards[2] and cards[3] replaced entirely) in single transform. This is why single comprehensive transform rule exists.
- [2026-03-17 23:21] DASHBOARD: mass-player-card REQUIRES custom integration mass_queue from github.com/droans/mass_queue — without it, card shows red error. Config uses entities: [list] not entity:. Install mass_queue integration first, then use: type: custom:mass-player-card, entities: [media_player.kitchen_2]. Full album art, queue, media browser, swipe gestures all work once dependency installed.
- [2026-03-17 23:26] DASHBOARD: Complete section 0 rebuild pattern: always replace cards[] list entirely in single transform to prevent drift. Never use .append() or index-based insertion across multiple transforms in same session. Two shopping list rows appeared due to accumulated drift — full rebuild fixed it.
- [2026-03-16 13:08] YAML: Storage-mode dashboards (kitchen-wall-v2) are not in /homeassistant/packages — they live in .storage/lovelace.<url_path_underscored>. Backup with: cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-YYYYMMDD.json then git commit. hac backup does not apply to storage-mode dashboards.
- [2026-03-16 13:08] YAML: python_transform sandbox: allowed = dict/list access, for loops, if/else, .get()/.pop()/in/append. Forbidden = import, def, try/except, isinstance, id, slice syntax ([:n]), ternary (x if y else z). Must target paths explicitly by index. No recursive walk possible — iterate known locations.
- [2026-03-16 13:22] YAML: input_select.kitchen_lighting_scene is set ONLY by dashboard tap actions — no automation watches it. Scene scripts only fire lights, they do not set the input_select. New script.kitchen_scene_select must fire both: the scene script AND input_select.select_option in sequence. History analysis (ha_get_history) is the reliable way to determine what actually sets a helper when deep_search returns stale results.
- [2026-03-16 13:22] YAML: Bubble Card scene buttons: button_type: state + entity: input_select watches the selector directly. styles: uses JS ${state === "Option"} for client-side active highlighting — zero Jinja2 CSS injection, zero card_mod. script.kitchen_scene_select: choose block toggles off if already active, else fires scene script + syncs input_select. All Off button calls script.kitchen_scene_all_off directly (no toggle logic needed).
- [2026-03-16 13:22] YAML: kitchen_wall theme: ha-view-sections-column-max-width controls column width only. View-level black gutters require ha-view-sections-max-width: none to override HAs default outer container cap. These are two separate CSS custom properties doing two different jobs.
- [2026-03-16 13:44] YAML: Bubble Card button_type CRITICAL distinction: button_type: state on input_select renders a built-in dropdown picker — tap_action is suppressed/overridden. button_type: name is a plain button that always fires tap_action on press. Set entity: for state access in styles: JS expressions without triggering the picker behavior. Always use button_type: name when the goal is tap -> script/action with visual state reflection.
- [2026-03-16 18:58] YAML: nano is unreliable for large YAML edits in HA SSH — use python3 heredoc with str.replace() for block insertions, sed -i for single-line deletions. Always verify line numbers with grep -n and sed -n before sed -i. Python str.replace() fails silently when whitespace differs — verify with grep -c after every write.
- [2026-03-16 18:58] YAML: kitchen_above_table_chandelier_inovelli is Smart Bulb Mode Inovelli switch powering 5 Hue chandelier bulbs. NEVER turn off in any scene script. Must stay powered. Remove from all_off and all_on. Control via light.kitchen_chandelier (Hue group) for color/brightness. Add exclusion comment in YAML.
- [2026-03-16 18:58] YAML: kitchen_scene_select toggle: YAML package is ground truth. Script added as first block under script: in kitchen_tablet_dashboard.yaml. Uses if/condition:template/value_template for toggle — NOT choose/condition:state with template (silently fails). Scene scripts handle input_select sync; select script only routes.
- [2026-03-16 18:58] YAML: YAML-defined scripts take precedence over UI scripts with same script_id after restart. When MCP-written scripts conflict with YAML definitions, delete MCP versions via ha_config_remove_script first. Always check packages with find+xargs+grep before writing MCP scripts.
- [2026-03-16 19:23] YAML: kitchen-wall-v2 dashboard redesign complete 2026-03-17: max_columns:3 + dense_section_placement:true fixes black bars. Single Home view: clock/weather section, calendar section (dominant), compact controls section (cameras, 4 scene buttons, climate, shopping list, music). Music popup has mass-player-card + spotify-card + genre buttons. Dashboard .storage not git-tracked — commit YAML packages only.
- [2026-03-16 19:23] YAML: Kitchen scene scripts final: Bright/Dim/Nightlight in kitchen_tablet_dashboard.yaml targeting Hue groups (color_temp_kelvin) and Inovelli dimmers. SBM switches (chandelier + sink Inovelli) never in scene lists. kitchen_scene_select uses if/condition:template for toggle. All scripts set input_select themselves — select script only routes.
- [2026-03-16 19:34] YAML: CRITICAL: UI-stored scripts (via MCP ha_config_set_script) override YAML package scripts with same ID even after restart. Must delete the UI version with ha_config_remove_script before reloading scripts via script.reload. Symptom: trace shows correct YAML script entity exists but old broken config runs. Fix: delete UI version, reload scripts, verify with ha_eval_template.
- [2026-03-16 20:03] YAML: Kitchen under-cabinet: TWO entities. light.kitchen_under_cabinet_aqara_t1_led_strip = Aqara T1 smart strip (color temp). light.inovelli_vzm31_sn_4 = dumb LED Inovelli switch (brightness only). Both in all scenes. all_off block is a single entity list — no above_sink_inovelli switch reference there.
- [2026-03-16 20:15] YAML: Kitchen scene under-cab levels tuned: Dim=(dumb:12%, Aqara:18%), Nightlight=(dumb:3%, Aqara:4%). Nightlight original 8% was too bright and overpowered scene.
- [2026-03-16 20:15] YAML: Bubble Card popup trigger: navigate action does not open popups. url action with url_path: /dashboard-url/view-path#hash is the correct pattern for kiosk mode. Full path required, not just #hash.
- [2026-03-16 20:15] YAML: Kitchen under-cab entity confirmed: light.inovelli_vzm31_sn_4 = dumb LED Inovelli switch (brightness only). light.kitchen_under_cabinet_aqara_t1_led_strip = smart Aqara T1 (color temp + hs). Both required in all scenes.
- [2026-03-16 20:19] YAML: Bubble Card popup trigger UNRESOLVED: navigate, url:#music, url:/path#music all attempted — none open popup from inside a sections-view section card. Next session: try converting music button to card_type:pop-up trigger placed at view root cards[] level, OR use browser_mod fire-dom-event approach.
- [2026-03-16 20:19] YAML: Black bars UNRESOLVED: max_columns:3 with 2 sections does not eliminate 1-inch gutters on A9+ tablet. Root cause: HA sections view has hardcoded max-width in shadow DOM. Next session fix: In Fully Kiosk Browser Settings > Web Content > set Custom Viewport Width to 1340 (A9+ native landscape width). Also try kitchen_wall theme with ha-view-sections-max-width override targeting the correct shadow DOM selector.
- [2026-03-16 20:19] YAML: Kitchen scenes COMPLETE: Bright=ceiling+pendants+dumb-under-cab 100%, chandelier+sink 100%/3500K, Aqara-strip 100%/4000K, lounge 70%/3000K, Govee OFF. Dim=dumb-under-cab 12%, Aqara 18%/2700K, chandelier 40%/2700K, sink 20%, lounge 35%/2200K, Govee 40% amber. Nightlight=dumb-under-cab 3%, Aqara 4%/2200K, chandelier 5%/2200K, sink 8%, lounge-lamp 5%/2200K, Govee 10% warm. AllOff=everything off, SBM switches stay powered.
- [2026-03-16 20:19] YAML: Calendar confirmed working: atomic-calendar-revive with 6 entities (alaina_ella, pigeonfallsrn_gmail_com, work, minnesota_vikings_2, pigeon_falls_lions_club, master_calendar), showColors:true, 7 days, 140% font. calendar.john_michelle intentionally excluded. calendar.minnesota_vikings (original) is disabled_by:user — use minnesota_vikings_2.
- [2026-03-16 20:19] YAML: Scene button toggle-off pattern confirmed working: 3 Bubble Card buttons (Bright/Dim/Night) each call script.kitchen_scene_select with scene param. Script uses if/condition:template to detect if scene already active — if so, calls kitchen_scene_all_off instead. No separate Off button needed. Off button removed from dashboard.
- [2026-03-16 20:46] YAML: Black bars fix attempt via card-mod-root-yaml in theme. Targets hui-sections-view shadow DOM div.sections-container with max-width:100%. FKB on A9+ does not expose viewport width setting in Web Zoom section. card-mod-root-yaml is the CSS injection point for global shadow DOM overrides in HA 2026.x themes.
