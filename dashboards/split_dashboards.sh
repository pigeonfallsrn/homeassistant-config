#!/bin/bash

# This will create individual dashboard YAML files
# from the combined kitchen_dashboards.yaml

echo "Splitting dashboards..."

# For now, let's create a simple working version
# We'll use the Kitchen dashboard as the base

cat > /config/dashboards/lovelace-mobile.yaml << 'MOBILE_YAML'
title: Mobile
icon: mdi:cellphone
path: mobile
views:
  - title: Home
    path: home
    cards:
      - type: markdown
        content: |
          # {{ states('sensor.house_occupancy_state') }}
          {{ now().strftime('%A, %B %d • %I:%M %p') }}
      
      - type: glance
        show_name: true
        show_state: true
        entities:
          - entity: input_boolean.john_home
            name: John
          - entity: input_boolean.alaina_home
            name: Alaina
          - entity: input_boolean.ella_home
            name: Ella
          - entity: input_boolean.michelle_home
            name: Michelle
      
      - type: entities
        title: Quick Controls
        entities:
          - entity: input_boolean.preserve_night_vision
            name: Night Vision
          - entity: input_boolean.guest_present
            name: Guest Mode
          - entity: input_select.occupancy_mode
            name: Occupancy
      
      - type: entities
        title: Main Lights
        entities:
          - entity: light.living_room_lounge_ceiling_hue_color_lights
            name: Living Room
          - entity: light.entry_room_ceiling_hue_white_lights
            name: Entry
          - entity: light.kitchen_chandelier_1of5
            name: Kitchen
          - entity: light.upstairs_hallway
            name: Upstairs
          - entity: light.alaina_s_ceiling_led_lights
            name: Alaina's Room
MOBILE_YAML

echo "Created mobile dashboard"
