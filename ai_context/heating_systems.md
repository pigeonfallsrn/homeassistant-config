# Complete Heating & Climate System Documentation

## HOME (40154 US Highway 53) - Multi-Zone Hydronic + Mini-Splits

### Primary Heat Source: Navien Combi Boiler
- **Model**: Navien combi unit with WiFi module
- **Control**: Currently via Nest thermostats (Google Home)
- **Future Goal**: Migrate to HA control
- **Distribution**: Hydronic (hot water) to multiple zones

---

## HYDRONIC ZONES (4 Total)

### Zone 1: Basement
- **Thermostat**: `climate.basement_nest_thermostat` (64.94°F)
- **Distribution**: Cast iron repurposed radiators
- **Controller**: Taco multi-zone "dumb" controller (called by Nest)
- **Current**: 64.94°F
- **Status**: ✅ Working well

### Zone 2: Main/1st Floor (Whole Floor - Single Zone)
- **Thermostat**: `climate.1st_floor_thermostat` (69.62°F)
- **Distribution**: In-floor PEX radiant (subfloor hydronic)
- **Control**: Mixing valve
- **Sensor**: Subfloor temperature probe → Navien input
- **Current**: 69.62°F
- **Status**: ✅ Works great throughout entire first floor

### Zone 3: Upstairs/2nd Floor (Whole Floor - Single Zone, TRANSITIONING)
- **Thermostat**: `climate.master_nest_thermostat` (68.0°F)
- **Distribution**: 5 cast iron radiators
  1. Master bedroom
  2. Ella's bedroom
  3. Alaina's bedroom
  4. Upstairs hallway
  5. Upstairs bathroom
- **Current Status**: Single zone for entire upstairs
- **In Progress**: Installing TRVs (Thermostatic Radiator Valves)
  - Requires valve replacement first
  - Planning: Zigbee Sonoff TRVs (likely choice)
  - Goal: Per-room temperature control
  - Logic needed:
    - Room-by-room TRV control
    - Taco zone controller integration
    - Thermal expansion safety guards
    - Room priority logic

### Zone 4: Home Garage (2-stall)
- **Thermostat**: `climate.garage_nest_thermostat` (61.52°F)
- **Distribution**: Baseboard hot water fin radiators (back/east wall)
- **Size**: Undersized but adequate
- **Status**: ✅ Functional
- **Doors**: 2 garage doors (west-facing)
  - Q LiftMaster openers
  - 2x ratgdo ESP Home devices (one per door) ✅
  - Aqara door sensors on each door
  - Named: "North" and "South"
- **Lighting Issues**: 
  - 2x Hue ceiling lights (should hardwire and automate OR install Inovelli smart bulb mode)
  - Each door has 2x Hue bulbs (CLUNKY - not wired hot, unreliable)
  - **Goal**: All lights function together (on/off simultaneously)
  - **Trigger**: Door open + motion-based automation
- **Walk-in Door**: To entry room, has Aqara door sensor

---

## MITSUBISHI MINI-SPLITS (Air & Supplemental Heat)

### Coverage:
- **1st Floor**: 2 units
  1. Kitchen mini-split
  2. Living room mini-split
- **2nd Floor**: 1 unit
  - Upstairs hallway
  - ⚠️ Insufficient cooling in peak summer (especially bedrooms)
  - **Future desire**: Bedroom fan automation + upstairs fans
- **3rd Floor/Attic**: 1 unit
  - Future living space (currently sheetrocked/primed only)
  - Needs: Outlets wired, finishing work

### Use Case:
- Efficient heating when mild weather
- Primary air conditioning
- Supplemental to hydronic heat

---

## BIG GARAGE (40003 Commercial Ave) - Freeze Protection Only

### Heating System:
- **Purpose**: FREEZE PREVENTION ONLY (not comfort heating)
- **Setpoint**: 50°F baseline (intentional)
- **Furnaces**: 2x natural gas hanging ceiling furnaces (older style)
  - PFP West: `climate.pfp_west_nest_thermostat_control` (50°F)
  - PFP East: `climate.pfp_east_nest_thermostat_control` (50°F)
- **Building**: Large, insulated storage/operations facility
- **Ceiling Fans**: Run constantly (poor circulation strategy)

### Current Issues & Future Plans:
1. **Circulation Problem**:
   - Loft/upper area much warmer than floor
   - Fans should run strategically based on temp delta
   - **Automation goal**: Activate fans when upper temp exceeds floor temp by X degrees

2. **Manual Warming**:
   - When working/washing trucks: Manually bump temp via Nest/Google Home app
   - **Future**: Automate warm-up schedules or presence-based heating

3. **Uneven Heating**:
   - East and West furnaces should work in concert
   - **Goal**: Balance heating zones or rotate furnace usage

4. **Local HA Control Needed**:
   - Additional HA Green planned (already have hardware)
   - UBB bridge provides network connection
   - **Expansion goals**:
     - Local control of thermostats
     - Door lock automation
     - Overhead door control
     - Security/lighting
     - Future electric heating preference

