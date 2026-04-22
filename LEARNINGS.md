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
