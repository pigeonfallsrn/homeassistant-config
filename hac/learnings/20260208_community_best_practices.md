# Community Best Practices Research & Gap Analysis
**Date**: 2026-02-08
**Context**: Comprehensive review of top HA community blueprints/automations vs current setup

## Research Summary
Analyzed top-rated community resources across all major integrations:
- Philips Hue (ZHA), Inovelli switches (ZHA), Adaptive Lighting (HACS)
- Motion sensor automations, Google Nest, Garage doors

### Key Findings

**Strengths (Top 10% Implementation)**
- ✅ Hue app groups for multi-bulb fixtures (vs HA groups)
- ✅ Smart Bulb Mode (param 52) enabled on all Inovelli+Hue combinations
- ✅ AL Hue-optimized settings (separate_turn_on_commands, take_over_control, detect_non_ha_changes: false)
- ✅ Dual-trigger motion pattern with mode: restart and trigger IDs
- ✅ Git-based config management with backup procedures
- ✅ Comprehensive garage automation with safety controls

**Gaps (Enhancement Opportunities)**
1. No lux-based automation (missing illuminance sensors)
2. No centralized Inovelli LED control (manual per-switch config)
3. Unclear if helper-based mode system exists (Home/Away/Sleep)
4. Not using HA Alert component (repeating/dismissible notifications)
5. Sleep mode in Adaptive Lighting may not be configured
6. Scene preservation unclear (save/restore light states)

## Priority Implementation Queue

### HIGH VALUE (Immediate Impact)

**1. Helper-Based Mode System** (QUICKEST - 15 min)
Create input_boolean helpers: Home/Away/Sleep/Vacation
- UI: Settings > Devices & Services > Helpers > Create Helper > Toggle
- Simplifies automation conditionals
- Foundation for other features

**2. HA Alert Component for Garage** (HIGH IMPACT - 30 min)
```yaml
alert:
  garage_open_alert:
    name: Garage Door Open
    message: "Garage open {{ states('sensor.garage_open_duration') }} min"
    done_message: "Garage closed"
    entity_id: binary_sensor.garage_door_contact
    state: 'on'
    repeat: 15  # Every 15 minutes
    can_acknowledge: true
    notifiers:
      - mobile_app_sm_s906b
```

**3. kschlichter Inovelli LED Script** (MOST POWERFUL - 60 min)
- GitHub: https://github.com/kschlichter/Home-Assistant-Inovelli-Effects-and-Colors
- Control all LEDs by floor/area/label in single call
```yaml
service: script.inovelli_led
data:
  floor: 'upstairs'
  LEDcolor: 'RED'
  effect: 'PULSE'
```

### MEDIUM VALUE

**4. Blacky Motion Blueprint**
- https://community.home-assistant.io/t/sensor-light-motion-sensor-door-sensor-sun-elevation-lux-value-scenes-time/481048
- 8 modes: sun elevation, lux control, night lights, media integration

**5. Lux Sensors**
- Aqara RTCGQ11LM or Hue motion sensors
- Real-time brightness adjustment based on ambient light

**6. AL Sleep Mode**
```yaml
automation:
  - alias: "Enable AL Sleep Mode"
    trigger:
      - platform: state
        entity_id: input_boolean.sleep_mode
        to: 'on'
    action:
      - service: switch.turn_on
        target:
          entity_id: switch.adaptive_lighting_sleep_mode_living_spaces
```

### LOW VALUE
7. Hue Scene Refresher: https://community.home-assistant.io/t/blueprint-philips-hue-intelligent-scene-refresher/965192
8. Button press blueprints for Inovelli
9. Google Assistant SDK integration

## Technical Patterns

### Scene Preservation
```yaml
- service: scene.create
  data:
    scene_id: garage_light_restore
    snapshot_entities:
      - light.garage
# Change light
- service: light.turn_on
  target:
    entity_id: light.garage
  data:
    rgb_color: [255, 0, 0]
# Restore
- service: scene.turn_on
  target:
    entity_id: scene.garage_light_restore
```

## Implementation Strategy

**Phase 1** (Week 1): Helper modes, LED script, Alert component
**Phase 2** (Week 2): Lux sensors, AL sleep mode, scene preservation  
**Phase 3** (Week 3): Blacky blueprint, button blueprints, optimization

## Resources
- LED: https://github.com/kschlichter/Home-Assistant-Inovelli-Effects-and-Colors
- Alert Guide: https://www.creatingsmarthome.com/index.php/2022/11/14/home-assistant-advanced-garage-door-alert/
- Blacky: https://community.home-assistant.io/t/sensor-light-motion-sensor-door-sensor-sun-elevation-lux-value-scenes-time/481048
- Blueprints Exchange: https://community.home-assistant.io/c/blueprints-exchange/53

