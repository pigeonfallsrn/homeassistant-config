# Session 2026-01-21 - Garage & Dashboard Fixes

## Issues Identified & Fixed

### 1. Garage Lighting Automation
**File**: `/config/packages/garage_lighting_automation.yaml`
**Problem**: Missing lights - only Third Reality nightlights were turning on
**Fixed**: Added all garage lights:
- `light.garage` (Hue ceiling group)
- `light.ratgdo32disco_fd8d8c_light` (North RATGDO)
- `light.ratgdo32disco_5735e8_light` (South RATGDO)
- Fixed south LiftMaster names: `light.south_west_garage_liftmaster`, `light.south_east_lift`

### 2. Quick Action Buttons Not Working
**File**: `/config/dashboards/lovelace-mobile.yaml`
**Problem**: `action: toggle` with `entity:` doesn't work for mushroom-template-card
**Fixed**: Changed to `action: call-service` with `service: input_boolean.toggle`

### 3. Michelle Not Showing Home
**Problem**: Dashboard used `input_boolean.michelle_home` which was "off"
**Fixed**: Changed to use `binary_sensor.michelle_home_anywhere`

### 4. Approaching Home Notification
**File**: `/config/packages/notifications_system.yaml`
**Created**: `/config/packages/john_proximity.yaml`
**Change**: Added 500m proximity trigger using `sensor.john_distance_to_home`

### 5. Winter Mode - Immediate Close Option
**Added**: When garage door opens, immediate notification with "Close Now" and "Auto 10s" options

## Pending Issues

### Ella Floor Detection Not Working
**Root Cause**: Ella's iPhone17 (MAC: `4a:7c:ea:7a:12:e0`) is on UniFi "Default" network, not tracked by HA
**Solution Options**:
1. Move Ella's iPhone to "Spencer IoT" network in UniFi
2. Enable "Default" network tracking in UniFi integration
**AP MACs for reference**:
- `70:a7:41:c6:1e:6c` = 2nd floor
- `d0:21:f9:eb:b8:8c` = 1st floor
- `f4:92:bf:69:53:f0` = Garage
- `60:22:32:3d:b6:44` = Michelle's House (Goetting)

### Ella Wake Lighting
**File**: `/config/packages/ella_bedroom.yaml`
**Added**: Automation to ramp lights 15 min before alarm
**Needs**: `sensor.ellas_iphone_next_alarm` - verify this entity exists

## Files Modified
- `/config/packages/garage_lighting_automation.yaml`
- `/config/packages/notifications_system.yaml`
- `/config/packages/john_proximity.yaml` (new)
- `/config/packages/ella_bedroom.yaml` (added wake automation)
- `/config/dashboards/lovelace-mobile.yaml`
