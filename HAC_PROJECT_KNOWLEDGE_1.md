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

## S3 SESSION LEARNINGS — 2026-04-08

### HUE ENTITIES
- 31 individual Hue bulb entities disabled. ALWAYS target zone/room group entities in automations: light.kitchen_lounge, light.ella_s_ceiling_lights, light.kitchen_chandelier, etc. Re-enable individually if needed.
- Hue V2 API: HTTPS only (HTTP → 301). Entity disable: MCP ha_set_entity(enabled=false) works. Supervisor PATCH /api/config/entity_registry returns 405. Vanity slugs use 1of3 not 1_of_3. Bridge API key appeared in session — ROTATE IT.
- Blink audit protocol: turn_off light.whole first, then turn_on each room at 60% — NO color_temp param (Hue groups reject it → 400 Bad Request). Confirmed rooms: Entry, Kitchen, Kitchen Lounge, Living Room, Living Room Lounge, 1st Floor Bathroom.

### KITCHEN LIGHTING
- Tier 2 dimmers (ceiling cans + bar pendants): time-aware 06-19=80%, 19-22=30%, 22-06=15%. Respects input_boolean.kitchen_manual_override. Double-tap UP on any kitchen Inovelli = override, auto-clears 12min no motion.
- Hot tub mode now pauses ALL 3 kitchen motion automations via automation.hot_tub_mode_pause_resume_kitchen_motion_automations. Re-enables on hot_tub_mode OFF (manual, 3am reset, or back-inside trigger).

### YAML EDITING
- Multi-target sed replace (3 entity IDs → same target) creates duplicate YAML mapping keys in scene dicts. Fix with Python dedup pass — not sed. Always grep -c for remaining duplicates after any multi-target replace.
- ha core check: KeyError triggers = known 2026.4 startup-timing false positive. Real signal = "Successful config (partial) → automation:". map/packages General Warnings are cosmetic.

### HAC SYSTEM
- hac.sh is NOT committed to git — lives only in container, wiped on HAOS updates. Needs rebuild after each HAOS reinstall. Learnings can be written directly to HAC_PROJECT_KNOWLEDGE_1.md as fallback.
- hac symlink: ln -sf /config/hac.sh /usr/local/bin/hac (only works if hac.sh exists first)

### S3 COMMIT
- 1d75d20 pushed to main. 10 files changed, 311 insertions, 567 deletions.
- Remaining: 11 rooms in blink audit, Hue switch automations (0 exist), missing scenes, ella_bedroom stale ref (light.ella_s_ceiling_light_1_of_3 in ella_school_night_bedtime condition — harmless but stale).

### [2026-04-08 00:02] HUE
- Individual Hue bulb entities disabled (31). Always target zone/room group entities: light.kitchen_lounge, light.ella_s_ceiling_lights, light.kitchen_chandelier, etc.

### [2026-04-08 00:02] HUE
- Hue V2 API HTTPS only. Entity disable: MCP ha_set_entity(enabled=false). Supervisor PATCH returns 405. Slugs use 1of3 not 1_of_3. Bridge API key appeared in session — ROTATE IT.

### [2026-04-08 00:02] KITCHEN
- Tier 2 dimmers time-aware: 06-19=80%, 19-22=30%, 22-06=15%. Respects input_boolean.kitchen_manual_override. Double-tap UP = override, auto-clears 12min no motion.

### [2026-04-08 00:02] HOT_TUB
- Hot tub mode pauses ALL 3 kitchen motion automations via automation.hot_tub_mode_pause_resume_kitchen_motion_automations. Re-enables on hot_tub_mode OFF.

### [2026-04-08 00:02] YAML
- Multi-target sed replace → duplicate YAML keys. Fix with Python dedup pass. Always grep -c duplicates after multi-target replace.

### [2026-04-08 00:02] HA_CHECK
- KeyError triggers in ha core check = 2026.4 false positive. Real signal = Successful config partial. map/packages warnings cosmetic.

### [2026-04-08 00:02] ROOM_AUDIT
- Blink audit: turn_off light.whole first, turn_on at 60% NO color_temp (Hue groups 400). Confirmed: Entry, Kitchen, Kitchen Lounge, Living Room, Living Room Lounge, 1st Floor Bathroom.

### [2026-04-08 00:02] HAC_SYSTEM
- hac.sh NOT committed to git — wiped on HAOS updates. Rebuild with: cat > /config/hac.sh (recreate script), chmod +x, ln -sf to /usr/local/bin/hac. Always commit hac.sh after rebuild.
