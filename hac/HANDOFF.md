# HANDOFF — S37 complete | 2026-04-17

## Current State Summary

### Automation Migration: COMPLETE
- 159 automations in UI storage, 0 ghosts, 0 unavailable
- All automation package files migrated and deleted (S23–S26)
- Zero `unique_id: auto_` contamination

### Package Files Remaining (14 — all template/infrastructure, NO automations)
adaptive_lighting_entry_lamp.yaml, ap_presence_hybrid.yaml, aqara_sensor_names.yaml,
climate_analytics.yaml, family_activities.yaml, garage_door_alerts.yaml,
garage_motion_combined.yaml, john_proximity.yaml, motion_aggregation.yaml,
occupancy_system.yaml, presence_display.yaml, presence_system.yaml, wifi_floor_presence.yaml
Top-level keys: template:, homeassistant: (customize), alert:, sensor:, zone:
Decision needed: keep as YAML spine or migrate template sensors to UI helpers

### Organization (S30–S37)
- 4 floors created (Outdoors, 1st Floor, 2nd Floor, Basement)
- 12 areas created (of ~25 planned — see missing list below)
- 12 labels created (all from master plan spec)
- ~1,200 entities labeled and area-assignment planned (S37)
- Entity discovery complete: Kitchen, Living Room, Bedrooms, Bathrooms, Garage, Entry Room, Master Bedroom, Upstairs Hallway, Laundry, Basement

### Helpers: 93 total
input_boolean: 51 | input_number: 10 | input_select: 6 | input_text: 2
input_datetime: 16 | timer: 4 | counter: 4
Status: Unknown how many are YAML vs UI — audit needed before migration

### Infrastructure
- SSH key-only auth complete (S26 security session)
- BREAK_GLASS restore runbook created
- CRITICAL_RULES_CORE updated with NEVER rules + helper label verification
- Cloudflare tunnel on EQ14 (61f4b989), external: ha.myhomehub13.xyz

## Missing Areas (from master plan, not yet created)
Kitchen Lounge, Stairway Cubby, Smart Home AV, Attic,
Basement (main), Basement Hallway, Laundry Area, Boiler Room, Workout Area,
Very Front Door, Front Driveway, Back Patio, Back Yard Tower, Pigeon Falls Properties
Note: generic "Bedroom" area exists — should be repurposed or deleted

## Resolved (previously tabled)
- ✅ WAYA softball calendar IDs — both input_text helpers populated
- ✅ upstairs_lighting.yaml — deleted S26 (was already empty)
- ✅ kids_bedroom_automation.yaml + ella_living_room.yaml — deleted S26
- ✅ humidity_smart_alerts.yaml — deleted S26 (rebuild still pending)
- ✅ notifications_system.yaml — deleted S26

## Tabled (carried forward)
- Person trackers: Ella (unknown), Michelle (unknown). Michelle MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen 192.168.21.233: OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66
- humidity_smart_alerts: YAML deleted, UI rebuild pending
- Aqara sensor gap: 6 door + 4 P1 motion sensors need EQ14 entity ID hunt
- first_floor_hallway_motion delay_off bug in lighting_motion_firstfloor.yaml
- 6 Ella bedroom scenes missing
- HA Green full config audit before wipe
- Security session: Cloudflare ZT + PAT rotation (~30 min dedicated)

## Next Priorities
1. Complete S37 area assignments (bulk ha_set_entity area_id across 11 pools)
2. Create missing areas (14 remaining from master plan)
3. YAML helper audit — determine which of 93 helpers are YAML vs UI
4. Helper migration to UI storage (S18 goal from master plan)
5. Dashboard rebuild (Phase 21)
