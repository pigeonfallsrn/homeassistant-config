# System Knowledge - 2026-01-27 22:14

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

## Recent Session Learnings
- 22:02: Handoff docs can become stale - always verify current state via entity registry before acting
- 22:02: ui_automations.yaml uses unconventional YAML key ordering (action before id) - valid but confusing
- 22:02: 134/137 lights still need area assignment via UI bulk edit

## Historical Learnings (last 30 lines)
- Climate controls (kitchen_mini_split, 1st_floor_thermostat)
- **Presence logic**: Currently uses person entities; should use AP-based presence for accuracy
- **[PERSON] shows "home"**: Need to refine template to exclude her when at her own house
- **Calendar entity**: Verify `calendar.alaina_and_ella` is correct entity ID
- **Kitchen mini-split**: Showed "Unavailable" - check Kumo Cloud integration
- `binary_sensor.very_front_door_doorbell` (G4 Doorbell)
- `binary_sensor.front_driveway_door_doorbell` (G4 Doorbell)
- Both have package detection capability
- `/config/packages/kitchen_tablet_dashboard.yaml` - Main package
- `/config/dashboards/lovelace-kitchen-tablet.yaml` - Dashboard YAML
- `/config/automations/tablet_power.yaml` - Away/arrival power
- `/config/automations/kitchen_tablet_wake.yaml` - Wake triggers
- Username: `dashboardtablet2026`
- Password: `dashboarduser`
- Group: Users (non-admin)
- Local access only: Yes
- HA behind Cloudflare Tunnel (cloudflared)
- `use_x_forwarded_for: true` with `trusted_proxies` for Cloudflare
- Local connections still get intercepted/proxied
- Trusted networks sees wrong source IP
- Settings → Advanced Web Settings → Accept Cookies: ON
- Settings → Advanced Web Settings → Clear Cookies on Exit: OFF
- Settings → Web Auto Reload → Reload on Network Reconnect: ON
- Tablets on IoT VLAN (192.168.21.x) can reach HA on Default ([IP])
- Cross-VLAN routing must be enabled in UniFi
- Use IP address, not hostname, for reliability
- 16:56: Kitchen tablet dashboard: layout-card/grid-layout causes red error circle on Fully Kiosk tablets - use vertical-stack + horizontal-stack instead. Tablet entity: notify.mobile_app_kitchen_samsung_tablet_wall_mount (HA Companion) and button.kitchen_wall_a9_tablet_* (Fully Kiosk integration). Kiosk mode needs ?kiosk URL param or admin:true for admin users.
- 19:20: Kitchen tablet automation fix: configuration.yaml was using single file include but automation files were in automations/ directory. Fixed by changing to include_dir_merge_list automations/ and moving automations.yaml to automations/ui_automations.yaml. Tablet wake automation uses binary_sensor.kitchen_motion + person home condition.
- 19:20: Kitchen tablet dashboard rebuild: Created scripts.yaml with kitchen_scene_cooking_bright, kitchen_scene_dinner_dim, kitchen_scene_movie_night, kitchen_scene_all_off, plus music scripts (kitchen_play_chill, kitchen_play_dinner, kitchen_play_kids, kitchen_sonos_stop). Dashboard uses verified entity IDs, added music quick-play buttons, streamlined layout.
- 19:20: Best practice automation directory structure: use include_dir_merge_list automations/ to load all YAML files from directory. Allows organized file-per-automation approach while keeping UI automations in automations/ui_automations.yaml
