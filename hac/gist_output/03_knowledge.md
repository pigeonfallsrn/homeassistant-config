# System Knowledge - 2026-01-23 12:55

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
- **Tablets:** Kitchen wall tablet (Fully Kiosk), [PERSON]'s Fire tablet
- **Garage:** ratgdo controllers (2x), Aqara motion sensors

### Automation Patterns Established
- **Presence:** Multi-method (WiFi AP + GPS + Motion)
- **Lighting:** Adaptive lighting with manual override detection
- **Bedtime:** Context-aware wind-down (new family_activities system)
- **Notifications:** Actionable mobile notifications with response handling

### HAC Workflow Preferences
- Terminal commands only, no GUI
- Chain with `&&` for efficiency
- `hac backup` before any edit
- Propose → approve → execute pattern
- `hac learn` to capture insights

- 12:24: Double-fire fix: combined motion sensors need delay_on debounce when OR-ing multiple physical sensors
- 12:50: HAC status double-fire false positives: HA sqlite stores multiple state rows per automation trigger (start, attribute updates). Query should use DISTINCT on timestamp rounded to seconds, or check last_changed vs last_updated to filter actual trigger events vs attribute updates
- 12:50: Confirmed: delay_on 150ms on template sensors works - combined sensor fired once at .879 after east sensor at .726 (153ms delta). Double-fires in status were reporting artifact, not actual duplicate automation runs
- 12:51: Fixing HAC status double-fire query to use last_changed_ts instead of last_updated_ts to avoid counting attribute updates as separate triggers

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
