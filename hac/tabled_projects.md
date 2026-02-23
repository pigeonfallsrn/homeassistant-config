# Tabled Projects
*Updated: 2026-02-21*

## Infrastructure
- [ ] SSH key auth to Synology for gdrive sync (ha_to_synology.pub → admin@192.168.1.52)
- [ ] UniFi Protect motion events to HA

## Cleanup (Low Priority)
- [ ] Delete orphan garage automations: garage_all_lights_off_2, garage_door_handle_notification_actions, garage_door_opened_close_option, garage_door_opened_close_prompt, garage_door_opened_handle_actions
- [ ] Cleanup duplicate garage automations (north_door vs generic overlap)

## Future Enhancements  
- [ ] Phase 2 family_activities: Connect winddown sensors, add WAYA softball calendars
- [ ] Inovelli blueprint migration: fxlt → MasterDevwi unified (root cause found 2/21 - per-device triggers)

## Completed (Archive)
- [x] 2026-02-21: Add 3 lights to Living Spaces AL (expanded 4→7)
- [x] 2026-02-21: HA MCP Server Integration (active)
- [x] 2026-02-21: HAC v8.0→v8.1 (ACTIVE.md task tracking)
- [x] 2026-02-21: Double-trigger root cause (fxlt blueprint design)

## Recent Ideas (Mobile Capture)
- [x] Hot tub mode: dim/off living room lounge lamp when activated (blinding from patio)

## Living Room Mobile Dashboard (S24 Ultra)

**Status**: Tabled for future session
**Priority**: Medium
**Created**: 2026-02-23

### Requirements
1. **A/V Controls**
   - Fire TV power on/off
   - AVR volume slider + mute
   - Quick source buttons (Netflix, YouTube, Prime Video)
   - Movie Mode script button

2. **Lighting Controls**
   - Inovelli VZM36 Fan/Light module:
     - Light toggle with brightness
     - Fan speed: Off / Low / Medium / High
   - TP-Link behind-TV light strip (RGB control)
   - Floor Lamps (L/R of TV): `light.living_room_east_floor_lamp`, `light.living_room_west_floor_lamp`
   - Table Lamps: `light.living_room_lamp_1_of_2`, `light.living_room_lamp_2_of_2`
   - Hue group: `light.living_room_floor_lamps`, `light.living_room_table_lamps`

3. **Hue Scene Research Needed**
   - Movie/TV watching scenes (bias lighting concepts)
   - Ambient/relaxed scenes
   - Consider complementary colors for Hue Color bulbs
   - Behind-TV bias lighting best practices (6500K vs warm)

### Entity Reference
| Control | Entity |
|---------|--------|
| Fire TV | `media_player.living_room_fire_tv_192_168_1_17` |
| Fire TV Remote | `remote.living_room_fire_tv_192_168_1_17` |
| AVR | `media_player.basement_yamaha_av_receiver_rx_v671_main` |
| Subwoofer | `switch.living_room_subwoofer_plug` |
| Ceiling Fan/Light | `light.inovelli_vzm36_light_3` or `_4`, `fan.xxx` |
| Behind TV Strip | TBD - find TP-Link entity |
| East Floor Lamp | `light.living_room_east_floor_lamp` |
| West Floor Lamp | `light.living_room_west_floor_lamp` |
| Table Lamp 1 | `light.living_room_lamp_1_of_2` |
| Table Lamp 2 | `light.living_room_lamp_2_of_2` |
| Floor Lamps Group | `light.living_room_floor_lamps` |
| Table Lamps Group | `light.living_room_table_lamps` |

### ADB Commands for App Launch
```yaml
# Netflix
service: media_player.select_source
target:
  entity_id: media_player.living_room_fire_tv_192_168_1_17
data:
  source: "com.netflix.ninja"

# Prime Video
source: "com.amazon.avod"

# YouTube  
source: "com.amazon.firetv.youtube"
```

### Dashboard Type
- Mobile-optimized (S24 Ultra: 3088 x 1440)
- Consider: Mushroom cards, Bubble card, or custom grid layout
- Prioritize touch targets for one-handed use
