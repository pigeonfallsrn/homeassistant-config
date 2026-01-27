
## [2026-01-17 12:43] Person Entity Tracking - Alaina Setup Complete

**CONTEXT:** Verified Alaina's person tracking after iPhone 17 setup

**ENTITIES:**
- Person: `person.alaina_spencer`
- Device Trackers:
  - `device_tracker.alaina_s_iphone` (UniFi network)
  - `device_tracker.alaina_s_iphone_17` (Mobile app GPS - primary source)
- Current state: home (GPS accurate, working correctly)

**KEY LEARNINGS:**
1. Person entities use format `person.{firstname}_{lastname}` not `person.{firstname}`
2. Multiple device trackers can be assigned (network + mobile app)
3. Mobile app GPS tracker typically becomes primary source
4. Entity registry: `/config/.storage/core.entity_registry`
5. Person config: `/config/.storage/person`
6. Current states: `/config/.storage/core.restore_state`

**VERIFICATION COMMANDS:**
```bash
# Find person entity
cat /config/.storage/core.entity_registry | jq '.data.entities[] | select(.platform == "person")'

# Check person state
cat /config/.storage/core.restore_state | jq '.data[] | select(.state.entity_id == "person.alaina_spencer")'

# Find device trackers
cat /config/.storage/core.entity_registry | jq '.data.entities[] | select(.entity_id | contains("device_tracker")) | select(.entity_id | contains("alaina"))'
```

**NEXT:** Ella's iPhone 17 setup tomorrow ~2pm - repeat same verification process for `person.ella_spencer`


## Automation Registry Orphans Explained (2026-01-27)

The 31 "orphaned" registry entries are NOT missing configs - they're **old IDs from before package migration**.

### What Happened
- Automations originally in `automations.yaml` with IDs like `bathroom_fan_auto_on_humidity`
- Migrated to `packages/` with new IDs like `bathroom_fan_humidity_auto_on`
- Registry kept BOTH old and new entries (144 total vs 113 YAML)

### The 5 "Duplicates" Are Actually
Same-name automations with old+new registry entries, not true duplicates in YAML.

### Cleanup Strategy
Safe to remove 31 orphaned entity registry entries - they're stale references.
Use: Settings → Devices & Services → Entities → filter "unavailable" automations → delete

### Key Files
- `configuration.yaml`: `packages: !include_dir_named packages`
- `automations/`: 13 automations (merge_list format `- id:`)
- `packages/`: 99 automations (named format `  - id:`)
- `automations.yaml`: 1 automation (legacy)
