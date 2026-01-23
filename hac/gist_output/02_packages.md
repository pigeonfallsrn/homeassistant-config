# HA Packages - 2026-01-21 20:46
All automation packages from /config/packages/

## adaptive_lighting_entry_lamp.yaml
```yaml
# Entry Room Lamp - Adaptive Lighting with Lux + Presence + Time Awareness
# Also contains: Hot Tub Mode, Extended Evening, Global AL controls

# =============================================================================
# HELPERS
# =============================================================================

input_boolean:
  hot_tub_mode:
    name: Hot Tub Mode
    icon: mdi:hot-tub
  extended_evening:
    name: Extended Evening Mode
    icon: mdi:weather-night-partly-cloudy

input_number:
  entry_room_lux_threshold:
    name: Entry Room Lux Threshold
    min: 10
    max: 200
    step: 10
    initial: 50
    unit_of_measurement: lux
    icon: mdi:brightness-5

template:
  - sensor:
      - name: "Entry Room Average Lux"
        unique_id: entry_room_average_lux
        unit_of_measurement: lux
        device_class: illuminance
        state: >
          {% set east = states('sensor.entry_room_east_wall_nightlight_illuminance') | float(0) %}
          {% set west = states('sensor.entry_room_west_wall_nightlight_illuminance') | float(0) %}
          {{ ((east + west) / 2) | round(1) }}

      # Dynamic evening off time based on conditions
      - name: "Evening Lamp Off Time"
        unique_id: evening_lamp_off_time
        state: >
          {% set kids_home = is_state('input_boolean.alaina_home', 'on') or is_state('input_boolean.ella_home', 'on') %}
          {% set school = is_state('input_boolean.school_tomorrow', 'on') %}
          {% if is_state('input_boolean.hot_tub_mode', 'on') %}
            01:00
          {% elif is_state('input_boolean.extended_evening', 'on') %}
            00:30
          {% elif is_state('input_boolean.guest_present', 'on') %}
            00:30
          {% elif kids_home and school %}
            22:30
          {% else %}
            23:30
          {% endif %}
        icon: mdi:clock-outline

      # Dynamic max brightness after wind-down time
      - name: "Evening Lamp Max Brightness"
        unique_id: evening_lamp_max_brightness
        unit_of_measurement: "%"
        state: >
          {% set hour = now().hour %}
          {% set minute = now().minute %}
          {% set time_val = hour + minute/60 %}
          {% set kids_home = is_state('input_boolean.alaina_home', 'on') or is_state('input_boolean.ella_home', 'on') %}
          {% set school = is_state('input_boolean.school_tomorrow', 'on') %}
          {% set extended = is_state('input_boolean.extended_evening', 'on') or is_state('input_boolean.guest_present', 'on') %}
          {% set hot_tub = is_state('input_boolean.hot_tub_mode', 'on') %}
          {% if hot_tub %}
            5
          {% elif extended %}
            100
          {% elif kids_home and school %}
            {% if time_val >= 21.5 %}30{% else %}100{% endif %}
          {% else %}
            {% if time_val >= 22.5 %}30{% else %}100{% endif %}
          {% endif %}

# =============================================================================
# AUTOMATIONS
# =============================================================================

automation:
  # ---------------------------------------------------------------------------
  # Extended Evening - Auto Set/Clear
  # ---------------------------------------------------------------------------
  - id: extended_evening_auto_set
    alias: "Extended Evening - Auto Set for Weekends/Holidays"
    trigger:
      - platform: time
        at: "18:00:00"
    condition:
      - condition: or
        conditions:
          - condition: time
            weekday: [fri, sat]
          - condition: state
            entity_id: calendar.holidays_in_united_states
            state: "on"
          - condition: state
            entity_id: input_boolean.guest_present
            state: "on"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.extended_evening

  - id: extended_evening_auto_clear
    alias: "Extended Evening - Auto Clear at 4am"
    trigger:
      - platform: time
        at: "04:00:00"
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.extended_evening

  # ---------------------------------------------------------------------------
  # Hot Tub Mode - Multiple Auto-Off Conditions
  # ---------------------------------------------------------------------------
  - id: hot_tub_mode_auto_reset
    alias: "Hot Tub Mode - Auto Reset at 3am"
    trigger:
      - platform: time
        at: "03:00:00"
    condition:
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "on"
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.hot_tub_mode

  - id: hot_tub_mode_auto_off_when_done
    alias: "Hot Tub Mode - Auto Off When Back Inside"
    description: "Turn off hot tub mode when back door closed 10 min OR nobody home"
    trigger:
      - platform: state
        entity_id: binary_sensor.aqara_door_and_window_sensor_door
        to: "off"
        for:
          minutes: 10
        id: door_closed
      - platform: time_pattern
        minutes: "/5"
        id: periodic_check
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
        id: nobody_home
    condition:
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "on"
    action:
      - choose:
          # Nobody home - immediate off
          - conditions:
              - condition: trigger
                id: nobody_home
            sequence:
              - service: input_boolean.turn_off
                target:
                  entity_id: input_boolean.hot_tub_mode
          # Door closed check
          - conditions:
              - condition: state
                entity_id: binary_sensor.aqara_door_and_window_sensor_door
                state: "off"
                for:
                  minutes: 10
            sequence:
              - service: input_boolean.turn_off
                target:
                  entity_id: input_boolean.hot_tub_mode
    mode: single

  # ---------------------------------------------------------------------------
  # Arrival - Turn On Adaptive Lighting + Welcome Light
  # ---------------------------------------------------------------------------
  - id: arrival_adaptive_lighting_on
    alias: "Arrival - Adaptive Lighting Welcome"
    description: "Turn on entry lamp when someone arrives after dark"
    trigger:
      # Person arrives home
      - platform: state
        entity_id:
          - person.john_spencer
          - person.alaina_spencer
          - person.ella_spencer
        to: "home"
        id: person_arrived
      # Garage door opens
      - platform: state
        entity_id:
          - cover.ratgdo32disco_5735e8_door
          - cover.ratgdo32disco_fd8d8c_door
        to: "open"
        id: garage_opened
      # Front doors open
      - platform: state
        entity_id:
          - binary_sensor.aqara_door_and_window_sensor_door_2
          - binary_sensor.aqara_door_and_window_sensor_door_4
        to: "on"
        id: front_door_opened
    condition:
      - condition: state
        entity_id: sun.sun
        state: "below_horizon"
      - condition: numeric_state
        entity_id: sensor.entry_room_average_lux
        below: 50
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "off"
      - condition: state
        entity_id: input_boolean.dad_bedtime_mode
        state: "off"
    action:
      - service: switch.turn_on
        target:
          entity_id: switch.adaptive_lighting_living_spaces
      - service: light.turn_on
        target:
          entity_id: light.entry_room_hue_color_lamp
        data:
          brightness_pct: "{{ states('sensor.evening_lamp_max_brightness') | int }}"

  # ---------------------------------------------------------------------------
  # Entry Room Lamp - Lux-Gated Adaptive Control
  # ---------------------------------------------------------------------------
  - id: entry_room_lamp_adaptive_control
    alias: "Entry Room Lamp - Adaptive Lux Control"
    description: "Manages lamp based on lux, presence, time, and modes"
    mode: single
    trigger:
      - platform: numeric_state
        entity_id: sensor.entry_room_average_lux
        below: input_number.entry_room_lux_threshold
        for:
          seconds: 30
        id: dark_enough
      - platform: numeric_state
        entity_id: sensor.entry_room_average_lux
        above: 150
        for:
          seconds: 30
        id: too_bright
      - platform: state
        entity_id: 
          - binary_sensor.entry_room_east_wall_nightlight_motion
          - binary_sensor.entry_room_west_wall_nightlight_motion
        to: "on"
        for:
          seconds: 2
        id: motion
      - platform: state
        entity_id: input_boolean.hot_tub_mode
        id: hot_tub_toggle
      - platform: state
        entity_id: input_boolean.entry_room_manual_override
        to: "off"
        id: override_cleared
      - platform: state
        entity_id: input_boolean.dad_bedtime_mode
        to: "on"
        id: bedtime_on
    condition:
      - condition: state
        entity_id: input_boolean.entry_room_manual_override
        state: "off"
      # Mode triggers always pass; motion/lux require light off
      - condition: or
        conditions:
          - condition: trigger
            id: hot_tub_toggle
          - condition: trigger
            id: bedtime_on
          - condition: trigger
            id: override_cleared
          - condition: trigger
            id: too_bright
          - condition: and
            conditions:
              - condition: or
                conditions:
                  - condition: trigger
                    id: motion
                  - condition: trigger
                    id: dark_enough
              - condition: state
                entity_id: light.entry_room_hue_color_lamp
                state: "off"
    action:
      - choose:
          # HOT TUB MODE - Deep red, very dim
          - conditions:
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "on"
            sequence:
              - service: light.turn_on
                target:
                  entity_id: light.entry_room_hue_color_lamp
                data:
                  rgb_color: [255, 30, 0]
                  brightness_pct: 5
                  transition: 2
              - service: switch.turn_off
                target:
                  entity_id: switch.adaptive_lighting_living_spaces

          # DAD BEDTIME MODE - Fade off
          - conditions:
              - condition: trigger
                id: bedtime_on
            sequence:
              - service: light.turn_on
                target:
                  entity_id: light.entry_room_hue_color_lamp
                data:
                  brightness_pct: 10
                  color_temp_kelvin: 2200
                  transition: 60
              - delay:
                  minutes: 15
              - service: light.turn_off
                target:
                  entity_id: light.entry_room_hue_color_lamp
                data:
                  transition: 60

          # ROOM TOO BRIGHT - Fade off
          - conditions:
              - condition: trigger
                id: too_bright
              - condition: state
                entity_id: light.entry_room_hue_color_lamp
                state: "on"
            sequence:
              - service: light.turn_off
                target:
                  entity_id: light.entry_room_hue_color_lamp
                data:
                  transition: 120

          # ROOM DARK + MOTION - Turn on with appropriate brightness
          - conditions:
              - condition: trigger
                id: motion
              - condition: numeric_state
                entity_id: sensor.entry_room_average_lux
                below: input_number.entry_room_lux_threshold
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
              - condition: state
                entity_id: input_boolean.dad_bedtime_mode
                state: "off"
              - condition: or
                conditions:
                  - condition: state
                    entity_id: sun.sun
                    state: "below_horizon"
                  - condition: state
                    entity_id: input_boolean.someone_home
                    state: "on"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - service: light.turn_on
                target:
                  entity_id: light.entry_room_hue_color_lamp
                data:
                  brightness_pct: "{{ states('sensor.evening_lamp_max_brightness') | int }}"

          # HOT TUB MODE TURNED OFF - Restore AL control
          - conditions:
              - condition: trigger
                id: hot_tub_toggle
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - condition: state
                entity_id: light.entry_room_hue_color_lamp
                state: "on"
              - service: adaptive_lighting.apply
                data:
                  entity_id: switch.adaptive_lighting_living_spaces
                  lights:
                    - light.entry_room_hue_color_lamp
                  transition: 5

  # ---------------------------------------------------------------------------
  # Entry Room Lamp - No Motion Timeout
  # ---------------------------------------------------------------------------
  - id: entry_room_lamp_no_motion_dim
    alias: "Entry Room Lamp - Dim After 15min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.entry_room_motion
        to: "off"
        for:
          minutes: 15
    condition:
      - condition: state
        entity_id: input_boolean.entry_room_manual_override
        state: "off"
      # Mode triggers always pass; motion/lux require light off
      - condition: or
        conditions:
          - condition: trigger
            id: hot_tub_toggle
          - condition: trigger
            id: bedtime_on
          - condition: trigger
            id: override_cleared
          - condition: trigger
            id: too_bright
          - condition: and
            conditions:
              - condition: or
                conditions:
                  - condition: trigger
                    id: motion
                  - condition: trigger
                    id: dark_enough
              - condition: state
                entity_id: light.entry_room_hue_color_lamp
                state: "off"
      - condition: state
        entity_id: light.entry_room_hue_color_lamp
        state: "on"
      - condition: numeric_state
        entity_id: light.entry_room_hue_color_lamp
        attribute: brightness
        above: 50
    action:
      - service: light.turn_on
        target:
          entity_id: light.entry_room_hue_color_lamp
        data:
          brightness_pct: 20
          transition: 60
    mode: single

  - id: entry_room_lamp_no_motion_off
    alias: "Entry Room Lamp - Off After 30min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.entry_room_motion
        to: "off"
        for:
          minutes: 30
    condition:
      - condition: state
        entity_id: input_boolean.entry_room_manual_override
        state: "off"
      # Mode triggers always pass; motion/lux require light off
      - condition: or
        conditions:
          - condition: trigger
            id: hot_tub_toggle
          - condition: trigger
            id: bedtime_on
          - condition: trigger
            id: override_cleared
          - condition: trigger
            id: too_bright
          - condition: and
            conditions:
              - condition: or
                conditions:
                  - condition: trigger
                    id: motion
                  - condition: trigger
                    id: dark_enough
              - condition: state
                entity_id: light.entry_room_hue_color_lamp
                state: "off"
      - condition: state
        entity_id: light.entry_room_hue_color_lamp
        state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id: light.entry_room_hue_color_lamp
        data:
          transition: 60
    mode: single

  # ---------------------------------------------------------------------------
  # Entry Room Lamp - Hard Off Time
  # ---------------------------------------------------------------------------
  - id: entry_room_lamp_hard_off
    alias: "Entry Room Lamp - Hard Off at Evening End"
    trigger:
      - platform: template
        value_template: >
          {{ now().strftime('%H:%M') == states('sensor.evening_lamp_off_time') }}
    condition:
      - condition: state
        entity_id: light.entry_room_hue_color_lamp
        state: "on"
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "off"
    action:
      - service: light.turn_off
        target:
          entity_id: light.entry_room_hue_color_lamp
        data:
          transition: 120
    mode: single

  # ---------------------------------------------------------------------------
  # Everyone Left - Lamps Off
  # ---------------------------------------------------------------------------
  - id: entry_room_lamp_everyone_left
    alias: "Entry Room Lamp - Off When Everyone Leaves"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
    condition:
      - condition: state
        entity_id: light.entry_room_hue_color_lamp
        state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id: light.entry_room_hue_color_lamp
        data:
          transition: 30
    mode: single

  # ---------------------------------------------------------------------------
  # Global AL Off - Nobody Home or Late Night
  # ---------------------------------------------------------------------------
  - id: adaptive_lighting_global_off
    alias: "Adaptive Lighting - Off When Nobody Home or Late Night"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
        id: nobody_home
      - platform: template
        value_template: >
          {% set off_time = states('sensor.evening_lamp_off_time') %}
          {{ now().strftime('%H:%M') == off_time }}
        id: hard_off_time
    condition:
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "off"
    action:
      - service: switch.turn_off
        target:
          entity_id: switch.adaptive_lighting_living_spaces
    mode: single

  # ---------------------------------------------------------------------------
  # Hot Tub Mode - Actionable Notification
  # ---------------------------------------------------------------------------
  - id: hot_tub_mode_notification
    alias: "Hot Tub Mode - Reminder Notification"
    trigger:
      - platform: state
        entity_id: input_boolean.hot_tub_mode
        to: "on"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Hot Tub Mode Active"
          message: "Adaptive lighting paused. Entry lamp set to red."
          data:
            tag: "hot_tub_mode"
            persistent: true
            actions:
              - action: "HOT_TUB_OFF"
                title: "Turn Off"
              - action: "HOT_TUB_SNOOZE_30"
                title: "Snooze 30m"
              - action: "HOT_TUB_SNOOZE_60"
                title: "Snooze 1hr"
    mode: single

  - id: hot_tub_mode_notification_actions
    alias: "Hot Tub Mode - Handle Notification Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HOT_TUB_OFF"
        id: turn_off
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HOT_TUB_SNOOZE_30"
        id: snooze_30
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HOT_TUB_SNOOZE_60"
        id: snooze_60
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: turn_off
            sequence:
              - service: input_boolean.turn_off
                target:
                  entity_id: input_boolean.hot_tub_mode
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "hot_tub_mode"

          - conditions:
              - condition: trigger
                id: snooze_30
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "hot_tub_mode"
              - delay:
                  minutes: 30
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "Hot Tub Mode Still Active"
                  message: "30 minute snooze ended."
                  data:
                    tag: "hot_tub_mode"
                    persistent: true
                    actions:
                      - action: "HOT_TUB_OFF"
                        title: "Turn Off"
                      - action: "HOT_TUB_SNOOZE_30"
                        title: "Snooze 30m"
                      - action: "HOT_TUB_SNOOZE_60"
                        title: "Snooze 1hr"

          - conditions:
              - condition: trigger
                id: snooze_60
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "hot_tub_mode"
              - delay:
                  minutes: 60
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "Hot Tub Mode Still Active"
                  message: "1 hour snooze ended."
                  data:
                    tag: "hot_tub_mode"
                    persistent: true
                    actions:
                      - action: "HOT_TUB_OFF"
                        title: "Turn Off"
                      - action: "HOT_TUB_SNOOZE_30"
                        title: "Snooze 30m"
                      - action: "HOT_TUB_SNOOZE_60"
                        title: "Snooze 1hr"
    mode: single
```

