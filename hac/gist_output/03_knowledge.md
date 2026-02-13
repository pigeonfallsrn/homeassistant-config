# System Knowledge - 2026-02-13 14:23

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
- 2026-02-09: HAC v8.0 - Enhanced Monitoring & Ghost Detection

## Recent Session Learnings
- 2026-02-13: MCP is now universal (Claude/ChatGPT/Gemini) — HA official MCP Server integration available since 2025.2
- 2026-02-13: Claude Projects can replace gist-based context — upload knowledge base files for persistent RAG access
- 2026-02-13: hac review [days] + hac promote for learning consolidation workflow
- 2026-02-13: Model selection: Sonnet 4.5 default (80% of work), Opus 4.6 for architecture/research, Haiku 4.5 for quick lookups
- 2026-02-13: Entity IDs generated from alias: field, not id: field — always search alias: when looking for automation definitions
**Key Learning:**
Entity ID generation: `alias: "Kitchen - Light"` → `automation.kitchen_light`

**Tools Created:**
- `/homeassistant/hac/scripts/count_automations.py` - Accurate counter
- `/homeassistant/hac/notes/automation_detection_workflow.md` - Reference guide
- `/homeassistant/hac/notes/automation_architecture.md` - System overview
- `/homeassistant/hac/notes/research_findings_ui_vs_yaml.md` - Full investigation

**Conclusion:** 
System already follows HA best practices. Package-based organization is industry standard for large systems. No migration needed. HAC detector needs fix to properly scan packages/.

**Research Sources:**
- Official HA docs (packages, splitting configuration)
- Community forums (100+ automation organization patterns)
- HA blog posts (future of YAML, 2020-2026 releases)
- Git version control best practices for HA

**Time Invested:** ~2 hours deep research
**Value:** Confirmed architecture is exemplary, documented for future reference

## Historical Learnings (last 30 lines)
- Daily statistics counters
- Automated timeout timers
- Removed duplicate: 2nd_floor_bathroom_manual_override
- Renamed for consistency: bathroom helpers now use 1st_floor/2nd_floor naming
- Found UI-created helpers not in YAML: extended_evening_mode, hot_tub_mode, occupancy_mode templates
- These were preserved and remain functional
---
- ✅ Helper system in place
- ✅ Helpers ready: garage_alert_acknowledged, last_garage_alert_sent, garage_open_alert_delay_minutes
- ✅ Counter ready: garage_opens_today
- Alert triggers when garage opens
- Alert repeats every X minutes (configurable)
- Alert can be dismissed via notification action
- Alert stops when garage closes
- Alert stops when manually acknowledged
- Counter increments on garage open
- No more forgotten open garage door
- Configurable alert frequency
- Can acknowledge when intentionally left open
- Foundation for other alert types (doors, leaks, security)
- Phase 1, Item #3: kschlichter Inovelli LED Control Script
- Phase 2, Item #6: Sleep Mode in Adaptive Lighting
- Garage light scene preservation
- HA Alert Docs: https://www.home-assistant.io/integrations/alert/
- Community Guide: https://www.creatingsmarthome.com/index.php/2022/11/14/home-assistant-advanced-garage-door-alert/
- Auto Entities Card: For dashboard display of all active alerts
- 09:30: Garage notification mess: 3 overlapping automation sets were all active. Single source of truth is now packages/garage_quick_open.yaml only. Removed automations/garage_arrival.yaml and garage_door_notifications.yaml plus 17 orphaned entity registry entries.
- 11:51: Fixed 2nd floor bathroom fan Shelly to Inovelli VZM35-SN, added Navien flow pretrigger, purged 52 ghost automations, installed 9 new hac workflow commands
- 22:41: Master Context Excel export system complete: v2.0 with Action Items tab, automated Synology/GDrive sync via hac export command
- 23:08: Upgraded to Master Context Excel v3.0: All sheets have headers, AutoFilter enabled, Dashboard uses Excel formulas for live counts, added LLM-optimized JSON output with token-efficient sampling
