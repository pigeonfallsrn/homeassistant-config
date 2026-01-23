# ENTITY CONTEXT MAPPING SYSTEM
Generated: 2026-01-16 21:50

## PURPOSE
Map entities to real-world context, learnings, and configurations so AIs understand WHY entities exist and HOW they're used.

## PERSON ENTITIES

### person.john_spencer
- **Tracker**: device_tracker.john_s_s24_ultra_4
- **Device**: Samsung S24 Ultra (192.168.1.135)
- **Network**: 1st Floor AP (Primary WiFi)
- **Location**: 40154 US Hwy 53
- **Context**: System owner, RN with shift work
- **Related Learning**: [Multiple - primary user]

### person.alaina_spencer
- **Tracker**: device_tracker.alaina_s_iphone
- **Device**: iPhone 17 (192.168.1.252)
- **Status**: Needs re-login Saturday 1pm
- **Location**: 40154 US Hwy 53 (John's daughter)
- **Other Devices**: School iPad, personal iPad, bedroom Roku
- **Related Learning**: [2026-01-16 17:08] iPhone 17 setup scheduled
- **Automations**: Bedroom lighting, wake/sleep routines

### person.ella_spencer
- **Tracker**: None linked (NEEDS SETUP)
- **Device**: iPhone 17 (192.168.1.96) - not connected to HA
- **Status**: Setup needed Sunday 4pm
- **Location**: 40154 US Hwy 53 (John's daughter)
- **Other Devices**: School iPad, Fire TV stick, LED lights
- **Related Learning**: [2026-01-16 17:08] iPhone 17 setup scheduled Sunday
- **Automations**: Bedroom lighting

### person.michelle
- **Tracker**: device_tracker.michelle_s_iphone_14_pro
- **Device**: iPhone 14 Pro (192.168.28.142 on Goetting WiFi)
- **Location**: 40062 US Hwy 53 (rental house, 3 houses down)
- **Work Schedule**: M/Tu/Th/F 8am-5pm (NOT Wed/weekends)
- **Network**: Goetting WiFi SSID = 40062 ONLY
- **Related Sensors**: 
  - binary_sensor.michelle_phone_at_michelle_s_house_40062
  - binary_sensor.michelle_present_goetting_wifi
- **Related Learning**: [2026-01-16 16:49] Michelle work laptop requires network priority during work hours
- **Critical**: Network changes during work hours FORBIDDEN

### person.jarrett_goetting
- **Tracker**: None (placeholder)
- **Device**: Android tablet (not integrated)
- **Location**: 40062 US Hwy 53 (Michelle's older son)
- **Other Devices**: Echo Show, multiple TVs, Nintendo Switch (shared)
- **Related Learning**: [2026-01-16 16:49] Jarrett older, has Echo Show

### person.owen_goetting
- **Tracker**: None (placeholder)
- **Device**: Android tablet (not integrated)
- **Location**: 40062 US Hwy 53 (Michelle's younger son)
- **Other Devices**: Nanit baby monitor cam (192.168.28.7), TV
- **Related Learning**: [2026-01-16 16:49] Owen is young (has Nanit cam)

### person.jean_spencer
- **Tracker**: None (will add when visits)
- **Device**: Samsung S25
- **Location**: Visits 40154 occasionally
- **Context**: John's mother (retired), helps with girls/laundry
- **Related Learning**: [2026-01-16 16:49] Jean is John's mother, occasional visitor

## CLIMATE ENTITIES

### climate.garage_nest_thermostat
- **Location**: Home garage (40154)
- **Temperature**: 61.52°F
- **Zone**: Baseboard hot water radiators (undersized but adequate)
- **Related Entities**: 
  - cover.garage_north_door (ratgdo)
  - cover.garage_south_door (ratgdo)
  - 6x Hue bulbs (UNRELIABLE - see lighting section)
- **Related Learning**: [2026-01-16 16:35] Garage lighting priority fix needed

### climate.basement_nest_thermostat
- **Location**: Basement (40154)
- **Temperature**: 64.94°F
- **Zone**: Cast iron repurposed radiators
- **System**: Navien combi via Taco multi-zone controller
- **Related Learning**: [2026-01-16 16:35] Basement radiant heat zone

### climate.1st_floor_thermostat
- **Location**: Main floor (40154)
- **Temperature**: 69.62°F
- **Zone**: In-floor PEX radiant (entire 1st floor)
- **System**: Mixing valve + subfloor temp probe to Navien
- **Status**: Works great
- **Related Learning**: [2026-01-16 16:35] 1st floor in-floor PEX

### climate.master_nest_thermostat
- **Location**: Master bedroom (40154)
- **Temperature**: 68.0°F
- **Zone**: Upstairs radiators (5 total - Master, Ella, Alaina, hallway, bathroom)
- **Status**: Single zone, TRV project planned
- **Related Learning**: [2026-01-16 16:35] TRV project: 5 upstairs radiators need Sonoff Zigbee TRVs

### climate.pfp_west_nest_thermostat_control
- **Location**: Big Garage West (40003)
- **Temperature**: 50°F (INTENTIONAL)
- **System**: Natural gas ceiling furnace (older hanging style)
- **Purpose**: FREEZE PROTECTION ONLY
- **Related Learning**: [2026-01-16 16:35] Big Garage 50°F freeze protection (intentional)

### climate.pfp_east_nest_thermostat_control
- **Location**: Big Garage East (40003)
- **Temperature**: 50°F (INTENTIONAL)
- **System**: Natural gas ceiling furnace (older hanging style)
- **Purpose**: FREEZE PROTECTION ONLY
- **Related Learning**: [2026-01-16 16:35] Big Garage 50°F freeze protection (intentional)

## PROBLEM ENTITIES (Need Attention)

### GARAGE LIGHTING (Priority 1)
**Problem**: 6 Hue bulbs unreliable (4 not wired hot)

Entities:
- light.garage_ceiling_1 (wired hot - reliable)
- light.garage_ceiling_2 (wired hot - reliable)
- light.garage_north_door_1 (NOT wired hot - UNRELIABLE)
- light.garage_north_door_2 (NOT wired hot - UNRELIABLE)
- light.garage_south_door_1 (NOT wired hot - UNRELIABLE)
- light.garage_south_door_2 (NOT wired hot - UNRELIABLE)

**Related Entities**:
- cover.garage_north_door (ratgdo ESP device)
- cover.garage_south_door (ratgdo ESP device)
- binary_sensor.garage_walk_in_door (Aqara)

**Options**:
A. Automation workaround (quick but unreliable)
B. Inovelli VZM31-SN switches (better - smart bulb mode)
C. Hardwire power to all fixtures (best - requires electrical work)

**Related Learning**: [2026-01-16 16:35] Home garage lighting priority fix

### UNAVAILABLE SCRIPTS
Many Alaina/Ella scripts show "unavailable" (likely orphaned from sed disaster):
- script.wake_up_alaina*
- script.bedtime_alaina*
- script.wake_up_ella*
- script.bedtime_ella*

**Action Needed**: Review and either restore or delete

## ZONE ENTITIES

### zone.home
- **Address**: 40154 US Hwy 53, Strum, WI
- **Coordinates**: 44.4244967, -91.2111594
- **Radius**: 60m
- **Fixed**: [2026-01-16 18:01] ChatGPT corrected coordinates

### zone.home_40154_hwy_53
- **Status**: DUPLICATE - needs cleanup
- **Action**: Should be removed (zone.home is primary)

### zone.michelle_house (NEEDS CREATION)
- **Address**: 40062 US Hwy 53
- **Status**: NOT YET CREATED
- **Priority**: Tier 1
- **Purpose**: Distinguish Michelle's location from John's

## NETWORK INFRASTRUCTURE

### device_tracker.goetting_wifi
- **Type**: UniFi AP (infrastructure device, NOT person)
- **Location**: 40062 US Hwy 53
- **SSID**: "Goetting"
- **Clients**: 16 connected
- **Related Learning**: [2026-01-16 16:49] Goetting WiFi = 40062 ONLY

### sensor.goetting_wifi_uplink_mac
- **Value**: ac:8b:a9:5c:a4:9f
- **Purpose**: Shows UBB bridge connection

## CALENDAR ENTITIES

### calendar.alaina_ella
- **ID**: 2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com
- **Status**: Restored [2026-01-16]
- **Purpose**: Shared calendar for daughters
- **Related Learning**: [2026-01-16] Google Calendar integration restored

## NEXT STEPS FOR ENTITY MAPPING

1. Create automated entity->learning linkage
2. Add "why this exists" annotations
3. Map automations to entities they control
4. Identify orphaned/unused entities
5. Create visual relationship map