## adaptive_lighting_kitchen_lounge_lamp.yaml
```yaml
# Kitchen Lounge Lamp - Adaptive Lighting with Lux + Presence + Time Awareness

# =============================================================================
# HELPERS
# =============================================================================

input_number:
  kitchen_lounge_lux_threshold:
    name: Kitchen Lounge Lux Threshold
    min: 10
    max: 200
    step: 10
    initial: 50
    unit_of_measurement: lux
    icon: mdi:brightness-5

template:
  - sensor:
      - name: "Kitchen Lounge Average Lux"
        unique_id: kitchen_lounge_average_lux
        unit_of_measurement: lux
        device_class: illuminance
        state: >
          {% set s1 = states('sensor.kitchen_lounge_east_wall_night_light_illuminance') | float(0) %}
          {% set s2 = states('sensor.kitchen_lounge_east_wall_nightlight_illuminance') | float(0) %}
          {% if s1 > 0 and s2 > 0 %}
            {{ ((s1 + s2) / 2) | round(1) }}
          {% elif s1 > 0 %}
            {{ s1 }}
          {% else %}
            {{ s2 }}
          {% endif %}

# =============================================================================
# AUTOMATIONS
# =============================================================================

automation:
  # ---------------------------------------------------------------------------
  # Kitchen Lounge Lamp - Lux-Gated Adaptive Control
  # ---------------------------------------------------------------------------
  - id: kitchen_lounge_lamp_adaptive_control
    alias: "Kitchen Lounge Lamp - Adaptive Lux Control"
    description: "Manages lamp based on lux, presence, time, and modes"
    mode: single
    trigger:
      - platform: numeric_state
        entity_id: sensor.kitchen_lounge_average_lux
        below: input_number.kitchen_lounge_lux_threshold
        for:
          seconds: 30
        id: dark_enough
      - platform: numeric_state
        entity_id: sensor.kitchen_lounge_average_lux
        above: 150
        for:
          seconds: 30
        id: too_bright
      - platform: state
        entity_id: 
          - binary_sensor.kitchen_lounge_east_wall_night_light_motion
          - binary_sensor.kitchen_lounge_east_wall_nightlight_motion
        to: "on"
        for:
          seconds: 2
        id: motion
      - platform: state
        entity_id: input_boolean.hot_tub_mode
        id: hot_tub_toggle
      - platform: state
        entity_id: input_boolean.dad_bedtime_mode
        to: "on"
        id: bedtime_on
    condition:
      # Only respond to motion if light is currently off
      - condition: or
        conditions:
          - condition: not
            conditions:
              - condition: trigger
                id: motion
          - condition: state
            entity_id: light.kitchen_lounge_lamp
            state: "off"
    action:
      - choose:
          # HOT TUB MODE - Deep red, very dim
          - conditions:
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "on"
            sequence:
              - service: light.turn_on
                target:
                  entity_id: light.kitchen_lounge_lamp
                data:
                  rgb_color: [255, 30, 0]
                  brightness_pct: 5
                  transition: 2

          # DAD BEDTIME MODE - Fade off
          - conditions:
              - condition: trigger
                id: bedtime_on
            sequence:
              - service: light.turn_on
                target:
                  entity_id: light.kitchen_lounge_lamp
                data:
                  brightness_pct: 10
                  color_temp_kelvin: 2200
                  transition: 60
              - delay:
                  minutes: 15
              - service: light.turn_off
                target:
                  entity_id: light.kitchen_lounge_lamp
                data:
                  transition: 60

          # ROOM TOO BRIGHT - Fade off
          - conditions:
              - condition: trigger
                id: too_bright
              - condition: state
                entity_id: light.kitchen_lounge_lamp
                state: "on"
            sequence:
              - service: light.turn_off
                target:
                  entity_id: light.kitchen_lounge_lamp
                data:
                  transition: 120

          # ROOM DARK + MOTION - Turn on with appropriate brightness
          - conditions:
              - condition: trigger
                id: motion
              - condition: numeric_state
                entity_id: sensor.kitchen_lounge_average_lux
                below: input_number.kitchen_lounge_lux_threshold
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
              - condition: state
                entity_id: input_boolean.dad_bedtime_mode
                state: "off"
              - condition: or
                conditions:
                  - condition: state
                    entity_id: sun.sun
                    state: "below_horizon"
                  - condition: state
                    entity_id: input_boolean.someone_home
                    state: "on"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - service: light.turn_on
                target:
                  entity_id: light.kitchen_lounge_lamp
                data:
                  brightness_pct: "{{ states('sensor.evening_lamp_max_brightness') | int }}"

          # HOT TUB MODE TURNED OFF - Restore AL control
          - conditions:
              - condition: trigger
                id: hot_tub_toggle
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - condition: state
                entity_id: light.kitchen_lounge_lamp
                state: "on"
              - service: adaptive_lighting.apply
                data:
                  entity_id: switch.adaptive_lighting_living_spaces
                  lights:
                    - light.kitchen_lounge_lamp
                  transition: 5

  # ---------------------------------------------------------------------------
  # Kitchen Lounge Lamp - No Motion Timeout
  # ---------------------------------------------------------------------------
  - id: kitchen_lounge_lamp_no_motion_dim
    alias: "Kitchen Lounge Lamp - Dim After 15min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.kitchen_lounge_motion
        to: "off"
        for:
          minutes: 15
    condition:
      - condition: state
        entity_id: light.kitchen_lounge_lamp
        state: "on"
      - condition: numeric_state
        entity_id: light.kitchen_lounge_lamp
        attribute: brightness
        above: 50
    action:
      - service: light.turn_on
        target:
          entity_id: light.kitchen_lounge_lamp
        data:
          brightness_pct: 20
          transition: 60
    mode: single

  - id: kitchen_lounge_lamp_no_motion_off
    alias: "Kitchen Lounge Lamp - Off After 30min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.kitchen_lounge_motion
        to: "off"
        for:
          minutes: 30
    condition:
      - condition: state
        entity_id: light.kitchen_lounge_lamp
        state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id: light.kitchen_lounge_lamp
        data:
          transition: 60

  # ---------------------------------------------------------------------------
  # Kitchen Lounge Lamp - Hard Off Time
  # ---------------------------------------------------------------------------
  - id: kitchen_lounge_lamp_hard_off
    alias: "Kitchen Lounge Lamp - Hard Off at Evening End"
    trigger:
      - platform: template
        value_template: >
          {{ now().strftime('%H:%M') == states('sensor.evening_lamp_off_time') }}
    condition:
      - condition: state
        entity_id: light.kitchen_lounge_lamp
        state: "on"
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "off"
    action:
      - service: light.turn_off
        target:
          entity_id: light.kitchen_lounge_lamp
        data:
          transition: 120

  # ---------------------------------------------------------------------------
  # Everyone Left - Lamp Off
  # ---------------------------------------------------------------------------
  - id: kitchen_lounge_lamp_everyone_left
    alias: "Kitchen Lounge Lamp - Off When Everyone Leaves"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
    condition:
      - condition: state
        entity_id: light.kitchen_lounge_lamp
        state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id: light.kitchen_lounge_lamp
        data:
          transition: 30
```

## adaptive_lighting_living_room.yaml
```yaml
# Living Room Lamps - Adaptive Lighting with Lux + Presence + Time Awareness
# Covers: light.living_room_east_floor_lamp, light.living_room_lounge_lamp

# =============================================================================
# HELPERS
# =============================================================================

input_number:
  living_room_lux_threshold:
    name: Living Room Lux Threshold
    min: 10
    max: 200
    step: 10
    initial: 50
    unit_of_measurement: lux
    icon: mdi:brightness-5

input_boolean:
  living_room_manual_override:
    name: Living Room Manual Override
    initial: false

# =============================================================================
# AUTOMATIONS
# =============================================================================

automation:
  # ---------------------------------------------------------------------------
  # Living Room Lamps - Motion Activated (using motionaware area sensor)
  # ---------------------------------------------------------------------------
  - id: living_room_lamps_adaptive_control
    alias: "Living Room Lamps - Adaptive Control"
    description: "Manages lamps based on motion, presence, time, and modes"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.living_rm_loungemotionaware_area
        to: "on"
        id: motion
      - platform: state
        entity_id: input_boolean.hot_tub_mode
        id: hot_tub_toggle
      - platform: state
        entity_id: input_boolean.dad_bedtime_mode
        to: "on"
        id: bedtime_on
    condition:
      - condition: state
        entity_id: input_boolean.living_room_manual_override
        state: "off"
    action:
      - choose:
          # HOT TUB MODE - Deep red, very dim
          - conditions:
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "on"
            sequence:
              - service: light.turn_on
                target:
                  entity_id:
                    - light.living_room_east_floor_lamp
                    - light.living_room_lounge_lamp
                data:
                  rgb_color: [255, 30, 0]
                  brightness_pct: 5
                  transition: 2
              - service: switch.turn_off
                target:
                  entity_id: switch.adaptive_lighting_living_spaces

          # DAD BEDTIME MODE - Fade off
          - conditions:
              - condition: trigger
                id: bedtime_on
            sequence:
              - service: light.turn_on
                target:
                  entity_id:
                    - light.living_room_east_floor_lamp
                    - light.living_room_lounge_lamp
                data:
                  brightness_pct: 10
                  color_temp_kelvin: 2200
                  transition: 60
              - delay:
                  minutes: 15
              - service: light.turn_off
                target:
                  entity_id:
                    - light.living_room_east_floor_lamp
                    - light.living_room_lounge_lamp
                data:
                  transition: 60

          # MOTION + DARK - Turn on with AL
          - conditions:
              - condition: trigger
                id: motion
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
              - condition: state
                entity_id: input_boolean.dad_bedtime_mode
                state: "off"
              - condition: state
                entity_id: sun.sun
                state: "below_horizon"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - service: light.turn_on
                target:
                  entity_id:
                    - light.living_room_east_floor_lamp
                    - light.living_room_lounge_lamp
                data:
                  brightness_pct: "{{ states('sensor.evening_lamp_max_brightness') | int }}"

          # HOT TUB MODE TURNED OFF - Restore AL
          - conditions:
              - condition: trigger
                id: hot_tub_toggle
              - condition: state
                entity_id: input_boolean.hot_tub_mode
                state: "off"
            sequence:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_living_spaces
              - service: adaptive_lighting.apply
                data:
                  entity_id: switch.adaptive_lighting_living_spaces
                  lights:
                    - light.living_room_east_floor_lamp
                    - light.living_room_lounge_lamp
                  transition: 5

  # ---------------------------------------------------------------------------
  # Living Room Lamps - No Motion Timeout
  # ---------------------------------------------------------------------------
  - id: living_room_lamps_no_motion_dim
    alias: "Living Room Lamps - Dim After 20min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.living_room_motion
        to: "off"
        for:
          minutes: 20
    condition:
      - condition: state
        entity_id: input_boolean.living_room_manual_override
        state: "off"
      - condition: or
        conditions:
          - condition: state
            entity_id: light.living_room_east_floor_lamp
            state: "on"
          - condition: state
            entity_id: light.living_room_lounge_lamp
            state: "on"
    action:
      - service: light.turn_on
        target:
          entity_id:
            - light.living_room_east_floor_lamp
            - light.living_room_lounge_lamp
        data:
          brightness_pct: 20
          transition: 60
    mode: single

  - id: living_room_lamps_no_motion_off
    alias: "Living Room Lamps - Off After 45min No Motion"
    trigger:
      - platform: state
        entity_id: binary_sensor.living_room_motion
        to: "off"
        for:
          minutes: 45
    condition:
      - condition: state
        entity_id: input_boolean.living_room_manual_override
        state: "off"
      - condition: or
        conditions:
          - condition: state
            entity_id: light.living_room_east_floor_lamp
            state: "on"
          - condition: state
            entity_id: light.living_room_lounge_lamp
            state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.living_room_east_floor_lamp
            - light.living_room_lounge_lamp
        data:
          transition: 60

  # ---------------------------------------------------------------------------
  # Living Room Lamps - Hard Off Time
  # ---------------------------------------------------------------------------
  - id: living_room_lamps_hard_off
    alias: "Living Room Lamps - Hard Off at Evening End"
    trigger:
      - platform: template
        value_template: >
          {{ now().strftime('%H:%M') == states('sensor.evening_lamp_off_time') }}
    condition:
      - condition: or
        conditions:
          - condition: state
            entity_id: light.living_room_east_floor_lamp
            state: "on"
          - condition: state
            entity_id: light.living_room_lounge_lamp
            state: "on"
      - condition: state
        entity_id: input_boolean.hot_tub_mode
        state: "off"
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.living_room_east_floor_lamp
            - light.living_room_lounge_lamp
        data:
          transition: 120

  # ---------------------------------------------------------------------------
  # Living Room Lamps - Everyone Left
  # ---------------------------------------------------------------------------
  - id: living_room_lamps_everyone_left
    alias: "Living Room Lamps - Off When Everyone Leaves"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
    condition:
      - condition: or
        conditions:
          - condition: state
            entity_id: light.living_room_east_floor_lamp
            state: "on"
          - condition: state
            entity_id: light.living_room_lounge_lamp
            state: "on"
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.living_room_east_floor_lamp
            - light.living_room_lounge_lamp
        data:
          transition: 30

  # ---------------------------------------------------------------------------
  # GLOBAL: Everyone Left - All Managed Lamps Off
  # ---------------------------------------------------------------------------
  - id: global_everyone_left_lamps_off
    alias: "Global - All Adaptive Lamps Off When Everyone Leaves"
    description: "Master switch - turns off all adaptive-managed lamps when house is empty"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.entry_room_hue_color_lamp
            - light.kitchen_lounge_lamp
            - light.living_room_east_floor_lamp
            - light.living_room_lounge_lamp
            - light.very_front_door_hallway
        data:
          transition: 10
```

