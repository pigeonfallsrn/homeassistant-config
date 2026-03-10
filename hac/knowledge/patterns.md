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

## A/V Automation Patterns

### Fire TV + AVR Coordination
```yaml
# Dual trigger pattern - catch both playback start AND wake from standby
trigger:
  - platform: state
    entity_id: media_player.fire_tv_xxx
    to: "playing"
    id: playing
  - platform: state
    entity_id: media_player.fire_tv_xxx
    from: "standby"
    to: "idle"
    id: woke_up
```

### HDMI ARC Setup
- Fire TV built-in to TV with HDMI eARC output
- Receiver HDMI OUT connects to TV HDMI eARC
- Audio travels FROM TV TO receiver via ARC
- Receiver source is typically `AV1`, `AV4`, or `AUDIO` - NOT an HDMI input number
- Check receiver display when audio works to confirm correct source name

### Subwoofer Smart Plug Sync
- Use 5-second delay on off to prevent cycling during quick power toggles
- Add condition to only act if state differs (prevent redundant commands)
- Mode: restart ensures timer resets on repeated triggers

## UniFi Protect Smart Detection Triggers
- **Use `event.*` entities** (not `binary_sensor.*`) for doorbell ring and vehicle triggers
  - Event entities fire once per detection, carry confidence + zone metadata in attributes
  - Binary sensors can go unavailable for ~1min during simultaneous detections
  - Pattern: trigger on state change of `event.camera_name_doorbell` or `event.camera_name_vehicle`
- **Package detection**: use `binary_sensor.*_package_detected` — no `event.*` equivalent exists
- **G4 Doorbell Pro package camera**: `camera.*_package_camera` — dedicated close-up lens, use for snapshots
- **Doorbell/package automations**: `mode: parallel` (not restart) — event-based, concurrent execution needed for multi-doorbell setups
