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
