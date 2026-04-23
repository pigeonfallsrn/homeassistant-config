# LEARNINGS — Accumulated across sessions
# Append-only. Never overwrite. Promote mature entries to Project Instructions.

---

## S51 (2026-04-21) — Green Deprecation + Dashboard Cleanup + Governance

### Green Deprecation Pattern
- Systematic: harvest configs → save creds to NordPass → verify on EQ14 → shutdown
- 59 integrations were actively conflicting — especially 4x Adaptive Lighting instances fighting EQ14's AL
- "No automations on old instance" does NOT mean "no interference" — integrations still poll/control devices
- PROMOTED S50, confirmed S51: after migration, remove ALL integrations on old instance that connect to devices the new instance manages

### HAC Workflow Review
- Green had hac.sh v9.1 (73KB) with learn/promote/health/table/doctor/route commands
- Most patterns superseded by Claude Project memory + HANDOFF.md + LEARNINGS.md
- Worth porting to EQ14: `hac health` — REST API query for unavailable entities, double-fires, integration status
- Not worth porting: gist-based context sharing (replaced by Claude Project), sanitization (no longer publishing)
- knowledge.yaml structured format (id, category, times_hit, promoted) was interesting but Claude memory handles this more naturally

### Dashboard Learnings
- auto-entities exclude filters: use glob patterns (light.adaptive_*, light.*inovelli*)
- Mushroom cards in 3-col grid still truncate entity names — consider 2-col or explicit name overrides
- show_empty: false hides entire auto-entities section when no matches — clean UX for "Lights On Now"
- Climate entity IDs: climate.1st_floor_nest_thermostat, climate.2nd_floor_nest_thermostat (not downstairs/upstairs)
- Front driveway light entity: light.front_driveway_2 (not light.front_driveway_inovelli)

### YAML Dashboard Removal
- configuration.yaml lovelace dashboards block: strip entire dashboards: section, keep lovelace: mode: storage
- Archive files before deleting: mkdir archive dir, mv files, rmdir original
- ha core restart required after configuration.yaml changes (not just reload)

## S52 — Full System Audit (2026-04-22)

### Adaptive Lighting entity naming pattern (CRITICAL)
- AL main switch entity IDs follow: switch.{instance_name}_adaptive_lighting_{instance_name}
- NOT switch.adaptive_lighting_{instance_name} (which is the old/intuitive format)
- Example: switch.living_spaces_adaptive_lighting_living_spaces (NOT switch.adaptive_lighting_living_spaces)
- adaptive_lighting.apply service requires the correct main switch entity_id or throws AssertionError
- This affected 4 automations with 16 recurring errors

### Hue migration entity renames — widened scope (3rd occurrence, PROMOTE)
- S42: Entry Room entities. S44: Bathroom + tablet. S52: Entry room lamp + kitchen + living room + master bedroom
- After Hue Bridge migration, entity names change unpredictably: light.entry_room_hue_color_lamp → light.entry_room_desk_lamp
- Also Inovelli entities: light.kitchen_ceiling_inovelli_vzm31_sn → light.kitchen_ceiling_can_led_lights_inovelli
- Midnight automation had 8 broken refs across kitchen, living room, and master bedroom lights
- RULE REINFORCEMENT: Entity ref verification before ANY review is mandatory. This is now a 3+ occurrence pattern.

### Ghost script rule confirmed (3rd occurrence)
- S45: kids scripts. S52: same pattern — ella_lights_off, ella_school_night, alaina_lights_off, alaina_school_night
- Scripts with restored:true and no config require ha_remove_entity, not ha_config_remove_script
- These survived from S45 cleanup — likely re-created by registry restore or missed in that session

### Template package YAML/UI collision pattern
- sensor.people_home_count (YAML template, unavailable) vs sensor.people_home_count_2 (UI template, working)
- YAML templates that fail to render on startup get restored:true and stay unavailable permanently
- If a UI replacement exists with _2 suffix, the fix is: remove YAML definition, rename UI entity to drop _2

### python_transform string method restrictions
- python_transform in ha_config_set_automation does NOT allow .replace() on strings
- For multi-entity-ref fixes, full config replacement is required (not python_transform)
- Allowed string methods: startswith, endswith, lower, upper, split, join, strip

