# System Knowledge - 2026-01-26 12:52

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
- 07:27: Lighting audit: removed 2 duplicate upstairs_hallway_motion automations (IDs 1769232386253, 1769232392078), verified Smart Bulb Mode on 4 Inovelli switches, created kitchen_chandelier Hue group, added AL instance with best practices (separate_turn_on_commands, take_over_control, detect_non_ha_changes=false)
- 11:05: 1st Floor Bathroom Motion Lighting template: trigger=hallway P1 motion, light=Hue ceiling group, night=10%/2200K, day=AL controls, timeout=8min, override=auto-reset on light off, mode=restart. Pattern reusable for other rooms. Vanity upgrade tabled: swap Inovelli to TP-Link dimmer for 3 dumb LEDs.
- 11:41: Automations location: /homeassistant/automations/ dir (not automations.yaml). Config uses include_dir_merge_list. Created bathroom_motion_lighting.yaml for motion automations.
- 11:54: 2nd Floor Bathroom motion lighting added. Disabled 2 old automations: bathroom_red_light_11pm_5_30am + 2nd_floor_bathroom_night_lighting (never triggered). New uses template sensor upstairs_bathroom_motion_combined + time_context. Both bathrooms consistent: 8min timeout, 10pct/2200K night, AL day, shared override.
- 11:56: ZSH CLI rules: 1) escape ! with quotes or omit (use "include_dir" not !include_dir), 2) avoid chaining commands after python3 -c with && on same line - run separately, 3) use single quotes for hac learn strings with special chars
- 12:11: Session summary: HAC script needs update - add automations dir + ZSH rules to Architecture/Critical Rules sections. Fix Historical Learnings grep. See previous session for full proposed changes.

## Historical Learnings (last 30 lines)
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
- 09:01: Created garage_quick_open.yaml with north door open/close notifications. Removed approaching_home and [PERSON] arrival from notifications_system.yaml. Installed HAC v6.0 with pkg/ids/edit/table commands.
- 09:16: HAC v6.1 deployed. Cleaned garage automations - removed duplicate notification handlers from garage_lighting_automation.yaml, kept lights on/off + left-open reminder. garage_quick_open.yaml handles north door open/close notifications. 5 orphan automations disabled.
- **HA Green hung** (Core unresponsive, SSH refused, but ping works): Use UniFi Network console to power cycle switch port 8 instead of physical unplug. Faster recovery.
- 15:45: Fixed double-trigger issue in kitchen_lounge_lamp_adaptive_control and entry_room_lamp_adaptive_lux_control. Added 5-second debounce condition using last_triggered timestamp. Reloaded automations. Fixed dad_bedtime_mode unavailable state (input_boolean reload).
- 16:05: Fixed double-trigger root cause - changed motion triggers from individual sensors to combined binary_sensor.kitchen_lounge_motion and binary_sensor.entry_room_motion. This eliminates the race condition where two sensors fired simultaneously.
- 17:02: MCP OAuth status 2026-01-22: HA creates tokens successfully, Claude.ai callback fails to complete handshake. Beta bug on Anthropic side. Infrastructure ready - will work when fixed. Pivot to exposure audit and WAF rules.
- 17:56: MCP CONNECTED 2026-01-22. Claude Desktop working via mcp-remote + Bearer token. Config: cmd.exe /C npx -y mcp-remote. Required: Node.js install + mkdir npm folder. 23 tools available. Claude.ai web OAuth still broken (beta bug) but Desktop works.
- 18:24: MCP SETUP COMPLETE 2026-01-22: Claude Desktop connected via mcp-remote+Bearer token. Claude.ai web OAuth blocked (Anthropic beta bug). 499 entities exposed, need to hide ~70 more (person/location/status sensors). TODO: rotate token, run jq command to hide sensitive entities, add Cloudflare WAF rule. Hybrid workflow: HAC=context+YAML, MCP=realtime queries+actions.
- 18:25: MCP SETUP 2026-01-22: Claude Desktop connected (mcp-remote+Bearer). Claude.ai OAuth blocked (Anthropic bug). 499 entities exposed, ~70 sensitive to hide. TODO: rotate token, jq hide entities, Cloudflare WAF. See mcp_integration_handoff.md for full details.
- 18:53: HAC v7.0 deployed - secret gist, auto-backup, safe sed, privacy sanitization
- 20:12: Fixed apply_context_on_time_change double-fire by removing redundant sun/time triggers (sensor.time_context already handles those transitions). Cleaned up .backup files from packages dir.
- 20:15: Fixed apply_context_on_time_change double-fire by removing redundant sun/time triggers (sensor.time_context already handles those transitions). Cleaned up .backup files from packages dir.
- 20:20: HAC v7.1 deployed: audit, sed --preview, diff, restore, check, hygiene. Fixed context_apply_on_time_change double-fire. Monitor 21:00 for calendar_refresh_school_in_session_now.
- 21:13: HAC v7.2: Python sanitizer with entity ID preservation. Sanitizes zone names, addresses, emails, IPs. Preserves snake_case entity IDs for debugging.
- 22:00: Fixed garage lights staying on - OFF trigger now fires after 6min in any state (removed 'to: off'). Migrated garage door notifications to native alert: integration with input_datetime snooze (survives restarts). Added South door quick close option. Reduced close notification delay 5s→2s. Added arrival lights automation (driveway + garage at night when approaching).
- 22:53: Adaptive lighting best practices: 1) Use lux-based triggers not sun.sun for precision, 2) Add activity boost automation to restore brightness when motion detected while dimmed, 3) Use consistent motion sensors (aggregated) for both on and timeout triggers, 4) Use platform:time with sensor for reliable hard-off (not template string match), 5) Remove redundant per-room everyone-left automations when global exists, 6) Tune timeouts per room type: transition spaces 5/10min, active areas 8/20min, relaxation areas 15/45min, 7) Add brightness gate (above 50) on dim automations to prevent re-dimming, 8) Keep lux sensors in motion_aggregation.yaml for centralized management.
