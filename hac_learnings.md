
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

