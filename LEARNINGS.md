
---

## S46 — 2026-04-20 — Garage Review + Quick Wins

### ESPHome reflash rename pattern (1st occurrence)
- ESPHome devices reflashed with new device names change ALL entity IDs
- ratgdo example: ratgdo32disco_fd8d8c → garage_north_garage_door_ratgdo32disco
- 9 of 13 broken garage refs were this pattern
- Analogous to Hue Migration Rule — when reviewing any area with ESPHome devices, check for entity ID shifts

### Entity Ref Rule — 4th occurrence (S42, S44, S45, S46)
- Garage: 13 of 27 entity refs broken (48%)
- Batch ha_get_state verification remains the gold standard

### Hue Migration Rule — 2nd occurrence
- Garage dimmer: hue_dimmer_switch_4_button_N → garage_dimmer_switch_button_N
- Same pattern as S45 kids dimmer switches

### python_transform does not support isinstance()
- Full config replacement is cleaner for multi-ref fixes — skip python_transform for these

### Motion light consolidation pattern
- Separate ON/OFF automations with overlapping triggers and targets → consolidate into matched ON/OFF pair
- Use combined motion sensor (binary_sensor.*_motion_combined) + helper timeout (input_number.*_timeout) for OFF
- Garage: 3 overlapping automations → 1 clean OFF automation

### Aqara sensor gaps confirmed
- binary_sensor.aqara_door_and_window_sensor_door_3 not found (garage walk-in door trigger)
- binary_sensor.garage_walk_in_door also not found
- Part of known Aqara sensor gap backlog (6 door + 4 motion sensors with entity ID mismatches)

### HANDOFF.md gap
- S45 never wrote HANDOFF.md — S46 started with S44 handoff
- Session close discipline: always verify HANDOFF.md was written before git push

### REST API vs websocket for entity registry (S47)
- REST API POST to /api/config/entity_registry/{entity_id} returns 404 — endpoint doesn't exist
- Entity registry renames MUST use websocket: type "config/entity_registry/update" with entity_id + new_entity_id
- Bulk rename pattern: python3 + websockets library (pip3 install websockets --break-system-packages)
- aiohttp is NOT available in HAOS — always use websockets module
- curl/REST approach will silently fail (grep finds nothing, no error output)

### VZM36 EP2 light entity (S47)
- EP2 creates both a fan entity AND a light entity — they control the same endpoint
- The light_2 entity brightness mirrors fan speed (33/66/100%)
- Disable light_2 on all VZM36 modules — it's redundant and confusing on dashboards

### Entity registry changes are not git-tracked (S47 — reinforces S44)
- Entity renames, disables, and area assignments live in .storage/ (gitignored)
- These survive reboots but are NOT version-controlled
- 87 entity renames this session exist only in HA's registry, not in git
- Dashboard configs also .storage/ — same pattern
