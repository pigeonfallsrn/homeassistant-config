# Home Assistant HAC - Project Knowledge
*John Spencer's HA system context — reference file for Claude*
*For critical rules and workflow see: hac/CRITICAL_RULES.md*
*For dashboard work see: hac/KITCHEN_DASHBOARD_REFERENCE.md*

## System Overview
- **Platform:** HA Green, HA 2026.3.x
- **Scale:** ~4000 entities | ~35 areas | ~140 automations
- **Config path:** /homeassistant/ (NEVER /config/)
- **Git root:** /homeassistant/
- **HAC version:** v9.1
- **Knowledge system:** hac/CRITICAL_RULES.md (Tier 1) + hac/learnings/YYYYMMDD.md (Tier 2)

## Key Infrastructure
- **ZHA coordinator:** Sonoff 3.0 USB Dongle Plus (49 devices)
- **Hue:** Established groups for major rooms, bridge integration
- **Network:** UniFi Dream Machine Pro, VLANs (IoT: 192.168.21.x), zone-based firewall
- **Presence:** UniFi AP-based tracking + binary_sensor templates
- **Zigbee:** ZHA on Sonoff dongle
- **Matter:** Aqara Hub M3 (MUST be on UDM Pro Port 4 — Port 2 causes unavailable cycles)
- **Garage:** ratgdo32disco North (fd8d8c) + South (5735e8)
- **Audio:** Sonos + Music Assistant (use bare Spotify playlist IDs, not spotify:// URIs)
- **Govee:** Matter only — govee2mqtt LAN discovery confirmed dead end, do not retry

## Presence Entities
- John: person.john_spencer, device_tracker.galaxy_s26_ultra, binary_sensor.john_home
- Michelle: binary_sensor.michelle_actually_home ONLY (no companion app)
- Alaina: binary_sensor.alaina_home (working)
- Ella: binary_sensor.ella_home (unreliable — tracks iPad not iPhone, tabled)
- Combined: binary_sensor.someone_home, girls_home, both_girls_home, john_and_girls, full_house

## Notification Targets
- **Primary (confirmed):** notify.mobile_app_john_s_s26_ultra
- **Watch:** notify.mobile_app_john_s_galaxy_watch8_classic_s7me
- **RETIRED — never use:** notify.mobile_app_sm_s928u (S24 Ultra)

## SBM Switches (NEVER in light.turn_off actions)
kitchen_chandelier_inovelli, above_sink_inovelli, kitchen_lounge_inovelli_smart_dimmer,
entry_room_ceiling_inovelli, 1st_floor_bathroom_inovelli, back_patio_inovelli

## Adaptive Lighting Instances
living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway
Hue bulbs require: separate_turn_on_commands:true, take_over_control:true, detect_non_ha_changes:false

## Kitchen Tablet
- Dashboard: kitchen-wall-v2 (storage-mode, sections layout)
- Hardware: Samsung Galaxy Tab A9+, FKB Plus v1.60.1-play
- FKB device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Full reference: hac/KITCHEN_DASHBOARD_REFERENCE.md
- Work queue: hac/BACKLOG_kitchen_dashboard.md

## Calendar IDs
- Kids (Alaina/Ella): 2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com
- Personal: pigeonfallsrn@gmail.com
- John/Michelle: 2aa2d81010ff6a637e674c2cd23eb3e7a80e9dd48e8e30c50d6784c3cab86043@group.calendar.google.com
- Work: 8249v7qv8g2m6bjc8v37f78gs0@group.calendar.google.com
- Lions Club: 333e072f891daea9a8ffaba89d8e67fb16e89b74fe0a5cc06ad9e1be2e2d5edf@group.calendar.google.com

## MCP Tool Constraints (hard-won)
- ha_config_get_dashboard: requires force_reload:True for current state
- ha_config_set_dashboard: requires matching config_hash
- python_transform sandbox: no import, isinstance, str(), enumerate(), next(), any(), all(), try/except
- ha_config_get_automation: returns config:null for all UI-created automations
- ha_deep_search: may return stale cached index — cross-reference with terminal grep
- ha_rename_entity: only viable path for entity registry changes

## Learning Categories
MOTION, INOVELLI, AL, YAML, ZHA, HAC, MATTER, ENTITY, DASHBOARD, HACS, PRESENCE, NETWORK
