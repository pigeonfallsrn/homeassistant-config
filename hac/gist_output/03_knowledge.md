# System Knowledge - 2026-02-08 22:47

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
- 2026-01-22: HA MCP Server Integration - Enable official HA MCP (2025.2+) for read-only device control queries alongside HAC for config editing. Requires: Settings > Devices & Services > Add Integration > Model Context Protocol Server
- 2026-01-22: Cleanup duplicate garage automations - garage_door_opened_close_option vs garage_north_door_opened_close_option, garage_door_opened_close_prompt overlap
- 2026-01-22: Delete orphan automations via GUI: garage_all_lights_off_2, garage_door_handle_notification_actions, garage_door_opened_close_option, garage_door_opened_close_prompt, garage_door_opened_handle_actions
- [ ] Fix SSH key auth to Synology (add ha_to_synology.pub to admin@[IP]:~/.ssh/authorized_keys) then integrate Google Drive sync into hac push
- [ ] Double-trigger still occurring - combined motion sensors may be firing twice. Investigate motion_aggregation.yaml template definition
- 2026-01-22: Fix SSH key auth to Synology for Google Drive sync - add ha_to_synology.pub to admin@[IP]:~/.ssh/authorized_keys, then integrate gdrive sync into hac push
- 2026-01-23: Phase 2 family_activities: Connect winddown sensors to kids_bedroom_automation.yaml, add WAYA softball calendars when season starts, dashboard card
- 2026-01-23: HAC v7.3 Architecture Redesign - Multi-LLM workflow optimization: (1) Dynamic tabled/learnings management with rationale tracking, (2) LLM-specific session prompts (Claude web, Claude Desktop+MCP, Gemini Pro), (3) MCP-aware mode with privacy guards and guided rules, (4) Token-efficient non-MCP fallback mode, (5) Strategic workflow guidance per use case (coding, research, config). See hac/learnings/20260123.md for full spec.
- 2026-01-23: Infrastructure integration: UniFi Protect motion events to HA, Synology automated HA snapshot backups
- 2026-01-28: Add 3 lights to Living Spaces AL via UI: living_room_west_floor_lamp, kitchen_hue_color_floor_lamp, kitchen_lounge_lamp (storage edits revert - must use UI)

## Recent Session Learnings
- 09:30: Garage notification mess: 3 overlapping automation sets were all active. Single source of truth is now packages/garage_quick_open.yaml only. Removed automations/garage_arrival.yaml and garage_door_notifications.yaml plus 17 orphaned entity registry entries.
- 11:51: Fixed 2nd floor bathroom fan Shelly to Inovelli VZM35-SN, added Navien flow pretrigger, purged 52 ghost automations, installed 9 new hac workflow commands
- 22:41: Master Context Excel export system complete: v2.0 with Action Items tab, automated Synology/GDrive sync via hac export command

## Historical Learnings (last 30 lines)
- Use `| default('', true)` for stricter default, OR add explicit null check before operations
- For string slicing: `{% if bssid and bssid[:8] in [...] %}` prevents TypeError on None
- GPS-based presence (`person.john_spencer`) requires phone companion app to actively report location changes
- If phone goes to sleep or battery optimization kicks in, departure may not register
- UniFi device_tracker shows connection but doesn't track GPS location
- Alternative triggers: garage door state, vehicle detection, WiFi BSSID changes
- **Background Location** - core presence tracking (1-3 min updates)
- **Location Zone** - triggers on zone enter/leave
- **Single Accurate Location** - precise on-demand location
- **High Accuracy Mode** - faster updates
- Set **Sensor Update Frequency** to "Fast Always" (1 min vs 15 min)
- Android: Settings → Apps → Home Assistant → Battery → Unrestricted
- `ha automation reload` doesn't exist - use REST API: `curl -X POST ... /api/services/automation/reload`
- 502 Bad Gateway from supervisor API = HA core is down/restarting
- Template reload: `curl -X POST ... /api/services/template/reload`
- `!include_dir_merge_list automations/` auto-includes all .yaml files in automations/
- New files are picked up on automation reload without config changes
- File naming: descriptive (e.g., `garage_door_notifications.yaml`, `exterior_lights_auto_off.yaml`)
- `binary_sensor.aqara_door_and_window_sensor_door_5` = North garage door (device_class: garage_door)
- `binary_sensor.aqara_door_and_window_sensor_door_6` = South garage door
- State: `off` = closed, `on` = open
- Faster/more reliable than ratgdo tilt sensor for "closed" detection
- `git fsck --full && git gc --prune=now` fixes "confused by unstable object source" errors
- Always exclude: `zigbee.db*`, `.ha_run.lock`
- 09:20: QUICK WINS COMPLETE: (1) Gist pushed, (2) Verified 5 orphan automations - 4 already gone, removed 2 garage_all_lights_off from entity registry, (3) Tabled projects cleaned. Next priority: legacy template audit for 2026.6 deprecation.
- 09:59: Orphan cleanup complete: removed 2 true orphans. Remaining garage_all_lights_off is legit (unique_id: garage_master_lights_off from garage_lighting_automation.yaml). HA regenerated it on restart.
- 10:47: PHASE 2-4 COMPLETE: Fixed duplicate YAML keys in kitchen_tablet_dashboard.yaml, presence_system.yaml, configuration.yaml. Removed duplicate unique_ids (alaina_at_moms etc). Added round() defaults. Moved 29 old .bak files to hac/backups/old_package_baks/. All configs validated.
- 11:47: HARDWARE CHANGE 2026-02-05: 1st Floor Bathroom - TP-Link dimmer installed for vanity lights, replaces Inovelli. Old Inovelli will move to 2nd Floor Bathroom (smart bulb mode). ISSUE: Remaining 1st FL Bathroom Inovelli (ceiling) not controlling Hue lights properly - needs Smart Bulb Mode check.
- 12:02: 1ST FL BATHROOM INOVELLI+HUE SETUP: (1) Enable Smart Bulb Mode via ZHA Manage Clusters → Inovelli_VZM31SN_Cluster → attribute 'Smart Bulb Mode' = 1. (2) Create automation using fxlt blueprint 'Inovelli VZM31-SN Blue Series 2-1 Switch (ZHA)'. (3) Map paddle presses to light.1st_floor_bathroom (Hue group). (4) Set automation mode: queued. This routes Inovelli→ZHA→HA→Hue Bridge→Hue Bulbs since direct Zigbee binding not possible across different coordinators.
- 21:02: 1ST FL BATHROOM INOVELLI WORKING: Key issue was automations.yaml being ignored - config uses include_dir_merge_list automations/ so automations must go in automations/ directory. Created automations/1st_floor_bathroom_inovelli.yaml using fxlt blueprint.
