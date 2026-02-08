# System Knowledge - 2026-02-07 13:34

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
Phase 3: Standardize Entry Room AUX (time-based scenes)
Phase 4: Kitchen Chandelier + Lounge Dimmer (time-based scenes, keep Above Sink basic)
Phase 5: Audit all 6 Adaptive Lighting instances
Phase 6: Test + document

BACKUPS: /homeassistant/backups/lighting_audit_20260207/

KEY FILES:
- automations/2nd_floor_bathroom_inovelli.yaml (GOOD TEMPLATE - copy pattern)
- automations/1st_floor_bathroom_inovelli.yaml (NEEDS UPGRADE)
- automations/kitchen_inovelli.yaml (NEEDS UPGRADE for chandelier/dimmer)
- automations/entry_room_aux.yaml (NEEDS UPGRADE)
- packages/upstairs_lighting.yaml (DELETE bathroom section, keep hallway)

HUE SCENES AVAILABLE:
- scene.2nd_fl_bathroom_ceiling_lights_energize
- scene.2nd_floor_vanity_lights_energize/relax/nightlight
- scene.1st_floor_ceiling_lights_energize/relax/read/nightlight
- Check for kitchen/entry scenes in .storage/core.entity_registry
- 12:36: Completed lighting audit 2026-02-07: Upgraded 4 Inovelli automations (1st floor bathroom, entry room AUX, kitchen chandelier, kitchen lounge) with time-based Hue scenes + manual override. Fixed AL config: enabled auto sunrise/sunset for Wisconsin seasonal tracking, added Entry Room Ceiling dedicated AL instance for motion-activated circadian health, consolidated all AL definitions to main config. Key insight: Motion-activated primary lights NEED dedicated AL instances for circadian health benefits.

## Historical Learnings (last 30 lines)
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
- 15:21: DOUBLE-FIRE ROOT CAUSES FIXED (2026-02-02): (1) Motion aggregation sensors (downstairs_motion, upstairs_motion, house_motion) had NO delay_off - added 60s/60s/90s respectively. (2) Six orphan automation entities in registry were triggering alongside current automations - removed calendar_refresh_school_tomorrow, calendar_refresh_school_in_session_now, entry_room_lamp_adaptive_lux_control, kitchen_lounge_lamp_adaptive_lux_control (these had old entity_ids but same unique_ids as current automations). (3) Entry Room P1 motion sensor added to aggregation. RESULT: No double-fires in past hour per hac health.
- 15:34: DOUBLE-FIRE ROOT CAUSES FIXED (2026-02-02): (1) Motion aggregation sensors (downstairs_motion, upstairs_motion, house_motion) had NO delay_off - added 60s/60s/90s respectively. (2) Six orphan automation entities in registry were triggering alongside current automations - removed calendar_refresh_school_tomorrow, calendar_refresh_school_in_session_now, entry_room_lamp_adaptive_lux_control, kitchen_lounge_lamp_adaptive_lux_control (these had old entity_ids but same unique_ids as current automations). (3) Entry Room P1 motion sensor added to aggregation. RESULT: No double-fires in past hour per hac health.
- 20:11: list
- 20:16: Created garage_arrival.yaml: 3 automations using person.john_spencer trigger (not proximity sensor). notify.mobile_app_john_s_phone + ratgdo covers.
- 21:38: Garage arrival system complete: cover.ratgdo32disco_fd8d8c_door (North), cover.ratgdo32disco_5735e8_door (South), 15sec delay before close prompt
- 21:41: [PERSON] wake automation: sensor.alaina_s_bedroom_echo_show_next_alarm triggers 10min sunrise fade. Conditions: home + 5am-10am. Phases: 1%/2000K → 10%/2200K → 30%/2700K → 60%/3200K → Energize scene
- 21:44: [PERSON] wake: sensor.alaina_s_bedroom_echo_show_next_alarm_2 (UTC format). Triggers 10min before alarm, 5-phase sunrise fade to Energize scene. Conditions: home + 5am-10am
- 21:57: Exterior auto-off: front_driveway_auto_off (5min no motion), garage_lights_auto_off (5min all 6 motion sensors off). Both use transition: 5 for smooth fade.
- 19:59: Hue scene cleanup: Keep only Energize+Nightlight+Concentrate per room. 448 registry scenes after zones auto-created defaults. Tap Dial configs: Entry Room 4-button, Master Bedroom B1=Energize B2=Dimmed B3=Nightlight B4=Off (hold=Entire Home). Tabled: Create Hue groups for [PERSON]/[PERSON] ceiling bulbs, FoH Hot Tub Mode, Entry ceiling bulb swap to Ambiance.
- 20:22: MOTION LIGHTING BEST PRACTICES (researched 2026-02-02): (1) DEBOUNCING: Use 'for:' on off triggers (60-120s) to prevent bounce. (2) MODE: Use 'mode: restart' for single automation with choose blocks - ensures immediate response to new motion while resetting timers. Use 'mode: single' for separate on/off automations. (3) AGGREGATION: Template binary sensors combining multiple motion sensors MUST have delay_off to prevent cascading triggers. (4) PATTERN: Dual-trigger with IDs (motion_on/motion_off) in single automation with choose block is cleanest. (5) CONDITIONS: Check lux/sun before turning on, not just in action. (6) RACE CONDITION FIX: Ensure aggregated motion sensor has delay_off >= individual sensor clear time.
- 20:51: MOTION AGGREGATION FIXES (2026-02-02): (1) Added Entry Room P1 (binary_sensor.aqara_motion_sensor_p1_occupancy) to entry_room_motion_combined - now has 3 sensors (P1 + 2x Third Reality). (2) Added delay_off: 60s to downstairs_motion_any and upstairs_motion_any aggregates. (3) Added delay_off: 90s to house_motion_any aggregate. (4) P1 SENSOR MAPPING: aqara_motion_sensor_p1_occupancy=Entry Room, _2=Upstairs Hallway, _3=1st Floor Bath Hallway, _6=Very Front Door. This prevents double-fire race conditions on Living Room and global automations.
- 20:51: MOTION AGGREGATION PATTERN: Room-level sensors get 30s delay_off + 150ms delay_on. Floor-level aggregates (downstairs/upstairs) get 60s delay_off. House-level aggregate gets 90s delay_off. This creates a debounce cascade that prevents automation double-fires.
- 21:26: ORPHAN AUTOMATION CLEANUP (2026-02-02): Removed 4 ghost automations from entity registry that were causing double-fires: calendar_refresh_school_in_session_now, calendar_refresh_school_tomorrow, entry_room_lamp_adaptive_lux_control, kitchen_lounge_lamp_adaptive_lux_control. These existed in registry but not in YAML (renamed/deleted). Root cause: HA keeps entity registry entries even when YAML is removed. Fix: Direct registry edit to remove orphans.
