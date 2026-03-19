# Claude Project Instructions (copy into Claude Project Settings)
# These inject automatically into every conversation — keep lean and critical only

John Spencer's Home Assistant system. HA Green, HA 2026.3.x, ~4000 entities.
Config path: /homeassistant/ (NEVER /config/)
Git root: /homeassistant/

## BEFORE ANY EDIT — NON-NEGOTIABLE
YAML files:      hac backup <filename>
Storage dashboards: cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
NEVER skip backup. NEVER use hac backup for storage-mode dashboards.

## TERMINAL (ZSH + BusyBox)
- Escape ! or use single quotes. NEVER double-quote strings with !
- BusyBox grep: NO --include flag. Use: grep -r 'pattern' /path/
- BusyBox sed: NO multi-line. Use python3 heredoc for complex edits.
- NEVER chain commands after python3 -c on same line
- NEVER chain after heredoc EOF on same line — use && on next line

## DASHBOARD TRANSFORMS (python_transform)
- ALWAYS force_reload:True before any transform — get fresh hash
- NEVER list comprehension on root cards[] — silently wipes sections
- NEVER piecemeal transforms — one comprehensive transform per section
- Direct index only: config['views'][0]['sections'][0]['cards'][2]
- No enumerate, isinstance, str(), any(), all(), next(), try/except
- Verify on tablet after EVERY transform before next edit

## DEAD ENDS — DO NOT RETRY
- Sections view gutter (black bars): unfixable via CSS. Accept it.
- hac backup on storage-mode dashboards: always fails silently
- Bubble Card popup via navigate/hash from inside sections: blocked by kiosk_mode
  STATUS: kiosk_mode test live as of 2026-03-17

## KEY FILES TO READ AT SESSION START
- hac/CRITICAL_RULES.md — full rule set
- hac/KITCHEN_DASHBOARD_REFERENCE.md — dashboard authority
- hac/BACKLOG_kitchen_dashboard.md — work queue, start from BLOCKING

## KNOWLEDGE SYSTEM
Tier 1 (authoritative): CRITICAL_RULES.md, KITCHEN_DASHBOARD_REFERENCE.md, BACKLOG_kitchen_dashboard.md
Tier 2 (raw capture): hac/learnings/YYYYMMDD.md
Rule: hac learn = new discoveries only. Already documented? Update Tier 1 instead.
Anything logged 2+ times → promote to Tier 1 same session.

## SBM SWITCHES (NEVER put in light.turn_off actions)
kitchen_chandelier_inovelli, above_sink_inovelli, kitchen_lounge_inovelli_smart_dimmer,
entry_room_ceiling_inovelli, 1st_floor_bathroom_inovelli, back_patio_inovelli

## NOTIFICATION TARGET (confirmed)
Primary: notify.mobile_app_john_s_s26_ultra
S24 Ultra (notify.mobile_app_sm_s928u) is RETIRED — never use

## PRESENCE ENTITIES
binary_sensor.john_home, alaina_home, ella_home, michelle_home
person.john_spencer, device_tracker.galaxy_s26_ultra
michelle tracked via binary_sensor.michelle_actually_home only

## THEME — kitchen_wall confirmed settings
ha-view-sections-column-max-width: 2000px  ← REQUIRED, do not reduce
ha-view-sections-column-min-width: 300px
ha-view-sections-column-gap: 8px
No card-mod-root-yaml needed. Simple theme vars only.

## DASHBOARD — section 0 card order (authoritative)
[0] clock-weather-card
[1] mushroom-chips-card  
[2] grid (2-col cameras)
[3] grid (4-col scene buttons: Bright/Dim/Music/Night)
[4] bubble-card media-player (album art, navigates to #music)
NEVER rebuild piecemeal. Always replace sections[0]['cards'] entirely.

## FKB CONFIGURATION (via HA service — no port 2323 needed)
fully_kiosk.set_config device_id=86870b5d8b01f345f5d5dd9c2ac06d2b
  autoUpdateApp=false  ← run this at start of every session to prevent restarts
  customCSS="css"      ← inject CSS for gutter fix
Tablet IoT VLAN 192.168.21.x — port 2323 unreachable from main LAN.
