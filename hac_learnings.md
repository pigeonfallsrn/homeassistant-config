
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

## Whole-Home Lighting - Answers from Context (2026-01-27)

### Q1: Floor Layout - CONFIRMED from area_registry
**1st Floor**: Entry Room, Kitchen, Kitchen Lounge, Living Room, Living Room Lounge, 1st Floor Bathroom, Garage, Stairway Cubby, Sun Room
**2nd Floor**: Upstairs Hallway, 2nd Floor Bathroom, Alaina's Bedroom, Ella's Bedroom, Master Bedroom
**Basement**: Basement, Laundry Area, Boiler Room, Workout Area
**Exterior**: Front Driveway, Back Patio, Very Front Door, Back Yard Tower

### Q2: Presence Detection - ALREADY EXISTS
- `binary_sensor.downstairs_motion` - combined 1st floor motion
- `binary_sensor.anyone_home` - person-based presence
- `binary_sensor.house_motion_any` - whole house motion

### Q3: Living Room Lounge Lamp - From "Zone Model"
Based on HAC learnings: "Active Living Zone" - should stay ON when downstairs presence, OFF after extended no-motion (30 min?)

### Q4: Hot Tub Mode - Need confirmation
Entry lamp behavior when hot_tub_mode ON?

### Q5: 1st Floor Bathroom - From learnings
"Momentary Zone" - uses hallway motion trigger, no dedicated sensor
Vanity light: likely night mode option (warm dim)

### Existing Infrastructure:
- `switch.adaptive_lighting_living_spaces` - controls entry lamp + floor lamps
- Motion aggregation in packages/motion_aggregation.yaml
- Presence system in packages/presence_system.yaml

## Lighting System Audit - Current State (2026-01-27)

### WORKING WELL:
- Entry lamp: Lux-aware, motion boost, hard off time, hot tub mode ✓
- Kitchen lounge lamp: Same pattern as entry ✓  
- Living room lamps: Adaptive + motion ✓
- Upstairs hallway + bathroom: NEW - motion + AL ✓
- Safety off: Nobody home + midnight ✓

### ISSUES TO FIX:
1. **Living room lounge lamp "too on/off"** - motion timeout too aggressive
   - Current: 45 min no motion → off
   - Fix: Use `binary_sensor.downstairs_motion` (combined) instead of room-specific
   - Or: Extend timeout to 60+ min when someone is home

2. **1st Floor Bathroom** - inconsistent with upstairs pattern
   - Current: Uses `binary_sensor.1st_floor_bathroom_motion_combined`
   - Has `input_boolean.bathroom_manual_override` shared with upstairs
   - Missing: Night red mode, AL integration

3. **Kitchen chandelier/ceiling** - no adaptive control
   - Manual Inovelli switches only
   - Could add to "Living Spaces" AL or separate zone

### RECOMMENDED FIXES (Priority Order):
1. Extend living room lamp timeouts + use downstairs_motion
2. Align 1st floor bathroom with upstairs pattern (night red, AL)
3. Add kitchen ceiling to adaptive lighting (optional)

### HOT TUB MODE - Already Handled:
- Entry lamp → red dim (5%)
- Living room lamps → red dim (5%)
- Kitchen lounge → red dim (5%)
- AL switch turns OFF

## Session Summary - Whole-Home Lighting Overhaul (2026-01-27)

### COMPLETED THIS SESSION:

#### 1. Automation Registry Cleanup
- Identified 144 registry vs 119 YAML automations
- Removed 26 orphaned registry entries
- Registry now clean: 118 entries matching YAML

#### 2. Upstairs Lighting (NEW)
- Created `packages/upstairs_lighting.yaml`
- Added Adaptive Lighting "Upstairs Zone" (hallway + 2nd floor bathroom)
- Motion-activated: night=dim red, evening=60%, day=full adaptive
- Timeouts: hallway 3min, bathroom 8min

#### 3. Living Room Lamps Fix
- Changed motion sensor: `living_room_motion` → `downstairs_motion`
- Extended timeout: 45min → 90min
- Prevents premature off when seated watching TV

#### 4. 1st Floor Bathroom Aligned
- Added night red mode (8%, RGB 255,30,0)
- Aligned with upstairs pattern
- Uses `1st_floor_bathroom_motion_combined`

#### 5. Arrival Lighting Debug
- Found `john_distance_to_home` sensor stuck at 4810m
- Found 2 disabled automations: first_person_home, arrival_john_home
- arrival_adaptive_lighting DID trigger correctly

### STILL TODO (Next Session):
1. Enable disabled automations in HA UI
2. Debug john_distance_to_home GPS sensor
3. Kitchen chandelier adaptive lighting (optional)
4. Assign areas to 134 lights with NO AREA
5. Test upstairs lighting behavior

### KEY FILES MODIFIED:
- `adaptive_lighting.yaml` - Added "Upstairs Zone"
- `packages/upstairs_lighting.yaml` - NEW
- `packages/adaptive_lighting_living_room.yaml` - timeout + sensor fix
- `automations/bathroom_motion_lighting.yaml` - night red mode
- `packages/lights_auto_off_safety.yaml` - added 2nd floor bathroom
- `.storage/core.entity_registry` - cleaned 26 orphans

