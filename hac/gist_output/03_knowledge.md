# System Knowledge - 2026-01-26 17:33

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
- 16:49: System Review 2026-01-26: 112 automations across 23 packages. Lighting: 4 AL instances (Living Spaces fixed today, Kitchen Chandelier correct, Entry Room Ceiling disabled, Bedroom test). Motion rooms: both bathrooms 8min/10%/2200K night, entry 5/10min, kitchen lounge 8/20min, living room 15/45min. All use combined sensors. Inovelli+Hue SBM verified on 5 switches. Tabled: Phase 2 family_activities, 1st floor vanity TP-Link swap, 2nd floor bathroom smart upgrade.
- 16:49: Unavailable entities to clean: Front Driveway North/South lights, Garage LiftMaster lights x4 (ratgdo replaced), Living Room Hue Color Lamps group, Living Room Lounge Ceiling Hue Color group, Entry Room Ceiling Hue White group, Very Front Door Motion sensor.
- 16:49: Rec priorities: (1) Check/recreate unavailable Hue groups in Hue app, (2) Verify upstairs hallway motion automation, (3) Consider consolidating activity boost into main adaptive control, (4) Enable or remove Entry Room Ceiling AL, (5) Delete stale entities via UI
- 16:53: Disabled old 2nd_floor_bathroom_night_lighting in occupancy_system.yaml - replaced by bathroom_motion_lighting.yaml. Fixed upstairs_hallway_motion_lighting to use combined sensor.
- 16:57: Disabled old 2nd_floor_bathroom_night_lighting in occupancy_system.yaml - replaced by bathroom_motion_lighting.yaml. Fixed upstairs_hallway_motion_lighting to use combined sensor.
- 17:00: Fixed Entry Room Ceiling AL: separate_turn_on_commands=true (was false). Updated via .storage/core.config_entries.
- 17:07: Session complete: 5 config fixes applied (2 AL separate_turn_on_commands, 2 combined motion sensors, 1 disabled duplicate). Remaining UI tasks: recreate 3 Hue groups, delete 6+ stale entities, enable Entry Room Ceiling AL if desired.
- 17:16: Front Driveway North/South Hue bulbs: controlled by TP-Link 3-way switch (not always hot). Shows unavailable in HA when switch is off. Not a bug - working as designed. Same pattern as 2nd floor bathroom (SPST). These are NOT smart bulb mode setups - physical switch controls power to bulbs.
- 17:16: Front Driveway North/South Hue bulbs: controlled by TP-Link 3-way switch (not always hot). Shows unavailable in HA when switch is off. Not a bug - working as designed. Same pattern as 2nd floor bathroom (SPST). These are NOT smart bulb mode setups - physical switch controls power to bulbs.
- 17:17: Hue switches inventory: DIMMER SWITCHES: [PERSON] Bedroom, [PERSON] Bedroom, Garage, Living Room Lounge (not configured). TAP DIAL SWITCHES: Entry Room, Master Bedroom. WORKS WITH HUE (Friends of Hue): [PERSON] Bedroom Hue Light Switch, Living Room Hue Switch, Living Room Lounge Hue Switch. Note: Living Room Lounge Dimmer shows "Not configured in this app" - may need setup or is orphaned.
- 17:26: Hue Bridge: IP [IP], Zigbee Ch25, 52 lights, 9 switches. MotionAware areas (4): [PERSON] Bedroom, Living Rm Lounge, Upstairs, [PERSON] Bedroom - these are Hue-native motion-triggered lighting zones that may conflict with HA automations. Smart home integrations: not configured (Alexa/Google/Matter available but unused).
- 17:26: Hue switch config summary: DIMMER SWITCHES (4): [PERSON] Bedroom (Concentrate scene), [PERSON] Bedroom (Time-based), Garage (Time-based), Living Room Lounge (SPARE in box). TAP DIALS (2): Entry Room (1st Floor Table Lamps, Time-based, buttons 2-4 unused - candidate for Hot Tub Mode), Master Bedroom (Master Bedroom room, Time-based). FRIENDS OF HUE (3): [PERSON] Bedroom (4-btn), Living Room (4-btn - needs reconfigured for Inovelli fan/light), Living Room Lounge (4-btn).
- 17:26: Hue/HA conflict analysis: (1) Hue Time-based light competes with HA Adaptive Lighting - both adjust color temp by time. (2) Hue MotionAware areas may conflict with HA motion automations. (3) Friends of Hue switches controlling Hue rooms cannot natively control ZHA devices like Inovelli. RECOMMENDATION: For rooms with HA AL control, disable Hue Time-based and MotionAware. Route button events through HA for unified control. Keep Hue direct control only for kids rooms (reliability when HA down).
- 17:28: Govee LED strips (separate from Hue, WiFi-based): [PERSON] Bedroom has 2 strips named "1" and "2" (need renaming), [PERSON] Bedroom has "[PERSON] LED lights", Living Room has "Living Room TV LED" strip, Master Bedroom LED strip exists but shows in Living Room (wrong room assignment in Govee app). These are NOT in Hue ecosystem - controlled via Govee integration or local API.
- 17:32: Govee LED strips (separate from Hue, WiFi-based): [PERSON] Bedroom has 2 strips named "1" and "2" (need renaming), [PERSON] Bedroom has "[PERSON] LED lights", Living Room has "Living Room TV LED" strip, Master Bedroom LED strip exists but shows in Living Room (wrong room assignment in Govee app). These are NOT in Hue ecosystem - controlled via Govee integration or local API.
- 17:32: Multi-ecosystem inventory: (1) HUE: 52 lights, 9 switches, Zigbee Ch25, Bridge at [IP]. (2) GOVEE: 2x Floor Lamp Basic (H6076, LAN Control ON, Living Room), LED strips for kids rooms + Living Room TV + Master Bedroom. (3) AQARA: Light strips (Kitchen_Under_Cabinet, Master_Bedroom_Behind_TV), Outlet in Basement. (4) KASA/TP-LINK: Basement_Hallway switch, Kitchen_Above_Sink_Light switch, 1st Floor Bathroom Vanity (all showing Offline in Govee favorites - wrong app). (5) ZHA: Inovelli switches, Aqara sensors, Third Reality nightlights on Sonoff coordinator.
- 17:32: Govee Floor Lamps (H6076): LAN Control enabled, Matter-capable, FW 1.04.05. Both named "Floor Lamp Basic" (need renaming to Living Room East/West Floor Lamp). These are the AL-controlled lamps in Living Spaces instance.
- 17:32: Aqara ecosystem (via Aqara Home app, likely also in ZHA): SECURITY: 2x Door/Window (Default Room), Water Leak x5 (Kitchen Sink, Dishwasher, Refrigerator + Basement x2), Motion x6 (Kitchen x2, Upstairs Hallway, Basement Hallway, Very Front Door Hallway, Entry Room). Door sensors at: Very Front Door, Entry Room Front, Entry Room (back?), Garage. ENVIRONMENT: Temp/Humidity/Pressure sensors in 1st Fl Bathroom, 2nd Fl Bathroom, Basement, Upstairs Hallway, [PERSON] Bedroom, [PERSON] Bedroom, Garage. Illumination sensors in Kitchen x2, Upstairs Hallway, Basement Hallway, Very Front Door Hallway, Entry Room (all OFF in overview - not displayed on dashboard). OUTLET: 1x Basement.
- 17:32: Aqara illumination sensors (lux) exist but not enabled in Aqara overview: Kitchen_Motion, Kitchen Table, Upstairs_Hallway, Basement Hallway, Very Front Door Hallway, Entry_Room. These SHOULD be used for lux-based lighting triggers in HA - verify they are exposed in ZHA and used in automations.
- 17:33: Current environment readings (2026-01-26 ~18:30): Bathrooms 70-77F/18-20%, Basement 66F/27%, Hallway 74F/19%, [PERSON] Bedroom 73F/20%, [PERSON] Bedroom 75F/19%, Garage 53F/25%. All humidity low (winter). Aqara sensors showing LAN mode (local, not cloud).

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
