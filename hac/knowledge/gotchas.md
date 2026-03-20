# HAC Gotchas
*Things that silently fail or behave unexpectedly*
*Check here before debugging for more than 10 minutes*

## YAML Silent Failures
- Duplicate top-level `template:` keys — second block silently dropped
  - Audit: `grep -c '^template:' file.yaml` must return 1
- `delay_off` on state-based template sensors — silently kills sensor definition
- Unindented comments inside `template:` lists — breaks list parsing
- `choose/condition:state` with template value — silently fails, use `if/condition:template`
- YAML scripts override UI scripts with same ID (YAML wins silently)

## Dashboard Silent Failures
- `python_transform` list comprehension on root `cards[]` — silently wipes sections
- Piecemeal index-based transforms across multiple calls — indices shift silently
- `ha_config_set_dashboard` with stale hash — write fails silently
- `ha_config_set_script` on YAML-defined scripts — creates conflicting UI duplicate
- `ha_deep_search` after restart — returns stale cached index, not current state

## Entity Registry
- ZHA assigns generic entity_ids — always rename via `ha_rename_entity`
- Orphan entities squat on canonical IDs — new sensors get `_2` suffix
- `ha_rename_entity` two-step rename only holds until next restart if template
  platform re-registers with same `unique_id`
- `ha_config_get_automation` returns `config: null` for ALL UI-created automations

## BusyBox Terminal (HA Green)
- `grep --include` flag does NOT exist — use `find | xargs grep`
- `sed` multi-line does NOT work — use python3 heredoc
- Never chain commands after `python3 -c` on same line
- Git `confused by unstable object` — run `git gc --prune=now` twice
- ZSH: escape `!` or use single quotes — double quotes with `!` break

## Hardware Gotchas
- Aqara Hub M3: MUST be on UDM Pro Port 4 — Port 2 causes unavailable cycles
- FKB auto-update causes random browser restarts — keep disabled
- FKB port 2323 unreachable cross-VLAN — use `fully_kiosk.set_config` service
- ratgdo van visor may need 2 presses — Security+ 2.0 serial bus timing, not a bug
- HA Green at ~2.3x recommended entity count — long-term migration needed

## Music Assistant
- `music_assistant.play_media` — bare Spotify playlist IDs only
- `spotify://playlist/ID` URI format causes 500 error
- Route through `media_player.kitchen_2` (MA entity), not direct Sonos

## Notification Targets
- RETIRED: `notify.mobile_app_sm_s928u` (S24 Ultra) — never use
- Primary: `notify.mobile_app_john_s_s26_ultra`
- Watch: `notify.mobile_app_john_s_galaxy_watch8_classic_s7me`
