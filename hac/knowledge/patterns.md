# Reusable Patterns
*Last updated: 2026-02-21*

## Adaptive Lighting + Hue
```yaml
separate_turn_on_commands: true  # Required for Hue
take_over_control: true          # Manual override detection
detect_non_ha_changes: false     # Prevents Hue bridge polling conflicts
```
Sleep mode: 1-5% brightness, 2200K or lower

## Inovelli Smart Bulb Mode
- **Hue bulbs:** Smart Bulb Mode ON (param 52 = 1)
- **Dumb loads:** Smart Bulb Mode OFF
- **3-way with aux:** Smart Bulb Mode OFF
- Configure via: ZHA UI → Manage Clusters → InovelliVZM31SNCluster

## AL Storage Architecture
YAML defines config, runtime stored in `.storage/core.config_entries`
To modify lights array:
1. `ha core stop`
2. Backup `.storage/core.config_entries`
3. Edit lights array
4. `ha core start`

## Motion Automation (Dual-Trigger)
```yaml
mode: restart
trigger:
  - platform: state
    entity_id: binary_sensor.room_motion
    to: 'on'   # Separate automation for 'off' with for: delay
```

## Inovelli → Hue Flow
Inovelli → ZHA → HA → Hue Bridge → Hue Bulbs
(Direct Zigbee binding not possible across coordinators)
