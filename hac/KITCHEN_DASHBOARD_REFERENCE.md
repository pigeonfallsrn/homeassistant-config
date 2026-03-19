# Kitchen Dashboard Reference
_Authoritative guide — update this file, not just learnings_

## Identity
- Dashboard: kitchen-wall-v2 (storage-mode, sections layout)
- Hardware: Samsung Galaxy Tab A9+, Fully Kiosk Browser Plus v1.60.1-play
- FKB device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Reload sequence: button.kitchen_wall_a9_tablet_clear_browser_cache then button.kitchen_wall_a9_tablet_load_start_url
- Restart: button.kitchen_wall_a9_tablet_restart_browser

## Backup (NON-NEGOTIABLE before any edit)
cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
hac backup does NOT work for storage-mode dashboards. Never attempt it.

## Session Start Checklist
1. Run backup command above
2. Read BACKLOG_kitchen_dashboard.md — work from BLOCKING items first
3. ha_config_get_dashboard force_reload:True — get fresh hash before ANY edit
4. Single comprehensive transform per section — never piecemeal index edits
5. Reload tablet + verify after EVERY transform before next edit
6. Commit + hac learn before ending session

## Layout Rules (confirmed working)
- type: sections, max_columns: 2, dense_section_placement: false
- column_span: 1 on BOTH sections = correct 50/50 left/right split
- Left section: weather + chips + cameras + scene buttons + shopping/music row
- Right section: atomic-calendar-revive only

## Black Side Bars — Fix Location
Fix is in /homeassistant/themes/kitchen_wall.yaml via card-mod-root-yaml.
Targets: hui-sections-view shadow DOM div.sections-container max-width:100%
After theme edits: frontend.reload_themes → clear tablet cache → reload URL.
CSS resource files (wall-tablet.css) do NOT work — load too late. Do not use.
If bars persist: check card-mod selector compatibility with current HA version.

## atomic-calendar-revive Settings (confirmed working)
compactMode: false        # NEVER true — collapses card height
maxDaysToShow: 3
maxEventCount: 12
dateSize: 230
titleSize: 220
timeSize: 180
showColors: true
showProgressBar: false
showCurrentEventLine: false
showLocation: false
showDescription: false
showWeekNumber: false

## Scene Buttons
- Script: script.kitchen_scene_select with field scene: Bright|Dim|Nightlight
- Toggle logic: if current scene == tapped then run all_off, else run scene script
- State tracked via: input_select.kitchen_lighting_scene (options: Off/Bright/Dim/Nightlight)
- Bubble Card button_type:name + entity:input_select.kitchen_lighting_scene + JS styles: for active state
- SBM switches MUST NOT appear in any off action list

## Music Popup (UNRESOLVED — kiosk_mode hypothesis pending test)
All failed approaches:
- navigate tap_action to /kitchen-wall-v2/home#music
- hash property on section button
- browser_mod fire-dom-event
- root-level hidden trigger button
FKB 1.60.1 confirmed — version NOT the issue.
NEXT TEST: temporarily set kiosk_mode:{} in dashboard config, reload, test popup.
If popup works then kiosk_mode is intercepting hash navigation.
Fix path: Bubble Card open_popup action (no hash nav) OR kiosk_mode allowlist.
Test is currently live — kiosk_mode disabled as of this session.

## python_transform Rules (hard-won)
- NEVER use list comprehension on root cards[] — silently wipes sections
- Use direct index ops only: config['views'][0]['cards'][0]
- No enumerate, isinstance, str(), any(), all(), next(), try/except
- Delete with .pop(index) — higher indices first
- One comprehensive transform per edit — never chain multiple transforms

## Dashboard Drift Prevention
Root cause: piecemeal index-based transforms across multiple calls shift indices silently.
Fix: always do full section rebuild in single transform when editing section[0].
Always force_reload before transform to get current structure.

## Two-Tier Knowledge System
Tier 1 — Reference files (authoritative, always current):
  CRITICAL_RULES.md, KITCHEN_DASHBOARD_REFERENCE.md, BACKLOG_kitchen_dashboard.md
Tier 2 — Dated learnings (raw capture, needs promotion):
  hac/learnings/YYYYMMDD.md
Rule: anything logged in learnings 2+ times MUST be promoted to Tier 1 same session.
hac learn has NO deduplication — before logging ask: is this already in a Tier 1 file?


## Confirmed Working Configuration (2026-03-19)
- Scene buttons: Bright/Dim/Music/Night in 4-col grid ✅
- Calendar: fills right column, 7 days, color-coded ✅  
- Bubble Card media-player: album art at bottom of left column ✅
- Music button: navigate to #music popup ✅ (popup open TBD)
- Black bars: ha-view-sections-column-max-width: 2000px in theme reduces bars
  Remaining fix: wall-tablet.css targeting hui-sections-view
- Section 0 card order: [0]weather [1]chips [2]cameras [3]scene-grid [4]media-player
- NEVER use piecemeal transforms — always rebuild sections[0]['cards'] entirely
