# Entity Context Map

Maps Home Assistant entities to real-world context, learnings, and configurations.
Enriches AI understanding of WHY entities exist and HOW they're used.

## Format
Each entry contains:
- **Entity ID**: The HA entity
- **Real-World Context**: What physical device/location/person
- **Purpose**: Why it exists, what problem it solves
- **Key Learnings**: Gotchas, config details, troubleshooting notes
- **Related Entities**: Dependencies, groups, automations
- **Last Updated**: Date of last context update

---

## Presence Detection

### binary_sensor.michelle_phone_at_michelle_s_house_40062
- **Real-World**: Michelle's iPhone 14 Pro at her house (40062 US Hwy 53)
- **Purpose**: Micro-location tracking - proves Michelle is physically AT 40062 vs just "home zone"
- **Key Learnings**:
  - Uses UniFi AP MAC (60:22:32:3d:b6:44) as PRIMARY proof
  - SSID 'Goetting' as fallback (less reliable, can reach from driveway)
  - AP MAC more precise than SSID for room-level accuracy
  - Created 2026-01-16 after SSID-only approach proved unreliable
- **Related Entities**:
  - `device_tracker.michelle_s_iphone_14_pro` (source)
  - Future: `binary_sensor.michelle_present` (rollup)
- **Config Location**: `/config/templates/binary_sensor.yaml`
- **Last Updated**: 2026-01-16

### device_tracker.michelle_s_iphone_14_pro
- **Real-World**: Michelle's iPhone 14 Pro (UniFi integration)
- **Purpose**: Raw tracking data from UniFi - provides essid, ap_mac, location data
- **Key Learnings**:
  - Attributes include: essid, ap_mac, hostname
  - Used as source for micro-location sensors
  - More granular than HA Companion app zones
- **Related Entities**:
  - `binary_sensor.michelle_phone_at_michelle_s_house_40062`
  - Future micro-location sensors
- **Last Updated**: 2026-01-16

---

## Next Entities to Document
- [ ] binary_sensor.michelle_phone_at_john_s_house_40154 (pending creation)
- [ ] binary_sensor.michelle_present (pending rollup)
- [ ] Garage door sensors/ratgdo
- [ ] Garage lighting entities
- [ ] Alaina/Ella device trackers

---

## Automation Ideas from Context
- Auto-document new entities when created via templates
- Link learnings.md entries to relevant entities
- Generate "entity health reports" based on context + state history


## Garage Control

### cover.ratgdo_*
- **Real-World**: Garage door openers with ratgdo controllers
- **Purpose**: Smart garage door control and monitoring
- **Key Learnings**: 
  - Part of garage automation system
  - Integrated with lighting automations
  - Referenced in "garage all lights on/off" automations
- **Related Entities**:
  - `automation.garage_all_lights_off`
  - `automation.garage_all_lights_off_2`
  - `automation.garage_all_lights_on`
- **Last Updated**: 2026-01-17

## Kitchen Lighting

### automation.kitchen_lounge_vzm36_fan_light_hue_ceiling
### automation.kitchen_lounge_vzm31_sn_dimmer_hue_ceiling
- **Real-World**: Inovelli VZM36 (fan+light) and VZM31-SN (dimmer) controlling Philips Hue bulbs
- **Purpose**: Smart switch control of Hue bulbs in kitchen lounge area
- **Key Learnings**:
  - VZM36 = fan/light combo canopy module
  - VZM31-SN = dimmer switch
  - Both control Hue bulbs (smart bulb mode required)
  - Part of kitchen lighting ecosystem
- **Related Entities**:
  - Kitchen lounge Hue ceiling lights
  - Inovelli switch entities
- **Last Updated**: 2026-01-17

## Person Tracking (In Progress)

### binary_sensor.anyone_home
- **Real-World**: Composite sensor - true if ANY family member home
- **Purpose**: Master presence detection for "everyone away" automations
- **Key Learnings**:
  - Used by `automation.everyone_away_all_lights_off`
  - Needs to integrate with individual person sensors
- **Related Entities**:
  - Individual person presence sensors (pending)
  - `automation.everyone_away_all_lights_off`
  - `automation.first_person_home_after_dark_entry_lights_on`
- **Last Updated**: 2026-01-17



### binary_sensor.michelle_present
- **Real-World**: Michelle's unified presence sensor (rollup of micro-location sensors)
- **Purpose**: Single source of truth for "Is Michelle present at either house?" - consolidates 40154 and 40062 locations
- **Key Learnings**:
  - Rolls up binary_sensor.michelle_phone_at_john_s_house_40154 and binary_sensor.michelle_phone_at_michelle_s_house_40062
  - Will be ON if Michelle is at EITHER location
  - Eliminates need to check multiple sensors in automations
  - Part of person.michelle device_tracker list
  - Pending creation - requires 40154 AP MAC capture first
- **Related Entities**:
  - `binary_sensor.michelle_phone_at_michelle_s_house_40062` (source)
  - `binary_sensor.michelle_phone_at_john_s_house_40154` (source, pending)
  - `device_tracker.michelle_s_iphone_14_pro` (data source)
  - `person.michelle` (will use this sensor)
  - `binary_sensor.anyone_home` (will reference this)
- **Config Location**: `/config/templates/binary_sensor.yaml` (pending)
- **Last Updated**: 2026-01-17

### binary_sensor.aqara_door_and_window_sensor_door_3
- **Real-World**: [Describe the physical device/location/person]
- **Purpose**: [Why this entity exists, what problem it solves]
- **Key Learnings**:
  - [Add configuration details, gotchas, etc.]
- **Related Entities**:
  - [List dependencies, groups, automations]
- **Last Updated**: 2026-01-17

### light.garage
- **Real-World**: [Describe the physical device/location/person]
- **Purpose**: [Why this entity exists, what problem it solves]
- **Key Learnings**:
  - [Add configuration details, gotchas, etc.]
- **Related Entities**:
  - [List dependencies, groups, automations]
- **Last Updated**: 2026-01-17

### light.ratgdo32disco_fd8d8c_light,light.ratgdo32disco_5735e8_light
- **Real-World**: [Describe the physical device/location/person]
- **Purpose**: [Why this entity exists, what problem it solves]
- **Key Learnings**:
  - [Add configuration details, gotchas, etc.]
- **Related Entities**:
  - [List dependencies, groups, automations]
- **Last Updated**: 2026-01-17

### automation_system_2026-01-17
- **Real-World**: [Describe the physical device/location/person]
- **Purpose**: [Why this entity exists, what problem it solves]
- **Key Learnings**:
  - [Add configuration details, gotchas, etc.]
- **Related Entities**:
  - [List dependencies, groups, automations]
- **Last Updated**: 2026-01-17

### garage_system_issue_<date>
- **Real-World**: [Describe the physical device/location/person]
- **Purpose**: [Why this entity exists, what problem it solves]
- **Key Learnings**:
  - [Add configuration details, gotchas, etc.]
- **Related Entities**:
  - [List dependencies, groups, automations]
- **Last Updated**: 2026-01-17
