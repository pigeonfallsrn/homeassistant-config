# Session Learnings - 2026-01-20

## Ella Dashboard Created
- **Location**: `/config/.storage/lovelace.ella_dashboard`
- **Features**: Mobile-first, volleyball theme, Mushroom cards
- **Sections**: Quick Actions, Bedtime Scenes, Lights, Music (Echo Show), Calendar
- **Scripts created**: `/config/packages/ella_bedroom.yaml`
  - `script.ella_lights_off`
  - `script.ella_school_night` (dim glow → auto-off 30min)
  - `script.ella_gentle_wake` (gradual sunrise)
  - Scenes: ella_dim_red, ella_reading, ella_bedtime_glow, ella_chill_purple, ella_volleyball_hype, ella_bright

## Ghost Entities Cleaned
- Removed 22 unavailable/restored Ella scripts and scenes from entity registry
- Old scripts had lost their definitions

## John's Mobile Dashboard Updated
- **Location**: `/config/dashboards/lovelace-mobile.yaml` (YAML mode)
- **Features**: Family presence with location text, map card, garage controls, climate, lights by floor
- **Presence display**: Shows emoji + location text (🏠 Home · Upstairs, 🏫 School, etc.)

## Garage Automation Fixed
- **File**: `/config/packages/garage_lighting_automation.yaml`
- **Fixed**: Added missing lights to automation:
  - `light.garage` (Hue ceiling group)
  - `light.ratgdo32disco_fd8d8c_light` (North RATGDO)
  - `light.ratgdo32disco_5735e8_light` (South RATGDO)
  - Fixed south LiftMaster entity names: `light.south_west_garage_liftmaster`, `light.south_east_lift`
- **Added**: Immediate close option notification when door opens (winter mode)
- **Added**: Auto-close with 10s delay option

## Approaching Home Automation
- **File**: `/config/packages/notifications_system.yaml`
- **Added**: Proximity trigger at 500m via `sensor.john_distance_to_home`
- **Created**: `/config/packages/john_proximity.yaml` - distance sensor template

## Presence/Floor Detection Notes
- **AP MACs**:
  - `70:a7:41:c6:1e:6c` = 2nd floor AP
  - `d0:21:f9:eb:b8:8c` = 1st floor AP  
  - `f4:92:bf:69:53:f0` = Garage AP
  - `60:22:32:3d:b6:44` = Michelle's House (Goetting WiFi)
- **Issue**: Ella's floor detection uses `device_tracker.ellas_iphone` which is GPS-based (no ap_mac). Need UniFi-based tracker.
- **Michelle presence**: Use `binary_sensor.michelle_home_anywhere` or `device_tracker.goetting_wifi` state="home", NOT `input_boolean.michelle_home`

## TODO Next Session
- [ ] Find/create UniFi device tracker for Ella's iPhone for floor detection
- [ ] Update dashboard to use `binary_sensor.michelle_home_anywhere` for Michelle
- [ ] Test garage lighting automation with all lights
- [ ] Test approaching home notification at 500m
- [ ] Verify Ella dashboard scripts work after restart

## Light Group Created
- `light.ella_s_ceiling_lights` - groups 3 ceiling lights together
- Added to `/config/configuration.yaml`
