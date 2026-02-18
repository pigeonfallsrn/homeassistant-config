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
- [x] `light.back_door_patio_light_inovelli_switch` → back_patio
- [x] `light.1st_floor_bathroom_ceiling_lights_dimmer_switch_inovelli_vzm31_sn` → 1st_floor_bathroom
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

## Phase 1 Final Status: COMPLETE (2026-02-18 ~17:00)

### Area Assignments Complete ✅
- ~42 light entities now have proper area assignments
- All major lighting systems covered

### Remaining Unassigned (19 entities - categorized for Phase 2)

**Immediate Fixes (3):**
- [ ] `light.1st_floor_bathroom_vanity_lights` → 2nd_floor_bathroom (MISNAMED - actually VZM30 for 2nd floor)
- [ ] `light.ella_s_govee_floor_lamp` → master_bedroom (per session notes)
- [ ] `light.alaina_s_floor_govee_lamp` → kitchen (per session notes)

**Triage Needed (5):**
- [ ] `light.aqara_led_strip_t1` - unavailable, unknown location
- [ ] `light.aqara_led_strip_t1_2` - unavailable, unknown location
- [ ] `light.outside_4_west_lights` - Hue group, unclear purpose
- [ ] `light.toy_room_light` - Alexa Media, friendly_name "Kitchen Lamp"
- [ ] 3× Echo Glows - Alexa Media, no device_id (master/alaina/ella bedrooms)

**Skip - Infrastructure (11):**
- `light.whole` - Hue meta-group (all lights)
- 9× UniFi AP LEDs - network device status indicators
- 2× ratgdo lights - hidden by user, garage door openers

### Phase 2 Priorities
1. Entity_id renames (generic hue_color_lamp_*, hue_color_candle_*)
2. Unavailable entity triage (11+ lights)
3. Blueprint migration (fxlt → MasterDevwi or Ratoka)
4. Fix Living Room Lounge device → sun_room area assignment
