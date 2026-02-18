# Lighting Audit Handoff
*Created: 2026-02-18 | Last Updated: 2026-02-18 11:15*

## Phase 1 Status: IN PROGRESS

### Completed ✅
1. Backup registry files (core.entity_registry, core.device_registry)
2. Fixed 2 typo entity_ids:
   - `front_drivay` → `light.front_driveway_inovelli` (area: front_driveway)
   - `smart_ligjt` → `light.living_room_tv_led_strip` (area: living_room)
3. Bulk area assignments: **~38 lights assigned** including:
   - Alaina's bedroom: LED strips, bedside lamp, ceiling candles (5 entities)
   - Ella's bedroom: wall light, bedside lamp, ceiling lights 1-3, LED strip (7 entities)
   - Master bedroom: wall light, room group, LED strip (3 entities)
   - Upstairs hallway: group + 3 ceiling candles + nightlight (5 entities)
   - 2nd floor bathroom: group + 5 vanity/ceiling bulbs + Inovelli switch + fan (8 entities)
   - Back patio: steps light, group (2 entities)
   - Garage: group, nightlight (2 entities)
   - Very front door: group, hallway (2 entities)
   - Living room: TV LED strip, 2 nightlights (3 entities)
   - Misc: stairway cubby nightlight, basement nightlight

### Remaining Phase 1 Work
- [ ] `light.back_door_patio_light_inovelli_switch` → back_patio
- [ ] `light.1st_floor_bathroom_ceiling_lights_dimmer_switch_inovelli_vzm31_sn` → 1st_floor_bathroom
- [ ] Check remaining ~20 lights for area assignment gaps
- [ ] Living room lounge ceiling individual bulbs
- [ ] Garage individual Hue bulbs (currently unavailable)
- [ ] Very front door individual Hue bulbs

### Phase 2 (Future Session)
- Entity_id rename for generic hue_ prefixes
- Unavailable entity triage (11+ lights)
- Blueprint migration for Inovelli controls
- Fix misassigned devices (Living Room Lounge → sun_room noted earlier)

## Git Commits
- `1b963d6` fix: rename typo entity_ids (front_drivay, smart_ligjt) + assign areas
- (pending) feat: bulk area assignments for ~38 light entities

## Quick Resume Commands
```bash
# Check current light area status
cd /homeassistant && hac mcp

# Continue area assignments via MCP
# Use ha_get_entity to check, ha_set_entity to assign
```

## Notes
- Entry room nightlights already had area assignments
- kitchen_counter_night_light is actually in stairway cubby (friendly_name: Stairwell_Night_Light)
- kitchen_west_wall_nightlight is actually in basement (friendly_name: Basement_Third Reality_Nightlight)
- alaina_s_led_light_strip_2 is hidden by integration (duplicate?)
