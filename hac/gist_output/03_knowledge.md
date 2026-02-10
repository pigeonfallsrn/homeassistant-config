# System Knowledge - 2026-02-09 19:52

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
- 12:49: Google Sheets Export v3.1 BREAKTHROUGH 2026-02-09: Now reading from HA registry files (.storage/core.entity_registry, core.device_registry, core.area_registry). MASSIVE improvements: 30 areas (was 1), 30 integrations (was 0), 367 actual devices with manufacturer/model (was 21 generic domains), 1198 action items (down from 2089). All entities now have correct area assignments. Devices tab shows real device names, manufacturers, models. Integrations tab shows all 30 platforms. This is the complete, production-ready version.
- 12:57: Phase 1 COMPLETE 2026-02-09 12:49: Master workbook fully operational with all 13 tabs populated. Next: Create LLM Index companion workbook for token-efficient queries (~700 tokens vs ~15,000). Current master: 3,201 entities, 193 automations, 30 areas, 30 integrations, 367 devices, 1,198 action items, 2 sessions. Export automation runs daily 11PM, on startup, and manual button.
- 13:24: LLM Index workbook created 2026-02-09: https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk - This will be the token-efficient companion with 5 summary tabs. Spreadsheet ID saved to /config/.llm_index_id. Next: Create dual export script that populates both master (full data) and LLM index (summaries).
- 13:59: Export v4.0 DUAL WORKBOOK COMPLETE 2026-02-09 13:58: Revolutionary setup working perfectly. TWO workbooks: (1) Master https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w - full data 13 tabs for deep analysis. (2) LLM Index https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk - 5 summary tabs (~700 tokens, 86% reduction). Script: /config/python_scripts/export_to_sheets.py exports to BOTH simultaneously. Auto-runs daily 11PM, startup, manual button. This is PRODUCTION READY.
- 14:07: HAC command enhancement 2026-02-09 14:04: Added 'hac sheets' command for quick dual-workbook export from terminal. Complements existing 'hac export' (Excel files). New workflow: 'hac sheets' updates both Google Sheets workbooks instantly. Function added to /config/hac/hac.sh. Ready for Part B: Gemini AI integration.
- 14:09: Gemini AI Integration COMPLETE 2026-02-09 14:08: Added AI-powered features to Master workbook. Dashboard now has Gemini Insights section with 5 pre-configured questions (automation gaps, area attention, device reliability, energy efficiency, next automations). New 'AI Suggestions' tab with automation recommendations across 5 categories. Chart recommendations added to Dashboard. Script: /config/python_scripts/add_gemini_formulas.py. Both Part A (hac sheets) and Part B (Gemini AI) COMPLETE.
- 14:18: Git security fix 2026-02-09 14:15: Removed Google service account credentials from git history using git-filter-repo. Both ha-service-account.json and homeassistant-sheetsync-c7be17aa6748.json purged from all commits. Added to .gitignore to prevent future commits. Successfully pushed cleaned history to GitHub. Credentials remain local-only in /config/ for Google Sheets API access.
- 14:33: Service account credentials restored. hac sheets working. System operational.
- 15:44: Major cleanup 2026-02-09: Fixed malformed area names (Master Bedroom, Upstairs Bathroom), removed 31 unavailable entities, standardized naming
- 16:13: Major cleanup 2026-02-09: Fixed malformed area names (Master Bedroom, Upstairs Bathroom), removed 31 unavailable entities, standardized naming
- 16:13: Cleanup complete 2026-02-09: Renamed Upstairs Bathroom area, disabled unavailable Hue devices (Front Driveway lights, vanity lights), updated automation area references in upstairs_lighting.yaml and occupancy_system.yaml. System cleaned from 3,201 entities with 31 unavailable down to clean working state.
- 16:22: Garage lighting fix 2026-02-09: Upgraded automation to use ALL 5 motion sensors (was only 2), added adjustable timeout helper (10min default), added night dimming (30% brightness 10PM-6AM). Fixes issue where lights turned off while working in garage away from door sensors.
- 16:33: Learnings export to Google Sheets COMPLETE 2026-02-09: Built learnings parser that reads all 25 learning files from /config/hac/learnings/, auto-categorizes by type (Automation, Lighting, Integration, etc.), extracts tags, and exports to new Learnings tab in Master workbook. 127 total learnings now searchable, filterable, and queryable. Stats: 66 Automation, 25 Lighting, 14 Integration. Top tags: automation (50), motion (33), hue (31). Token-efficient alternative to reading raw text files.
- 16:39: AI Query Dashboard COMPLETE 2026-02-09: Added 10 pre-configured Gemini AI query buttons to Dashboard tab. One-click insights for learning patterns, focus areas, area analysis, complexity ranking, monthly comparison, integration health, automation evolution, top tags, lighting insights, and recent wins.
- 16:44: AI Insights Historical Tracking COMPLETE 2026-02-09: Built complete tracking system for AI queries and responses. New 'AI Insights History' tab logs: timestamp, query type, question, AI response, implementation status (📋 Planned, 🔄 In Progress, ✅ Complete), notes, and tags. Added 'hac track' command for manual logging. Dashboard now includes tracking instructions. Creates closed-loop improvement system - track what AI recommends, mark when implemented, see evolution over time.
- 16:46: AI Insights Historical Tracking COMPLETE 2026-02-09: Built complete tracking system for AI queries and responses. New 'AI Insights History' tab logs: timestamp, query type, question, AI response, implementation status (📋 Planned, 🔄 In Progress, ✅ Complete), notes, and tags. Added 'hac track' command for manual logging. Dashboard now includes tracking instructions. Creates closed-loop improvement system - track what AI recommends, mark when implemented, see evolution over time.
- 16:57: SESSION COMPLETE 2026-02-09 17:00: Built complete AI-powered knowledge management system. Learnings export (131 learnings auto-categorized), AI query dashboard (10 persistent buttons), historical tracking with status management, garage lighting fixed, system cleaned. Dashboard now permanently includes AI Insights section that persists across exports. Token-efficient (86% reduction), Gemini AI integration working, closed-loop improvement system operational. LEGENDARY session.
- 16:57: SESSION COMPLETE 2026-02-09 17:00: Built complete AI-powered knowledge management system. Learnings export (131 learnings auto-categorized), AI query dashboard (10 persistent buttons), historical tracking with status management, garage lighting fixed, system cleaned. Dashboard now permanently includes AI Insights section that persists across exports. Token-efficient (86% reduction), Gemini AI integration working, closed-loop improvement system operational. LEGENDARY session.
- 19:32: Calendar refresh automations (school_tomorrow, school_in_session_now) double-fire on restart - expected behavior with mode: single protection
- 19:51: Upgraded HAC to v8.0: Added double-fire ignore list for calendar automations, new ui-automations command (found 187 UI automations), and doctor command for comprehensive diagnostics. Fixed kitchen tablet brightness and google sheets startup delays.

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
