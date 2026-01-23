# Climate Control & Temperature Monitoring System

## NEST THERMOSTAT ZONES

### Home (40154 US Highway 53) - 4 Zones
1. **Garage** - `climate.garage_nest_thermostat`
   - Mode: Heat
   - Current: 61.52°F
   - Use: Detached garage heating

2. **Basement** - `climate.basement_nest_thermostat`
   - Mode: Heat
   - Current: 64.94°F
   - Use: Radiant floor heating (likely)

3. **1st Floor** - `climate.1st_floor_thermostat`
   - Mode: Heat
   - Current: 69.62°F
   - Primary living space

4. **Master Bedroom** - `climate.master_nest_thermostat`
   - Mode: Heat
   - Current: 68.0°F
   - Sleeping area

### Big Garage/PFP (40003 Commercial Ave) - 2 Zones
5. **PFP West** - `climate.pfp_west_nest_thermostat_control`
   - Mode: Heat
   - Current: 49.46°F
   - Status: ⚠️ Running cold (climate-controlled storage should be warmer?)

6. **PFP East** - `climate.pfp_east_nest_thermostat_control`
   - Mode: Heat
   - Current: 50.18°F
   - Status: ⚠️ Running cold (climate-controlled storage should be warmer?)

---

## AQARA TEMPERATURE SENSORS (Home) - 7 Sensors

| Sensor | Temp | Likely Location |
|--------|------|-----------------|
| Sensor #1 | 70.84°F | Unknown |
| Sensor #2 | 64.76°F | Coolest indoor (basement?) |
| Sensor #3 | 71.55°F | Living area |
| Sensor #4 | 72.91°F | Warmest indoor |
| Sensor #5 | 70.34°F | Living area |
| Sensor #6 | 72.12°F | Living area |
| Sensor #7 | 57.29°F | Coldest (garage/outdoors?) |

---

## NETWORK HARDWARE TEMPERATURES

| Device | Temp | Location | Status |
|--------|------|----------|--------|
| **UDM-PRO** | 120.56°F | Home server rack | ✅ Normal |
| **USW Pro Max 16 PoE** | 102.2°F | Home switch | ✅ Normal |
| **PFP UBB Bridge** | 91.4°F | Big Garage | ✅ Normal |
| **40062 UBB Bridge** | 98.6°F | Michelle's House | ✅ Normal |

---

## CLIMATE AUTOMATION OPPORTUNITIES

### 1. Big Garage Cold Alert
```yaml
automation:
  - alias: "PFP Storage Too Cold"
    trigger:
      - platform: numeric_state
        entity_id:
          - climate.pfp_west_nest_thermostat_control
          - climate.pfp_east_nest_thermostat_control
        below: 50
    action:
      - service: notify.mobile_app_john_s_s24_ultra
        data:
          message: "Big Garage temp below 50°F - check climate control"
```

### 2. Home Comfort Optimization
- Basement radiant heat scheduling
- Master bedroom sleep temperature (lower at night)
- 1st floor day/night profiles

### 3. Energy Monitoring
- Track heating costs across 6 zones
- Compare home vs business facility usage
- Identify heating inefficiencies

### 4. Freeze Protection
- Alert if any zone drops below 40°F
- Critical for Big Garage storage
- Michelle's house monitoring

### 5. Network Equipment Health
- Alert if UDM-PRO exceeds 130°F
- Monitor bridge temps at remote sites

---

## CAMERA LOCATIONS (Based on Names)

### Home (40154 US Highway 53):
- ✅ **Very Front Door** (High Res + Package + Insecure channel)
- ✅ **Front Driveway Door** (High Res + Package + Insecure channel)
- ✅ **Back Yard** (G4 Bullet)

### Unknown Location (Need Identification):
- ⚠️ **Kitchen AI Theta** (unavailable - likely at Home)
- ⚠️ **AI Theta** (unavailable - location unknown)
- ⚠️ **G6 Bullet** (unavailable - Big Garage?)
- ⚠️ **Third Party Camera** (unavailable - needs adoption)

**Action Item**: Identify which cameras monitor Big Garage (40003)

---

## IMMEDIATE CONCERNS

### ⚠️ Big Garage Climate Control
- Both PFP thermostats at ~50°F
- If this is climate-controlled storage, should be warmer (55-65°F minimum)
- Possible issues:
  1. Thermostats set too low for winter
  2. Heating system not keeping up
  3. Insulation problems
  4. Door left open

**Recommendation**: Check PFP thermostat setpoints and heating system

### ⚠️ Unavailable Cameras
- 3 cameras offline/unavailable
- Need troubleshooting:
  - Kitchen AI Theta
  - AI Theta (unknown location)
  - G6 Bullet

---

## AUTOMATION PRIORITIES

1. **Critical**: Big Garage freeze protection alert
2. **High**: Home comfort scheduling (bedroom temps at night)
3. **Medium**: Network equipment temperature monitoring
4. **Low**: Energy usage tracking and optimization

---

## ZONE HEATING SUMMARY (Winter Settings)

| Zone | Current | Typical Target | Status |
|------|---------|----------------|--------|
| Master Bedroom | 68°F | 68-70°F | ✅ Good |
| 1st Floor | 69.62°F | 68-72°F | ✅ Good |
| Basement | 64.94°F | 64-68°F | ✅ Good |
| Garage (Home) | 61.52°F | 55-65°F | ✅ Good |
| PFP West | 49.46°F | 55-65°F | ⚠️ LOW |
| PFP East | 50.18°F | 55-65°F | ⚠️ LOW |

