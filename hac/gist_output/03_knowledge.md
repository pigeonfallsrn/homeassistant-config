# System Knowledge - 2026-02-12 17:43

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
- 07:05: 2026-02-11 AL cleanup complete: removed 5 ghost instances, disabled Upstairs Zone. Final config: 2 AL instances (Living Spaces + Entry Room Ceiling) managing 5 lights total. System clean and working.
- 07:05: 2026-02-11 AL cleanup complete: Removed 5 ghost instances (bedroom_test, kitchen_entry_ceiling, living_room_ceiling, kitchen_chandelier, pre_release), disabled Upstairs Zone AL. Final config: 2 active AL instances - Living Spaces (4 accent lamps) + Entry Room Ceiling (1 motion light) = 5 lights under AL control. 141 lights remain manual/automation-controlled. Ghost entity conflicts resolved, system clean and working.
- 14:38: 2026-02-11 AL cleanup complete: Removed 5 ghost instances (bedroom_test, kitchen_entry_ceiling, living_room_ceiling, kitchen_chandelier, pre_release), disabled Upstairs Zone AL. Final config: 2 active AL instances - Living Spaces (4 accent lamps) + Entry Room Ceiling (1 motion light) = 5 lights under AL control. 141 lights remain manual/automation-controlled. Ghost entity conflicts resolved, system clean and working.
- 14:41: 2026-02-11 AL cleanup complete: Removed 5 ghost instances (bedroom_test, kitchen_entry_ceiling, living_room_ceiling, kitchen_chandelier, pre_release), disabled Upstairs Zone AL. Final config: 2 active AL instances - Living Spaces (4 accent lamps) + Entry Room Ceiling (1 motion light) = 5 lights under AL control. 141 lights remain manual/automation-controlled. Ghost entity conflicts resolved, system clean and working.
- 15:07: MCP Privacy Policy: Claude has READ-ONLY access to motion/door/temp sensors for context. Claude CANNOT control and has NO live access to: garage doors (covers), locks, water valves, or network equipment. These exist in context CSVs for knowledge but are intentionally blocked from MCP control/query. If user asks about their state, acknowledge from context but state 'I don't have live MCP access - please check HA app.'
- 15:09: MCP Exposure Audit: CORRECT command is 'ha core info' (works). INCORRECT: jq query on entity_registry/list endpoint - API format incompatible. Always verify exposure via HA UI: Settings > Voice Assistants > Assist > Exposed Entities. No reliable CLI method exists for exposure status.
- 15:09: MCP Privacy Boundaries: LIVE ACCESS via MCP = motion sensors (binary_sensor.*_motion), door sensors (binary_sensor.*_door), temp/humidity (sensor.*_temperature/humidity), lights. BLOCKED from MCP = garage door covers (cover.garage_*), locks (lock.*), water valve controls (switch.*_valve*), network equipment (button.usw_*). Context CSVs contain ALL devices for knowledge; MCP provides live state only for safe sensors.
- 15:12: URGENT: Water valve control (switch.basement_domestic_water_main_valve) currently EXPOSED to MCP - must be blocked immediately. Also found: basement_avr_hard_reset exposed. Both are safety-critical controls that should never be in MCP exposure.
- 15:15: AVR hard reset correction: User correctly identified this is just a smart plug for AV receiver, not a critical safety device. Low risk - acceptable to remain exposed. Only TRUE safety-critical items are: water valve (now blocked), garage door covers, locks, network equipment.
- 15:22: MCP Exposure Complete: Added 8 motion sensors + 5 door sensors via terminal script. Total safe sensors now exposed: kitchen/living/entry/upstairs motion detection + all door sensors (garage walk-in, front doors, garage bay door sensors). Water valve remains blocked.
- 15:33: MCP Full Exposure Complete: Exposed all 290 zero-risk sensors (temperature, humidity, battery, power monitoring). Critical controls remain blocked: garage doors, locks, water valve, network equipment. Total MCP context now maximized while maintaining safety.
- 16:10: Upstairs hallway 3-way switch testing in progress. User will determine if switch cuts power to light or if power is always hot. This determines whether Hue click switch installation is required before automations can work. Apollo Pro mmWave sensors planned for kitchen testing, then bedroom installations.
- 17:00: Terminal heredoc syntax (cat << 'EOF') consistently fails in zsh causing dquote> prompts. ALWAYS use simple echo redirection instead: echo 'content' > file. Avoid multi-line heredocs in all future sessions. Use printf or multiple echo commands for multi-line content. This prevents terminal quote hell.
- 17:00: Session 2026-02-12 achievements: MCP exposure optimized (290 safe sensors exposed, critical controls blocked), lighting issues diagnosed ([PERSON] LED needs auto-off, upstairs hallway needs time-based automation or Hue click switch), Apollo Pro mmWave strategy created for future bedroom occupancy detection. Awaiting 3-way switch power test to determine implementation path.
- 17:02: HAC prompt optimization needed: Review all learnings for common patterns, terminal preferences (zsh, no heredocs, simple commands), HA debugging workflow, MCP privacy model, Git habits. Goal: Create condensed strategic session starter that gives LLM maximum context with minimum tokens.
- 17:16: CRITICAL: Avoid complex multi-step scripts that chain multiple heredocs and loops. Script went into infinite loop creating files. Always use simple, single-purpose commands. Test scripts individually before chaining.
- 17:35: Session v3 prompt created with MANDATORY automation workflow: 1) Verify entities exist 2) Check group membership 3) Validate YAML 4) Commit. Added critical rules: NEVER use sed for YAML, NEVER use view tool (use cat/less), ALWAYS verify entity status before creating automations. Prevents sed disasters, vim traps, and entity mismatches.
- 17:35: Entity verification pattern established: python3 one-liners to check entity_registry for hidden/disabled status, core.config_entries for group membership. Light groups created via UI stored in config_entries domain='group', NOT separate files. This workflow eliminates back-and-forth debugging.
- 17:35: [PERSON] LED strip automation COMPLETE: Targets light.alaina_s_led_strips group (contains strip_1 visible + strip_2 hidden). Turns off at midnight. Ready for HA reload. Next: await 3-way switch test results for upstairs hallway automation path.
- 17:43: HAC export workflow: 'hac export' generates comprehensive Excel files (FULL, AI_SAFE, LLM.json) from current HA state - includes entities, devices, areas, integrations, automations, and learnings. Useful for: 1) Generating fresh context before major sessions, 2) Sharing sanitized system state, 3) External analysis in Excel, 4) Backup snapshots. Files sync to Google Drive automatically. Consider running export at session start for up-to-date context.

