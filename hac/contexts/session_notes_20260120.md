# Session Notes - 2026-01-20

## Completed
1. **Morning Wake Automations** - Added to occupancy_system.yaml
   - `morning_wake_upstairs_hallway` - triggers on hallway motion during morning
   - `morning_wake_master_bedroom` - triggers when john_sleeping turns off
   
2. **Floor Location Sensors** - Added to presence_system.yaml
   - `sensor.john_floor_location` (2nd_floor/1st_floor/garage/away)
   - `sensor.alaina_floor_location`
   - `sensor.ella_floor_location`
   - `binary_sensor.john_upstairs`
   - `binary_sensor.anyone_upstairs`
   - `binary_sensor.upstairs_occupied`

## AP MAC Reference
| AP | MAC | Location |
|----|-----|----------|
| 2nd_floor_ap | 70:a7:41:c6:1e:6c | Upstairs (bedrooms/bathroom) |
| 1st_floor_ap | d0:21:f9:eb:b8:8c | Main floor |
| garage_ap | f4:92:bf:69:53:f0 | Garage |

## Tabled Items

### 1. Humidity Alert Enhancement
**Current:** Hourly check, notifies if <30% humidity, offers to pause bathroom fan
**Proposed improvements:**
- Add context: Only alert when `binary_sensor.john_upstairs = on`
- Add "about to shower" detection: john_upstairs + morning + low humidity
- New action: "Open bathroom door after shower" suggestion to distribute humidity
- Rate limiting: Track last notification to avoid alert fatigue
- Check if fan is actually running before suggesting pause

### 2. Protect Camera Motion Context
- Could use camera motion (front_driveway, very_front_door, etc.) to enhance arrival/departure detection
- Correlate with AP transitions for more reliable presence

### 3. UniFi Client Count
- `sensor.1st_floor_ap_clients` / `sensor.2nd_floor_ap_clients` could indicate activity level
- Spike in clients = family gathering, etc.

## Observations from Today's Data
- john_sleeping turned off at 06:03 (phone unplugged)
- AP transition to 1st floor at 06:53 (came downstairs)
- 50-minute gap where John was upstairs without automated lighting
- New automations should catch this pattern

## Additional Changes Made

### Arrival/Garage Fixes
1. **Fixed `approaching_home_john` automation**
   - Removed sun.below_horizon condition - now works day AND night
   - Lights turn on only if dark (conditional)
   - Notification always sent with garage options: North, South, Both, Dismiss
   - Added ttl:0 and priority:high for immediate delivery

2. **Disabled redundant `arrival_john_home` automation**
   - Was sending double notifications
   - Had backwards condition (required someone_home = on)

3. **Unlocked south garage door remotes**
   - `lock.ratgdo32disco_5735e8_lock_remotes` was locked, now unlocked
   - Physical remotes should now work for south door

### Garage Door Diagnosis
**North door (fd8d8c) obstruction sensor issue - HARDWARE:**
- Sensor flickers on/off constantly (even at 2am, 4am)
- Currently stuck ON since 13:59:18
- This prevents physical remote from closing door (safety feature)
- ratgdo sync/query doesn't clear it
- **Physical fix needed:** Clean sensors, check alignment, check wiring

**South door (5735e8):** Working normally, obstruction = off

### Morning Wake Automation Enhancement
- Added upstairs bathroom light prep (10% warm) when john_sleeping turns off
- Auto-turns off after 10 min if no motion detected

## Current Automation Flow for Arrivals
1. `person.john_spencer` → "home"
2. `approaching_home_john` fires:
   - If dark: turns on driveway lights
   - Sends notification: "Welcome Home. Open garage?"
   - Actions: North | South | Both | Dismiss
3. `approaching_home_actions` handles button presses

## Additional Changes Made

### Arrival/Garage Fixes
1. **Fixed `approaching_home_john` automation**
   - Removed sun.below_horizon condition - now works day AND night
   - Lights turn on only if dark (conditional)
   - Notification always sent with garage options: North, South, Both, Dismiss
   - Added ttl:0 and priority:high for immediate delivery

2. **Disabled redundant `arrival_john_home` automation**
   - Was sending double notifications
   - Had backwards condition (required someone_home = on)

3. **Unlocked south garage door remotes**
   - `lock.ratgdo32disco_5735e8_lock_remotes` was locked, now unlocked
   - Physical remotes should now work for south door

### Garage Door Diagnosis
**North door (fd8d8c) obstruction sensor issue - HARDWARE:**
- Sensor flickers on/off constantly (even at 2am, 4am)
- Currently stuck ON since 13:59:18
- This prevents physical remote from closing door (safety feature)
- ratgdo sync/query doesn't clear it
- **Physical fix needed:** Clean sensors, check alignment, check wiring

**South door (5735e8):** Working normally, obstruction = off

### Morning Wake Automation Enhancement
- Added upstairs bathroom light prep (10% warm) when john_sleeping turns off
- Auto-turns off after 10 min if no motion detected

## Current Automation Flow for Arrivals
1. `person.john_spencer` → "home"
2. `approaching_home_john` fires:
   - If dark: turns on driveway lights
   - Sends notification: "Welcome Home. Open garage?"
   - Actions: North | South | Both | Dismiss
3. `approaching_home_actions` handles button presses

## Late Session Updates

### Timing Fixes
- **Away detection** reduced from 5 min → 2 min for faster response
- **Garage door opened notification** added 3-second delay before checking `john_home`, fixes race condition on arrival where door opens before presence updates

### Automations Enabled
- `automation.garage_all_lights_on` - was OFF since Dec 31
- `automation.garage_all_lights_off_2` - was OFF
- `switch.adaptive_lighting_living_spaces` - was OFF

### Automations Disabled  
- `automation.arrival_ella_home` - John only wants dashboard, not notifications for kids

### Dashboard Fixes
- Fixed `climate.upstairs` → `climate.upstairs_hallway_mini_split`

### Remaining Issues
- `sensor.people_home_count` and `sensor.house_occupancy_state` showing unavailable - template block structure issue needs investigation
- North garage obstruction sensor - hardware issue