## ap_presence_hybrid.yaml
```yaml
# =============================================================================
# HYBRID AP-Based Presence Detection System
# Updated: 2026-01-21 - Added motion-based floor fallback for iPhones
# =============================================================================
# Uses: UniFi ap_mac, Companion App BSSID, AND motion sensors as fallback
#
# AP REFERENCE:
#   2nd Floor: MAC 70:a7:41:c6:1e:6c | BSSIDs start with 70:a7:41 or 72:a7:41
#   1st Floor: MAC d0:21:f9:eb:b8:8c | BSSIDs start with d0:21:f9 or d2:21:f9
#   Garage:    MAC f4:92:bf:69:53:f0 | BSSIDs start with f4:92:bf or f6:92:bf
#   Michelle's: MAC 60:22:32:3d:b6:44 | BSSIDs start with 60:22:32 or 62:22:32
#   Big Garage: MAC f0:9f:c2:26:6e:23 | BSSIDs start with f0:9f:c2 or f2:9f:c2
# =============================================================================

template:
  - sensor:
      # -------------------------------------------------------------------------
      # JOHN - Uses UniFi (Samsung S24) - Works perfectly
      # -------------------------------------------------------------------------
      - name: "John AP Location"
        unique_id: john_ap_location_hybrid
        icon: mdi:map-marker-account
        state: >
          {% set ap = state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') | default('') %}
          {% set state = states('device_tracker.john_s_s24_ultra_4') %}
          {% if ap[:11] in ['70:a7:41:c6', '72:a7:41'] or ap == '70:a7:41:c6:1e:6c' %}Home · Upstairs
          {% elif ap[:11] in ['d0:21:f9:eb', 'd2:21:f9'] or ap == 'd0:21:f9:eb:b8:8c' %}Home · Downstairs
          {% elif ap[:11] in ['f4:92:bf:69', 'f6:92:bf'] or ap == 'f4:92:bf:69:53:f0' %}Home · Garage
          {% elif ap[:11] in ['60:22:32:3d', '62:22:32'] or ap == '60:22:32:3d:b6:44' %}Michelle's House
          {% elif ap[:11] in ['f0:9f:c2:26', 'f2:9f:c2'] or ap == 'f0:9f:c2:26:6e:23' %}Big Garage
          {% elif state == 'home' %}Home
          {% elif state == 'not_home' %}Away
          {% else %}{{ state | title }}{% endif %}
        attributes:
          source: unifi
          ap_mac: "{{ state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') }}"
          floor: >
            {% set ap = state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') | default('') %}
            {% if ap[:8] in ['70:a7:41', '72:a7:41'] %}2nd
            {% elif ap[:8] in ['d0:21:f9', 'd2:21:f9'] %}1st
            {% elif ap[:8] in ['f4:92:bf', 'f6:92:bf'] %}garage
            {% else %}unknown{% endif %}

      # -------------------------------------------------------------------------
      # ELLA - Uses BSSID + Motion fallback (iPhone with Private Address)
      # -------------------------------------------------------------------------
      - name: "Ella AP Location"
        unique_id: ella_ap_location_hybrid
        icon: mdi:map-marker-account
        state: >
          {% set bssid = states('sensor.ellas_iphone_bssid') | default('') %}
          {% set ssid = states('sensor.ellas_iphone_ssid') | default('') %}
          {% set icloud_state = states('device_tracker.ellas_iphone') %}
          {% set icloud_addr = state_attr('device_tracker.ellas_iphone', 'address') | default('') %}
          {% set home = is_state('input_boolean.ella_home', 'on') %}
          {% set upstairs_motion = is_state('binary_sensor.upstairs_motion', 'on') %}
          {% set downstairs_motion = is_state('binary_sensor.downstairs_motion', 'on') %}
          {# BSSID detection first #}
          {% if bssid[:8] in ['70:a7:41', '72:a7:41'] %}Home · Upstairs
          {% elif bssid[:8] in ['d0:21:f9', 'd2:21:f9'] %}Home · Downstairs
          {% elif bssid[:8] in ['f4:92:bf', 'f6:92:bf'] %}Home · Garage
          {% elif bssid[:8] in ['60:22:32', '62:22:32'] %}Michelle's House
          {% elif bssid[:8] in ['f0:9f:c2', 'f2:9f:c2'] %}Big Garage
          {% elif ssid in ['Spencer', 'Spencer IoT', 'Spencer - guest'] %}Home
          {# iCloud location fallback #}
          {% elif 'Traci' in icloud_addr %}At Mom's
          {# Home with motion-based floor detection #}
          {% elif home or icloud_state == 'home' %}
            {% if upstairs_motion and not downstairs_motion %}Home · Upstairs
            {% elif downstairs_motion and not upstairs_motion %}Home · Downstairs
            {% else %}Home
            {% endif %}
          {% elif icloud_state == 'not_home' %}Away
          {% else %}{{ icloud_state | title }}{% endif %}
        attributes:
          source: "{% if states('sensor.ellas_iphone_bssid') not in ['Not Connected', 'unknown', 'unavailable', ''] %}companion_bssid{% else %}motion_fallback{% endif %}"
          bssid: "{{ states('sensor.ellas_iphone_bssid') }}"
          ssid: "{{ states('sensor.ellas_iphone_ssid') }}"
          floor: >
            {% set bssid = states('sensor.ellas_iphone_bssid') | default('') %}
            {% set home = is_state('input_boolean.ella_home', 'on') %}
            {% set upstairs = is_state('binary_sensor.upstairs_motion', 'on') %}
            {% set downstairs = is_state('binary_sensor.downstairs_motion', 'on') %}
            {% if bssid[:8] in ['70:a7:41', '72:a7:41'] %}2nd
            {% elif bssid[:8] in ['d0:21:f9', 'd2:21:f9'] %}1st
            {% elif bssid[:8] in ['f4:92:bf', 'f6:92:bf'] %}garage
            {% elif home and upstairs and not downstairs %}2nd
            {% elif home and downstairs and not upstairs %}1st
            {% else %}unknown{% endif %}
          at_moms: "{{ 'Traci' in (state_attr('device_tracker.ellas_iphone', 'address') | default('')) }}"

      # -------------------------------------------------------------------------
      # ALAINA - Uses BSSID + Motion fallback (iPhone with Private Address)
      # -------------------------------------------------------------------------
      - name: "Alaina AP Location"
        unique_id: alaina_ap_location_hybrid
        icon: mdi:map-marker-account
        state: >
          {% set bssid = states('sensor.alainas_iphone_bssid') | default('') %}
          {% set ssid = states('sensor.alainas_iphone_ssid') | default('') %}
          {% set icloud_state = states('device_tracker.alaina_s_iphone_17') %}
          {% set icloud_addr = state_attr('device_tracker.alaina_s_iphone_17', 'address') | default('') %}
          {% set home = is_state('input_boolean.alaina_home', 'on') %}
          {% set upstairs_motion = is_state('binary_sensor.upstairs_motion', 'on') %}
          {% set downstairs_motion = is_state('binary_sensor.downstairs_motion', 'on') %}
          {# BSSID detection first #}
          {% if bssid[:8] in ['70:a7:41', '72:a7:41'] %}Home · Upstairs
          {% elif bssid[:8] in ['d0:21:f9', 'd2:21:f9'] %}Home · Downstairs
          {% elif bssid[:8] in ['f4:92:bf', 'f6:92:bf'] %}Home · Garage
          {% elif bssid[:8] in ['60:22:32', '62:22:32'] %}Michelle's House
          {% elif bssid[:8] in ['f0:9f:c2', 'f2:9f:c2'] %}Big Garage
          {% elif ssid in ['Spencer', 'Spencer IoT', 'Spencer - guest'] %}Home
          {# iCloud location fallback #}
          {% elif 'Traci' in icloud_addr %}At Mom's
          {# Home with motion-based floor detection #}
          {% elif home or icloud_state == 'home' %}
            {% if upstairs_motion and not downstairs_motion %}Home · Upstairs
            {% elif downstairs_motion and not upstairs_motion %}Home · Downstairs
            {% else %}Home
            {% endif %}
          {% elif icloud_state == 'not_home' %}Away
          {% else %}{{ icloud_state | title }}{% endif %}
        attributes:
          source: "{% if states('sensor.alainas_iphone_bssid') not in ['Not Connected', 'unknown', 'unavailable', ''] %}companion_bssid{% else %}motion_fallback{% endif %}"
          bssid: "{{ states('sensor.alainas_iphone_bssid') }}"
          ssid: "{{ states('sensor.alainas_iphone_ssid') }}"
          floor: >
            {% set bssid = states('sensor.alainas_iphone_bssid') | default('') %}
            {% set home = is_state('input_boolean.alaina_home', 'on') %}
            {% set upstairs = is_state('binary_sensor.upstairs_motion', 'on') %}
            {% set downstairs = is_state('binary_sensor.downstairs_motion', 'on') %}
            {% if bssid[:8] in ['70:a7:41', '72:a7:41'] %}2nd
            {% elif bssid[:8] in ['d0:21:f9', 'd2:21:f9'] %}1st
            {% elif bssid[:8] in ['f4:92:bf', 'f6:92:bf'] %}garage
            {% elif home and upstairs and not downstairs %}2nd
            {% elif home and downstairs and not upstairs %}1st
            {% else %}unknown{% endif %}
          at_moms: "{{ 'Traci' in (state_attr('device_tracker.alaina_s_iphone_17', 'address') | default('')) }}"

      # -------------------------------------------------------------------------
      # MICHELLE - Uses UniFi (iPhone tracked by UniFi)
      # -------------------------------------------------------------------------
      - name: "Michelle AP Location"
        unique_id: michelle_ap_location_hybrid
        icon: mdi:map-marker-account
        state: >
          {% set ap = state_attr('device_tracker.michelle_s_iphone_14_pro', 'ap_mac') | default('') %}
          {% set state = states('device_tracker.michelle_s_iphone_14_pro') %}
          {% if ap[:8] in ['60:22:32', '62:22:32'] or ap == '60:22:32:3d:b6:44' %}Her House
          {% elif ap[:8] in ['70:a7:41', '72:a7:41'] %}John's House · Upstairs
          {% elif ap[:8] in ['d0:21:f9', 'd2:21:f9'] %}John's House · Downstairs
          {% elif ap[:8] in ['f4:92:bf', 'f6:92:bf'] %}John's House · Garage
          {% elif ap[:8] in ['f0:9f:c2', 'f2:9f:c2'] %}Big Garage
          {% elif state == 'home' %}Home
          {% elif state == 'not_home' %}Away
          {% else %}{{ state | title }}{% endif %}
        attributes:
          source: unifi
          ap_mac: "{{ state_attr('device_tracker.michelle_s_iphone_14_pro', 'ap_mac') }}"
          at_her_house: >
            {% set ap = state_attr('device_tracker.michelle_s_iphone_14_pro', 'ap_mac') | default('') %}
            {{ ap[:8] in ['60:22:32', '62:22:32'] }}
          at_johns_house: >
            {% set ap = state_attr('device_tracker.michelle_s_iphone_14_pro', 'ap_mac') | default('') %}
            {{ ap[:8] in ['70:a7:41', '72:a7:41', 'd0:21:f9', 'd2:21:f9', 'f4:92:bf', 'f6:92:bf'] }}

  # ---------------------------------------------------------------------------
  # AGGREGATE SENSORS - Floor occupancy with "who" attribute
  # ---------------------------------------------------------------------------
  - binary_sensor:
      - name: "Family Upstairs"
        unique_id: family_upstairs_hybrid
        device_class: occupancy
        state: >
          {{ is_state('sensor.john_ap_location', 'Home · Upstairs') or
             'Upstairs' in states('sensor.ella_ap_location') or
             'Upstairs' in states('sensor.alaina_ap_location') or
             is_state('sensor.michelle_ap_location', "John's House · Upstairs") }}
        attributes:
          who: >
            {% set p = [] %}
            {% if is_state('sensor.john_ap_location', 'Home · Upstairs') %}{% set p = p + ['John'] %}{% endif %}
            {% if 'Upstairs' in states('sensor.ella_ap_location') %}{% set p = p + ['Ella'] %}{% endif %}
            {% if 'Upstairs' in states('sensor.alaina_ap_location') %}{% set p = p + ['Alaina'] %}{% endif %}
            {% if is_state('sensor.michelle_ap_location', "John's House · Upstairs") %}{% set p = p + ['Michelle'] %}{% endif %}
            {{ p | join(', ') if p else 'Nobody' }}

      - name: "Family Downstairs"
        unique_id: family_downstairs_hybrid
        device_class: occupancy
        state: >
          {{ is_state('sensor.john_ap_location', 'Home · Downstairs') or
             'Downstairs' in states('sensor.ella_ap_location') or
             'Downstairs' in states('sensor.alaina_ap_location') or
             is_state('sensor.michelle_ap_location', "John's House · Downstairs") }}
        attributes:
          who: >
            {% set p = [] %}
            {% if is_state('sensor.john_ap_location', 'Home · Downstairs') %}{% set p = p + ['John'] %}{% endif %}
            {% if 'Downstairs' in states('sensor.ella_ap_location') %}{% set p = p + ['Ella'] %}{% endif %}
            {% if 'Downstairs' in states('sensor.alaina_ap_location') %}{% set p = p + ['Alaina'] %}{% endif %}
            {% if is_state('sensor.michelle_ap_location', "John's House · Downstairs") %}{% set p = p + ['Michelle'] %}{% endif %}
            {{ p | join(', ') if p else 'Nobody' }}

      - name: "Anyone Home"
        unique_id: anyone_home_hybrid
        device_class: presence
        state: >
          {{ 'Home' in states('sensor.john_ap_location') or
             'Home' in states('sensor.ella_ap_location') or
             'Home' in states('sensor.alaina_ap_location') or
             "John's House" in states('sensor.michelle_ap_location') }}
        attributes:
          who_home: >
            {% set p = [] %}
            {% if 'Home' in states('sensor.john_ap_location') %}{% set p = p + ['John'] %}{% endif %}
            {% if 'Home' in states('sensor.ella_ap_location') %}{% set p = p + ['Ella'] %}{% endif %}
            {% if 'Home' in states('sensor.alaina_ap_location') %}{% set p = p + ['Alaina'] %}{% endif %}
            {% if "John's House" in states('sensor.michelle_ap_location') %}{% set p = p + ['Michelle'] %}{% endif %}
            {{ p | join(', ') if p else 'Nobody' }}
          count: >
            {% set c = 0 %}
            {% if 'Home' in states('sensor.john_ap_location') %}{% set c = c + 1 %}{% endif %}
            {% if 'Home' in states('sensor.ella_ap_location') %}{% set c = c + 1 %}{% endif %}
            {% if 'Home' in states('sensor.alaina_ap_location') %}{% set c = c + 1 %}{% endif %}
            {% if "John's House" in states('sensor.michelle_ap_location') %}{% set c = c + 1 %}{% endif %}
            {{ c }}

      - name: "John At Big Garage"
        unique_id: john_at_big_garage_hybrid
        device_class: occupancy
        state: "{{ is_state('sensor.john_ap_location', 'Big Garage') }}"

      - name: "Michelle At Her House"
        unique_id: michelle_at_her_house_hybrid
        device_class: presence
        state: "{{ is_state('sensor.michelle_ap_location', 'Her House') }}"
```

## ella_bedroom.yaml
```yaml
# Ella's Bedroom - Scripts & Scenes
# Created: 2026-01-20
# Volleyball-loving 13-year-old, prefers dim warm lights for bedtime

script:
  # Quick action - all lights off
  ella_lights_off:
    alias: "Ella Lights Off"
    icon: mdi:lightbulb-off
    sequence:
      - service: light.turn_off
        target:
          entity_id:
            - light.ella_s_ceiling_light_1_of_3
            - light.ella_s_ceiling_light_2_of_3
            - light.ella_s_ceiling_light_3_of_3
            - light.ella_s_wall_light
            - light.ella_s_bedside_lamp
            - light.ella_s_led_lights

  # School night - dim glow then auto-off
  ella_school_night:
    alias: "Ella School Night"
    icon: mdi:bed-clock
    sequence:
      - service: light.turn_off
        target:
          entity_id:
            - light.ella_s_ceiling_light_1_of_3
            - light.ella_s_ceiling_light_2_of_3
            - light.ella_s_ceiling_light_3_of_3
            - light.ella_s_led_lights
      - service: light.turn_on
        target:
          entity_id: light.ella_s_bedside_lamp
        data:
          brightness_pct: 5
          color_temp_kelvin: 2000
      - service: light.turn_on
        target:
          entity_id: light.ella_s_wall_light
        data:
          brightness_pct: 3
          color_temp_kelvin: 2000
      - delay:
          minutes: 30
      - service: light.turn_off
        target:
          entity_id:
            - light.ella_s_wall_light
            - light.ella_s_bedside_lamp

  # Gentle wake - gradual sunrise simulation
  ella_gentle_wake:
    alias: "Ella Gentle Wake"
    icon: mdi:weather-sunset-up
    sequence:
      - service: light.turn_on
        target:
          entity_id:
            - light.ella_s_ceiling_light_1_of_3
            - light.ella_s_ceiling_light_2_of_3
            - light.ella_s_ceiling_light_3_of_3
        data:
          brightness_pct: 5
          color_temp_kelvin: 2200
      - delay:
          seconds: 30
      - service: light.turn_on
        target:
          entity_id:
            - light.ella_s_ceiling_light_1_of_3
            - light.ella_s_ceiling_light_2_of_3
            - light.ella_s_ceiling_light_3_of_3
        data:
          brightness_pct: 30
          color_temp_kelvin: 3500
          transition: 60
      - delay:
          seconds: 90
      - service: light.turn_on
        target:
          entity_id:
            - light.ella_s_ceiling_light_1_of_3
            - light.ella_s_ceiling_light_2_of_3
            - light.ella_s_ceiling_light_3_of_3
        data:
          brightness_pct: 80
          color_temp_kelvin: 5000
          transition: 90

scene:
  # Very dim red for sleeping - barely visible
  - name: "Ella Dim Red"
    icon: mdi:moon-waning-crescent
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "off"
      light.ella_s_ceiling_light_2_of_3:
        state: "off"
      light.ella_s_ceiling_light_3_of_3:
        state: "off"
      light.ella_s_wall_light:
        state: "on"
        brightness: 8
        rgb_color: [255, 50, 0]
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 8
        rgb_color: [255, 50, 0]
      light.ella_s_led_lights:
        state: "off"

  # Reading - focused warm light
  - name: "Ella Reading"
    icon: mdi:book-open-page-variant
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "off"
      light.ella_s_ceiling_light_2_of_3:
        state: "off"
      light.ella_s_ceiling_light_3_of_3:
        state: "off"
      light.ella_s_wall_light:
        state: "on"
        brightness: 200
        color_temp_kelvin: 4000
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 220
        color_temp_kelvin: 4000
      light.ella_s_led_lights:
        state: "off"

  # Bedtime glow - very dim warm
  - name: "Ella Bedtime Glow"
    icon: mdi:star-four-points
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "off"
      light.ella_s_ceiling_light_2_of_3:
        state: "off"
      light.ella_s_ceiling_light_3_of_3:
        state: "off"
      light.ella_s_wall_light:
        state: "on"
        brightness: 15
        color_temp_kelvin: 2000
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 15
        color_temp_kelvin: 2000
      light.ella_s_led_lights:
        state: "off"

  # Chill purple - relaxing vibe
  - name: "Ella Chill Purple"
    icon: mdi:lightbulb
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "on"
        brightness: 80
        hs_color: [270, 80]
      light.ella_s_ceiling_light_2_of_3:
        state: "on"
        brightness: 80
        hs_color: [270, 80]
      light.ella_s_ceiling_light_3_of_3:
        state: "on"
        brightness: 80
        hs_color: [270, 80]
      light.ella_s_wall_light:
        state: "on"
        brightness: 60
        hs_color: [280, 70]
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 60
        hs_color: [280, 70]
      light.ella_s_led_lights:
        state: "on"
        brightness: 120

  # Volleyball hype - energizing orange/team colors
  - name: "Ella Volleyball Hype"
    icon: mdi:volleyball
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "on"
        brightness: 255
        hs_color: [30, 100]
      light.ella_s_ceiling_light_2_of_3:
        state: "on"
        brightness: 255
        hs_color: [30, 100]
      light.ella_s_ceiling_light_3_of_3:
        state: "on"
        brightness: 255
        hs_color: [30, 100]
      light.ella_s_wall_light:
        state: "on"
        brightness: 255
        rgb_color: [255, 255, 255]
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 255
        rgb_color: [255, 255, 255]
      light.ella_s_led_lights:
        state: "on"
        brightness: 255

  # Bright white - full on for getting ready
  - name: "Ella Bright"
    icon: mdi:lightbulb-on
    entities:
      light.ella_s_ceiling_light_1_of_3:
        state: "on"
        brightness: 255
        color_temp_kelvin: 5000
      light.ella_s_ceiling_light_2_of_3:
        state: "on"
        brightness: 255
        color_temp_kelvin: 5000
      light.ella_s_ceiling_light_3_of_3:
        state: "on"
        brightness: 255
        color_temp_kelvin: 5000
      light.ella_s_wall_light:
        state: "on"
        brightness: 255
        color_temp_kelvin: 5000
      light.ella_s_bedside_lamp:
        state: "on"
        brightness: 255
        color_temp_kelvin: 5000
      light.ella_s_led_lights:
        state: "on"
        brightness: 255
```

