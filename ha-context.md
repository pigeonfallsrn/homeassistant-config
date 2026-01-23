# Home Assistant - Living Context Document
**Last Manual Update**: 2025-11-05 | **Last AI Session**: 2025-11-05 22:10
**Version**: 1.0 | **Owner**: John Spencer | **Location**: Strum, WI

---

## 📖 DOCUMENT USAGE - READ THIS FIRST

### For AI Assistants (Claude, ChatGPT, Gemini, Copilot)

**Universal AI Prompt Template**:
```
Context: /config/ha-context.md (John Spencer's Home Assistant)
Load sections: #quick-start, #[specific-section-needed]
Task: [your question]
After completion: Append summary to #session-log using template
```

**Your Role**: 
- Read ONLY sections relevant to the query (use anchor links)
- At END of session, append summary to [Session Log](#session-log)
- Never modify existing sections without explicit instruction
- Reference entities from [Entity Reference](#entity-reference)

**Session Summary Template**:
```
### YYYY-MM-DD HH:MM - [AI Name] - [Brief Title]
**Query**: [What user asked]
**Actions**: [Bullet points of what was done]
**Entities Modified**: [List entity IDs changed]
**New Issues**: [Problems discovered]
**Recommendations**: [Suggestions]
```

### For John Spencer

**Weekly**: Review [Session Log](#session-log)
**Monthly**: Archive old sessions to [System Evolution](#system-evolution)
**As Needed**: Update entity reference when adding devices

---

## 🚀 QUICK START

### System Overview
- **HA Version**: Latest (2025)
- **Hardware**: Home Assistant (a0d7b954-ssh)
- **Network**: 192.168.1.3/24
- **External URL**: https://ha.myhomehub13.xyz
- **Timezone**: America/Chicago (assumed from location)
- **Total Entities**: 3,378

### Critical IPs
```yaml
home_assistant: 192.168.1.3
yamaha_receiver: 192.168.21.171:50000  # CRITICAL - NOT .1.171
# Add other static IPs as discovered
```

### Top 10 Rules
1. **Samsung S24**: Event-based notifications ONLY (mobile_app_notification_action)
2. **Ratgdo**: Aqara sensors for triggers, ratgdo for control
3. **Kitchen**: 5 motion sensors (NOT 6 - exclude upstairs)
4. **Lux**: ON <20, OFF >100 (sensor.kitchen_counter_night_light_illuminance)
5. **Entry Room**: Always-on pattern (not motion-only)
6. **Timeouts**: 5-10min night, 5min day (never 30min)
7. **Yamaha**: 192.168.21.171:50000 socket connection
8. **Remove duplicates** before creating automations
9. **Timer entities** must exist before referencing
10. **Adaptive Lighting**: Use adaptive_lighting.apply service

### Family Members
```yaml
people:
  - person.john_spencer      # Primary user, Samsung S24 Ultra
  - person.alaina_spencer    # Automated bedroom (8:30 PM bedtime)
  - person.ella_spencer      # Manual bedroom control only
```

### Quick Entity Reference
```yaml
# Most-used lights
light.entry_room
light.kitchen_table_chandelier_smart_dimmer_switch
light.kitchen_lounge
light.alaina_s_ceiling_hue_lights
light.ella_s_led_lights  # MANUAL ONLY

# Garage (USE AQARA FOR TRIGGERS)
binary_sensor.aqara_door_and_window_sensor_door_5  # North
binary_sensor.aqara_door_and_window_sensor_door_6  # South
cover.ratgdo32disco_fd8d8c_door  # North control
cover.ratgdo32disco_5735e8_door  # South control

# Lux sensors
sensor.kitchen_counter_night_light_illuminance
sensor.garage_north_wall_nightlight_illuminance

# Notifications (PRIMARY)
notify.mobile_app_john_s_phone  # Samsung S24 Ultra
notify.kitchen_echo_show_announce  # TTS backup
notify.everywhere_announce  # All Echos

# Adaptive Lighting
switch.adaptive_lighting_living_spaces
switch.adaptive_lighting_kitchen_table
switch.adaptive_lighting_entry_room_sun_follow
```

---

## 🔑 ENTITY REFERENCE

### Lights (40+ devices)

#### Kitchen & Dining
```yaml
light.kitchen_table_chandelier_smart_dimmer_switch  # Main kitchen
light.kitchen_lounge  # Secondary kitchen area
light.kitchen_counter_night_light
light.kitchen_west_wall_nightlight
light.kitchen_lounge_east_wall_nightlight
```

#### Living & Entry
```yaml
light.entry_room  # Hue - Always-on pattern
light.living_room_tv_led_strip  # Manual control
light.1st_floor_bathroom_nightlight
```

#### Master Bedroom
```yaml
light.master_bedroom_led_light_strip  # Manual control
light.master_bedroom_echo_show
light.master_bedroom_tv
```

#### Alaina's Bedroom (AUTOMATED)
```yaml
light.alaina_s_ceiling_hue_lights  # Main ceiling
light.alaina_s_floor_govee_lamp  # Matter/Govee
light.alaina_s_bedroom  # Bedside Hue
light.kl3_3  # LED Strip 1 (TP-Link)
light.kl3_2  # LED Strip 2 (TP-Link)
light.2  # Ceiling LED (TP-Link) - was hidden

# Automation: 8:30 PM bedtime dim
```

#### Ella's Bedroom (MANUAL ONLY - DO NOT AUTOMATE)
```yaml
light.ella_s_ceiling_hue_lights
light.ella_s_led_lights  # TP-Link strip
light.ella_s_govee_floor_lamp  # Matter
light.ella_s_bedroom  # Bedside Hue

# User preference: Alexa control only
```

#### Upstairs
```yaml
light.upstairs_hallway  # Motion-activated
light.upstairs_bathroom_night_light
light.upstairs_hallway_east_wall_night_light
light.upstairs_hallway_night_light
```

#### Garage
```yaml
light.garage_north_wall_nightlight  # Motion + walk-in door
sensor.garage_north_wall_nightlight_illuminance
```

#### Outdoor
```yaml
light.front_driveway_lights
light.garage_receiver
switch.front_driveway_lights
switch.front_driveway_lights_led
```

### Binary Sensors (50+ devices)

#### Motion Sensors
```yaml
# Kitchen (5 sensors - CRITICAL: NOT 6)
binary_sensor.kitchen_motion
binary_sensor.kitchen_counter_night_light_motion
binary_sensor.kitchen_west_wall_nightlight_motion
binary_sensor.aqara_motion_sensor_p1_occupancy  # Kitchen P1
binary_sensor.kitchen_lounge_east_wall_nightlight_motion

# Entry & Living
binary_sensor.entry_room_motion
binary_sensor.1st_floor_bathroom_nightlight_motion

# Garage
binary_sensor.east_section_of_garage_motion
binary_sensor.west_section_of_garage_walk_in_door_motion
binary_sensor.garage_north_wall_nightlight_motion

# Upstairs (NOT in kitchen automation)
binary_sensor.aqara_motion_sensor_p1_occupancy_2  # Upstairs hallway
binary_sensor.upstairs_hallway_east_wall_night_light_motion
binary_sensor.upstairs_hallway_night_light_motion
binary_sensor.upstairs_bathroom_night_light_motion
```

#### Door Sensors
```yaml
# Garage Doors (USE THESE FOR TRIGGERS - reliable)
binary_sensor.aqara_door_and_window_sensor_door_5  # North garage
binary_sensor.aqara_door_and_window_sensor_door_6  # South garage
binary_sensor.aqara_door_and_window_sensor_door_3  # Walk-in door

# Other Doors
binary_sensor.back_door_contact
binary_sensor.entry_room_door
binary_sensor.front_door_contact
```

#### Doorbells
```yaml
binary_sensor.front_driveway_door_doorbell
binary_sensor.very_front_door_doorbell
```

#### Occupancy & Presence
```yaml
binary_sensor.alaina_s_bedroom_occupancy
binary_sensor.ella_s_bedroom_occupancy
binary_sensor.kitchen_occupancy
binary_sensor.living_room_occupancy
```

### Covers (Garage Doors)
```yaml
# USE FOR CONTROL ONLY (not triggers)
cover.ratgdo32disco_fd8d8c_door  # North garage
cover.ratgdo32disco_5735e8_door  # South garage

# ESPHome - MUST have "Allow device to perform HA actions" enabled
```

### Sensors (100+ devices)

#### Illuminance / Lux
```yaml
sensor.kitchen_counter_night_light_illuminance  # PRIMARY kitchen lux
sensor.garage_north_wall_nightlight_illuminance
sensor.upstairs_bathroom_night_light_illuminance
sensor.upstairs_hallway_east_wall_night_light_illuminance
sensor.upstairs_hallway_night_light_illuminance
```

#### Temperature & Humidity
```yaml
sensor.kitchen_temperature
sensor.kitchen_humidity
sensor.master_bedroom_temperature
sensor.master_bedroom_humidity
sensor.upstairs_temperature
sensor.upstairs_humidity
sensor.garage_temperature
```

#### System Monitoring
```yaml
sensor.home_assistant_core_cpu_percent
sensor.home_assistant_core_memory_percent
sensor.home_assistant_supervisor_cpu_percent
sensor.home_assistant_host_disk_free
sensor.home_assistant_operating_system_version
```

#### Network Equipment
```yaml
sensor.udm_pro_temperature
sensor.udm_pro_cpu
sensor.udm_pro_memory
sensor.usw_pro_max_16_poe_temperature
```

### Media Players (40+ devices)

#### Echo Devices
```yaml
media_player.kitchen_echo_show
media_player.living_room_echo_show
media_player.master_bedroom_echo_show
media_player.alaina_s_bedroom_echo_show
media_player.ella_s_bedroom_echo_show
media_player.upstairs_bathroom_echo_plus
media_player.basement_echo
media_player.1st_floor_bathroom_echo_dot
media_player.echo_extra_3
media_player.echo_dot_extra
media_player.echo_dot_extra_2
media_player.echo_dot_extra_4
media_player.john_s_echo
media_player.john_s_echo_link
```

#### Yamaha AV Receiver
```yaml
media_player.basement_yamaha_av_receiver_rx_v671_main
media_player.rx_v671  # Main zone
media_player.rx_v671_zone2  # Back patio
# IP: 192.168.21.171:50000
# Connection: socket://192.168.21.171:50000
```

#### TVs & Streaming
```yaml
# Roku
media_player.living_room_roku
media_player.kitchen_lounge_tv
media_player.alaina_s_bedroom_roku

# Fire TV
media_player.ella_s_bedroom_fire_tv_192_168_1_189
media_player.living_room_fire_tv_192_168_1_17
media_player.master_bedroom_fire_tv_192_168_1_21
media_player.john_s_firetvstick

# TVs
media_player.living_room_tv
media_player.master_bedroom_tv
media_player.kitchen_lounge_tv
```

#### Plex
```yaml
media_player.plex_plex_for_android_mobile_john_s_s24_ultra
media_player.plex_plex_for_android_tv_aftti43
media_player.plex_plex_for_android_tv_afttiff43
media_player.plex_plex_for_roku_kitchen_lounge_tv
media_player.plex_plex_for_roku_living_room_roku
```

#### Spotify
```yaml
media_player.spotify_pigeonfallsrn
```

### Notification Services

#### Mobile App (Primary)
```yaml
notify.mobile_app_john_s_phone  # Samsung S24 Ultra
# Battery: MUST be Unrestricted
# Notifications: MUST use event-based architecture
# Event: mobile_app_notification_action
```

#### Alexa TTS (Backup/Announcements)
```yaml
# Announce (TTS to device)
notify.kitchen_echo_show_announce
notify.living_room_echo_show_announce
notify.master_bedroom_echo_show_announce
notify.alaina_s_bedroom_echo_show_announce
notify.ella_s_bedroom_echo_show_announce
notify.upstairs_bathroom_echo_plus_announce
notify.1st_floor_bathroom_echo_dot_announce
notify.everywhere_announce  # All Echo devices
notify.upstairs_announce  # Upstairs group

# Speak (Alexa voice responses)
notify.kitchen_echo_show_speak
notify.living_room_echo_show_speak
# ... (speak versions for each device)
```

### Switches

#### Adaptive Lighting
```yaml
switch.adaptive_lighting_living_spaces  # PRIMARY
switch.adaptive_lighting_kitchen_table
switch.adaptive_lighting_entry_room_sun_follow
switch.adaptive_lighting_kids_rooms
switch.adaptive_lighting_bedroom_lighting_test

# Use with: adaptive_lighting.apply service
```

#### Smart Plugs & Devices
```yaml
switch.front_driveway_lights
switch.garage_receiver
# Additional TP-Link switches as discovered
```

### Cameras (35+ UniFi Protect)

#### Outdoor Coverage
```yaml
camera.front_driveway_door_high_resolution_channel
camera.front_driveway_door_package_camera
camera.very_front_door_high_resolution_channel
camera.very_front_door_package_camera
camera.back_door
camera.back_patio
camera.back_yard_high_resolution_channel
camera.east_driveway
camera.west_driveway
camera.yard_barn_area
camera.yard_barns
```

#### Indoor Coverage
```yaml
camera.entry_room
camera.kitchen
camera.kitchen_ai_theta_high_resolution_channel
camera.workspace
camera.below_east_side_of_loft
camera.below_west_side_of_loft
```

#### Garage
```yaml
camera.east_section_of_garage
camera.west_section_of_garage_walk_in_door
camera.east_walk_in_door
camera.west_walk_in_door
```

### Weather
```yaml
weather.forecast_home
weather.forecast_home_2
```

### Other Important Entities
```yaml
# Sun
binary_sensor.sun_solar_rising
sensor.sun_next_dawn
sensor.sun_next_dusk
sensor.sun_solar_elevation

# TTS
tts.google_translate_en_com

# Shopping
todo.shopping_list
```

---

## 🤖 AUTOMATIONS REFERENCE

### Current Automations (30+)

#### Bedtime Routines
```yaml
- id: dad_bedtime_timer_finished
  alias: "Dad – Bedtime Timer Finished"
  
- id: alaina_bedtime_timer_finished
  alias: "Alaina – Bedtime Timer Finished"
  
- id: ella_bedtime_timer_finished
  alias: "Ella – Bedtime Timer Finished"
  
- id: alaina_bedtime_lights_dim
  alias: "Alaina Bedtime → Dim Lights (8:30 PM)"
  
- id: ella_bedtime_lights_dim
  alias: "Ella Bedtime → Dim Lights (8:30 PM)"
  
- id: alaina_ceiling_leds_auto_off_11pm
  alias: "Alaina's Ceiling LEDs → Auto OFF at 11 PM"
  
- id: alaina_bedtime_phone_charging
  alias: "Alaina's Room → Bedtime Mode (Phone Charging)"
```

#### Motion-Based Lighting
```yaml
- id: entry_room_motion_brightness_boost
  alias: "Entry Room Motion → Brightness Boost"
  
- id: upstairs_hallway_motion_brightness_boost
  alias: "Upstairs Hallway Motion → Brightness Boost"
  
- id: kitchen_lounge_motion_brightness_boost
  alias: "Kitchen Lounge Motion → Brightness Boost"
  
- id: upstairs_hallway_motion_lights_off
  alias: "Upstairs Hallway No Motion → Lights Off (3 min)"
```

#### Kitchen Lighting Schedules
```yaml
- id: kitchen_counter_lights_morning
  alias: "Kitchen Counter → Morning (6-9 AM)"
  
- id: kitchen_counter_lights_day
  alias: "Kitchen Counter → Day (9 AM-5 PM)"
  
- id: kitchen_counter_lights_evening
  alias: "Kitchen Counter → Evening (5-9 PM)"
  
- id: kitchen_counter_lights_night
  alias: "Kitchen Counter → Night (9 PM-6 AM)"
```

#### Auto-Off Automations
```yaml
- id: kitchen_lights_auto_off_midnight
  alias: "Kitchen Area Lights → Auto OFF at Midnight"
  
- id: kitchen_lights_auto_off_no_motion
  alias: "Kitchen Area Lights → OFF After 30 Min No Motion"
  # NOTE: 30 min may be too long - consider reducing
  
- id: living_entry_lights_auto_off_midnight
  alias: "Living Room & Entry → Auto OFF at Midnight"
  
- id: living_entry_lights_auto_off_no_motion
  alias: "Living Room & Entry → OFF After 30 Min No Motion"
```

#### Presence-Based
```yaml
- id: everyone_away_lights_off
  alias: "Everyone Away → All Lights Off"
  
- id: first_person_home_lights_on
  alias: "First Person Home After Dark → Entry Lights On"
```

#### Garage
```yaml
- id: garage_alert_final
  alias: "Garage Door Alert"
  # Event-based notification system
  
- id: garage_light_on
  alias: "Garage Light → ON"
  
- id: garage_light_off
  alias: "Garage Light → OFF"
```

#### Bathroom Fan
```yaml
- id: bathroom_fan_auto_on_humidity
  alias: "Bathroom Fan – Auto ON (RH ≥ 70% for 1 min)"
  
- id: bathroom_fan_auto_off_humidity
  alias: "Bathroom Fan – Auto OFF (RH ≤ 60% for 10 min)"
  
- id: bathroom_fan_backup_check
  alias: "Bathroom Fan Backup Check (Every 5 min if RH > 70%)"
```

#### Special Automations
```yaml
- id: kitchen_lounge_vzm36_adaptive_on
  alias: "Kitchen Lounge VZM36 → Adaptive ON (Home Only)"
  
- id: alaina_dashboard_school_morning
  alias: "Kitchen Lounge TV → Alaina's Dashboard (School Mornings)"
  
- id: kitchen_motion_test_automotion
  alias: "Kitchen motion test automotion"
  # Test automation - may need removal
```

---

## 🔌 INTEGRATIONS

### Active Integrations (25+)

#### Network & Infrastructure
```yaml
dhcp: 12 instances
zeroconf: 9 instances
ssdp: 4 instances
hassio: 4 instances (Supervisor)
unifi: 1 instance
  # 499 entities, 50 devices
  # Authentication: Local user
  # Note: Regenerate API token if 403 errors
```

#### Smart Home Protocols
```yaml
zha: 1 instance
  # Zigbee coordinator
  # Aqara sensors, motion, door sensors
  
thread: 1 instance
  # Matter border router
  
matter: (via Thread)
  # Govee floor lamps (Alaina, Ella)
```

#### Device Integrations
```yaml
tplink: 10 instances
  # Kasa smart plugs, LED strips
  # Alaina: light.kl3_3, light.kl3_2, light.2
  # Ella: light.ella_s_led_lights (manual only)
  
esphome: 2 instances
  # ratgdo32disco fd8d8c (North garage)
  # ratgdo32disco 5735e8 (South garage)
  # CRITICAL: "Allow device to perform HA actions" MUST be enabled
  
shelly: 1 instance
  
nest: 1 instance
  # Thermostat integration
```

#### Media & Entertainment
```yaml
alexa_media: (via mobile_app)
  # 12+ Echo devices
  # TTS via notify.X_announce services
  
spotify: 1 instance
  # media_player.spotify_pigeonfallsrn
  
plex: 1 instance
  # Multiple clients (Android, Roku, Fire TV)
  
roku: 2 instances
  # Living room, Kitchen lounge, Alaina's bedroom
  
androidtv: 3 instances
  # Fire TV devices
  
yamaha_ynca: 1 instance
  # RX-V671 at 192.168.21.171:50000
  # Socket connection
```

#### Security & Cameras
```yaml
unifiprotect: 1 instance
  # 35+ cameras
  # UniFi Protect NVR integration
  # Includes: Doorbells, G4 Bullet, G6 Bullet, AI Theta
```

#### Automation & Voice
```yaml
adaptive_lighting: 4 instances
  # Living spaces, Kitchen table, Entry room, Kids rooms
  # Use: adaptive_lighting.apply service
  
wyoming: 3 instances
  # Voice assistant protocol
  
nodered: 1 instance
  # Advanced automation flows
```

#### Mobile Apps
```yaml
mobile_app: 4 instances
  # John's S24 Ultra (primary)
  # notify.mobile_app_john_s_phone
  # Battery: MUST be Unrestricted
  # Event-based notifications only
```

#### Utilities
```yaml
met: 2 instances
  # Weather forecast (Met.no)
  
sun: 1 instance
  # Sun elevation, sunrise/sunset
  
shopping_list: 1 instance
  # todo.shopping_list
  
radio_browser: 1 instance
  # Internet radio
```

---

## 🎨 AUTOMATION PATTERNS

### Adaptive Lighting Pattern
```yaml
# Best practice for instant correct brightness/color
trigger:
  - platform: state
    entity_id: binary_sensor.motion_sensor
    to: 'on'
condition:
  - condition: numeric_state
    entity_id: sensor.lux_sensor
    below: 20
action:
  - service: adaptive_lighting.apply
    data:
      entity_id: switch.adaptive_lighting_living_spaces
      lights: light.target_light
      turn_on_lights: true
```

### Event-Based Notification (Samsung S24 Compatible)
```yaml
# Notification sender
- id: send_notification
  alias: "Send Notification"
  trigger:
    - platform: state
      entity_id: sensor.example
      to: 'problem'
      for: '00:05:00'
  action:
    - service: notify.mobile_app_john_s_phone
      data:
        title: 'Alert Title'
        message: 'Alert message'
        data:
          tag: "alert_{{ trigger.entity_id.split('.')[-1] }}"
          channel: 'Alert Channel'
          importance: 'high'
          actions:
            - action: 'FIX_PROBLEM'
              title: 'Fix It'
            - action: 'SNOOZE'
              title: 'Snooze'

# Action handler (separate automation)
- id: handle_notification_action
  alias: "Handle Notification Action"
  trigger:
    - platform: event
      event_type: mobile_app_notification_action
      event_data:
        action: 'FIX_PROBLEM'
  action:
    - service: some_domain.fix_service
      target:
        entity_id: entity.to_control
```

### Motion Lighting with Timeout
```yaml
- id: room_motion_light
  alias: "Room Motion → Light ON"
  mode: restart
  trigger:
    - platform: state
      entity_id: binary_sensor.room_motion
      to: 'on'
  condition:
    - condition: numeric_state
      entity_id: sensor.room_lux
      below: 20
    - condition: or
      conditions:
        - condition: sun
          after: sunset
        - condition: sun
          before: sunrise
  action:
    - service: adaptive_lighting.apply
      data:
        entity_id: switch.adaptive_lighting_living_spaces
        lights: light.room_light
        turn_on_lights: true
    - wait_for_trigger:
        - platform: state
          entity_id: binary_sensor.room_motion
          to: 'off'
      timeout: '00:10:00'  # 10 min at night
    - condition: template
      value_template: '{{ wait.trigger is none }}'
    - service: light.turn_off
      target:
        entity_id: light.room_light
```

---

## 🔧 TROUBLESHOOTING

### Samsung S24 Notification Buttons Not Working
**Symptoms**: Buttons appear but don't respond

**Fix**:
1. Settings → Apps → HA → Permissions → Notifications → Allowed
2. Settings → Apps → HA → Battery → Unrestricted
3. Settings → Special app access → Notification access → Enable HA
4. Force stop HA app, reopen
5. Toggle "Receive notifications" in HA app

**Test**: Monitor events
```bash
ha core logs | grep mobile_app_notification_action
```

### ESPHome Ratgdo Can't Execute Actions
**Symptoms**: Automation triggers but garage door doesn't respond

**Fix**: Settings → Devices & Services → ESPHome → Click gear on device → ☑ "Allow device to perform HA actions"

### Kitchen Lights Trigger from Upstairs Motion
**Cause**: binary_sensor.aqara_motion_sensor_p1_occupancy_2 (upstairs hallway) incorrectly in kitchen automation

**Fix**: Remove upstairs sensor, use only these 5:
- binary_sensor.kitchen_motion
- binary_sensor.kitchen_counter_night_light_motion
- binary_sensor.kitchen_west_wall_nightlight_motion
- binary_sensor.aqara_motion_sensor_p1_occupancy
- binary_sensor.kitchen_lounge_east_wall_nightlight_motion

### Lights Staying On All Night
**Common Causes**:
1. 30-minute timeout too long → Reduce to 5-10min at night
2. Missing lux conditions → Add: lux < 20 for ON, lux > 100 for day OFF
3. Timer entities don't exist → Remove timer references or create timers
4. No midnight safety shutoff → Add time-based OFF at midnight

### Ratgdo Shows Wrong Garage Door State
**Cause**: Ratgdo covers don't report state reliably

**Solution**: Use Aqara door sensors for triggers:
- binary_sensor.aqara_door_and_window_sensor_door_5 (North)
- binary_sensor.aqara_door_and_window_sensor_door_6 (South)
- Use ratgdo covers ONLY for control (cover.close_cover)

---

## 👨‍👩‍👧 FAMILY CONTEXT

### John Spencer (Primary User)
- **Device**: Samsung S24 Ultra (Android)
- **Notify**: notify.mobile_app_john_s_phone
- **Location**: Strum, Wisconsin
- **Timezone**: America/Chicago
- **Style**: Direct, results-focused, terminal commands preferred
- **Preferences**:
  - Minimal notifications (no routine alerts)
  - 24/7 garage alerts (no time restrictions)
  - Adaptive lighting over fixed schedules
  - Silent operation for routine events
  - Reliability over complexity

### Alaina Spencer
- **Person**: person.alaina_spencer
- **Bedroom**: Automated lighting system
- **Bedtime**: 8:30 PM dim routine
- **Lights**: light.alaina_s_ceiling_hue_lights, light.kl3_3, light.kl3_2, light.2, light.alaina_s_floor_govee_lamp
- **Dashboard**: Kitchen Lounge TV shows dashboard on school mornings
- **Preferences**: Gentle lighting transitions

### Ella Spencer
- **Person**: person.ella_spencer
- **Bedroom**: MANUAL CONTROL ONLY (DO NOT AUTOMATE)
- **Bedtime**: 8:30 PM dim routine (manual trigger)
- **Lights**: light.ella_s_ceiling_hue_lights, light.ella_s_led_lights, light.ella_s_govee_floor_lamp
- **Control**: Alexa voice commands only
- **Preferences**: Full manual control, no automation

---

## 📅 GOOGLE CALENDAR REFERENCE
```yaml
calendars:
  john_default: pigeonfallsrn@gmail.com
  family: 2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com
  couple: 2aa2d81010ff6a637e674c2cd23eb3e7@group.calendar.google.com
  work: 8249v7qv8g2m6bjc8v37f78gs0@group.calendar.google.com
  lions_club: 333e072f891daea9a8ffaba89d8e67fb1@group.calendar.google.com

rules:
  unspecified_request: john_default
  alaina_ella_mention: family
  work_mention: work
```

---

## 🌐 NETWORK & INFRASTRUCTURE

### Home Assistant
```yaml
internal_ip: 192.168.1.3
subnet: 192.168.1.0/24
docker_network: 172.30.32.1/23
hassio_network: 172.30.232.1/23
hostname: a0d7b954-ssh
external_url: https://ha.myhomehub13.xyz
access_method: Cloudflare Tunnel
```

### Critical Static IPs
```yaml
home_assistant: 192.168.1.3
yamaha_rx_v671: 192.168.21.171
  port: 50000
  socket: socket://192.168.21.171:50000
  note: "CRITICAL - NOT .1.171 subnet"
  
# Add as discovered:
# ratgdo_north: [IP]
# ratgdo_south: [IP]
# unifi_controller: [IP]
# hue_bridge: [IP]
```

### Network Equipment
```yaml
# UniFi Dream Machine Pro (UDM Pro)
sensor.udm_pro_temperature
sensor.udm_pro_cpu
sensor.udm_pro_memory

# UniFi Switch Pro Max 16 PoE
sensor.usw_pro_max_16_poe_temperature

# 35+ UniFi Protect Cameras
# Integration: unifiprotect
```

---

## 🔐 SECURITY PATTERNS

**Note**: This section contains patterns, NOT actual secrets

### Secrets.yaml Structure
```yaml
# Example (not actual values)
http_base_url: "https://ha.myhomehub13.xyz"
home_latitude: "[REDACTED]"
home_longitude: "[REDACTED]"
yamaha_host: "192.168.21.171"  # OK to store (local IP)
unifi_username: "[REDACTED]"
unifi_password: "[REDACTED]"
```

### Security Layers
1. **File permissions**: chmod 600 /config/secrets.yaml
2. **.gitignore**: Exclude secrets.yaml
3. **git-crypt**: Encrypted git commits (optional)
4. **Pre-commit hooks**: Scan for secrets (optional)

### Backup Strategy
- **Local**: HA Supervisor backups (daily at 3:00 AM recommended)
- **External**: Google Drive Backup add-on
- **Off-site**: Encrypted cloud storage
- **Files**: configuration.yaml, automations.yaml, secrets.yaml (encrypted), ha-context.md

---

## 📝 SESSION LOG

*AI assistants: Append your summary here after each session*
*John: Review weekly, archive quarterly*

### 2025-11-05 22:10 - Claude - Initial Context Document Creation
**Query**: Create comprehensive living context document for cross-AI use
**Actions**:
- Extracted 3,378 entities from entity registry
- Cataloged 40+ lights, 50+ binary sensors, 35+ cameras
- Documented 30+ automations, 25+ integrations
- Identified critical systems: UniFi Protect, Adaptive Lighting, Yamaha, ESPHome Ratgdo
- Created token-optimized structure (<2000 tokens per query)
**Entities Documented**: All major entities organized by domain
**New Issues Found**: 
- 30-minute motion timeouts may be too long
- Kitchen motion automation test may need cleanup
**Recommendations**:
- Run monthly: Update entity reference when adding devices
- Add mobile_app notify service for John's phone
- Verify Yamaha IP static reservation
- Document remaining static IPs (Ratgdo, Hue bridge)
- Test Samsung S24 notification permissions

---

## 🔄 SYSTEM EVOLUTION

*Quarterly: Reorganize session log into themes*

### Q4 2025 - System Foundation
**Achievement**: Complete context system with 3,378 entities documented
- Comprehensive smart home: Lighting, security, media, climate
- UniFi ecosystem: Protect cameras, network monitoring
- Adaptive lighting: 5 zones configured
- Family bedtime routines: Alaina & Ella automated
- Garage security: Ratgdo ESPHome with Aqara sensors

**Key Patterns Established**:
- Event-based Samsung notifications (not URI)
- Adaptive lighting via apply service
- Motion timeouts: 5-10min optimal
- Kitchen: 5 sensors (not 6)
- Entry room: Always-on pattern
- Ella's room: Manual only

---

## 📚 GLOSSARY

### Entity ID Patterns
```
light.[location]_[device]
binary_sensor.[device]_[type]
sensor.[device]_[measurement]
cover.[device]_door
person.[name]
media_player.[location]_[device]
notify.mobile_app_[device]
switch.adaptive_lighting_[zone]
```

### Common Services
```yaml
light.turn_on / light.turn_off
adaptive_lighting.apply
cover.open_cover / cover.close_cover
notify.mobile_app_john_s_phone
tts.google_translate_say
```

### Automation Modes
```yaml
single: Only one run at a time (default)
restart: Restart when triggered again
queued: Queue multiple triggers
parallel: Allow simultaneous runs
```

---

## 📊 SYSTEM METRICS

### Current Status
- **Total Entities**: 3,378
- **Integrations**: 25+ active
- **Automations**: 30+
- **Cameras**: 35+ (UniFi Protect)
- **Media Players**: 40+
- **Adaptive Lighting Zones**: 5

### Health Checklist
- [ ] All integrations active
- [ ] Backups running daily
- [ ] Static IPs verified
- [ ] Samsung S24 notifications: Unrestricted battery
- [ ] ESPHome actions enabled on both Ratgdo
- [ ] Monthly entity reference update

---

## END OF LIVING DOCUMENT

**Next Update**: As needed
**Document Size**: ~85KB
**Token Count**: ~1,800 per typical query
**Last Modified**: 2025-11-05 22:10 CST
