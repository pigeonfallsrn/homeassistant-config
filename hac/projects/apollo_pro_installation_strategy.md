# Apollo Pro mmWave Sensor Strategy

## Current Situation Analysis

### Existing Detection (Weak)
- **Upstairs:** Only motion sensor is `binary_sensor.upstairs_hallway_motion` (P1 style)
- **Girls' bedrooms:** NO motion sensors (only presence tracking via school/home)
- **UniFi AP detection:** 2nd Floor AP shows presence but no room-level granularity

### Problems This Causes
1. Can't tell if Alaina/Ella are actually in their rooms vs just upstairs
2. Can't detect when girls are asleep vs awake in bed
3. Hallway light doesn't know if bedrooms are occupied
4. No way to auto-off Alaina's LEDs based on room occupancy

## Apollo Pro Solution (3 Sensors Available)

### Recommended Placement Priority

**Priority 1: Kitchen (Testing)**
- **Why:** High traffic, easy access, test all features before bedroom install
- **What to test:** 
  - Zone configuration
  - Presence vs occupancy detection
  - False positive rate
  - Integration with HA automations
- **Mount:** Counter/shelf mounted (temporary for testing)

**Priority 2: Alaina's Bedroom**
- **Why:** Solves LED auto-off problem (detect when she leaves room)
- **Zones:** 
  - Zone 1: Bed area (detect sleeping)
  - Zone 2: Desk/play area (detect awake activity)
  - Zone 3: Doorway (detect entry/exit)
- **Automation benefit:** Auto-off LEDs when room empty for 10min

**Priority 3: Ella's Bedroom**
- **Why:** Same benefits as Alaina, plus future automation potential
- **Zones:** Similar to Alaina's setup

**Priority 4 (Future): Upstairs Hallway**
- **Why:** Currently has P1, but Apollo Pro would give better zone control
- **Zones:**
  - Zone 1: Bathroom approach
  - Zone 2: Bedrooms approach  
  - Zone 3: Stairway
- **Benefit:** Different light behavior based on which direction person is going

## Strategic Implementation Plan

### Phase 1: Kitchen Testing (Week 1)
```yaml
# Test automation in kitchen
- Test presence detection accuracy
- Configure zone sensitivity
- Test "room empty" detection timing
- Verify ESPHome/HA integration works smoothly
```

### Phase 2: Alaina's Room (Week 2)
**Once kitchen test successful:**

1. Install Apollo Pro in Alaina's room
2. Configure 3 zones (bed, activity, door)
3. Create new automation:
```yaml
# Alaina LED Auto-Off - Smart Version
- When: Room unoccupied for 10 minutes
- And: LEDs are on
- Action: Turn off LEDs
- Exception: If it's past midnight, turn off immediately
```

**Benefits:**
- Auto-off when she leaves room (not just midnight)
- Keeps LEDs on if she's still in room past midnight (reading, etc.)
- Parents can override by turning back on

### Phase 3: Ella's Room (Week 3)
- Same setup as Alaina
- Add cross-room logic (both girls in bed? House sleep mode)

### Phase 4: Smart Hallway (Future)
**Replace P1 with Apollo Pro:**
- Better zone detection
- Combine with alarm state: `input_select.alarm_mode`
- Combine with bedroom occupancy

**New hallway logic:**
```
If Alaina in bed (zone 1) + Ella in bed (zone 1):
  → Deep sleep mode (very dim red)
  
If alarm = "Disarmed" + bedroom motion detected:
  → Morning prep mode (bright white)
  
If moving toward bathroom zone:
  → Dim warm light
  
If moving toward stairs:
  → Brighter directional light
```

## Integration with Alarm System

**Current alarm:** `input_select.alarm_mode` (currently "Disarmed")

**Proposed logic:**
- Disarmed = Girls home
- When girls home + bedroom occupancy detected + time 5:30-7:30am:
  → Hallway: Bright mode (they're getting ready)
- When girls home + no bedroom occupancy + time 5:30-7:30am:
  → Hallway: Dim mode (they're still sleeping)

## Answer Your Questions Based on Above

**Q1: 3-way switch cuts power to ceiling light?**
Need your answer - does the physical switch cut power to `light.upstairs_hallway`?

**Q2: Planning Hue click switch?**
Recommendation: YES - Install Hue click to keep power always on, use automation for control

**Q3: Alarm system?**
You have `input_select.alarm_mode` - "Disarmed" = girls home

**Q4: Wake-up time on school days?**
Need your answer - but suggest: 6:00am based on typical school schedules

**Q5: Brighter when alarm shows girls home?**
YES - With Apollo Pro in bedrooms, we can be even smarter:
- If bedroom occupancy detected → bright light
- If no bedroom occupancy → dim light (still sleeping)

**Q6: Weekends different?**
Suggest: Same schedule, but add condition:
- Weekend + no bedroom motion before 8am → stay dim
- Weekend + bedroom motion → bright (they're up, help them)