## garage_lighting_automation.yaml
```yaml
# ============================================================================
# Garage Lighting & Door Automation
# Updated: 2026-01-20
# 
# LIGHTS CONTROLLED:
# - light.garage (Hue ceiling group)
# - light.ratgdo32disco_fd8d8c_light (North RATGDO opener)
# - light.ratgdo32disco_5735e8_light (South RATGDO opener)
# - light.garage_north_lift_master_garage_door_opener_west_light
# - light.garage_north_lift_master_garage_door_opener_east_light
# - light.south_west_garage_liftmaster
# - light.south_east_lift
# - light.garage_north_wall_nightlight (Third Reality)
# - light.garage_north_of_east_wall_motion_light_sensor (Third Reality)
# - light.garage_south_of_east_wall_motion_light_sensor (Third Reality)
# - light.garage_south_wall_motion_light_sensor (Third Reality)
# ============================================================================

automation:
  # === LIGHTS ON ===
  - id: garage_master_lights_on
    alias: "Garage All Lights ON"
    trigger:
      - platform: state
        entity_id: cover.ratgdo32disco_5735e8_door
        to: 'open'
      - platform: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        to: 'open'
      - platform: state
        entity_id: binary_sensor.aqara_door_and_window_sensor_door_3
        to: 'on'
      - platform: state
        entity_id: binary_sensor.ratgdo32disco_5735e8_motion
        to: 'on'
      - platform: state
        entity_id: binary_sensor.ratgdo32disco_fd8d8c_motion
        to: 'on'
    action:
      - service: light.turn_on
        target:
          entity_id:
            # Hue ceiling group
            - light.garage
            # RATGDO opener lights
            - light.ratgdo32disco_fd8d8c_light
            - light.ratgdo32disco_5735e8_light
            # North LiftMaster
            - light.garage_north_lift_master_garage_door_opener_west_light
            - light.garage_north_lift_master_garage_door_opener_east_light
            # South LiftMaster (correct names)
            - light.south_west_garage_liftmaster
            - light.south_east_lift
            # Third Reality nightlights
            - light.garage_north_wall_nightlight
            - light.garage_north_of_east_wall_motion_light_sensor
            - light.garage_south_of_east_wall_motion_light_sensor
            - light.garage_south_wall_motion_light_sensor
        data:
          brightness_pct: 100
    mode: restart

  # === LIGHTS OFF ===
  - id: garage_master_lights_off
    alias: "Garage All Lights OFF"
    trigger:
      - platform: state
        entity_id:
          - binary_sensor.ratgdo32disco_5735e8_motion
          - binary_sensor.ratgdo32disco_fd8d8c_motion
        to: 'off'
        for:
          minutes: 6
    condition:
      - condition: state
        entity_id: cover.ratgdo32disco_5735e8_door
        state: 'closed'
      - condition: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        state: 'closed'
      - condition: state
        entity_id: binary_sensor.aqara_door_and_window_sensor_door_3
        state: 'off'
      - condition: state
        entity_id: binary_sensor.ratgdo32disco_5735e8_motion
        state: 'off'
      - condition: state
        entity_id: binary_sensor.ratgdo32disco_fd8d8c_motion
        state: 'off'
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.garage
            - light.ratgdo32disco_fd8d8c_light
            - light.ratgdo32disco_5735e8_light
            - light.garage_north_lift_master_garage_door_opener_west_light
            - light.garage_north_lift_master_garage_door_opener_east_light
            - light.south_west_garage_liftmaster
            - light.south_east_lift
            - light.garage_north_wall_nightlight
            - light.garage_north_of_east_wall_motion_light_sensor
            - light.garage_south_of_east_wall_motion_light_sensor
            - light.garage_south_wall_motion_light_sensor
    mode: restart

  # === DOOR LEFT OPEN NOTIFICATION ===
  - id: garage_door_left_open_notification
    alias: "Garage Door Left Open - Reminder"
    trigger:
      - platform: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        to: "open"
        for:
          minutes: 1
        id: north
      - platform: state
        entity_id: cover.ratgdo32disco_5735e8_door
        to: "open"
        for:
          minutes: 1
        id: south
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "🚗 Garage Door Open"
          message: "{{ trigger.id | title }} door has been open for 1 minute"
          data:
            tag: "garage_door_{{ trigger.id }}"
            ttl: 0
            priority: high
            persistent: true
            actions:
              - action: "GARAGE_CLOSE_{{ trigger.id | upper }}"
                title: "Close"
              - action: "GARAGE_SNOOZE_10_{{ trigger.id | upper }}"
                title: "10m"
              - action: "GARAGE_SNOOZE_30_{{ trigger.id | upper }}"
                title: "30m"
    mode: parallel

  # === DOOR OPENED - IMMEDIATE CLOSE OPTION (WINTER MODE) ===
  - id: garage_door_opened_close_option
    alias: "Garage Door Opened - Close Option"
    trigger:
      - platform: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        to: "open"
        id: north
      - platform: state
        entity_id: cover.ratgdo32disco_5735e8_door
        to: "open"
        id: south
    action:
      - delay:
          seconds: 3
      - service: notify.mobile_app_john_s_phone
        data:
          title: "🚗 {{ trigger.id | title }} Door Open"
          message: "Tap to close"
          data:
            tag: "garage_quick_close_{{ trigger.id }}"
            ttl: 0
            priority: high
            timeout: 120
            actions:
              - action: "GARAGE_CLOSE_{{ trigger.id | upper }}"
                title: "Close Now"
              - action: "GARAGE_AUTO_CLOSE_{{ trigger.id | upper }}"
                title: "Auto 10s"
    mode: parallel

  # === NOTIFICATION ACTIONS ===
  - id: garage_door_notification_actions
    alias: "Garage Door Notification Actions"
    trigger:
      # Close actions
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_CLOSE_NORTH"
        id: close_north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_CLOSE_SOUTH"
        id: close_south
      # Auto-close actions (10 second delay)
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_AUTO_CLOSE_NORTH"
        id: auto_close_north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_AUTO_CLOSE_SOUTH"
        id: auto_close_south
      # Snooze actions
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_SNOOZE_10_NORTH"
        id: snooze_10_north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_SNOOZE_10_SOUTH"
        id: snooze_10_south
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_SNOOZE_30_NORTH"
        id: snooze_30_north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_SNOOZE_30_SOUTH"
        id: snooze_30_south
    action:
      - choose:
          # CLOSE NORTH
          - conditions:
              - condition: trigger
                id: close_north
            sequence:
              - service: cover.close_cover
                target:
                  entity_id: cover.ratgdo32disco_fd8d8c_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_north"
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_quick_close_north"
          # CLOSE SOUTH
          - conditions:
              - condition: trigger
                id: close_south
            sequence:
              - service: cover.close_cover
                target:
                  entity_id: cover.ratgdo32disco_5735e8_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_south"
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_quick_close_south"
          # AUTO CLOSE NORTH (10s delay)
          - conditions:
              - condition: trigger
                id: auto_close_north
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "⏱️ Auto-closing North"
                  message: "Closing in 10 seconds..."
                  data:
                    tag: "garage_quick_close_north"
                    timeout: 10
              - delay:
                  seconds: 10
              - service: cover.close_cover
                target:
                  entity_id: cover.ratgdo32disco_fd8d8c_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_quick_close_north"
          # AUTO CLOSE SOUTH (10s delay)
          - conditions:
              - condition: trigger
                id: auto_close_south
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "⏱️ Auto-closing South"
                  message: "Closing in 10 seconds..."
                  data:
                    tag: "garage_quick_close_south"
                    timeout: 10
              - delay:
                  seconds: 10
              - service: cover.close_cover
                target:
                  entity_id: cover.ratgdo32disco_5735e8_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_quick_close_south"
          # SNOOZE 10 NORTH
          - conditions:
              - condition: trigger
                id: snooze_10_north
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_north"
              - delay:
                  minutes: 10
              - condition: state
                entity_id: cover.ratgdo32disco_fd8d8c_door
                state: "open"
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "🚗 North Door Still Open"
                  message: "10 minute snooze ended"
                  data:
                    tag: "garage_door_north"
                    persistent: true
                    actions:
                      - action: "GARAGE_CLOSE_NORTH"
                        title: "Close"
                      - action: "GARAGE_SNOOZE_10_NORTH"
                        title: "10m"
                      - action: "GARAGE_SNOOZE_30_NORTH"
                        title: "30m"
          # SNOOZE 10 SOUTH
          - conditions:
              - condition: trigger
                id: snooze_10_south
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_south"
              - delay:
                  minutes: 10
              - condition: state
                entity_id: cover.ratgdo32disco_5735e8_door
                state: "open"
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "🚗 South Door Still Open"
                  message: "10 minute snooze ended"
                  data:
                    tag: "garage_door_south"
                    persistent: true
                    actions:
                      - action: "GARAGE_CLOSE_SOUTH"
                        title: "Close"
                      - action: "GARAGE_SNOOZE_10_SOUTH"
                        title: "10m"
                      - action: "GARAGE_SNOOZE_30_SOUTH"
                        title: "30m"
          # SNOOZE 30 NORTH
          - conditions:
              - condition: trigger
                id: snooze_30_north
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_north"
              - delay:
                  minutes: 30
              - condition: state
                entity_id: cover.ratgdo32disco_fd8d8c_door
                state: "open"
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "🚗 North Door Still Open"
                  message: "30 minute snooze ended"
                  data:
                    tag: "garage_door_north"
                    persistent: true
                    actions:
                      - action: "GARAGE_CLOSE_NORTH"
                        title: "Close"
                      - action: "GARAGE_SNOOZE_10_NORTH"
                        title: "10m"
                      - action: "GARAGE_SNOOZE_30_NORTH"
                        title: "30m"
          # SNOOZE 30 SOUTH
          - conditions:
              - condition: trigger
                id: snooze_30_south
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_door_south"
              - delay:
                  minutes: 30
              - condition: state
                entity_id: cover.ratgdo32disco_5735e8_door
                state: "open"
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "🚗 South Door Still Open"
                  message: "30 minute snooze ended"
                  data:
                    tag: "garage_door_south"
                    persistent: true
                    actions:
                      - action: "GARAGE_CLOSE_SOUTH"
                        title: "Close"
                      - action: "GARAGE_SNOOZE_10_SOUTH"
                        title: "10m"
                      - action: "GARAGE_SNOOZE_30_SOUTH"
                        title: "30m"
    mode: parallel
    max: 10

  # === CLEAR NOTIFICATION ON CLOSE ===
  - id: garage_door_closed_clear_notification
    alias: "Garage Door Closed - Clear Notification"
    trigger:
      - platform: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        to: "closed"
        id: north
      - platform: state
        entity_id: cover.ratgdo32disco_5735e8_door
        to: "closed"
        id: south
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          message: "clear_notification"
          data:
            tag: "garage_door_{{ trigger.id }}"
      - service: notify.mobile_app_john_s_phone
        data:
          message: "clear_notification"
          data:
            tag: "garage_quick_close_{{ trigger.id }}"
    mode: parallel
```

## john_proximity.yaml
```yaml
# John Proximity to Home
# Triggers approaching home notification earlier

template:
  - sensor:
      - name: "John Distance to Home"
        unique_id: john_distance_to_home
        unit_of_measurement: "m"
        state: >
          {% set home_lat = 44.42452455932065 %}
          {% set home_lon = -91.21117829649491 %}
          {% set john_lat = state_attr('device_tracker.john_s_phone', 'latitude') | float(0) %}
          {% set john_lon = state_attr('device_tracker.john_s_phone', 'longitude') | float(0) %}
          {% if john_lat == 0 or john_lon == 0 %}
            unknown
          {% else %}
            {% set lat_diff = (home_lat - john_lat) * 111000 %}
            {% set lon_diff = (home_lon - john_lon) * 111000 * cos(home_lat * 3.14159 / 180) %}
            {{ ((lat_diff**2 + lon_diff**2) ** 0.5) | round(0) }}
          {% endif %}
        icon: mdi:map-marker-distance

  - binary_sensor:
      - name: "John Approaching Home"
        unique_id: john_approaching_home
        state: >
          {% set dist = states('sensor.john_distance_to_home') | float(9999) %}
          {% set prev = state_attr('binary_sensor.john_approaching_home', 'previous_distance') | float(9999) %}
          {{ dist < 500 and dist < prev and states('person.john_spencer') != 'home' }}
        attributes:
          previous_distance: "{{ states('sensor.john_distance_to_home') | float(9999) }}"
        icon: mdi:home-import-outline
```

## kids_bedroom_automation.yaml
```yaml
# =============================================================================
# Kids Bedroom Automation - Ella & Alaina
# Created: 2026-01-21
# 
# Features:
# - Gentle wake lights triggered 15min before Echo alarm
# - School night bedtime routine (auto-dim then off)
# - Lights off when leaving / everyone away
# - Manual override support
# =============================================================================

# =============================================================================
# HELPERS
# =============================================================================
input_boolean:
  ella_bedroom_override:
    name: "Ella Bedroom Override"
    icon: mdi:lightbulb-auto-outline
  alaina_bedroom_override:
    name: "Alaina Bedroom Override"
    icon: mdi:lightbulb-auto-outline
  kids_wake_lights_enabled:
    name: "Kids Wake Lights Enabled"
    icon: mdi:alarm-light
    initial: true

input_datetime:
  ella_wake_time_override:
    name: "Ella Wake Override"
    has_date: false
    has_time: true
  alaina_wake_time_override:
    name: "Alaina Wake Override"
    has_date: false
    has_time: true

# =============================================================================
# TEMPLATE SENSORS - Next Wake Time
# =============================================================================
template:
  - sensor:
      - name: "Ella Next Wake Time"
        unique_id: ella_next_wake_time
        icon: mdi:alarm
        state: >
          {% set echo_alarm = states('sensor.ella_s_bedroom_echo_show_next_alarm_2') %}
          {% set override = states('input_datetime.ella_wake_time_override') %}
          {% if echo_alarm not in ['unknown', 'unavailable', 'None', ''] %}
            {{ echo_alarm }}
          {% elif override not in ['unknown', 'unavailable', 'None', ''] %}
            {{ override }}
          {% else %}
            unknown
          {% endif %}
        attributes:
          source: >
            {% set echo_alarm = states('sensor.ella_s_bedroom_echo_show_next_alarm_2') %}
            {% if echo_alarm not in ['unknown', 'unavailable', 'None', ''] %}echo
            {% else %}override{% endif %}

      - name: "Alaina Next Wake Time"
        unique_id: alaina_next_wake_time
        icon: mdi:alarm
        state: >
          {% set echo_alarm = states('sensor.alaina_s_bedroom_echo_show_next_alarm_2') %}
          {% set override = states('input_datetime.alaina_wake_time_override') %}
          {% if echo_alarm not in ['unknown', 'unavailable', 'None', ''] %}
            {{ echo_alarm }}
          {% elif override not in ['unknown', 'unavailable', 'None', ''] %}
            {{ override }}
          {% else %}
            unknown
          {% endif %}
        attributes:
          source: >
            {% set echo_alarm = states('sensor.alaina_s_bedroom_echo_show_next_alarm_2') %}
            {% if echo_alarm not in ['unknown', 'unavailable', 'None', ''] %}echo
            {% else %}override{% endif %}

      # Time until wake (for triggering 15min before)
      - name: "Ella Minutes Until Wake"
        unique_id: ella_minutes_until_wake
        unit_of_measurement: "min"
        state: >
          {% set wake = states('sensor.ella_next_wake_time') %}
          {% if wake in ['unknown', 'unavailable', 'None', ''] %}
            -1
          {% else %}
            {% set wake_dt = wake | as_datetime %}
            {% if wake_dt %}
              {% set diff = (wake_dt - now()).total_seconds() / 60 %}
              {{ diff | round(0) }}
            {% else %}
              -1
            {% endif %}
          {% endif %}

      - name: "Alaina Minutes Until Wake"
        unique_id: alaina_minutes_until_wake
        unit_of_measurement: "min"
        state: >
          {% set wake = states('sensor.alaina_next_wake_time') %}
          {% if wake in ['unknown', 'unavailable', 'None', ''] %}
            -1
          {% else %}
            {% set wake_dt = wake | as_datetime %}
            {% if wake_dt %}
              {% set diff = (wake_dt - now()).total_seconds() / 60 %}
              {{ diff | round(0) }}
            {% else %}
              -1
            {% endif %}
          {% endif %}

# =============================================================================
# ALAINA SCRIPTS (mirror Ella's)
# =============================================================================
script:
  alaina_lights_off:
    alias: "Alaina Lights Off"
    icon: mdi:lightbulb-off
    sequence:
      - service: light.turn_off
        target:
          entity_id:
            - light.alaina_s_bedroom
            - light.alaina_s_bedside_lamp
            - light.alaina_s_ceiling_led_lights
            - light.alaina_s_floor_govee_lamp
            - light.alaina_s_led_light_strip_1
            - light.alaina_s_bedroom_echo_glow

  alaina_school_night:
    alias: "Alaina School Night"
    icon: mdi:bed-clock
    sequence:
      - service: light.turn_off
        target:
          entity_id:
            - light.alaina_s_ceiling_led_lights
            - light.alaina_s_led_light_strip_1
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedside_lamp
        data:
          brightness_pct: 5
          color_temp_kelvin: 2000
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedroom_echo_glow
        data:
          brightness_pct: 3
          rgb_color: [255, 100, 50]
      - delay:
          minutes: 30
      - service: light.turn_off
        target:
          entity_id:
            - light.alaina_s_bedside_lamp
            - light.alaina_s_bedroom_echo_glow

  alaina_gentle_wake:
    alias: "Alaina Gentle Wake"
    icon: mdi:weather-sunset-up
    sequence:
      # Phase 1: Very dim warm (5%)
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedroom
        data:
          brightness_pct: 5
          color_temp_kelvin: 2200
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedroom_echo_glow
        data:
          brightness_pct: 10
          rgb_color: [255, 150, 50]
      - delay:
          seconds: 30
      # Phase 2: Warmer, brighter (30%)
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedroom
        data:
          brightness_pct: 30
          color_temp_kelvin: 3500
          transition: 60
      - delay:
          seconds: 90
      # Phase 3: Full brightness (80%)
      - service: light.turn_on
        target:
          entity_id: light.alaina_s_bedroom
        data:
          brightness_pct: 80
          color_temp_kelvin: 5000
          transition: 90

# =============================================================================
# AUTOMATIONS
# =============================================================================
automation:
  # ---------------------------------------------------------------------------
  # ELLA - Gentle Wake 15min Before Alarm
  # ---------------------------------------------------------------------------
  - id: ella_gentle_wake_automation
    alias: "Ella - Gentle Wake Before Alarm"
    description: "Start gentle wake lights 15 minutes before Echo alarm"
    trigger:
      - platform: numeric_state
        entity_id: sensor.ella_minutes_until_wake
        below: 16
        above: 14
    condition:
      - condition: state
        entity_id: input_boolean.kids_wake_lights_enabled
        state: "on"
      - condition: state
        entity_id: input_boolean.ella_bedroom_override
        state: "off"
      - condition: state
        entity_id: input_boolean.ella_home
        state: "on"
      - condition: time
        after: "05:00:00"
        before: "09:00:00"
    action:
      - service: script.ella_gentle_wake
    mode: single

  # ---------------------------------------------------------------------------
  # ALAINA - Gentle Wake 15min Before Alarm
  # ---------------------------------------------------------------------------
  - id: alaina_gentle_wake_automation
    alias: "Alaina - Gentle Wake Before Alarm"
    description: "Start gentle wake lights 15 minutes before Echo alarm"
    trigger:
      - platform: numeric_state
        entity_id: sensor.alaina_minutes_until_wake
        below: 16
        above: 14
    condition:
      - condition: state
        entity_id: input_boolean.kids_wake_lights_enabled
        state: "on"
      - condition: state
        entity_id: input_boolean.alaina_bedroom_override
        state: "off"
      - condition: state
        entity_id: input_boolean.alaina_home
        state: "on"
      - condition: time
        after: "05:00:00"
        before: "09:00:00"
    action:
      - service: script.alaina_gentle_wake
    mode: single

  # ---------------------------------------------------------------------------
  # ELLA - School Night Bedtime (9:30 PM)
  # ---------------------------------------------------------------------------
  - id: ella_school_night_bedtime
    alias: "Ella - School Night Bedtime"
    description: "Dim lights on school nights at 9:30 PM"
    trigger:
      - platform: time
        at: "21:30:00"
    condition:
      - condition: state
        entity_id: input_boolean.school_tomorrow
        state: "on"
      - condition: state
        entity_id: input_boolean.ella_home
        state: "on"
      - condition: state
        entity_id: input_boolean.ella_bedroom_override
        state: "off"
      # Only if lights are on
      - condition: or
        conditions:
          - condition: state
            entity_id: light.ella_s_bedroom
            state: "on"
          - condition: state
            entity_id: light.ella_s_ceiling_light_1_of_3
            state: "on"
          - condition: state
            entity_id: light.ella_s_led_lights
            state: "on"
    action:
      - service: script.ella_school_night
    mode: single

  # ---------------------------------------------------------------------------
  # ALAINA - School Night Bedtime (9:30 PM)
  # ---------------------------------------------------------------------------
  - id: alaina_school_night_bedtime
    alias: "Alaina - School Night Bedtime"
    description: "Dim lights on school nights at 9:30 PM"
    trigger:
      - platform: time
        at: "21:30:00"
    condition:
      - condition: state
        entity_id: input_boolean.school_tomorrow
        state: "on"
      - condition: state
        entity_id: input_boolean.alaina_home
        state: "on"
      - condition: state
        entity_id: input_boolean.alaina_bedroom_override
        state: "off"
      - condition: or
        conditions:
          - condition: state
            entity_id: light.alaina_s_bedroom
            state: "on"
          - condition: state
            entity_id: light.alaina_s_ceiling_led_lights
            state: "on"
    action:
      - service: script.alaina_school_night
    mode: single

  # ---------------------------------------------------------------------------
  # ELLA - Hard Off at 10:30 PM (School Nights)
  # ---------------------------------------------------------------------------
  - id: ella_lights_hard_off_school
    alias: "Ella - Lights Off 10:30 PM School Nights"
    trigger:
      - platform: time
        at: "22:30:00"
    condition:
      - condition: state
        entity_id: input_boolean.school_tomorrow
        state: "on"
      - condition: state
        entity_id: input_boolean.ella_bedroom_override
        state: "off"
    action:
      - service: script.ella_lights_off
    mode: single

  # ---------------------------------------------------------------------------
  # ALAINA - Hard Off at 10:30 PM (School Nights)
  # ---------------------------------------------------------------------------
  - id: alaina_lights_hard_off_school
    alias: "Alaina - Lights Off 10:30 PM School Nights"
    trigger:
      - platform: time
        at: "22:30:00"
    condition:
      - condition: state
        entity_id: input_boolean.school_tomorrow
        state: "on"
      - condition: state
        entity_id: input_boolean.alaina_bedroom_override
        state: "off"
    action:
      - service: script.alaina_lights_off
    mode: single

  # ---------------------------------------------------------------------------
  # ELLA - Lights Off When Leaving
  # ---------------------------------------------------------------------------
  - id: ella_lights_off_when_leaving
    alias: "Ella - Lights Off When Leaving"
    trigger:
      - platform: state
        entity_id: input_boolean.ella_home
        to: "off"
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: input_boolean.ella_bedroom_override
        state: "off"
    action:
      - service: script.ella_lights_off
    mode: single

  # ---------------------------------------------------------------------------
  # ALAINA - Lights Off When Leaving
  # ---------------------------------------------------------------------------
  - id: alaina_lights_off_when_leaving
    alias: "Alaina - Lights Off When Leaving"
    trigger:
      - platform: state
        entity_id: input_boolean.alaina_home
        to: "off"
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: input_boolean.alaina_bedroom_override
        state: "off"
    action:
      - service: script.alaina_lights_off
    mode: single

  # ---------------------------------------------------------------------------
  # BOTH - Lights Off When Everyone Leaves
  # ---------------------------------------------------------------------------
  - id: kids_lights_off_everyone_away
    alias: "Kids - Lights Off When Everyone Away"
    trigger:
      - platform: state
        entity_id: input_boolean.someone_home
        to: "off"
    action:
      - service: script.ella_lights_off
      - service: script.alaina_lights_off
    mode: single

  # ---------------------------------------------------------------------------
  # Override Clear - Auto-reset at 4 AM
  # ---------------------------------------------------------------------------
  - id: kids_bedroom_override_reset
    alias: "Kids - Bedroom Override Reset"
    trigger:
      - platform: time
        at: "04:00:00"
    action:
      - service: input_boolean.turn_off
        target:
          entity_id:
            - input_boolean.ella_bedroom_override
            - input_boolean.alaina_bedroom_override
    mode: single
```