### AUTOMATION STORAGE LOCATIONS:
```
configuration.yaml: packages: !include_dir_named packages
automations.yaml: [] (cleared - now uses packages)
automations/: 4 files, ~20 automations
packages/: 23 files, ~100 automations
```
- 2026-01-28: Fixed 2nd floor bathroom quad-fire - v2 automation was using upstairs_hallway_motion instead of upstairs_bathroom_motion. Removed redundant fallback automation and 2 orphan registry entries.
- 2026-01-28: Comprehensive AL restructure - functional zones (lamps vs ceiling):
  - "Living Spaces" (lamps): Added kitchen_hue_color_floor_lamp, kitchen_lounge_lamp, living_room_west_floor_lamp. sunset 21:00
  - "Kitchen & Entry Ceiling" (renamed from Kitchen Chandelier): kitchen_chandelier, kitchen_above_sink_light, kitchen_lounge, very_front_door_hallway. sunset 22:00, min_brightness 40%
  - "Living Room Ceiling" (NEW): living_room_lounge_ceiling_light. sunset 22:00, min_brightness 40%
  - Best practice: Separate AL by function (ambient lamps vs task ceiling), not just location. Ceiling task lights stay brighter/cooler longer.
- 2026-01-28: AL storage edits revert on restart - AL integration maintains internal state that overwrites storage changes. For light list changes, must use:
  1. UI: Settings > Devices & Services > Adaptive Lighting > Configure
  2. Or delete/recreate the entry
  Successfully created: Kitchen & Entry Ceiling (4 lights), Living Room Ceiling (1 light)
  TODO via UI: Add to Living Spaces: light.living_room_west_floor_lamp, light.kitchen_hue_color_floor_lamp, light.kitchen_lounge_lamp
  TODO: Clean up orphan switch.adaptive_lighting_kitchen_chandelier (unavailable)

## Blueprint Audit (2026-02-02)

### Inventory: 6 blueprints (down from 7)
- automation/panhans/advanced_heating_control.yaml → KEEP (gold standard, 3100+ forum posts)
- automation/Blackshome/sensor-light.yaml → KEEP (community standard, 8 lighting modes, weekly updates)
- automation/fxlt/zha-inovelli-vzm31-sn-blue-series-2-1-switch.yaml → KEEP (essential for Blue switches, mode: queued)
- automation/homeassistant/notify_leaving_zone.yaml → EVALUATE (case-sensitivity bug, consider panhans Extended)
- script/homeassistant/confirmable_notification.yaml → EVALUATE (no timeout, consider samuelthng fork)
- template/homeassistant/inverted_binary_sensor.yaml → EVALUATE (unused, keep for now)

### Deleted
- automation/homeassistant/motion_light.yaml → DELETED (teaching tool only, Blackshome replaces it)

### Key Findings
- ZERO blueprints were actively referenced by any automation or script
- No use_blueprint in: automations.yaml, automations/, packages/, scripts.yaml
- Official HA blueprints = teaching tools, not production quality
- Blackshome + panhans = trusted community authors
- Never use overlapping blueprints on same entity
- Check last_triggered before deleting blueprint-based automations
- Blueprint count doesn't matter; quality does

### Quality Indicators for Blueprints
✅ Active forum threads, responsive author, version numbers, recent updates
❌ No updates in 6+ months, unresolved bug reports, author non-responsive

## TABLED: Entry Room Tap Dial → HA Hot Tub Mode Integration (2026-02-02)

### Current State (WORKING - DO NOT CHANGE)
- Button 1: 1st Floor Table Lamps → Scene cycle (Energize) / Hold: Off
- Button 2: Entry + Kitchen Area → Dimmed / Hold: Off
- Button 3: Exterior (Very Front Door, Driveway, Back Patio) → Scene cycle (5 scenes) / Hold: Off
- Button 4: Hot Tub zone → Lights off / Hold: Entire Home off

### Gap
- Button 4 turns Hot Tub Hue lights OFF but does NOT toggle input_boolean.hot_tub_mode in HA
- Need: Physical button that fires HA hot_tub_mode toggle (triggers red dim scenes, AL disable, etc.)
- Options: (A) Reroute Tap Dial btn 4 to HA, (B) Use Master Bedroom Tap Dial unused button, (C) Dashboard only

### Action
- Evaluate during Master Bedroom Tap Dial config
- Requires: hue_event automation listening for button press → toggle input_boolean.hot_tub_mode

## Hue Scene Cleanup Session (2026-02-02)

### Summary
- Started with 179 scenes in HA entity registry
- Registry ballooned to 448 Hue scenes (zones auto-create defaults)
- Cleaned rooms in Hue app: Entry Room, Living Room Lounge, Kitchen Chandelier, Kitchen Lounge, Alaina's Bedroom, Ella's Bedroom, Master Bedroom
- Pattern: Keep only Energize + Nightlight + Concentrate per room
- Deleted 11 unavailable HA-native scenes (ella/dad reading/chill/rainbow/bedtime + new_scene x3)

### Tap Dial Configs
- Entry Room: 4 buttons all configured (Table Lamps, Entry+Kitchen, Exterior, Hot Tub zone)
- Master Bedroom: Button 1=Energize, 2=Dimmed, 3=Nightlight, 4=Lights off (hold=Entire Home off)

### Tabled for Next Session
- Create Hue groups: Alaina's Bedroom Ceiling (2 bulbs), Ella's Bedroom Ceiling (3 bulbs)
- Configure Living Room Lounge FoH switch for HA Hot Tub Mode integration
- Replace Entry Room ceiling bulbs (LWB014 white-only) with Ambiance for AL color temp
- Route Master Bedroom Tap Dial button 4 to HA for Hot Tub Mode toggle

### Power On Settings
- Set all Hue bulbs behind Inovelli Smart Bulb Mode switches to "Last on" for AL recovery