## Recommended Start
**Helper Mode System** - quickest win, no file editing, done in UI

## Implementation Completed - 2026-02-08 12:52 PM

### Gold Standard Helper System Deployed Successfully ✅

**Files Created/Updated:**
- input_boolean.yaml: 38 helpers (was 10, added 28)
- input_number.yaml: 9 helpers (was 1, added 8)
- input_select.yaml: 3 selects (NEW FILE)
- input_datetime.yaml: 9 datetimes (NEW FILE)
- counter.yaml: 4 counters (NEW FILE)
- timer.yaml: 5 timers (NEW FILE)
- configuration.yaml: Updated with new includes

**Backups Created:**
- All original helper files timestamped
- HAC backup completed
- Git commit: 65aea76

**Key Additions:**
- House Mode select (Normal/Sleep/Away/Vacation/Guest/Party/Cleaning/Maintenance)
- Alarm Mode select (Disarmed/Armed Home/Armed Away/Armed Night)
- Adaptive Lighting Mode select
- Notification management (quiet_hours, critical_only, cooldown)
- Routine state tracking (good_morning, good_night, leaving_home, arriving_home)
- Garage controls (auto_close_enabled, auto_open_enabled, alert_acknowledged)
- Manual overrides per room (9 zones)
- Tracking helpers (last routine times, garage events, manual changes)
- Daily statistics counters
- Automated timeout timers

**Fixes:**
- Removed duplicate: 2nd_floor_bathroom_manual_override
- Renamed for consistency: bathroom helpers now use 1st_floor/2nd_floor naming

**Discovery:**
- Found UI-created helpers not in YAML: extended_evening_mode, hot_tub_mode, occupancy_mode templates
- These were preserved and remain functional

### Verified in UI ✅
All helpers successfully loaded and visible in Settings → Devices & Services → Helpers

---

## NEXT SESSION: Phase 1, Item #2 - HA Alert Component

### Implementation Plan

**Goal:** Replace one-shot garage notifications with persistent, repeating, dismissible alerts

**Estimated Time:** 30 minutes

**Prerequisites Met:**
- ✅ Helper system in place
- ✅ Helpers ready: garage_alert_acknowledged, last_garage_alert_sent, garage_open_alert_delay_minutes
- ✅ Counter ready: garage_opens_today

**Implementation Steps:**

1. **Create alerts.yaml** (~10 min)
   - Define garage_open_alert with:
     - Repeating notifications (every 15 min, configurable via helper)
     - Dismissible (can_acknowledge: true)
     - State tracking (monitors garage door contact sensor)
     - Uses input_number.garage_open_alert_delay_minutes for delay
   
2. **Update configuration.yaml** (~2 min)
   - Add: `alert: !include alerts.yaml`
   
3. **Create automation to track alert acknowledgment** (~8 min)
   - When alert dismissed → set input_boolean.garage_alert_acknowledged
   - When garage closes → reset garage_alert_acknowledged
   - Update input_datetime.last_garage_alert_sent

4. **Optional: Dashboard card** (~5 min)
   - Show alert state
   - Quick acknowledge button
   - Last alert timestamp

5. **Test** (~5 min)
   - Open garage
   - Wait for alert
   - Dismiss alert
   - Verify no more alerts
   - Close garage
   - Verify reset

**Configuration Pattern:**
```yaml
alert:
  garage_open_alert:
    name: Garage Door Open
    entity_id: binary_sensor.garage_door_contact
    state: 'on'
    repeat: 
      - "{{ states('input_number.garage_open_alert_delay_minutes') | int }}"
    can_acknowledge: true
    skip_first: false
    notifiers:
      - mobile_app_sm_s906b
    title: "Garage Alert"
    message: "Garage door has been open for {{ relative_time(states.binary_sensor.garage_door_contact.last_changed) }}"
    done_message: "Garage door closed"
```

**Success Criteria:**
- Alert triggers when garage opens
- Alert repeats every X minutes (configurable)
- Alert can be dismissed via notification action
- Alert stops when garage closes
- Alert stops when manually acknowledged
- Counter increments on garage open

**Benefits:**
- No more forgotten open garage door
- Configurable alert frequency
- Can acknowledge when intentionally left open
- Foundation for other alert types (doors, leaks, security)

**Next After This:**
- Phase 1, Item #3: kschlichter Inovelli LED Control Script
- Phase 2, Item #6: Sleep Mode in Adaptive Lighting
- Garage light scene preservation

### Reference Resources
- HA Alert Docs: https://www.home-assistant.io/integrations/alert/
- Community Guide: https://www.creatingsmarthome.com/index.php/2022/11/14/home-assistant-advanced-garage-door-alert/
- Auto Entities Card: For dashboard display of all active alerts