## motion_aggregation.yaml
```yaml
# Motion Aggregation - Room-Level Occupancy Sensors
# Combines P1 (fast) + Third Reality (motion+lux) per room
# Created: 2026-01-20

template:
  - binary_sensor:
      # -----------------------------------------------------------------
      # Entry Room - Combined Motion
      # -----------------------------------------------------------------
      - name: "Entry Room Motion"
        unique_id: entry_room_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.entry_room_east_wall_nightlight_motion', 'on')
             or is_state('binary_sensor.entry_room_west_wall_nightlight_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Kitchen Lounge - Combined Motion (P1 + TR)
      # -----------------------------------------------------------------
      - name: "Kitchen Lounge Motion"
        unique_id: kitchen_lounge_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.aqara_motion_sensor_p1_occupancy', 'on')
             or is_state('binary_sensor.kitchen_lounge_east_wall_night_light_motion', 'on')
             or is_state('binary_sensor.kitchen_lounge_east_wall_nightlight_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Kitchen - Combined Motion
      # -----------------------------------------------------------------
      - name: "Kitchen Motion"
        unique_id: kitchen_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.kitchen_counter_nightlight_motion', 'on')
             or is_state('binary_sensor.kitchen_counter_night_light_motion', 'on')
             or is_state('binary_sensor.kitchen_west_wall_nightlight_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # 1st Floor Bathroom Hallway - P1 + Bathroom TR
      # -----------------------------------------------------------------
      - name: "1st Floor Bathroom Hallway Motion"
        unique_id: 1st_floor_bath_hallway_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.aqara_motion_sensor_p1_occupancy_3', 'on')
             or is_state('binary_sensor.1st_floor_bathroom_night_light_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Front Door Hallway / Stairs - P1
      # -----------------------------------------------------------------
      - name: "Front Door Hallway Motion"
        unique_id: front_door_hallway_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.aqara_motion_sensor_p1_occupancy_6', 'on')
             or is_state('binary_sensor.very_front_door_motion_sensor_occupancy', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Upstairs Hallway - P1 + TR
      # -----------------------------------------------------------------
      - name: "Upstairs Hallway Motion"
        unique_id: upstairs_hallway_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.aqara_motion_sensor_p1_occupancy_2', 'on')
             or is_state('binary_sensor.upstairs_hallway_night_light_motion', 'on')
             or is_state('binary_sensor.upstairs_hallway_east_wall_night_light_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Upstairs Bathroom - TR only
      # -----------------------------------------------------------------
      - name: "Upstairs Bathroom Motion"
        unique_id: upstairs_bathroom_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.upstairs_bathroom_night_light_motion', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Living Room - existing motionaware + add any P1 nearby
      # -----------------------------------------------------------------
      - name: "Living Room Motion"
        unique_id: living_room_motion_combined
        device_class: motion
        state: >
          {{ is_state('binary_sensor.living_rm_loungemotionaware_area', 'on') }}
        delay_off:
          seconds: 30

      # -----------------------------------------------------------------
      # Downstairs - Any motion on first floor
      # -----------------------------------------------------------------
      - name: "Downstairs Motion"
        unique_id: downstairs_motion_any
        device_class: motion
        state: >
          {{ is_state('binary_sensor.entry_room_motion', 'on')
             or is_state('binary_sensor.kitchen_lounge_motion', 'on')
             or is_state('binary_sensor.kitchen_motion', 'on')
             or is_state('binary_sensor.1st_floor_bathroom_hallway_motion', 'on')
             or is_state('binary_sensor.front_door_hallway_motion', 'on')
             or is_state('binary_sensor.living_room_motion', 'on') }}

      # -----------------------------------------------------------------
      # Upstairs - Any motion on second floor
      # -----------------------------------------------------------------
      - name: "Upstairs Motion"
        unique_id: upstairs_motion_any
        device_class: motion
        state: >
          {{ is_state('binary_sensor.upstairs_hallway_motion', 'on')
             or is_state('binary_sensor.upstairs_bathroom_motion', 'on')
             or is_state('binary_sensor.upstairs_motionaware_area', 'on') }}

      # -----------------------------------------------------------------
      # Whole House - Any motion anywhere
      # -----------------------------------------------------------------
      - name: "House Motion Any"
        unique_id: house_motion_any
        device_class: motion
        state: >
          {{ is_state('binary_sensor.downstairs_motion', 'on')
             or is_state('binary_sensor.upstairs_motion', 'on')
             or is_state('binary_sensor.basement_hallway_motion_sensor_occupancy', 'on') }}
```

## notifications_system.yaml
```yaml
# =============================================================================
# NOTIFICATIONS SYSTEM
# Arrival alerts, low battery digest, actionable notifications
# =============================================================================

automation:
  # ---------------------------------------------------------------------------
  # Arrival Notifications
  # ---------------------------------------------------------------------------
  - id: arrival_notification_john
    alias: "Arrival - John Home"
    trigger:
      - platform: state
        entity_id: person.john_spencer
        to: "home"
    condition:
      - condition: state
        entity_id: input_boolean.someone_home
        state: "on"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Welcome Home"
          message: "You arrived home at {{ now().strftime('%I:%M %p') }}"
          data:
            tag: "arrival_john"
            actions:
              - action: "ARRIVAL_LIGHTS_ON"
                title: "Lights On"
              - action: "ARRIVAL_DISARM"
                title: "Disarm"
              - action: "ARRIVAL_DISMISS"
                title: "Dismiss"
    mode: single

  - id: arrival_notification_michelle
    alias: "Arrival - Michelle Home"
    trigger:
      - platform: state
        entity_id: person.michelle
        to: "home"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Michelle Arrived"
          message: "Michelle arrived home at {{ now().strftime('%I:%M %p') }}"
          data:
            tag: "arrival_michelle"
    mode: single

  - id: arrival_notification_alaina
    alias: "Arrival - Alaina Home"
    trigger:
      - platform: state
        entity_id: person.alaina_spencer
        to: "home"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Alaina Arrived"
          message: "Alaina arrived home at {{ now().strftime('%I:%M %p') }}"
          data:
            tag: "arrival_alaina"
    mode: single

  - id: arrival_notification_ella
    alias: "Arrival - Ella Home"
    trigger:
      - platform: state
        entity_id: person.ella_spencer
        to: "home"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Ella Arrived"
          message: "Ella arrived home at {{ now().strftime('%I:%M %p') }}"
          data:
            tag: "arrival_ella"
    mode: single

  # ---------------------------------------------------------------------------
  # Arrival Action Handlers
  # ---------------------------------------------------------------------------
  - id: arrival_notification_actions
    alias: "Arrival - Handle Notification Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "ARRIVAL_LIGHTS_ON"
        id: lights_on
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "ARRIVAL_DISARM"
        id: disarm
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: lights_on
            sequence:
              - service: light.turn_on
                target:
                  entity_id:
                    - light.entry_room_hue_color_lamp
                    - light.living_room_east_floor_lamp
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "arrival_john"

          - conditions:
              - condition: trigger
                id: disarm
            sequence:
              # Add your alarm disarm service here if you have one
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "arrival_john"
    mode: single

  # ---------------------------------------------------------------------------
  # Low Battery Daily Digest - 9 AM
  # ---------------------------------------------------------------------------
  - id: low_battery_daily_digest
    alias: "Low Battery - Daily Digest"
    trigger:
      - platform: time
        at: "09:00:00"
    action:
      - variables:
          low_batteries: >
            {% set threshold = 20 %}
            {% set ns = namespace(devices=[]) %}
            {% for state in states.sensor 
               if 'battery' in state.entity_id 
               and 'voltage' not in state.entity_id 
               and 'type' not in state.entity_id 
               and 'state' not in state.entity_id
               and state.state not in ['unknown', 'unavailable', 'None']
               and state.state | int(100) < threshold %}
              {% set ns.devices = ns.devices + [state.name ~ ': ' ~ state.state ~ '%'] %}
            {% endfor %}
            {{ ns.devices }}
      - condition: template
        value_template: "{{ low_batteries | length > 0 }}"
      - service: notify.mobile_app_john_s_phone
        data:
          title: "🔋 Low Battery Alert"
          message: "{{ low_batteries | length }} device(s) need attention:\n{{ low_batteries | join('\n') }}"
          data:
            tag: "low_battery_digest"
            persistent: true
            actions:
              - action: "BATTERY_DISMISS"
                title: "Dismiss"
              - action: "BATTERY_SNOOZE_24H"
                title: "Remind Tomorrow"
    mode: single

  - id: low_battery_notification_actions
    alias: "Low Battery - Handle Notification Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BATTERY_DISMISS"
        id: dismiss
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BATTERY_SNOOZE_24H"
        id: snooze
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: dismiss
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "low_battery_digest"

          - conditions:
              - condition: trigger
                id: snooze
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "low_battery_digest"
              # Snooze just clears - tomorrow's 9 AM trigger will fire again
    mode: single

  # ---------------------------------------------------------------------------
  # Critical Battery Alert (Below 10%) - Immediate
  # ---------------------------------------------------------------------------
  - id: critical_battery_alert
    alias: "Critical Battery - Immediate Alert"
    trigger:
      - platform: numeric_state
        entity_id:
          - sensor.aqara_water_leak_sensor_battery_5
          - sensor.aqara_water_leak_sensor_battery
          - sensor.aqara_water_leak_sensor_battery_3
          - sensor.aqara_water_leak_sensor_battery_4
          - sensor.aqara_water_leak_sensor_battery_2
          - sensor.aqara_door_and_window_sensor_battery_5
          - sensor.aqara_door_and_window_sensor_battery_4
          - sensor.aqara_door_and_window_sensor_battery_6
          - sensor.aqara_door_and_window_sensor_battery
          - sensor.aqara_door_and_window_sensor_battery_3
          - sensor.aqara_door_and_window_sensor_battery_2
          - sensor.aqara_motion_sensor_p1_battery
          - sensor.aqara_motion_sensor_p1_battery_3
          - sensor.aqara_motion_sensor_p1_battery_2
          - sensor.aqara_motion_sensor_p1_battery_6
          - sensor.aqara_motion_sensor_p1_battery_4
          - sensor.aqara_motion_sensor_p1_battery_5
          - sensor.hue_tap_dial_switch_3_battery
          - sensor.hue_dimmer_switch_3_battery
          - sensor.hue_dimmer_switch_2_battery
          - sensor.hue_dimmer_switch_4_battery
          - sensor.hue_tap_dial_switch_1_battery
          - sensor.hue_dimmer_switch_1_battery
          - sensor.lumi_lumi_sensor_wleak_aq1_battery
        below: 10
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "⚠️ Critical Battery"
          message: "{{ trigger.to_state.name }} is at {{ trigger.to_state.state }}%"
          data:
            tag: "critical_battery_{{ trigger.entity_id }}"
            persistent: true
            importance: high
            channel: "critical_alerts"
    mode: parallel

  # ---------------------------------------------------------------------------
  # Approaching Home - Lights + Garage Notification
  # ---------------------------------------------------------------------------
  - id: approaching_home_john
    alias: "Approaching Home - John"
    trigger:
      # Trigger when within 500m and approaching
      - platform: numeric_state
        entity_id: sensor.john_distance_to_home
        below: 500
        id: approaching
      # Backup trigger when entering home zone
      - platform: state
        entity_id: person.john_spencer
        to: "home"
        id: arrived
    condition:
      # Only if not already home and notification not recently sent
      - condition: template
        value_template: "{{ states('person.john_spencer') != 'home' or trigger.id == 'arrived' }}"
    action:
      # Turn on driveway lights if dark
      - if:
          - condition: state
            entity_id: sun.sun
            state: "below_horizon"
        then:
          - service: light.turn_on
            target:
              entity_id: light.front_driveway
            data:
              brightness_pct: 100
      # Always send notification with garage options
      - service: notify.mobile_app_john_s_phone
        data:
          title: "🏠 Welcome Home"
          message: >
            {% if is_state('sun.sun', 'below_horizon') %}Driveway lights on. {% endif %}Open garage?
          data:
            tag: "approaching_home"
            ttl: 0
            priority: high
            actions:
              - action: "OPEN_NORTH_GARAGE"
                title: "North"
              - action: "OPEN_SOUTH_GARAGE"
                title: "South"
              - action: "OPEN_BOTH_GARAGE"
                title: "Both"
              - action: "ARRIVAL_DISMISS"
                title: "Dismiss"
    mode: single

  - id: approaching_home_actions
    alias: "Approaching Home - Handle Garage Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "OPEN_NORTH_GARAGE"
        id: north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "OPEN_SOUTH_GARAGE"
        id: south
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "OPEN_BOTH_GARAGE"
        id: both
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: north
            sequence:
              - service: cover.open_cover
                target:
                  entity_id: cover.ratgdo32disco_fd8d8c_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "approaching_home"

          - conditions:
              - condition: trigger
                id: south
            sequence:
              - service: cover.open_cover
                target:
                  entity_id: cover.ratgdo32disco_5735e8_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "approaching_home"

          - conditions:
              - condition: trigger
                id: both
            sequence:
              - service: cover.open_cover
                target:
                  entity_id:
                    - cover.ratgdo32disco_fd8d8c_door
                    - cover.ratgdo32disco_5735e8_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "approaching_home"
    mode: single
  # ---------------------------------------------------------------------------
  # Garage Door Opened - Offer to Close
  # ---------------------------------------------------------------------------
  - id: garage_door_opened_notification
    alias: "Garage Door Opened - Close Prompt"
    trigger:
      - platform: state
        entity_id: cover.ratgdo32disco_fd8d8c_door
        to: "open"
        id: north
      - platform: state
        entity_id: cover.ratgdo32disco_5735e8_door
        to: "open"
        id: south
    condition:
      # Only if not already home and notification not recently sent
      - condition: template
        value_template: "{{ states('person.john_spencer') != 'home' or trigger.id == 'arrived' }}"
    action:
      # Small delay to let presence update on arrival
      - delay:
          seconds: 3
      # Only notify if john is home (after delay)
      - condition: state
        entity_id: input_boolean.john_home
        state: "on"
      - service: notify.mobile_app_john_s_phone
        data:
          title: "🚗 Garage Door Opened"
          message: '{{ trigger.to_state.attributes.friendly_name | default(trigger.id | title ~ " door") }} is open'
          data:
            tag: "garage_opened_{{ trigger.id }}"
            ttl: 0
            priority: high
            actions:
              - action: "GARAGE_CLOSE_{{ trigger.id | upper }}"
                title: "Close"
              - action: "GARAGE_DISMISS_{{ trigger.id | upper }}"
                title: "Dismiss"
    mode: parallel
  - id: garage_door_opened_actions
    alias: "Garage Door Opened - Handle Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_DISMISS_NORTH"
        id: dismiss_north
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "GARAGE_DISMISS_SOUTH"
        id: dismiss_south
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: dismiss_north
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_opened_north"
          - conditions:
              - condition: trigger
                id: dismiss_south
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "garage_opened_south"
    mode: parallel

  # ---------------------------------------------------------------------------
  # Bedtime - John Connected to 2nd Floor AP After 7 PM
  # ---------------------------------------------------------------------------
  - id: bedtime_first_floor_lights_off_prompt
    alias: "Bedtime - Prompt to Turn Off 1st Floor Lights"
    trigger:
      - platform: template
        value_template: >
          {{ state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') == '70:a7:41:c6:1e:6c' }}
    condition:
      - condition: time
        after: "19:00:00"
      - condition: or
        conditions:
          - condition: state
            entity_id: light.entry_room
            state: "on"
          - condition: state
            entity_id: light.living_room
            state: "on"
          - condition: state
            entity_id: light.kitchen_lounge
            state: "on"
          - condition: state
            entity_id: light.front_driveway
            state: "on"
          - condition: state
            entity_id: light.back_patio
            state: "on"
    action:
      - service: notify.mobile_app_john_s_phone
        data:
          title: "Heading to Bed?"
          message: "1st floor or outside lights are still on."
          data:
            tag: "bedtime_lights"
            actions:
              - action: "BEDTIME_ALL_OFF"
                title: "All Off"
              - action: "BEDTIME_1ST_FLOOR_OFF"
                title: "1st Floor"
              - action: "BEDTIME_OUTSIDE_OFF"
                title: "Outside"
              - action: "BEDTIME_DISMISS"
                title: "Dismiss"
    mode: single

  - id: bedtime_lights_notification_actions
    alias: "Bedtime - Handle Light Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BEDTIME_ALL_OFF"
        id: all_off
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BEDTIME_1ST_FLOOR_OFF"
        id: first_floor
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BEDTIME_OUTSIDE_OFF"
        id: outside
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "BEDTIME_DISMISS"
        id: dismiss
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: all_off
            sequence:
              - service: light.turn_off
                target:
                  entity_id:
                    - light.entry_room
                    - light.living_room
                    - light.kitchen_lounge
                    - light.1st_floor_bathroom
                    - light.front_driveway
                    - light.back_patio
                    - light.very_front_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "bedtime_lights"

          - conditions:
              - condition: trigger
                id: first_floor
            sequence:
              - service: light.turn_off
                target:
                  entity_id:
                    - light.entry_room
                    - light.living_room
                    - light.kitchen_lounge
                    - light.1st_floor_bathroom
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "bedtime_lights"

          - conditions:
              - condition: trigger
                id: outside
            sequence:
              - service: light.turn_off
                target:
                  entity_id:
                    - light.front_driveway
                    - light.back_patio
                    - light.very_front_door
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "bedtime_lights"

          - conditions:
              - condition: trigger
                id: dismiss
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "bedtime_lights"
    mode: single

  # ---------------------------------------------------------------------------
  # Humidity Alert - 2nd Floor Average
  # ---------------------------------------------------------------------------
  - id: humidity_alert_2nd_floor
    alias: "Humidity Alert - 2nd Floor Low or High"
    trigger:
      # Low humidity check every hour
      - platform: time_pattern
        minutes: 0
    condition:
      - condition: state
        entity_id: input_boolean.john_home
        state: "on"
    action:
      - variables:
          avg_humidity: >
            {% set h1 = states('sensor.aqara_temp_humidity_sensor_humidity_4') | float(0) %}
            {% set h2 = states('sensor.aqara_temp_humidity_sensor_humidity_5') | float(0) %}
            {% set h3 = states('sensor.aqara_temp_humidity_sensor_humidity_6') | float(0) %}
            {% set count = (1 if h1 > 0 else 0) + (1 if h2 > 0 else 0) + (1 if h3 > 0 else 0) %}
            {% if count > 0 %}
              {{ ((h1 + h2 + h3) / count) | round(1) }}
            {% else %}
              0
            {% endif %}
          is_summer: >
            {{ now().month in [5, 6, 7, 8, 9] }}
      - choose:
          # LOW HUMIDITY (below 30%)
          - conditions:
              - condition: template
                value_template: "{{ avg_humidity < 30 }}"
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "🏜️ Low Humidity Alert"
                  message: "2nd floor avg: {{ avg_humidity }}%. Pause bathroom fan?"
                  data:
                    tag: "humidity_alert"
                    persistent: true
                    actions:
                      - action: "HUMIDITY_PAUSE_15M"
                        title: "Pause 15m"
                      - action: "HUMIDITY_PAUSE_12H"
                        title: "Pause 12hr"
                      - action: "HUMIDITY_DISMISS"
                        title: "Dismiss"

          # HIGH HUMIDITY (above 55%) - Summer only
          - conditions:
              - condition: template
                value_template: "{{ avg_humidity > 55 and is_summer }}"
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  title: "💧 High Humidity Alert"
                  message: "2nd floor avg: {{ avg_humidity }}%. Turn on AC?"
                  data:
                    tag: "humidity_alert"
                    persistent: true
                    actions:
                      - action: "HUMIDITY_AC_ON"
                        title: "AC 74°"
                      - action: "HUMIDITY_PAUSE_15M"
                        title: "Pause Fan 15m"
                      - action: "HUMIDITY_DISMISS"
                        title: "Dismiss"

  - id: humidity_notification_actions
    alias: "Humidity - Handle Notification Actions"
    trigger:
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HUMIDITY_PAUSE_15M"
        id: pause_15m
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HUMIDITY_PAUSE_12H"
        id: pause_12h
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HUMIDITY_AC_ON"
        id: ac_on
      - platform: event
        event_type: mobile_app_notification_action
        event_data:
          action: "HUMIDITY_DISMISS"
        id: dismiss
    action:
      - choose:
          - conditions:
              - condition: trigger
                id: pause_15m
            sequence:
              - service: switch.turn_off
                target:
                  entity_id: switch.upstairs_bathroom_fan
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "humidity_alert"
              - delay:
                  minutes: 15
              - service: switch.turn_on
                target:
                  entity_id: switch.upstairs_bathroom_fan

          - conditions:
              - condition: trigger
                id: pause_12h
            sequence:
              - service: switch.turn_off
                target:
                  entity_id: switch.upstairs_bathroom_fan
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "humidity_alert"
              - delay:
                  hours: 12
              - service: switch.turn_on
                target:
                  entity_id: switch.upstairs_bathroom_fan

          - conditions:
              - condition: trigger
                id: ac_on
            sequence:
              - service: climate.set_temperature
                target:
                  entity_id: climate.upstairs_hallway_mini_split
                data:
                  temperature: 74
                  hvac_mode: cool
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "humidity_alert"

          - conditions:
              - condition: trigger
                id: dismiss
            sequence:
              - service: notify.mobile_app_john_s_phone
                data:
                  message: "clear_notification"
                  data:
                    tag: "humidity_alert"
    mode: restart
```

