# Home Assistant Entity Reference Guide
Generated: $(date)

This document provides a comprehensive reference of all entities in your Home Assistant system, organized for easy automation creation.

---

## Quick Reference by Room/Area

### Kitchen
```yaml
kitchen_lights:
  - light.kitchen_table_chandelier_smart_dimmer_switch
  - light.kitchen_lounge_tv_dual_smart_plug_light
  
kitchen_plugs:
  - switch.kitchen_keurig_plug
  - switch.kitchen_roomba_smart_plug
  - switch.kitchen_echo_show_plug
  - switch.kitchen_lounge_samsung_tv_plug
  
kitchen_media:
  - media_player.kitchen_echo_show
```

### Living Room
```yaml
living_room_lights:
  - light.living_room_*
  
living_room_media:
  - media_player.living_room_echo_show
  - media_player.living_room_tv
  
living_room_plugs:
  - switch.living_room_tv_smart_plug
  - switch.living_room_tv_dual_plug
```

### Master Bedroom
```yaml
master_bedroom_media:
  - media_player.master_bedroom_echo_show
  - media_player.master_bedroom_tv
```

### Alaina's Room
```yaml
alaina_lights:
  - light.alaina_s_ceiling_led_lights
  - light.alaina_s_floor_govee_lamp
  - light.alaina_s_bedside_color_lamp
```

### Ella's Room
```yaml
ella_lights:
  - light.ella_s_bedside_lamp
  - light.ella_s_wall_light
```

### Basement
```yaml
basement_lights:
  - switch.basement_hallway_smart_switch
  - switch.basement_flourescent_light_plug
  
basement_media:
  - media_player.basement_echo
  - switch.basement_yamaha_av_receiver_plug
  
basement_appliances:
  - switch.basement_washer_plug
  - switch.basement_milwaukee_charger_smart_plug
```

### Garage
```yaml
garage_doors:
  - cover.ratgdo32disco_5735e8_door
  - cover.ratgdo32disco_fd8d8c_door
  
garage_media:
  - switch.garage_projector_and_av_smart_plug
  - switch.garage_receiver
```

### Outdoor/Security
```yaml
outdoor_lights:
  - switch.front_driveway_lights

security_cameras:
  - camera.front_driveway_door
  - camera.very_front_door
  - camera.g4_bullet
  - camera.g6_bullet
  - camera.kitchen_ai_theta
```

---

## By Device Type

### All Lights (Controllable Brightness)
```yaml
all_lights:
  - light.kitchen_table_chandelier_smart_dimmer_switch
  - light.alaina_s_ceiling_led_lights
  - light.alaina_s_floor_govee_lamp
  - light.alaina_s_bedside_color_lamp
  - light.ella_s_bedside_lamp
  - light.ella_s_wall_light
  # Add all from hue, adaptive_lighting, etc.
```

### All Smart Plugs/Switches
```yaml
all_plugs:
  - switch.kitchen_keurig_plug
  - switch.basement_washer_plug
  - switch.living_room_tv_smart_plug
  # See full list in switches section
```

### All Media Players
```yaml
all_echo_devices:
  - media_player.kitchen_echo_show
  - media_player.living_room_echo_show
  - media_player.master_bedroom_echo_show
  - media_player.upstairs_bathroom_echo_plus
  - media_player.john_s_echo
  - media_player.basement_echo
  
all_tvs:
  - media_player.living_room_tv
  - media_player.master_bedroom_tv
```

### Climate Control
```yaml
thermostats:
  - climate.* # Nest and Mitsubishi mini-splits
```

### Covers/Garage Doors
```yaml
garage_doors:
  - cover.ratgdo32disco_5735e8_door
  - cover.ratgdo32disco_fd8d8c_door
```

---

## Automation Examples

### Example: Good Night Routine
```yaml
automation:
  - alias: "Good Night - All Off"
    trigger:
      - platform: time
        at: "22:00:00"
    action:
      - service: light.turn_off
        target:
          entity_id:
            - light.kitchen_table_chandelier_smart_dimmer_switch
            - light.living_room_*
      - service: switch.turn_off
        target:
          entity_id:
            - switch.kitchen_keurig_plug
            - switch.living_room_tv_smart_plug
```

### Example: Girls Bedtime
```yaml
automation:
  - alias: "Girls Bedtime - Adaptive Lighting Sleep Mode"
    trigger:
      - platform: time
        at: "20:00:00"
    action:
      - service: adaptive_lighting.set_manual_control
        data:
          entity_id: switch.adaptive_lighting_girls_bedside_lamps
          manual_control: false
      - service: adaptive_lighting.apply
        data:
          entity_id: switch.adaptive_lighting_girls_bedside_lamps
          turn_on_lights: true
```

---

## Network Devices (UniFi)
```yaml
network_switches:
  - switch.unifi_network_lan_to_iot
  - switch.unifi_network_aqara_to_ha
  - switch.unifi_network_goetting_guest_to_vpn
```

---

## Full Inventory Location
Complete detailed inventory: `/config/entity_inventory_complete_TIMESTAMP.txt`

