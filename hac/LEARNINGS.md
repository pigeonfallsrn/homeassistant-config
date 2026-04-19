# LEARNINGS LOG — Accumulated across sessions
# Format: S## | Category | Learning
# Promoted to CRITICAL_RULES after 2nd occurrence

S44 | kiosk-mode | Does NOT work on strategy dashboards — must use storage-mode
S44 | fkb | Tier 1 (native wake/sleep) vs Tier 2 (HA automations) pattern
S44 | fkb | set_config requires device_id, not entity_id
S44 | fkb | switch.*.motion_detection is a toggle, not a sensor
S44 | entity-refs | RULE PROMOTED: Always verify entity existence before trusting automation configs (2nd occurrence: S42 Entry Room, S44 bathroom+tablet)
S44 | triple-fire | Multiple automations on same ZHA IEEE all fire — must delete legacy, not just disable
S44 | dashboard | .storage/lovelace.* is gitignored — dashboard configs not version-controlled
S44 | google-cal | OAuth tokens don't transfer between HA instances — need fresh flow
S44 | tablet-user | Non-admin + kiosk_mode + FKB kiosk lock = full lockdown stack
S43 | yaml-migration | MCP returns 0 for YAML-defined entities — reliable signal, not error
S42 | entity-refs | Broken entity refs survive across sessions (1st occurrence)