## occupancy_system.yaml
```yaml
# ═══════════════════════════════════════════════════════════
# Occupancy-Driven Context System
# Ground-up build: Calendar-aware, AL-friendly, best practices
# Created: 2026-01-19
# ═══════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════
# HELPERS (Input Booleans & Selects)
# ═══════════════════════════════════════════════════════════

input_boolean:
  # Calendar-derived states (set by automation)
  school_tomorrow:
    name: "School Tomorrow"
    icon: mdi:school
  
  school_in_session_now:
    name: "School In Session Now"
    icon: mdi:school-outline
  
  kids_expected_away_now:
    name: "Kids Expected Away Now"
    icon: mdi:account-clock
  
  # Overlay states
  preserve_night_vision:
    name: "Preserve Night Vision"
    icon: mdi:brightness-2
  
  guest_present:
    name: "Guest Present"
    icon: mdi:account-supervisor
  
  kids_bedtime_override:
    name: "Kids Bedtime Override"
    icon: mdi:sleep-off

input_select:
  occupancy_mode:
    name: "Occupancy Mode"
    options:
      - "Empty"
      - "John Only"
      - "Kids Only"
      - "John + Kids"
      - "John + Michelle"
      - "Full House"
      - "Mixed"
    icon: mdi:home-account

# ═══════════════════════════════════════════════════════════
# TEMPLATE SENSORS
# ═══════════════════════════════════════════════════════════

template:
  - sensor:
      # Occupancy mode (auto-calculated from presence system)
      - name: "Occupancy Mode Auto"
        unique_id: occupancy_mode_auto
        state: >
          {% set john = is_state('input_boolean.john_home', 'on') %}
          {% set alaina = is_state('input_boolean.alaina_home', 'on') %}
          {% set ella = is_state('input_boolean.ella_home', 'on') %}
          {% set michelle = is_state('input_boolean.michelle_home', 'on') %}
          {% set kids = alaina or ella %}
          {% set both_kids = alaina and ella %}
          
          {% if john and both_kids and michelle %}
            Full House
          {% elif john and both_kids %}
            John + Kids
          {% elif john and michelle %}
            John + Michelle
          {% elif john and kids %}
            John + Kids
          {% elif kids %}
            Kids Only
          {% elif john %}
            John Only
          {% else %}
            Empty
          {% endif %}
        icon: mdi:home-analytics
      
      # Time of day context
      - name: "Time Context"
        unique_id: time_context
        state: >
          {% set hour = now().hour %}
          {% if hour >= 22 or hour < 6 %}
            night
          {% elif hour >= 18 %}
            evening
          {% elif hour >= 12 %}
            afternoon
          {% else %}
            morning
          {% endif %}
        icon: >
          {% set hour = now().hour %}
          {% if hour >= 22 or hour < 6 %}
            mdi:weather-night
          {% elif hour >= 18 %}
            mdi:weather-sunset
          {% else %}
            mdi:weather-sunny
          {% endif %}
      
      # Bedtime window (based on school tomorrow)
      - name: "Bedtime Window Active"
        unique_id: bedtime_window_active
        state: >
          {% set hour = now().hour %}
          {% set school_tomorrow = is_state('input_boolean.school_tomorrow', 'on') %}
          {% set override = is_state('input_boolean.kids_bedtime_override', 'on') %}
          
          {% if override %}
            off
          {% elif school_tomorrow and hour >= 20 and hour < 22 %}
            on
          {% elif not school_tomorrow and hour >= 21 and hour < 23 %}
            on
          {% else %}
            off
          {% endif %}
        icon: mdi:bed-clock

  - binary_sensor:
      # School in session NOW (weekday + not holiday/closed + during school hours)
      - name: "School In Session Now"
        unique_id: school_in_session_now
        state: >
          {% set weekday = now().weekday() < 5 %}
          {% set hour = now().hour %}
          {% set school_hours = hour >= 8 and hour < 15 %}
          {{ weekday and school_hours and is_state('input_boolean.school_in_session_now', 'on') }}
        device_class: occupancy
      
      # Kids expected away (school in session + kids should be there)
      - name: "Kids Expected Away"
        unique_id: kids_expected_away
        state: >
          {{ is_state('binary_sensor.school_in_session_now', 'on') }}
        device_class: occupancy

# ═══════════════════════════════════════════════════════════
# SCRIPTS - Context Engines
# ═══════════════════════════════════════════════════════════

script:
  # ─────────────────────────────────────────────────────────
  # LIGHTING CONTEXT ENGINE
  # ─────────────────────────────────────────────────────────
  apply_lighting_context:
    alias: "Apply Lighting Context"
    icon: mdi:lightbulb-auto
    mode: restart
    sequence:
      - variables:
          occupancy: "{{ states('input_select.occupancy_mode') }}"
          time_ctx: "{{ states('sensor.time_context') }}"
          night_vision: "{{ is_state('input_boolean.preserve_night_vision', 'on') }}"
          bedtime: "{{ is_state('sensor.bedtime_window_active', 'on') }}"
          guest: "{{ is_state('input_boolean.guest_present', 'on') }}"
      
      # ── EMPTY HOUSE ──
      - if:
          - condition: template
            value_template: "{{ occupancy == 'Empty' }}"
        then:
          # All AL instances to sleep mode, minimal brightness
          - service: switch.turn_on
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_living_spaces
                - switch.adaptive_lighting_sleep_mode_kids_rooms
                - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
                - switch.adaptive_lighting_sleep_mode_upstairs_hallway
                - switch.adaptive_lighting_sleep_mode_kitchen_table
          # Optional: Turn off non-essential lights
          - service: light.turn_off
            target:
              entity_id:
                - light.living_room_tv_smart_light_strip
                - light.kitchen_lounge_ceiling_1of2
                - light.kitchen_lounge_ceiling_2of2
      
      # ── JOHN ONLY ──
      - if:
          - condition: template
            value_template: "{{ occupancy == 'John Only' }}"
        then:
          # Living spaces normal, rest minimal
          - service: switch.turn_off
            target:
              entity_id: switch.adaptive_lighting_sleep_mode_living_spaces
          - service: switch.turn_on
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_kids_rooms
                - switch.adaptive_lighting_sleep_mode_upstairs_hallway
          # Entry and kitchen based on time
          - if:
              - condition: template
                value_template: "{{ time_ctx in ['evening', 'night'] }}"
            then:
              - service: switch.turn_on
                target:
                  entity_id: switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
            else:
              - service: switch.turn_off
                target:
                  entity_id: switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
      
      # ── KIDS ONLY ──
      - if:
          - condition: template
            value_template: "{{ occupancy == 'Kids Only' }}"
        then:
          # Kids rooms active, living spaces minimal
          - service: switch.turn_off
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_kids_rooms
                - switch.adaptive_lighting_sleep_mode_upstairs_hallway
          - service: switch.turn_on
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_living_spaces
          # If bedtime window, enable sleep mode for kids areas
          - if:
              - condition: template
                value_template: "{{ bedtime }}"
            then:
              - service: switch.turn_on
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_kids_rooms
                    - switch.adaptive_lighting_sleep_mode_upstairs_hallway
      
      # ── JOHN + KIDS ──
      - if:
          - condition: template
            value_template: "{{ occupancy == 'John + Kids' }}"
        then:
          # All main areas active unless bedtime
          - if:
              - condition: template
                value_template: "{{ bedtime }}"
            then:
              # Bedtime: dim kids areas, normal living spaces
              - service: switch.turn_on
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_kids_rooms
                    - switch.adaptive_lighting_sleep_mode_upstairs_hallway
              - service: switch.turn_off
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_living_spaces
                    - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
            else:
              # Normal: all areas active
              - service: switch.turn_off
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_living_spaces
                    - switch.adaptive_lighting_sleep_mode_kids_rooms
                    - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
                    - switch.adaptive_lighting_sleep_mode_upstairs_hallway
                    - switch.adaptive_lighting_sleep_mode_kitchen_table
      
      # ── FULL HOUSE (John + Kids + Michelle) ──
      - if:
          - condition: template
            value_template: "{{ occupancy == 'Full House' }}"
        then:
          # All areas active, unless night
          - if:
              - condition: template
                value_template: "{{ time_ctx == 'night' }}"
            then:
              # Night mode for all
              - service: switch.turn_on
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_living_spaces
                    - switch.adaptive_lighting_sleep_mode_kids_rooms
                    - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
                    - switch.adaptive_lighting_sleep_mode_upstairs_hallway
                    - switch.adaptive_lighting_sleep_mode_kitchen_table
            else:
              # Daytime: all normal
              - service: switch.turn_off
                target:
                  entity_id:
                    - switch.adaptive_lighting_sleep_mode_living_spaces
                    - switch.adaptive_lighting_sleep_mode_kids_rooms
                    - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
                    - switch.adaptive_lighting_sleep_mode_upstairs_hallway
                    - switch.adaptive_lighting_sleep_mode_kitchen_table
      
      # ── GUEST PRESENT OVERLAY ──
      - if:
          - condition: template
            value_template: "{{ guest }}"
        then:
          # Ensure living spaces and entry are welcoming
          - service: switch.turn_off
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_living_spaces
                - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
      
      # ── PRESERVE NIGHT VISION OVERLAY ──
      - if:
          - condition: template
            value_template: "{{ night_vision }}"
        then:
          # Force all to sleep mode (deep red/dim)
          - service: switch.turn_on
            target:
              entity_id:
                - switch.adaptive_lighting_sleep_mode_living_spaces
                - switch.adaptive_lighting_sleep_mode_kids_rooms
                - switch.adaptive_lighting_sleep_mode_entry_room_ceiling_lights
                - switch.adaptive_lighting_sleep_mode_upstairs_hallway
                - switch.adaptive_lighting_sleep_mode_kitchen_table

  # ─────────────────────────────────────────────────────────
  # TABLET CONTEXT ENGINE
  # ─────────────────────────────────────────────────────────
  apply_tablet_context:
    alias: "Apply Tablet Context"
    icon: mdi:tablet-dashboard
    mode: restart
    sequence:
      - variables:
          occupancy: "{{ states('input_select.occupancy_mode') }}"
          kids_away: "{{ is_state('binary_sensor.kids_expected_away', 'on') }}"
          guest: "{{ is_state('input_boolean.guest_present', 'on') }}"
          base_url: "http://192.168.1.3:8123"
      
      # Determine dashboard URL
      - variables:
          dashboard_url: >
            {% if guest %}
              {{ base_url }}/lovelace/kitchen-guest
            {% elif occupancy == 'Empty' %}
              {{ base_url }}/lovelace/kitchen-away
            {% elif occupancy == 'John Only' %}
              {{ base_url }}/lovelace/kitchen-john
            {% elif occupancy == 'Kids Only' %}
              {{ base_url }}/lovelace/kitchen-kids
            {% else %}
              {{ base_url }}/lovelace/kitchen-family
            {% endif %}
      
      # Load URL on tablet
      - service: fully_kiosk.load_url
        data:
          entity_id: media_player.kitchen_wall_a9_tablet
          url: "{{ dashboard_url }}"
# ═══════════════════════════════════════════════════════════
# AUTOMATIONS - Core Triggers
# ═══════════════════════════════════════════════════════════

automation:
  # ─────────────────────────────────────────────────────────
  # OCCUPANCY MODE UPDATE (from presence system)
  # ─────────────────────────────────────────────────────────
  - id: update_occupancy_mode
    alias: "Occupancy → Update Mode"
    mode: restart
    trigger:
      - platform: state
        entity_id:
          - input_boolean.john_home
          - input_boolean.alaina_home
          - input_boolean.ella_home
          - input_boolean.michelle_home
        for:
          seconds: 30  # Debounce
    action:
      - service: input_select.select_option
        target:
          entity_id: input_select.occupancy_mode
        data:
          option: "{{ states('sensor.occupancy_mode_auto') }}"
  
  # ─────────────────────────────────────────────────────────
  # CONTEXT APPLICATION TRIGGERS
  # ─────────────────────────────────────────────────────────
  - id: apply_context_on_occupancy_change
    alias: "Context → Apply on Occupancy Change"
    mode: restart
    trigger:
      - platform: state
        entity_id: input_select.occupancy_mode
    action:
      - service: script.apply_lighting_context
      - service: script.apply_tablet_context
  
  - id: apply_context_on_time_change
    alias: "Context → Apply on Time Change"
    mode: restart
    trigger:
      - platform: state
        entity_id: sensor.time_context
      - platform: sun
        event: sunset
      - platform: time
        at: "20:00:00"  # Bedtime start (school nights)
      - platform: time
        at: "22:00:00"  # Night mode
    action:
      - service: script.apply_lighting_context
  
  - id: apply_context_on_overlay_change
    alias: "Context → Apply on Overlay Change"
    mode: restart
    trigger:
      - platform: state
        entity_id:
          - input_boolean.preserve_night_vision
          - input_boolean.guest_present
          - input_boolean.kids_bedtime_override
    action:
      - service: script.apply_lighting_context
  
  # ─────────────────────────────────────────────────────────
  # CALENDAR SNAPSHOT REFRESH
  # ─────────────────────────────────────────────────────────
  - id: refresh_school_tomorrow
    alias: "Calendar → Refresh School Tomorrow"
    mode: restart
    trigger:
      - platform: time
        at: "17:00:00"  # Daily refresh
      - platform: homeassistant
        event: start
    action:
      - service: calendar.get_events
        data:
          start_date_time: >
            {{ (now() + timedelta(days=1)).strftime('%Y-%m-%d 00:00:00') }}
          end_date_time: >
            {{ (now() + timedelta(days=1)).strftime('%Y-%m-%d 23:59:59') }}
        target:
          entity_id: calendar.master_calendar
        response_variable: tomorrow_events
      
      - variables:
          has_no_school: >
            {{ tomorrow_events['calendar.master_calendar'].events
               | selectattr('summary', 'search', '(?i)(no school|school closed|holiday|inservice|break)')
               | list | length > 0 }}
          is_weekend: >
            {{ (now() + timedelta(days=1)).weekday() >= 5 }}
      
      - service: input_boolean.turn_{{ 'off' if (has_no_school or is_weekend) else 'on' }}
        target:
          entity_id: input_boolean.school_tomorrow
  
  - id: refresh_school_in_session_now
    alias: "Calendar → Refresh School In Session Now"
    mode: restart
    trigger:
      - platform: time_pattern
        hours: "/1"  # Hourly check
      - platform: homeassistant
        event: start
    action:
      - service: calendar.get_events
        data:
          start_date_time: >
            {{ now().strftime('%Y-%m-%d 00:00:00') }}
          end_date_time: >
            {{ now().strftime('%Y-%m-%d 23:59:59') }}
        target:
          entity_id: calendar.master_calendar
        response_variable: today_events
      
      - variables:
          has_no_school: >
            {{ today_events['calendar.master_calendar'].events
               | selectattr('summary', 'search', '(?i)(no school|school closed|holiday|inservice|break)')
               | list | length > 0 }}
          is_weekend: >
            {{ now().weekday() >= 5 }}
      
      - service: input_boolean.turn_{{ 'off' if (has_no_school or is_weekend) else 'on' }}
        target:
          entity_id: input_boolean.school_in_session_now
  
  # ─────────────────────────────────────────────────────────
  # NIGHT PATH LIGHTING (Motion-based)
  # ─────────────────────────────────────────────────────────
  - id: night_path_upstairs_hallway
    alias: "Night Path → Upstairs Hallway"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.upstairs_hallway_aqara_motion_sensor
        to: "on"
    condition:
      - condition: state
        entity_id: sensor.time_context
        state: "night"
    action:
      # Turn on hallway light at low brightness
      - service: light.turn_on
        target:
          entity_id: light.upstairs_hallway  # TODO: Replace with actual entity
        data:
          brightness_pct: 5
          kelvin: 2200
      # Wait for motion to clear
      - wait_for_trigger:
          - platform: state
            entity_id: binary_sensor.upstairs_hallway_aqara_motion_sensor
            to: "off"
            for:
              minutes: 2
        timeout:
          minutes: 10
      # Dim before off
      - service: light.turn_on
        target:
          entity_id: light.upstairs_hallway
        data:
          brightness_pct: 1
          transition: 3
      - delay:
          seconds: 5
      - service: light.turn_off
        target:
          entity_id: light.upstairs_hallway
        data:
          transition: 2


  # ─────────────────────────────────────────────────────────
  # NIGHT PATH - 2nd Floor Bathroom
  # ─────────────────────────────────────────────────────────
  - id: night_path_2nd_floor_bathroom
    alias: "Night Path → 2nd Floor Bathroom"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.upstairs_hallway_aqara_motion_sensor  # TODO: Replace with actual motion sensor
        to: "on"
    condition:
      - condition: state
        entity_id: sensor.time_context
        state: "night"
    action:
      # Turn on bathroom lights at low red/warm
      - service: light.turn_on
        target:
          entity_id: light.2nd_floor_bathroom
        data:
          brightness_pct: 5
          rgb_color: [255, 20, 0]  # Deep red
      # Wait for motion to clear
      - wait_for_trigger:
          - platform: state
            entity_id: binary_sensor.upstairs_hallway_aqara_motion_sensor
            to: "off"
            for:
              minutes: 2
        timeout:
          minutes: 15
      # Dim before off
      - service: light.turn_on
        target:
          entity_id: light.2nd_floor_bathroom
        data:
          brightness_pct: 1
          transition: 3
      - delay:
          seconds: 5
      - service: light.turn_off
        target:
          entity_id: light.2nd_floor_bathroom
        data:
          transition: 2

  # ─────────────────────────────────────────────────────────
  # MORNING WAKE - Upstairs Hallway
  # Triggers adaptive morning lighting when someone wakes up
  # ─────────────────────────────────────────────────────────
  - id: morning_wake_upstairs_hallway
    alias: "Morning Wake → Upstairs Hallway"
    mode: single
    trigger:
      - platform: state
        entity_id: binary_sensor.upstairs_hallway_motion
        to: "on"
    condition:
      - condition: state
        entity_id: sensor.time_context
        state: "morning"
      - condition: time
        after: "06:00:00"
        before: "09:00:00"
      # Only trigger if someone was sleeping (recently woke)
      - condition: or
        conditions:
          # John just woke up (sleeping turned off in last 30 min)
          - condition: template
            value_template: >
              {{ states.binary_sensor.john_sleeping.last_changed is defined and
                 (now() - states.binary_sensor.john_sleeping.last_changed).total_seconds() < 1800 and
                 is_state('binary_sensor.john_sleeping', 'off') }}
          # Or Alaina/Ella still in bed (helping them wake)
          - condition: state
            entity_id: binary_sensor.alaina_in_bed
            state: "on"
          - condition: state
            entity_id: binary_sensor.ella_in_bed
            state: "on"
    action:
      - choose:
          # WORKDAY MORNING - John only home, low start then adaptive
          - conditions:
              - condition: template
                value_template: "{{ now().weekday() < 5 }}"  # Mon-Fri
              - condition: state
                entity_id: input_boolean.john_home
                state: "on"
              - condition: template
                value_template: >
                  {{ is_state('binary_sensor.alaina_in_bed', 'off') and 
                     is_state('binary_sensor.ella_in_bed', 'off') }}
            sequence:
              # Start low, ramp up
              - service: light.turn_on
                target:
                  entity_id: light.upstairs_hallway
                data:
                  brightness_pct: 15
                  kelvin: 2200
              - delay:
                  seconds: 10
              # Hand off to adaptive lighting
              - service: switch.turn_off
                target:
                  entity_id: switch.adaptive_lighting_sleep_mode_upstairs_hallway
              # Also prep master bedroom if john_sleeping just changed
              - if:
                  - condition: template
                    value_template: >
                      {{ states.binary_sensor.john_sleeping.last_changed is defined and
                         (now() - states.binary_sensor.john_sleeping.last_changed).total_seconds() < 1800 }}
                then:
                  - service: light.turn_on
                    target:
                      entity_id: light.master_bedroom
                    data:
                      brightness_pct: 20
                      kelvin: 2400
          # KIDS GETTING READY - brighter to help them
          - conditions:
              - condition: or
                conditions:
                  - condition: state
                    entity_id: binary_sensor.alaina_in_bed
                    state: "on"
                  - condition: state
                    entity_id: binary_sensor.ella_in_bed
                    state: "on"
            sequence:
              - service: light.turn_on
                target:
                  entity_id: light.upstairs_hallway
                data:
                  brightness_pct: 40
                  kelvin: 3000
              - service: switch.turn_off
                target:
                  entity_id: switch.adaptive_lighting_sleep_mode_upstairs_hallway
        # DEFAULT - moderate morning light
        default:
          - service: light.turn_on
            target:
              entity_id: light.upstairs_hallway
            data:
              brightness_pct: 30
              kelvin: 2700
          - service: switch.turn_off
            target:
              entity_id: switch.adaptive_lighting_sleep_mode_upstairs_hallway

  # ─────────────────────────────────────────────────────────
  # MORNING WAKE - Master Bedroom (John wakes)
  # Soft light when unplugging phone in bedroom
  # ─────────────────────────────────────────────────────────
  - id: morning_wake_master_bedroom
    alias: "Morning Wake → Master Bedroom"
    mode: single
    trigger:
      - platform: state
        entity_id: binary_sensor.john_sleeping
        from: "on"
        to: "off"
    condition:
      - condition: time
        after: "05:30:00"
        before: "09:00:00"
      - condition: state
        entity_id: input_boolean.john_home
        state: "on"
    action:
      - service: light.turn_on
        target:
          entity_id: light.master_bedroom
        data:
          brightness_pct: 15
          kelvin: 2200
          transition: 5
      # Gradually brighten over 2 minutes
      - delay:
          seconds: 30
      - service: light.turn_on
        target:
          entity_id: light.master_bedroom
        data:
          brightness_pct: 30
          kelvin: 2500
          transition: 10
      # Prep upstairs bathroom - soft light ready for when John walks in
      - service: light.turn_on
        target:
          entity_id: light.2nd_floor_bathroom
        data:
          brightness_pct: 10
          kelvin: 2200
      # Turn off bathroom after 10 min if no motion (he went downstairs)
      - delay:
          minutes: 10
      - if:
          - condition: state
            entity_id: binary_sensor.upstairs_bathroom_motion
            state: "off"
            for:
              minutes: 5
        then:
          - service: light.turn_off
            target:
              entity_id: light.2nd_floor_bathroom
            data:
              transition: 5
```

