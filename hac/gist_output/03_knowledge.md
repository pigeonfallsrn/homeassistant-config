# System Knowledge - 2026-02-09 09:42

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
- 09:41: Garage arrival automation complete: 400m trigger, Bluetooth van detection, instant notifications, auto-restart on hac check, dashboard auto-open on van BT connect to /lovelace/arriving

## Historical Learnings (last 30 lines)
- Vanity switch (602bdb2b4675a5e364853ac1e53ed689) -> light.2nd_floor_vanity_lights
- Fan switch (3eed85f7ca546a7ed7e24b0cfc6c818b) -> switch.upstairs_bathroom_fan
- Humidity auto: >65% on, <55% off with manual override
- Key: Use Hue ZONE entities not Room entity for separate control
- 20:16: HYBRID AUTOMATION SETUP (Best Practice):
- automation manual: include_dir_merge_list automations/ (YAML)
- automation ui: include automations.yaml (UI-created)
- Blueprints now work from UI and save to automations.yaml
- Existing YAML automations preserved in automations/ dir
- Source: Official HA docs splitting_configuration
- 20:35: AUTOMATION CLEANUP SESSION:
- ui_automations.yaml - old UI automations duplicated in dedicated files
- bathroom_motion_lighting.yaml - duplicates 1st/2nd floor bathroom
- All .bak files in automations/
- 1st_floor_bathroom_inovelli.yaml
- 2nd_floor_bathroom_inovelli.yaml (new humidity/fan setup)
- upstairs_bathroom_motion.yaml (2nd floor motion)
- alaina_wake_echo_alarm.yaml
- exterior_lights_auto_off.yaml
- garage_arrival.yaml
- garage_door_notifications.yaml
- kitchen_tablet_wake.yaml
- tablet_power.yaml
- entry_room_aux_switch
- kitchen_lounge_vzm36_fixed
- kitchen_lounge_dimmer_fixed
- kitchen_chandelier_switch_v2
- kitchen_above_sink_inovelli
- living_room_tv_off_trigger_av_system_off
- first_person_home_lights_on