## Historical Learnings (last 30 lines)
- 07:51: 2ND FL BATHROOM LIGHTING FIX:
- Problem: Lights dim because adaptive_lighting controls light.2nd_floor_bathroom
- Solution: Button press activates TIME-BASED Hue scenes + sets manual_control
- DAY (6am-8pm): Energize scene (bright cool)
- EVENING (8pm-11pm): Relax scene (warm medium)
- NIGHT (11pm-6am): Nightlight scene (dim red)
- Use adaptive_lighting.set_manual_control to pause AL on button press
- Scenes: scene.2nd_floor_vanity_lights_energize/relax/nightlight
- Scenes: scene.2nd_fl_bathroom_ceiling_lights_energize
- 12:06: LIGHTING AUDIT SESSION HANDOFF - 2026-02-07
- Fixed 2nd floor bathroom Inovelli (ceiling+vanity separate, time-based scenes)
- Removed light.2nd_floor_bathroom from Adaptive Lighting (was fighting)
- Set up hybrid automation config (YAML + UI)
- Cleaned up duplicate automations (33→19)
- Created entry_room_aux.yaml, kitchen_inovelli.yaml, living_room_av.yaml, first_person_home.yaml
- Button UP: Time-based scene (Energize 6am-8pm / Relax 8pm-11pm / Nightlight 11pm-6am)
- Button DOWN: Off + clear override
- Button HOLD: Dim up/down
- Motion: Only fires if input_boolean.ROOM_manual_override is OFF
- Override auto-clears after 30 min
- automations/2nd_floor_bathroom_inovelli.yaml (GOOD TEMPLATE - copy pattern)
- automations/1st_floor_bathroom_inovelli.yaml (NEEDS UPGRADE)
- automations/kitchen_inovelli.yaml (NEEDS UPGRADE for chandelier/dimmer)
- automations/entry_room_aux.yaml (NEEDS UPGRADE)
- packages/upstairs_lighting.yaml (DELETE bathroom section, keep hallway)
- scene.2nd_fl_bathroom_ceiling_lights_energize
- scene.2nd_floor_vanity_lights_energize/relax/nightlight
- scene.1st_floor_ceiling_lights_energize/relax/read/nightlight
- Check for kitchen/entry scenes in .storage/core.entity_registry
- 12:36: Completed lighting audit 2026-02-07: Upgraded 4 Inovelli automations (1st floor bathroom, entry room AUX, kitchen chandelier, kitchen lounge) with time-based Hue scenes + manual override. Fixed AL config: enabled auto sunrise/sunset for Wisconsin seasonal tracking, added Entry Room Ceiling dedicated AL instance for motion-activated circadian health, consolidated all AL definitions to main config. Key insight: Motion-activated primary lights NEED dedicated AL instances for circadian health benefits.
