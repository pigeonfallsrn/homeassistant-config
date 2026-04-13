# Phases C, D, E — Renames, Scenes, Dependencies
## S13B | EQ14 Deployment Playbook

## Phase C: Entity Renames (55 total, per-group during migration)
Process per group:
1. ha_search_entities(area_filter="kitchen") — review entities
2. Check against naming convention: domain.area_descriptor
3. ha_rename_entity(entity_id="old", new_entity_id="new")
Common fixes: remove redundant domain words, add area prefix, standardize separators

## Phase D: Native Scenes (4 kitchen scripts → Scenes)
Kitchen Bright: chandelier 255/4000K, above_sink 255
Kitchen Cooking: chandelier 200/3500K, above_sink 255
Kitchen Dining: chandelier 128/2700K, above_sink off
Kitchen Evening: chandelier 64/2200K, above_sink off
NOTE: Get exact values from John during Group 2 session.

## Phase E: Group Dependencies
Group 0 Infrastructure: nothing (build first)
Group 1 Entry Room: Group 0, BP-2, BP-3, Hue Bridge, Apollo Entry ESPHome, AL instances
Group 2 Kitchen: Group 0, BP-2, BP-3, Hue, Apollo Kitchen (OTA first!), AL instances
Group 3 Living Room: Group 0, BP-2, Hue, AL living_spaces instance
Group 4 Garage: Group 0, ratgdo ESPHome x2, UniFi (BT HFL arrival trigger)
Group 5 Upstairs: Group 0, BP-3, BP-4, ZHA (VZM30-SN), AL upstairs instance
Group 6 Kids: Group 0 (presence), Group 5 (hallway lights for bedtime)
Group 7 Climate: Group 5 (fan helpers), Nest, Kumo Cloud
Group 8 Security: Group 0, Group 4, UniFi Protect
Group 9 AV: Group 3 (living room entities), Yamaha/Roku/Plex
Group 10 Notifications: Groups 0,4,8 (consolidates all notify.*)
Group 11 Utilities: All prior groups stable

## Integration Priority Order
1. Hue Bridge (Groups 1-3)
2. ESPHome ratgdo x2 (Group 4)
3. ESPHome Apollo Entry (Group 1)
4. ESPHome Apollo Kitchen — OTA flash first (Group 2)
5. UniFi + Protect (Groups 4,8)
6. Google Calendar (Group 6)
7. Nest (Group 7)
8-9. Spotify/Plex/Roku (Group 9)
10. Kumo Cloud (Group 7)
12. TP-Link Kasa
13. Sonos
15. Mobile App (Groups 0,10)
16. Fully Kiosk Browser