## presence_display.yaml
```yaml
# ═══════════════════════════════════════════════════════════
# Presence Display - Uses AP-Based Location Sensors
# Sources: ap_presence_hybrid.yaml sensors
# ═══════════════════════════════════════════════════════════

template:
  - sensor:
      # ─────────────────────────────────────────────────────
      # JOHN - Uses AP location (has floor built in)
      # ─────────────────────────────────────────────────────
      - name: "John Status"
        unique_id: john_status_display
        icon: >
          {% set loc = states('sensor.john_ap_location') %}
          {% if 'Home' in loc %}mdi:home-account
          {% elif loc == 'Away' %}mdi:car
          {% else %}mdi:map-marker
          {% endif %}
        state: "{{ states('sensor.john_ap_location') }}"

      # ─────────────────────────────────────────────────────
      # ALAINA - Uses AP location with school/mom fallback
      # ─────────────────────────────────────────────────────
      - name: "Alaina Status"
        unique_id: alaina_status_display
        icon: >
          {% set loc = states('sensor.alaina_ap_location') %}
          {% if 'Home' in loc %}mdi:home-account
          {% elif loc == 'School' or 'School' in states('person.alaina_spencer') %}mdi:school
          {% elif loc == 'Away' %}mdi:car
          {% else %}mdi:map-marker
          {% endif %}
        state: >
          {% set ap = states('sensor.alaina_ap_location') %}
          {% set person = states('person.alaina_spencer') %}
          {% if ap not in ['unavailable', 'unknown', ''] and ap != 'Away' %}
            {{ ap }}
          {% elif 'School' in person or 'Whitehall' in person %}
            School
          {% elif "Traci" in person or is_state_attr('sensor.alaina_ap_location', 'at_moms', true) %}
            At Mom's
          {% elif person == 'home' or is_state('input_boolean.alaina_home', 'on') %}
            Home
          {% else %}
            Away
          {% endif %}

      # ─────────────────────────────────────────────────────
      # ELLA - Uses AP location with school/mom fallback
      # ─────────────────────────────────────────────────────
      - name: "Ella Status"
        unique_id: ella_status_display
        icon: >
          {% set loc = states('sensor.ella_ap_location') %}
          {% if 'Home' in loc %}mdi:home-account
          {% elif loc == 'School' or 'School' in states('person.ella_spencer') %}mdi:school
          {% elif loc == 'Away' %}mdi:car
          {% else %}mdi:map-marker
          {% endif %}
        state: >
          {% set ap = states('sensor.ella_ap_location') %}
          {% set person = states('person.ella_spencer') %}
          {% if ap not in ['unavailable', 'unknown', ''] and ap != 'Away' %}
            {{ ap }}
          {% elif 'School' in person or 'Whitehall' in person %}
            School
          {% elif "Traci" in person or is_state_attr('sensor.ella_ap_location', 'at_moms', true) %}
            At Mom's
          {% elif person == 'home' or is_state('input_boolean.ella_home', 'on') %}
            Home
          {% else %}
            Away
          {% endif %}

      # ─────────────────────────────────────────────────────
      # MICHELLE - Uses AP location
      # ─────────────────────────────────────────────────────
      - name: "Michelle Status"
        unique_id: michelle_status_display
        icon: >
          {% set loc = states('sensor.michelle_ap_location') %}
          {% if "John's House" in loc %}mdi:home-account
          {% elif loc == 'Her House' %}mdi:home-heart
          {% elif loc == 'Away' %}mdi:car
          {% else %}mdi:map-marker
          {% endif %}
        state: "{{ states('sensor.michelle_ap_location') }}"

      # ─────────────────────────────────────────────────────
      # HOUSE SUMMARY - Who's home using AP data
      # ─────────────────────────────────────────────────────
      - name: "House Summary"
        unique_id: house_summary_display
        icon: mdi:home-group
        state: >
          {% set john = 'Home' in states('sensor.john_ap_location') %}
          {% set alaina = 'Home' in states('sensor.alaina_ap_location') or is_state('input_boolean.alaina_home', 'on') %}
          {% set ella = 'Home' in states('sensor.ella_ap_location') or is_state('input_boolean.ella_home', 'on') %}
          {% set michelle = "John's House" in states('sensor.michelle_ap_location') %}
          {% set count = [john, alaina, ella, michelle] | select('true') | list | length %}
          {% if count == 0 %}Empty
          {% elif count == 1 %}
            {% if john %}John Only{% elif alaina %}Alaina Only{% elif ella %}Ella Only{% else %}Michelle Only{% endif %}
          {% elif count == 4 %}Full House
          {% else %}{{ count }} People Home{% endif %}
        attributes:
          who_home: >
            {% set p = [] %}
            {% if 'Home' in states('sensor.john_ap_location') %}{% set p = p + ['John'] %}{% endif %}
            {% if 'Home' in states('sensor.alaina_ap_location') or is_state('input_boolean.alaina_home', 'on') %}{% set p = p + ['Alaina'] %}{% endif %}
            {% if 'Home' in states('sensor.ella_ap_location') or is_state('input_boolean.ella_home', 'on') %}{% set p = p + ['Ella'] %}{% endif %}
            {% if "John's House" in states('sensor.michelle_ap_location') %}{% set p = p + ['Michelle'] %}{% endif %}
            {{ p | join(', ') if p else 'Nobody' }}
```

