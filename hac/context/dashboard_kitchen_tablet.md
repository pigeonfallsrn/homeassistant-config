# HAC Context: Kitchen Tablet Dashboard

## Dashboard Overview
**File:** `/config/dashboards/lovelace-kitchen-tablet.yaml`
**Resolution:** 1920x1200 (Samsung Galaxy Tab, landscape)
**Layout:** custom:grid-layout (2 columns, 4 rows)

## Entity Reference

### Garage Doors (ratgdo)
- `cover.ratgdo32disco_5735e8_door` - North garage door
- `cover.ratgdo32disco_fd8d8c_door` - South garage door

### Presence (Person entities)
- `person.john_spencer`
- `person.alaina_spencer`  
- `person.ella_spencer`

### Climate - Nest Thermostats
- `climate.1st_floor_thermostat` - Main floor (heat only)
- `climate.basement_nest_thermostat` - Basement (heat only)
- `climate.master_nest_thermostat` - Master bedroom (heat/cool)
- `climate.garage_nest_thermostat` - Attached garage (heat only)

### Climate - PFP Garage (Pigeon Falls Properties)
- `climate.pfp_east_nest_thermostat_control` - East furnace
- `climate.pfp_west_nest_thermostat_control` - West furnace
- `sensor.pfp_east_nest_thermostat_sensor_temperature`
- `sensor.pfp_west_nest_sensor_temperature`

### Climate - Mitsubishi Mini-Splits (kumo_cloud)
- `climate.kitchen_mini_split` - Kitchen (heat/cool/dry/fan)
- `climate.living_room_mini_split` - Living room
- `climate.attic_mini_split` - Attic
- `climate.upstairs_hallway_mini_split` - Upstairs hallway

### Temperature Sensors (Nest)
- `sensor.first_floor_thermostat_temperature`
- `sensor.basement_thermostat_temperature`
- `sensor.master_nest_thermostat_temperature`
- `sensor.garage_thermostat_temperature`

### Navien Boiler
- `water_heater.navi_link_wifi_module` - Main control
- `binary_sensor.navien_running_2` - Running status
- `sensor.navien_hot_water_temp` - Output temp (F)
- `sensor.navien_inlet_temp` - Inlet temp (F)
- `sensor.navien_water_flow` - Flow rate (gal/min)
- `sensor.navien_heating_power` - Power level (%)
- `sensor.navien_current_gas_use` - Gas use (BTU/h)

### Kitchen Lights
- `light.kitchen_ceiling_inovelli_vzm31_sn` - Main ceiling (Inovelli dimmer)
- `light.kitchen_above_table_chandelier_inovelli` - Chandelier (Inovelli)
- `light.kitchen_lounge_inovelli_smart_dimmer` - Lounge area
- `light.kitchen_counter_night_light` - Counter nightlight (ZHA/Hue)
- `light.kitchen_west_wall_nightlight` - West wall nightlight (ZHA/Hue)
- `light.living_room_lounge_ceiling_hue_color_lights` - Living room ceiling (Hue group)

### Kitchen Scene Scripts (required)
- `script.kitchen_scene_cooking_bright`
- `script.kitchen_scene_dinner_dim`
- `script.kitchen_scene_movie_night`
- `script.kitchen_scene_all_off`

### Media
- `media_player.kitchen_sonos_beam`

### Calendar
- `calendar.alaina_ella` (ID: 2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com)

### Weather
- `weather.forecast_home`

### Shopping List
- `todo.shopping_list`

## Required HACS Frontend Cards
- mushroom
- atomic-calendar-revive
- layout-card (grid-layout)
- kiosk-mode

## Dashboard Design Patterns

### Header Chips Pattern
Conditional chips that only show when relevant:
- Garage doors: red alert when open, tap to close
- Person presence: colored dot when home
- HVAC activity: fire=heating, snowflake=cooling
- Navien: orange when running with live flow rate

### Light Toggle Pattern
Using mushroom light chips with use_light_color: true:
- Glows light color when on, grey when off
- Tap to toggle, hold for more-info

### Freeze Warning Pattern
PFP garage icon color based on temp thresholds:
- Red: <35F (freeze risk)
- Orange: <42F (warning)
- Green: >=42F (safe)

## Session Learnings (2026-01-23)

### Dashboard Patterns Established
- Fullscreen 1920x1200 grid-layout (2col x 4row)
- Conditional chips for alerts (garage, HVAC, presence)
- Light toggle chips with use_light_color: true
- Freeze warning color thresholds (red<35, orange<42, green>=42)

### Entity Naming Discoveries
- Garage doors: cover.ratgdo32disco_*_door (North=5735e8, South=fd8d8c)
- Mini-splits: climate.*_mini_split (kumo_cloud)
- Nest temps: sensor.*_thermostat_temperature
- PFP sensors: sensor.pfp_*_nest_*_temperature

### Next Session Context
- Tablet wake automation needed (motion or presence trigger)
- Aqara temp sensors need room-friendly names
- Consider adding doorbell camera popup
- Calendar entity naming standardization pending
