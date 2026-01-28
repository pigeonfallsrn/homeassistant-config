
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

## Final Automation Audit (2026-01-27)

### Accurate Counts
- YAML automations: 119
- Registry entities: 144  
- Orphaned registry entries: 26

### Orphan Categories
1. **Replaced with new ID** (have similar automation in packages):
   - approaching_home_john → john_proximity.yaml
   - morning_wake_upstairs_hallway → occupancy_system.yaml

2. **Truly orphaned** (automation deleted, no replacement):
   - garage_door_* series (6 entries)
   - night_path_* (2 entries)
   - *_everyone_left (3 entries) 
   - humidity/arrival notifications
   - 2nd floor bathroom night lighting
   - Entry room inovelli/ceiling entries

### Cleanup Command
In HA UI: Settings → Automations → filter for "unavailable" → delete orphaned entries

### Storage Locations (FINAL)
```
automations.yaml          → 1 automation (legacy)
automations/*.yaml        → 19 automations (- id: and   id: formats mixed)
packages/*.yaml           → 99 automations (  - id: format)
TOTAL                     → 119 automations
```

### 5 True Duplicate Pairs (same name, 2 registry entries)
Run cleanup to remove the older/disabled variant of each pair.

## Arrival Lighting Debug Session (2026-01-27)

### Issue: Entry room adaptive lights & driveway lights didn't come on at arrival

### Root Causes Found:
1. **sensor.john_distance_to_home stuck at 4810m** - never dropped below 500m threshold
   - binary_sensor.john_approaching_home = off
   - Driveway lights automation never triggered

2. **Two automations DISABLED:**
   - `automation.first_person_home_after_dark_entry_lights_on` - state: OFF since Dec 31
   - `automation.arrival_john_home` - state: OFF since Jan 20

3. **arrival_adaptive_lighting_welcome DID trigger** at 8:06 PM
   - Entry lamp came on (confirmed on at brightness 255)

### Action Items:
1. Enable disabled automations in HA UI
2. Debug john_distance_to_home sensor (check Companion App GPS settings)
3. Consider adding garage door open as backup trigger for driveway lights

### Key Automations for Arrival:
- arrival_adaptive_lighting_on → entry lamp (working)
- arrival_lights_approaching → driveway + garage (distance sensor issue)
- first_person_home_lights_on → DISABLED
- arrival_notification_john → DISABLED

## Whole-Home Lighting Strategy Session (2026-01-27)

### User Requirements Summary:
1. **All lights OFF when nobody home** (5 min delay)
2. **All lights OFF at midnight** (except party/extended evening modes)
3. **Lux-aware** - only turn on when actually dark enough
4. **Room-specific behavior** with adaptive lighting
5. **Motion-based** where appropriate
6. **Security lighting** - entry room lamp can stay on (brightness boost, lux aware)

### Room-by-Room Analysis Needed:
- Entry Room: Security lamp always on (lux-aware), brightness boost on motion
- Living Room Lounge: Less on/off - stay on when downstairs, off when upstairs/away
- 1st Floor Bathroom: Motion-based like upstairs
- Kitchen areas: TBD
- Bedrooms: Kids have separate logic already
- Garage/Exterior: TBD

### Key Questions:
1. What defines "downstairs presence" vs "upstairs"?
2. Hot tub mode exception - entry lamp stays off?
3. Kitchen lounge lamp - same logic as living room lounge?

## First Floor Lighting Architecture (2026-01-27)

### Zone Model (not room-based):
1. **Transition/Arrival Zone**: Entry room, Front hallway, Kitchen-lounge hallway
2. **Active Living Zone**: Kitchen, Kitchen lounge, Living room lounge + living room
3. **Momentary Zone**: 1st floor bathroom (hallway-triggered)

### Key Principle: Motion ACTIVATES, Presence RETAINS
- Motion sensors trigger lights ON
- Phone Wi-Fi presence PREVENTS premature off
- No flicker while seated watching TV

### Sensors Available:
- Entry room: Aqara P1
- Front hallway/stairs: Aqara P1  
- Kitchen: Aqara P1
- Kitchen lounge: Aqara P1
- 1st floor bathroom: NO sensor (uses hallway motion)

### Pain Points to Solve:
- Flicker/cycling while seated
- Dim useless lighting
- Motion-only killing lights too fast
- Hot tub mode exception
