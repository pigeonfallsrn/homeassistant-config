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
