# MCP Entity Safety Matrix - Complete Audit

## Risk Classification System

### 🟢 ZERO RISK - Always Safe to Expose
**Criteria:** Read-only sensors with no control capability
- `binary_sensor.*_motion` - Motion detection
- `binary_sensor.*_door` - Door/window contact sensors  
- `binary_sensor.*_occupancy` - Occupancy detection
- `binary_sensor.*_presence` - Presence detection
- `sensor.*_temperature` - Temperature sensors
- `sensor.*_humidity` - Humidity sensors
- `sensor.*_battery` - Battery level sensors
- `sensor.*_power` - Power consumption (monitoring only)
- `sensor.*_energy` - Energy usage (monitoring only)
- `weather.*` - Weather data
- `sun.*` - Sun position

### 🟡 LOW RISK - Safe with Consideration
**Criteria:** Can control devices but low consequence if triggered
- `light.*` - All lights (worst case: lights turn on/off)
- `switch.*_plug` - Smart plugs for non-critical devices
  - TV plugs, charger plugs, lamp plugs: SAFE
  - Exception: Critical equipment (see RED below)
- `fan.*` - Ceiling fans, portable fans
- `media_player.*` - Echo, Sonos, TV (worst case: audio plays)
- `climate.*` - Thermostats (read state is safe, control is low risk)
- `scene.*` - Scene activation (safe, just triggers lights)

### 🟠 MEDIUM RISK - Requires Review
**Criteria:** Could cause inconvenience or minor issues
- `switch.*_receiver` - AV receivers (could disrupt entertainment)
- `automation.*` - Automation toggles (could disable automations)
- `script.*` - Script execution (depends on what script does)
- `input_boolean.*` - Helper toggles (depends on what they control)
- `select.*` - Input selects (depends on usage)

### 🔴 HIGH RISK - Never Expose
**Criteria:** Physical security, safety, or critical infrastructure
- `cover.garage_*` - Garage door openers (physical security breach)
- `lock.*` - All locks (physical security)
- `switch.*_valve*` - Water/gas valves (flooding/safety risk)
- `valve.*` - Any valve controls
- `button.usw_*` - Network equipment controls (internet outage)
- `button.*_reboot` - Device reboot controls
- `switch.*_main_*` - Main power/water controls
- `alarm_control_panel.*` - Security system controls

## Domain-by-Domain Analysis

### Currently Exposed (~70 entities)
✅ Safe exposure confirmed

### Recommended Additions (Zero Risk)
These should be exposed for better context:

**Environmental Sensors:**
- All `sensor.*_temperature` entities
- All `sensor.*_humidity` entities  
- All `sensor.*_battery` entities (for maintenance alerts)

**Additional Motion Sensors:**
- Any `binary_sensor.*_motion` not yet exposed
- `binary_sensor.house_motion_active` (if exists)

**Power Monitoring (Read-Only):**
- `sensor.*_power` - Real-time power usage
- `sensor.*_energy` - Energy consumption tracking

### Keep Blocked (High Risk)
Currently correctly blocked:

**Critical Controls:**
- `cover.garage_north_garage_door_ratgdo32disco_door`
- `cover.garage_south_garage_door_ratgdo32disco_door`
- `switch.basement_domestic_water_main_valve_aqara_t1_valve_control`

**Network Infrastructure:**
- All `button.usw_*` entities

## HAC Process Workflow Integration

### Current HAC Safety Model
✅ **Knowledge Layer (CSVs):** Full device inventory with no security risk
✅ **Live State Layer (MCP):** Filtered safe sensors only
✅ **Control Layer:** Blocked from MCP entirely

### Recommended Workflow Enhancements

1. **Auto-generate safe exposure list:**
   - Script that scans entity registry
   - Classifies by risk level
   - Suggests additions based on safety matrix

2. **Periodic audit script:**
   - Check for new entities
   - Verify critical items remain blocked
   - Alert on exposure drift

3. **Context optimization:**
   - Include entity exposure status in HAC context CSVs
   - Flag MCP-accessible vs knowledge-only entities
   - Document privacy boundaries in context headers