### hac.sh not on EQ14
- shell_command.hac_export calls hac.sh which was on Green, not ported to EQ14
- automation.hac_daily_master_context_export runs daily and generates return code 127 errors
- Either port hac.sh or disable the automation until ported

## S53 — 2026-04-22

### HUE MIGRATION RULE — 6th occurrence (PROMOTED)
Master Bedroom Tap Dial Switch automation had ALL 5 triggers referencing dead `event.hue_tap_dial_switch_3_*` entity IDs. Automation was 100% non-functional. Correct entities were `event.master_bedroom_tap_dial_switch_*`. This is the 6th confirmed occurrence of stale Hue generic entity refs surviving migration. Rule: after ANY Hue device review, scan all automations for `hue_` prefixed entity refs.

### Premature script anti-pattern
`script.apply_tablet_context` was built referencing 5 dashboard URLs that didn't exist yet (kitchen-guest, kitchen-away, kitchen-john, kitchen-kids, kitchen-family). It failed on every occupancy change since creation. Also used `entity_id` targeting for `fully_kiosk.load_url` which requires `device_id`. Lesson: don't build automations/scripts referencing resources that don't exist yet. Build the infrastructure first.

### VZM36 device rename creates ghost entity registrations
Renaming a VZM36 device from "Upstairs Hallway" to "Master Bedroom" created new entity registrations at `master_bedroom_vzm36_*` without removing the old `upstairs_hallway_vzm36_*` ones. Both sets exist in registry. The old-prefix entities are the live ones (have state), the new-prefix ones are stale ghosts. Attempting `new_entity_id` rename fails with "already registered." Low priority — diagnostic entities only.

### Master Bedroom Tap Dial layout pattern
Bedroom with FOH + Tap Dial: FOH at door = power states (ON/Energize/OFF/Nightlight). Tap Dial at nightstand = comfort from bed (Relax/Read/Nightlight/Fan, rotary=dim). Nightlight on both controllers because it's needed from either location. Fan on tap dial button 4 — only non-lighting need from bed.

## S54 — Hue Ecosystem Audit (2026-04-22)

### Hue Bridge Automation Switches — MCP 500 Error
- switch.hue_bridge_automation_* entities throw 500 Internal Server Error when toggled via MCP ha_call_service OR REST API
- Must be toggled in HA UI manually (Settings → Devices → Hue Bridge)
- Likely a Hue bridge API / behavior_instance endpoint issue, not an HA problem

### Bridge Automation Dual-Fire Pattern
- Bridge-side automations (switch.hue_bridge_automation_*) run independently of HA automations
- If HA also has automations for the same accessory, BOTH fire on every button press
- Rule: If HA handles scene cycling for an accessory, disable that accessory's bridge automation
- Keep bridge automation ON only for accessories with no HA automation (pure bridge control)

### Hue Scene Reliability — Bridge Native vs HA
- Hue bridge scenes send atomic group commands (all lights in one Zigbee message) — smoother, faster
- HA-created scenes send sequential commands to each light individually
- scene.turn_on on a Hue scene entity delegates to the bridge API — you get atomic group control
- Always prefer Hue bridge scenes for multi-bulb rooms, not HA-created scenes

### Hue Rooms vs Zones (confirmed)
- Rooms: exclusive (each bulb belongs to exactly one room), represent physical spaces
- Zones: flexible (bulbs can be in multiple zones), represent logical subsets
- Use zones for scene cycling on bulb subsets (e.g., Kitchen Chandelier zone = 5 chandelier bulbs only)
- 64 groups max per bridge (rooms + zones combined)

### Entity Ref Audit — 4th occurrence (S42, S44, S45, S54)
- Entry Room tap dial: 5 stale refs (hue_tap_dial_switch_1_* → entry_room_tap_dial_switch_*)
- Living Room FOH: 8 stale trigger refs + 3 missing helpers (completely dead automation)
- All stale refs were generic Hue names from before bridge migration (works_with_hue_switch_1_*, hue_tap_dial_switch_1_*)
- HUE MIGRATION RULE confirmed again: After any Hue bridge re-add/migration, ALL automations must be scanned for stale hue_ prefixed entity refs
