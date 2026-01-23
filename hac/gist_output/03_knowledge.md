# System Knowledge - 2026-01-23 09:33

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

## Recent Session Learnings
- 09:33: Consolidated 2nd floor lighting: Replaced 3 automations (night_path_upstairs_hallway, night_path_2nd_floor_bathroom, morning_wake_upstairs_hallway) with 2 clean automations: upstairs_hallway_motion_lighting (all time contexts, deep red at night, adaptive handoff day) and 2nd_floor_bathroom_night_lighting (night only, triggered by hallway P1, shower-safe 15min timeout). Disabled morning_wake_master_bedroom in UI. Lines 505 and 570 in occupancy_system.yaml.

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