---

## BIG GARAGE - DOORS & ACCESS CONTROL

### Current Access:
1. **Tenants**:
   - **Brian Borreson** (neighbor) - Permanent access
   - **Virgil Helgeson** - Stores Nova car, temporary code access via Kwikset app

2. **Walk-in Doors** (2x exterior):
   - Currently: Kwikset WiFi locks (not HA compatible)
   - **Future**: Replace with HA-compatible locks for local control

3. **Commercial Overhead Doors** (5x south-facing):
   - Size: 12' x 14' each
   - Brand: Overhead Doors
   - Built: ~1997 (original bus garage)
   - **Current Control**: RF remote (unreliable impression)
   - **Safety Issue**: Pneumatic air safety system broken/outdated
   - **Future Project**:
     - HA-compatible openers/controllers
     - Modern safety equipment (photoelectric sensors, etc.)
     - Local HA control
     - Automation for open/close schedules

### Future HA Green @ Big Garage:
- **Hardware**: HA Green (already purchased)
- **Network**: Via UBB bridge
- **Integrations planned**:
  - Smart locks (walk-in doors)
  - Overhead door controllers
  - Lighting automation
  - Security cameras
  - HVAC control (ceiling fans + furnaces)
  - Temperature monitoring

---

## DOOR SENSORS (Aqara)

### Home (40154):
- Garage walk-in door (to entry room)
- North garage door (overhead)
- South garage door (overhead)
- Back patio/back door walk-in
- Front driveway walk-in door
- "Very front door" exterior door

### Big Garage:
- TBD (future installation)

---

## LIGHTING AUTOMATION NEEDS

### Home Garage (Priority):
1. **Ceiling Lights**: 2x Hue bulbs
   - Should hardwire OR install Inovelli smart bulb mode switches
2. **Door Lights**: Each door has 2x Hue bulbs (4 total)
   - Not wired hot = unreliable
   - **Goal**: All lights on/off together
   - **Triggers**: 
     - Door open
     - Motion detected
     - After X minutes without motion → off
     - Best practice needed

### Other Rooms with Many Devices:
- Kitchen
- Kitchen Lounge
- Entry Room
- Living Room
- Living Room Lounge

---

## TRV AUTOMATION STRATEGY (Upstairs - In Progress)

### Hardware:
- **TRVs**: Likely Zigbee Sonoff TRVs
- **Radiators**: 5 total (Master, Ella, Alaina, Hallway, Bathroom)

### Logic Requirements:
1. **Room Priority**: Which room(s) call for heat
2. **Taco Controller Integration**: Call main zone when any TRV demands heat
3. **Safety Guards**:
   - Thermal expansion protection
   - Prevent boiler short-cycling
   - Min/max temperature limits
4. **Room-by-room Control**: Individual setpoints per bedroom

### Future Automation:
- Sleep schedules (lower temps at night per room)
- Presence detection (lower when empty)
- Balance with mini-split usage

---

## FUTURE PROJECTS (Priority Order)

### High Priority:
1. **Home Garage Lighting**: Reliable Hue automation or Inovelli switches
2. **Upstairs TRVs**: Complete valve installation + automation logic
3. **Big Garage HA Green**: Deploy second HA instance for local control

### Medium Priority:
4. **Big Garage Door Automation**: Replace overhead door controls + safety equipment
5. **Big Garage Smart Locks**: Replace Kwikset with HA-compatible locks
6. **Ceiling Fan Automation**: Big Garage temp-based circulation

### Low Priority:
7. **Upstairs Bedroom Fans**: Summer cooling automation
8. **3rd Floor/Attic**: Complete buildout + climate control
9. **Navien Direct Integration**: Replace Nest → HA direct control

---

## AUTOMATION OPPORTUNITIES

### Immediate (Home):
```yaml
# Garage lighting - all on/off together
automation:
  - alias: "Garage Lights - Door Open"
    trigger:
      - platform: state
        entity_id:
          - cover.garage_north_door
          - cover.garage_south_door
        to: 'open'
    action:
      - service: light.turn_on
        target:
          entity_id:
            - light.garage_ceiling_1
            - light.garage_ceiling_2
            - light.garage_north_door_1
            - light.garage_north_door_2
            - light.garage_south_door_1
            - light.garage_south_door_2
            
  - alias: "Garage Lights - Auto Off"
    trigger:
      - platform: state
        entity_id:
          - binary_sensor.garage_motion  # if you have motion sensor
        to: 'off'
        for: '00:10:00'  # 10 minutes
    condition:
      - condition: state
        entity_id: cover.garage_north_door
        state: 'closed'
      - condition: state
        entity_id: cover.garage_south_door
        state: 'closed'
    action:
      - service: light.turn_off
        target:
          entity_id: all garage lights
```

### Big Garage (Future):
- Temp delta ceiling fan automation
- Overhead door schedules
- Security lighting
- Work session heating boost
