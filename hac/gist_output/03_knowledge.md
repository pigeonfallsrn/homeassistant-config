# System Knowledge - 2026-01-24 11:57

## Architecture Quick Ref
- **Packages:** /config/packages/*.yaml
- **Presence:** input_boolean.john_home (NOT binary_sensor)
- **North garage door:** cover.ratgdo32disco_fd8d8c_door
- **South garage door:** cover.ratgdo32disco_5735e8_door  
- **Walk-in door sensor:** binary_sensor.aqara_door_and_window_sensor_door_3
- **Motion aggregation:** /config/packages/motion_aggregation.yaml

## Critical Rules (from past disasters)
- NEVER use raw sed on YAML without backup
- ALWAYS use `hac sed` or `hac backup` first
- Check `ha core check` before restart
- Inovelli+Hue: Smart Bulb Mode must be ON

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
- 10:54: Kitchen tablet Spotify playback: Scripts use HA Spotify integration to cast to Kitchen Echo Show (Sonos not in Spotify source list initially). Service flow: media_player.select_source to pick device, 4-second delay, then media_player.play_media with spotify:playlist URI. Fixed tablet_power.yaml - replaced invalid fully_kiosk.load_start_url service with button.press on button.kitchen_wall_a9_tablet_load_start_url.
- 11:48: Config audit cleanup commands: Stage 1 unavailable entities: hac cmd 'ha state list' | grep unavailable. Stage 2 check Hue integration health for bulk unavailable lights. Stage 3 find duplicate entity_ids with grep patterns. Stage 4 area config via .storage/core.area_registry. Stage 5 delete orphaned scenes via UI bulk delete. Key issues found: 23 unavailable entities (mostly Hue), duplicate names (Anyone Home, Kitchen media, bathroom plugs), Master Bedroom area corruption (empty comma), low humidity (kitchen 11.7%), orphaned 'New scene' entries.
- 11:50: Config audit 2026-01-24: 23 unavailable entities (mostly Hue lights - 2nd Floor Bath, [PERSON] Echo Glow, Entry/Front Driveway, Garage LiftMaster, Upstairs Hallway Ceiling), duplicate entity names (Anyone Home x2, Kitchen media x2, bathroom plugs x2, VZM36 lights x2), Master Bedroom area corruption (empty comma in 'Master Bedroom, , Dad's Bedroom'), low humidity (Kitchen 11.7%, 1st Bath 19-24%), orphaned scenes (3x 'New scene' unavailable), double-fire issue persists (calendar_refresh automations need mode: single). Cleanup: UI bulk delete unavailable, fix area registry, reconfigure Hue integration, add mode: single to calendar automations.
- 11:54: Config audit 2026-01-24: 492 total unavailable entities. Breakdown: switch(97), script(75), sensor(68), binary_sensor(47), number(47), button(38), light(23), automation(23), select(20), scene(11), media_player(10). Hue bridge healthy ([IP] reachable) - only 1 Hue light unavailable ([PERSON] ceiling LED). Most unavailable are UniFi PoE buttons (expected), Protect camera motion sensors, and likely orphaned scripts/automations. Area registry has empty alias string in Master Bedroom aliases array. Priority: investigate switch/script bulk unavailable - suggests disabled integration or orphaned config.
- 11:56: CONFIG AUDIT METHODOLOGY 2026-01-24: (1) Check unavailable entities via REST API: curl -s -H 'Authorization: Bearer $SUPERVISOR_TOKEN' http://supervisor/core/api/states | python3 -c 'import sys,json; [print(e["entity_id"],e["state"]) for e in json.load(sys.stdin) if e["state"]=="unavailable"]' (2) Count by domain: Counter(e.split(".")[0] for e in unavail) (3) Integration configs in .storage/core.config_entries (4) Area registry in .storage/core.area_registry (5) Entity registry in .storage/core.entity_registry. FINDINGS: 492 unavailable - switch(97 UniFi Protect cam settings), script(75 orphaned from deleted definitions), sensor(68), binary_sensor(47 Protect motion), light(23 inc orphaned Hue + Echo Glows + LiftMaster), automation(23). ROOT CAUSES: Scripts exist in entity_registry but definitions deleted (check .storage backups). AI Theta cameras offline. Generic hue_color_lamp_X are unpaired bulbs. Echo Glows cloud issue. Area registry has empty string in Master Bedroom aliases array. FIX PRIORITY: (1) Restore scripts from backup or purge orphaned entities (2) Check AI Theta physical cameras (3) Clean Hue orphans via Hue app (4) Fix area alias via UI

## Historical Learnings (last 30 lines)
- hacs: v2.0.5
- kumo_cloud: v1.0.0
- navien_water_heater: v1.0.1
- ui_lovelace_minimalist: vv1.5.0
- yamaha_ynca: v9.3.0
-rw-r--r--    1 root     root        1.7K Nov 15 11:17 /config/[PERSON]-dashboard.yaml.backup_20251115_111746
-rw-r--r--    1 root     root       10.2K Nov 15 13:11 /config/[PERSON]-dashboard.yaml.backup_adaptive_20251115_131117
-rw-r--r--    1 root     root       23.5K Dec 15 16:49 /config/automations.backup.yaml
-rw-r--r--    1 root     root       21.8K Jan 12 13:52 /config/automations.yaml.backup
-rw-r--r--    1 root     root       23.5K Dec 26 10:40 /config/automations.yaml.backup-motion
-rw-r--r--    1 root     root        2.8K Dec 21 19:22 /config/automations.yaml.backup2
-rw-r--r--    1 root     root        2.8K Dec 21 20:30 /config/automations.yaml.backup3
-rw-r--r--    1 root     root        2.9K Dec 22 09:29 /config/automations.yaml.backup_1766417359
-rw-r--r--    1 root     root       32.3K Oct 30 06:50 /config/automations.yaml.backup_20251030_065008
-rw-r--r--    1 root     root       29.9K Nov 13 20:57 /config/automations.yaml.backup_20251113_205737
-rw-r--r--    1 root     root         952 Jan 17 22:49 HAC_v4.2_COMPLETE.md
-rwxr-xr-x    1 root     root        6.1K Jan 17 22:45 hac.sh
-rwxr-xr-x    1 root     root        7.5K Jan 17 19:44 hac.sh.broken
-rwxr-xr-x    1 root     root       16.3K Jan 17 19:36 hac.sh.menu_version
-rwxr-xr-x    1 root     root        2.6K Jan 17 19:25 hac.sh.v4.0.backup
-rwxr-xr-x    1 root     root        8.5K Jan 17 22:38 hac.sh.v4.1
-rw-r--r--    1 root     root        2.8K Jan 17 22:59 claude_20260117_225901.md
-rw-r--r--    1 root     root        2.3K Jan 17 22:46 chatgpt_20260117_224653.md
-rw-r--r--    1 root     root        1.8K Jan 17 22:46 gemini_20260117_224652.txt
-rw-r--r--    1 root     root        3.3K Jan 17 22:46 claude_20260117_224600.md
-rw-r--r--    1 root     root        5.2K Jan 17 22:44 claude_20260117_224409.md
-rw-r--r--    1 root     root        5.2K Jan 17 22:43 claude_20260117_224349.md
-rw-r--r--    1 root     root        3.0K Jan 17 22:39 chatgpt_20260117_223945.md
-rw-r--r--    1 root     root        2.2K Jan 17 22:39 gemini_20260117_223933.txt
-rw-r--r--    1 root     root        5.2K Jan 17 22:39 claude_20260117_223925.md