## presence_system.yaml
```yaml
# ═══════════════════════════════════════════════════════════
# Presence Detection System - 40154 Hwy 53
# Multi-method detection: WiFi + Motion + Geo + Mobile App
# Created: 2026-01-19
# ═══════════════════════════════════════════════════════════

input_boolean:
  # Individual presence
  john_home:
    name: "John Home"
    icon: mdi:account
  
  alaina_home:
    name: "Alaina Home"
    icon: mdi:account
  
  ella_home:
    name: "Ella Home"
    icon: mdi:account
  
  michelle_home:
    name: "Michelle Home"
    icon: mdi:account
  
  # Composite states
  someone_home:
    name: "Someone Home"
    icon: mdi:home-account
  
  girls_home:
    name: "Girls Home (Any)"
    icon: mdi:account-multiple
  
  both_girls_home:
    name: "Both Girls Home"
    icon: mdi:account-multiple
  
  john_and_girls:
    name: "John + Girls Home"
    icon: mdi:home-group
  
  john_and_michelle:
    name: "John + Michelle Home"
    icon: mdi:home-heart
  
  full_house:
    name: "Full House (John + Girls + Michelle)"
    icon: mdi:home-group
  
  # Activity tracking
  recent_motion:
    name: "Recent Motion Detected"
    icon: mdi:motion-sensor

# ═══════════════════════════════════════════════════════════
# BINARY SENSORS

# ═══════════════════════════════════════════════════════════
# TEMPLATE SENSORS (Modern Format)
# ═══════════════════════════════════════════════════════════

template:
  - binary_sensor:
      - name: "House Motion Active"
        unique_id: house_motion_active
        device_class: motion
        state: >
          {{
            is_state('binary_sensor.aqara_motion_sensor_p1_occupancy', 'on') or
            is_state('binary_sensor.garage_north_wall_nightlight_motion', 'on') or
            is_state('binary_sensor.ratgdo32disco_5735e8_motion', 'on') or
            is_state('binary_sensor.ratgdo32disco_fd8d8c_motion', 'on')
          }}
        icon: mdi:motion-sensor

  - sensor:
      - name: "People Home Count"
        unique_id: people_home_count_sensor
        state: >
          {% set count = 0 %}
          {% if is_state('input_boolean.john_home', 'on') %}{% set count = count + 1 %}{% endif %}
          {% if is_state('input_boolean.alaina_home', 'on') %}{% set count = count + 1 %}{% endif %}
          {% if is_state('input_boolean.ella_home', 'on') %}{% set count = count + 1 %}{% endif %}
          {% if is_state('input_boolean.michelle_home', 'on') %}{% set count = count + 1 %}{% endif %}
          {{ count }}
        icon: mdi:counter
      
      - name: "House Occupancy State"
        unique_id: house_occupancy_state_sensor
        state: >
          {% set john = is_state('input_boolean.john_home', 'on') %}
          {% set alaina = is_state('input_boolean.alaina_home', 'on') %}
          {% set ella = is_state('input_boolean.ella_home', 'on') %}
          {% set michelle = is_state('input_boolean.michelle_home', 'on') %}
          
          {% if john and alaina and ella and michelle %}
            Full House
          {% elif john and alaina and ella %}
            John + Girls
          {% elif john and michelle %}
            John + Michelle
          {% elif alaina and ella %}
            Girls Only
          {% elif john %}
            John Only
          {% elif alaina %}
            Alaina Only
          {% elif ella %}
            Ella Only
          {% elif michelle %}
            Michelle Only
          {% elif john and alaina %}
            John + Alaina
          {% elif john and ella %}
            John + Ella
          {% else %}
            Empty
          {% endif %}
        icon: >
          {% set count = states('sensor.people_home_count') | int %}
          {% if count == 0 %}mdi:home-outline
          {% elif count == 1 %}mdi:home-account
          {% elif count == 2 %}mdi:home-group
          {% else %}mdi:home-group-plus
          {% endif %}

# ═══════════════════════════════════════════════════════════
# AUTOMATIONS
# ═══════════════════════════════════════════════════════════

automation:
  # ─────────────────────────────────────────────────────────
  # JOHN'S PRESENCE (Mobile App + Person Entity)
  # ─────────────────────────────────────────────────────────
  
  - id: john_home_detection
    alias: "Presence → John Home"
    description: "Detect John at home via mobile app or person entity"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.john_spencer
        to: "home"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.john_home
  
  - id: john_away_detection
    alias: "Presence → John Away"
    description: "Detect John left home"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.john_spencer
        to: "not_home"
        for:
          minutes: 2
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.john_home

  # ─────────────────────────────────────────────────────────
  # ALAINA'S PRESENCE
  # ─────────────────────────────────────────────────────────
  
  - id: alaina_home_detection
    alias: "Presence → Alaina Home"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.alaina_spencer
        to: "home"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.alaina_home
  
  - id: alaina_away_detection
    alias: "Presence → Alaina Away"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.alaina_spencer
        to: "not_home"
        for:
          minutes: 2
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.alaina_home

  # ─────────────────────────────────────────────────────────
  # ELLA'S PRESENCE
  # ─────────────────────────────────────────────────────────
  
  - id: ella_home_detection
    alias: "Presence → Ella Home"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.ella_spencer
        to: "home"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.ella_home
  
  - id: ella_away_detection
    alias: "Presence → Ella Away"
    mode: restart
    trigger:
      - platform: state
        entity_id: person.ella_spencer
        to: "not_home"
        for:
          minutes: 2
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.ella_home

  # ─────────────────────────────────────────────────────────
  # MICHELLE'S PRESENCE (WiFi-based - no person entity)
  # NOTE: You'll need to find her device_tracker entity
  # ─────────────────────────────────────────────────────────
  
  - id: michelle_home_detection
    alias: "Presence → Michelle Home"
    description: "Detect Michelle via WiFi - UPDATE with her device_tracker"
    mode: restart
    trigger:
      # TODO: Replace with Michelle's actual device_tracker
      - platform: state
        entity_id: binary_sensor.michelle_actually_home
        to: "on"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.michelle_home
  
  - id: michelle_away_detection
    alias: "Presence → Michelle Away"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.michelle_actually_home
        to: "off"
        for:
          minutes: 10
    action:
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.michelle_home

  # ─────────────────────────────────────────────────────────
  # COMPOSITE PRESENCE UPDATES
  # ─────────────────────────────────────────────────────────
  
  - id: update_girls_home_status
    alias: "Presence → Update Girls Status"
    mode: restart
    trigger:
      - platform: state
        entity_id:
          - input_boolean.alaina_home
          - input_boolean.ella_home
    action:
      # At least one girl home
      - if:
          - or:
              - condition: state
                entity_id: input_boolean.alaina_home
                state: "on"
              - condition: state
                entity_id: input_boolean.ella_home
                state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.girls_home
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.girls_home
      
      # Both girls home
      - if:
          - condition: state
            entity_id: input_boolean.alaina_home
            state: "on"
          - condition: state
            entity_id: input_boolean.ella_home
            state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.both_girls_home
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.both_girls_home
  
  - id: update_occupancy_combinations
    alias: "Presence → Update Occupancy Combinations"
    mode: restart
    trigger:
      - platform: state
        entity_id:
          - input_boolean.john_home
          - input_boolean.girls_home
          - input_boolean.michelle_home
    action:
      # John + Girls
      - if:
          - condition: state
            entity_id: input_boolean.john_home
            state: "on"
          - condition: state
            entity_id: input_boolean.girls_home
            state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.john_and_girls
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.john_and_girls
      
      # John + Michelle
      - if:
          - condition: state
            entity_id: input_boolean.john_home
            state: "on"
          - condition: state
            entity_id: input_boolean.michelle_home
            state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.john_and_michelle
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.john_and_michelle
      
      # Full House
      - if:
          - condition: state
            entity_id: input_boolean.john_home
            state: "on"
          - condition: state
            entity_id: input_boolean.both_girls_home
            state: "on"
          - condition: state
            entity_id: input_boolean.michelle_home
            state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.full_house
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.full_house
  
  - id: update_someone_home
    alias: "Presence → Update Someone Home"
    mode: restart
    trigger:
      - platform: state
        entity_id:
          - input_boolean.john_home
          - input_boolean.alaina_home
          - input_boolean.ella_home
          - input_boolean.michelle_home
    action:
      - if:
          - or:
              - condition: state
                entity_id: input_boolean.john_home
                state: "on"
              - condition: state
                entity_id: input_boolean.alaina_home
                state: "on"
              - condition: state
                entity_id: input_boolean.ella_home
                state: "on"
              - condition: state
                entity_id: input_boolean.michelle_home
                state: "on"
        then:
          - service: input_boolean.turn_on
            target:
              entity_id: input_boolean.someone_home
        else:
          - service: input_boolean.turn_off
            target:
              entity_id: input_boolean.someone_home

  # ─────────────────────────────────────────────────────────
  # MOTION-BASED ACTIVITY TRACKING
  # ─────────────────────────────────────────────────────────
  
  - id: recent_motion_detected
    alias: "Activity → Recent Motion Detected"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.house_motion_active
        to: "on"
    action:
      - service: input_boolean.turn_on
        target:
          entity_id: input_boolean.recent_motion
      - delay:
          minutes: 15
      - service: input_boolean.turn_off
        target:
          entity_id: input_boolean.recent_motion

template:

# =============================================================================

  - binary_sensor:
      # John sleeping/in bed detection
      - name: "John Sleeping"
        unique_id: john_sleeping
        state: >
          {% set on_2nd_floor_ap = state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') == '70:a7:41:c6:1e:6c' %}
          {% set charging = states('sensor.john_s_phone_battery_state') in ['charging', 'Charging', 'full', 'Full'] %}
          {% set after_bedtime = now().hour >= 21 or now().hour < 7 %}
          {{ on_2nd_floor_ap and charging and after_bedtime }}
        device_class: occupancy
        icon: mdi:sleep

      # Alaina in bed detection  
      - name: "Alaina In Bed"
        unique_id: alaina_in_bed
        state: >
          {% set on_2nd_floor_ap = state_attr('device_tracker.alaina_s_iphone', 'ap_mac') == '70:a7:41:c6:1e:6c' %}
          {% set charging = states('sensor.alainas_iphone_battery_state') in ['charging', 'Charging', 'full', 'Full'] %}
          {% set at_home = is_state('input_boolean.alaina_home', 'on') %}
          {{ at_home and on_2nd_floor_ap and charging }}
        device_class: occupancy
        icon: mdi:sleep

      # Ella in bed detection
      - name: "Ella In Bed"
        unique_id: ella_in_bed
        state: >
          {% set on_2nd_floor_ap = state_attr('device_tracker.unifi_default_4a_7c_ea_7a_12_e0', 'ap_mac') == '70:a7:41:c6:1e:6c' %}
          {% set charging = states('sensor.ellas_iphone_battery_state') in ['charging', 'Charging', 'full', 'Full'] %}
          {% set at_home = is_state('input_boolean.ella_home', 'on') %}
          {{ at_home and on_2nd_floor_ap and charging }}
        device_class: occupancy
        icon: mdi:sleep

      # Girls heading to bed (on 2nd floor AP, home, evening hours)
      - name: "Girls Heading to Bed"
        unique_id: girls_heading_to_bed
        state: >
          {% set alaina_2nd = state_attr('device_tracker.alaina_s_iphone', 'ap_mac') == '70:a7:41:c6:1e:6c' %}
          {% set ella_2nd = state_attr('device_tracker.unifi_default_4a_7c_ea_7a_12_e0', 'ap_mac') == '70:a7:41:c6:1e:6c' %}
          {% set alaina_home = is_state('input_boolean.alaina_home', 'on') %}
          {% set ella_home = is_state('input_boolean.ella_home', 'on') %}
          {% set evening = now().hour >= 19 or now().hour < 1 %}
          {{ evening and ((alaina_home and alaina_2nd) or (ella_home and ella_2nd)) }}
        device_class: occupancy
        icon: mdi:bed-clock

      # Kids asleep (both in bed and charging)
      - name: "Kids Asleep"
        unique_id: kids_asleep
        state: >
          {% set alaina_sleeping = is_state('binary_sensor.alaina_in_bed', 'on') %}
          {% set ella_sleeping = is_state('binary_sensor.ella_in_bed', 'on') %}
          {% set alaina_home = is_state('input_boolean.alaina_home', 'on') %}
          {% set ella_home = is_state('input_boolean.ella_home', 'on') %}
          {% set both_home = alaina_home and ella_home %}
          {% set one_home = alaina_home != ella_home %}
          {% if both_home %}
            {{ alaina_sleeping and ella_sleeping }}
          {% elif one_home %}
            {{ (alaina_home and alaina_sleeping) or (ella_home and ella_sleeping) }}
          {% else %}
            false
          {% endif %}
        device_class: occupancy
        icon: mdi:sleep

# =============================================================================
# GIRLS AT MOM'S HOUSE DETECTION
# =============================================================================

  - binary_sensor:
      - name: "Alaina at Mom's"
        unique_id: alaina_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-account

      - name: "Ella at Mom's"
        unique_id: ella_at_moms
        state: >
          {{ is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-account

      - name: "Both Girls at Mom's"
        unique_id: both_girls_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") and is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-group

      - name: "Any Girl at Mom's"
        unique_id: any_girl_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") or is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-group

      - name: "Girls Location Summary"
        unique_id: girls_location_summary
        state: >
          {% set alaina = states('person.alaina_spencer') %}
          {% set ella = states('person.ella_spencer') %}
          {% if alaina == ella %}
            {{ 'Both at ' ~ alaina }}
          {% else %}
            {{ 'Alaina: ' ~ alaina ~ ', Ella: ' ~ ella }}
          {% endif %}
        icon: mdi:map-marker-multiple

# =============================================================================
# GIRLS AT MOM'S HOUSE DETECTION
# =============================================================================

  - binary_sensor:
      - name: "Alaina at Mom's"
        unique_id: alaina_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-account

      - name: "Ella at Mom's"
        unique_id: ella_at_moms
        state: >
          {{ is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-account

      - name: "Both Girls at Mom's"
        unique_id: both_girls_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") and is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-group

      - name: "Any Girl at Mom's"
        unique_id: any_girl_at_moms
        state: >
          {{ is_state('person.alaina_spencer', "Traci's House") or is_state('person.ella_spencer', "Traci's House") }}
        device_class: presence
        icon: mdi:home-group

      - name: "Girls Location Summary"
        unique_id: girls_location_summary
        state: >
          {% set alaina = states('person.alaina_spencer') %}
          {% set ella = states('person.ella_spencer') %}
          {% if alaina == ella %}
            {{ 'Both at ' ~ alaina }}
          {% else %}
            {{ 'Alaina: ' ~ alaina ~ ', Ella: ' ~ ella }}
          {% endif %}
        icon: mdi:map-marker-multiple

      - name: "Alaina at School"
        unique_id: alaina_at_school
        state: >
          {{ is_state('person.alaina_spencer', 'Whitehall School') }}
        device_class: presence
        icon: mdi:school

      - name: "Ella at School"
        unique_id: ella_at_school
        state: >
          {{ is_state('person.ella_spencer', 'Whitehall School') }}
        device_class: presence
        icon: mdi:school

      - name: "Both Girls at School"
        unique_id: both_girls_at_school
        state: >
          {{ is_state('person.alaina_spencer', 'Whitehall School') and is_state('person.ella_spencer', 'Whitehall School') }}
        device_class: presence
        icon: mdi:school

      - name: "Any Girl at School"
        unique_id: any_girl_at_school
        state: >
          {{ is_state('person.alaina_spencer', 'Whitehall School') or is_state('person.ella_spencer', 'Whitehall School') }}
        device_class: presence
        icon: mdi:school

# =============================================================================
# FLOOR LOCATION SENSORS - Based on UniFi AP Association
# =============================================================================
# AP MAC Reference:
#   2nd_floor_ap: 70:a7:41:c6:1e:6c (upstairs - bedrooms/bathroom)
#   1st_floor_ap: d0:21:f9:eb:b8:8c (main floor)
#   garage_ap:    f4:92:bf:69:53:f0 (garage)
# =============================================================================
  - sensor:
      - name: "John Floor Location"
        unique_id: john_floor_location
        state: >
          {% set ap_mac = state_attr('device_tracker.john_s_s24_ultra_4', 'ap_mac') %}
          {% if ap_mac == '70:a7:41:c6:1e:6c' %}
            2nd_floor
          {% elif ap_mac == 'd0:21:f9:eb:b8:8c' %}
            1st_floor
          {% elif ap_mac == 'f4:92:bf:69:53:f0' %}
            garage
          {% elif ap_mac is none or ap_mac == '' %}
            away
          {% else %}
            unknown
          {% endif %}
        icon: >
          {% set floor = this.state %}
          {% if floor == '2nd_floor' %}
            mdi:home-floor-2
          {% elif floor == '1st_floor' %}
            mdi:home-floor-1
          {% elif floor == 'garage' %}
            mdi:garage
          {% else %}
            mdi:help-circle
          {% endif %}

      - name: "Alaina Floor Location"
        unique_id: alaina_floor_location
        state: >
          {% set ap_mac = state_attr('device_tracker.alaina_s_iphone', 'ap_mac') %}
          {% if ap_mac == '70:a7:41:c6:1e:6c' %}
            2nd_floor
          {% elif ap_mac == 'd0:21:f9:eb:b8:8c' %}
            1st_floor
          {% elif ap_mac == 'f4:92:bf:69:53:f0' %}
            garage
          {% elif ap_mac is none or ap_mac == '' %}
            away
          {% else %}
            unknown
          {% endif %}
        icon: >
          {% set floor = this.state %}
          {% if floor == '2nd_floor' %}
            mdi:home-floor-2
          {% elif floor == '1st_floor' %}
            mdi:home-floor-1
          {% elif floor == 'garage' %}
            mdi:garage
          {% else %}
            mdi:help-circle
          {% endif %}

      - name: "Ella Floor Location"
        unique_id: ella_floor_location
        state: >
          {% set ap_mac = state_attr('device_tracker.unifi_default_4a_7c_ea_7a_12_e0', 'ap_mac') %}
          {% if ap_mac == '70:a7:41:c6:1e:6c' %}
            2nd_floor
          {% elif ap_mac == 'd0:21:f9:eb:b8:8c' %}
            1st_floor
          {% elif ap_mac == 'f4:92:bf:69:53:f0' %}
            garage
          {% elif ap_mac is none or ap_mac == '' %}
            away
          {% else %}
            unknown
          {% endif %}
        icon: >
          {% set floor = this.state %}
          {% if floor == '2nd_floor' %}
            mdi:home-floor-2
          {% elif floor == '1st_floor' %}
            mdi:home-floor-1
          {% elif floor == 'garage' %}
            mdi:garage
          {% else %}
            mdi:help-circle
          {% endif %}

  - binary_sensor:
      # John upstairs - useful for automations
      - name: "John Upstairs"
        unique_id: john_upstairs
        state: "{{ is_state('sensor.john_floor_location', '2nd_floor') }}"
        device_class: occupancy
        icon: mdi:home-floor-2

      # Anyone upstairs
      - name: "Anyone Upstairs"
        unique_id: anyone_upstairs
        state: >
          {{ is_state('sensor.john_floor_location', '2nd_floor')
             or is_state('sensor.alaina_floor_location', '2nd_floor')
             or is_state('sensor.ella_floor_location', '2nd_floor') }}
        device_class: occupancy
        icon: mdi:home-floor-2

      # Upstairs occupied (someone there + motion recently)
      - name: "Upstairs Occupied"
        unique_id: upstairs_occupied
        state: >
          {% set someone_upstairs = is_state('binary_sensor.anyone_upstairs', 'on') %}
          {% set recent_motion = is_state('binary_sensor.upstairs_hallway_motion', 'on')
                                 or is_state('binary_sensor.upstairs_bathroom_motion', 'on') %}
          {{ someone_upstairs or recent_motion }}
        device_class: occupancy
        icon: mdi:motion-sensor

# =============================================================================
# MICHELLE LOCATION SENSORS
# =============================================================================
  - binary_sensor:
      - name: "Michelle at John's House"
        unique_id: michelle_at_johns_house
        state: >
          {{ is_state('person.michelle', 'home') and 
             not is_state('binary_sensor.michelle_phone_at_michelle_s_house_40062', 'on') }}
        device_class: presence
        icon: mdi:home-account

      - name: "Michelle at Her House"
        unique_id: michelle_at_her_house
        state: >
          {{ is_state('binary_sensor.michelle_phone_at_michelle_s_house_40062', 'on') or
             is_state('person.michelle', "Michelle's House 40062 US Hwy 53") }}
        device_class: presence
        icon: mdi:home

      - name: "Michelle Home Anywhere"
        unique_id: michelle_home_anywhere
        state: >
          {{ is_state('binary_sensor.michelle_at_johns_house', 'on') or
             is_state('binary_sensor.michelle_at_her_house', 'on') }}
        device_class: presence
        icon: mdi:home-heart

  - sensor:
      - name: "Michelle Location"
        unique_id: michelle_location_friendly
        state: >
          {% if is_state('binary_sensor.michelle_phone_at_michelle_s_house_40062', 'on') %}
            Her House
          {% elif is_state('person.michelle', 'home') %}
            John's House
          {% else %}
            {{ states('person.michelle') }}
          {% endif %}
        icon: mdi:map-marker

# =============================================================================
# GIRLS LOCATION SENSORS (Friendly)
# =============================================================================
  - sensor:
      - name: "Alaina Location"
        unique_id: alaina_location_friendly
        state: >
          {% if is_state('person.alaina_spencer', 'Whitehall School') %}
            School
          {% elif is_state('person.alaina_spencer', "Traci's House") %}
            Mom's
          {% elif is_state('person.alaina_spencer', 'home') %}
            Home
          {% else %}
            {{ states('person.alaina_spencer') }}
          {% endif %}
        icon: >
          {% if is_state('person.alaina_spencer', 'Whitehall School') %}
            mdi:school
          {% elif is_state('person.alaina_spencer', "Traci's House") %}
            mdi:home-heart
          {% elif is_state('person.alaina_spencer', 'home') %}
            mdi:home
          {% else %}
            mdi:map-marker
          {% endif %}

      - name: "Ella Location"
        unique_id: ella_location_friendly
        state: >
          {% if is_state('person.ella_spencer', 'Whitehall School') %}
            School
          {% elif is_state('person.ella_spencer', "Traci's House") %}
            Mom's
          {% elif is_state('person.ella_spencer', 'home') %}
            Home
          {% else %}
            {{ states('person.ella_spencer') }}
          {% endif %}
        icon: >
          {% if is_state('person.ella_spencer', 'Whitehall School') %}
            mdi:school
          {% elif is_state('person.ella_spencer', "Traci's House") %}
            mdi:home-heart
          {% elif is_state('person.ella_spencer', 'home') %}
            mdi:home
          {% else %}
            mdi:map-marker
          {% endif %}

      - name: "John Location"
        unique_id: john_location_friendly
        state: >
          {% if is_state('input_boolean.john_home', 'on') %}
            Home
          {% elif is_state('person.john_spencer', 'TCHCC') %}
            Work
          {% else %}
            {{ states('person.john_spencer') }}
          {% endif %}
        icon: >
          {% if is_state('input_boolean.john_home', 'on') %}
            mdi:home
          {% elif is_state('person.john_spencer', 'TCHCC') %}
            mdi:hospital-building
          {% else %}
            mdi:map-marker
          {% endif %}
```

## sun_follow_entry_room.yaml
```yaml
# Entry Room: Adaptive Lighting for Hue Group
adaptive_lighting:
  - name: "Entry Room Ceiling Lights"
    lights:
      - light.entry_room
    prefer_rgb_color: false
    initial_transition: 2
    min_brightness: 30
    max_brightness: 100
    sleep_brightness: 10
    sleep_rgb_or_color_temp: "color_temp"
    sleep_color_temp: 2200
    take_over_control: true
    detect_non_ha_changes: false
```
