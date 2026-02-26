# Lighting Debug - Critical Findings

## Discovery: Upstairs Hallway Automations are UNAVAILABLE

**Found 3 automations in UNAVAILABLE state:**
- `automation.night_path_upstairs_hallway` (unavailable)
- `automation.morning_wake_upstairs_hallway` (unavailable)
- `automation.upstairs_hallway_motion_lighting` (unavailable)

**This explains the problems!** These automations exist but are broken/disabled.

## Hardware Analysis

### Upstairs Hallway Lights
**Main ceiling light:** NOT shown in output (likely `light.upstairs_hallway`)
**Nightlights:**
- `light.upstairs_hallway_night_light` (OFF, supports color temp + RGB)
- `light.upstairs_hallway_east_wall_night_light` (UNAVAILABLE - device offline?)

**Motion sensor:** `binary_sensor.upstairs_hallway_motion` (confirmed exists)

**Capabilities:** Full color + color temp control available

### Adaptive Lighting
**Active AL instances:**
- Living Spaces (working)
- Entry Room Ceiling (working)
- NO upstairs hallway AL instance (was disabled)

## Root Cause Analysis

### Upstairs Hallway Issue:
1. AL was disabled for upstairs zone
2. Three automations exist but are UNAVAILABLE (broken config)
3. Light defaults to previous behavior without control
4. Family complaints about "stupid light" = broken automations

### Alaina's LED Issue:
Need to check automations.yaml for her LED automation status.

## Next Steps

1. **Check automations.yaml** for broken automation syntax
2. **Fix unavailable automations** 
3. **Decide:** Restore automations OR replace with new time-based logic
4. **Check Alaina's LED automation** in automations.yaml

