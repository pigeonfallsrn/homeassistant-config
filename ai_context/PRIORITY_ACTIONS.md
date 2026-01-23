# Priority Actions & Quick Wins

## IMMEDIATE (This Week)

### 1. Create Person Entities for Jarrett & Owen
**Time**: 5 minutes  
**Impact**: Family tracking complete  
**Steps**:
- Settings → People → Add Person
- Name: Jarrett, Name: Owen
- No device trackers yet (placeholders)
- Zone: Michelle's House (when zone created)

### 2. Link Michelle's Device Tracker
**Time**: 2 minutes  
**Impact**: Complete person tracking for all current devices  
**Steps**:
- Settings → People → Michelle
- Add device_tracker.michelle_s_iphone_14_pro
- Verify with `hac person`

### 3. Sunday: Alaina & Ella iPhone Setup
**Time**: 10 minutes per phone  
**Critical**: Re-enable primary device tracking  
**Steps**: See /config/ai_context/phone_setup_guide.md

---

## SHORT TERM (Next 2 Weeks)

### 4. Home Garage Lighting Automation
**Problem**: 6 Hue bulbs unreliable (4 not wired hot)  
**Options**:
  A. **Quick Fix**: Create automation despite unreliability
  B. **Better Fix**: Install Inovelli Blue switches (smart bulb mode)
  C. **Best Fix**: Hardwire power to all fixtures

**Recommended Automation** (Option A - works now):
```yaml
# All garage lights on/off together
script:
  garage_all_lights_on:
    sequence:
      - service: light.turn_on
        target:
          entity_id:
            - light.garage_ceiling_1
            - light.garage_ceiling_2
            - light.garage_north_bulb_1
            - light.garage_north_bulb_2
            - light.garage_south_bulb_1
            - light.garage_south_bulb_2

automation:
  - alias: "Garage Lights - Door Opens"
    trigger:
      - platform: state
        entity_id: 
          - cover.garage_north_door
          - cover.garage_south_door
        to: 'opening'
    action:
      - service: script.garage_all_lights_on
      
  - alias: "Garage Lights - Auto Off After Closed"
    trigger:
      - platform: state
        entity_id:
          - cover.garage_north_door
          - cover.garage_south_door
        to: 'closed'
        for: '00:05:00'
    condition:
      - condition: state
        entity_id: cover.garage_north_door
        state: 'closed'
      - condition: state
        entity_id: cover.garage_south_door
        state: 'closed'
    action:
      - service: script.garage_all_lights_off
```

### 5. Create "Michelle's House" Zone
**Impact**: Distinguish Michelle's location from John's home  
**Steps**:
```yaml
# Add to configuration.yaml
zone:
  - name: Michelle's House
    latitude: [40062 coordinates]
    longitude: [coordinates]
    radius: 50
    icon: mdi:home-account
```

---

## MEDIUM TERM (Next Month)

### 6. Map All Aqara Sensors to Rooms
**Current**: 7 temp sensors with generic names  
**Goal**: Rename with actual locations  
**Command**: `hac entity "aqara" > /config/ai_context/aqara_sensors.txt`

### 7. Fix Unavailable Cameras
- Kitchen AI Theta
- G6 Bullet (possible Big Garage location?)
- Determine placement/adoption

### 8. TRV Planning & Valve Replacement
**Rooms**: 5 upstairs radiators  
**Hardware**: Zigbee Sonoff TRVs  
**Pre-work**: Replace radiator valves  
**Automation**: Room priority logic + safety guards

---

## LONG TERM (Next 3-6 Months)

### 9. Big Garage HA Green Deployment
**Hardware**: HA Green (already owned) ✅  
**Network**: Via UBB bridge ✅  
**Integrations to Add**:
- [ ] Smart locks (2 walk-in doors)
- [ ] Overhead door controllers (5 doors, 12x14 each)
- [ ] Ceiling fan automation (temp delta based)
- [ ] Security lighting
- [ ] HVAC control (PFP East/West thermostats)

**Automation Priorities**:
1. **Ceiling Fan Logic**: 
   - Trigger when loft temp > floor temp by 10°F
   - Run fans to push warm air down
2. **Work Session Heating**:
   - Button/switch to boost from 50°F to 65°F
   - Auto-return to 50°F after 4 hours
3. **Overhead Door Schedules**:
   - Security: Auto-close at night if left open
   - Alerts if door open during non-business hours
4. **Security Lighting**:
   - Motion-activated exterior lights
   - Interior lights on door open after dark

### 10. Replace Kwikset Locks (Big Garage)
**Current**: WiFi Kwikset (not HA compatible)  
**Recommended**: Yale/Schlage Z-Wave or Zigbee locks  
**Users**: Brian Borreson (permanent), Virgil Helgeson (temporary codes)

### 11. Overhead Door Safety Upgrades
**Issue**: Pneumatic safety broken/outdated  
**Required**: Modern photoelectric sensors  
**Integration**: HA-compatible door controllers  
**Safety**: Auto-reverse on obstruction

---

## FUTURE VISION (6-12 Months)

### 12. Migrate Nest → HA Direct Control
**Current**: 6 Nest thermostats via Google Home  
**Goal**: Direct HA control of all HVAC  
**Benefits**: 
- Advanced scheduling
- Room-by-room TRV coordination
- Energy optimization
- No cloud dependency

### 13. Navien Direct Integration
**Current**: Navien WiFi module (cloud-based)  
**Goal**: Local HA control of boiler  
**Benefits**:
- Bypass Nest completely
- TRV-driven boiler calls
- Precise temperature control

### 14. Upstairs Mini-Split Expansion
**Problem**: Insufficient cooling in bedrooms (summer)  
**Options**:
  A. Add bedroom mini-split units
  B. Automate bedroom fans + existing hallway unit
  C. Combination approach

### 15. 3rd Floor/Attic Completion
**Status**: Sheetrocked/primed  
**Needs**: Electrical outlets, climate control  
**Mini-Split**: Already installed  
**Future**: Additional living space

---

## QUICK REFERENCE COMMANDS
```bash
# Check all person statuses
hac person

# Full system export for AI analysis
hac full

# Check specific integration
hac integration unifi
hac integration nest

# Search entities
hac entity "garage"
hac entity "camera"
hac entity "climate"

# Create backup before changes
hac backup

# Add learning
hac learn "Your important discovery here"

# View recent learnings
hac learn
```

---

## SYSTEM HEALTH CHECKS

### Daily:
- [ ] `hac quick` - Fast status check

### Weekly:
- [ ] Check camera recordings
- [ ] Verify all person entities tracking correctly
- [ ] Review automations (are they running as expected?)

### Monthly:
- [ ] `hac full` - Export fresh context
- [ ] Review learnings for patterns
- [ ] Check Big Garage temps (freeze protection)
- [ ] Network hardware temps (UDM-PRO, switches)

