# Session Learnings - 2026-01-19
## Adaptive Lighting System Build

### Architecture Created
```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ADAPTIVE LIGHTING SYSTEM                             │
├─────────────────────────────────────────────────────────────────────────┤
│ MANAGED LAMPS (all in AL "Living Spaces" config):                       │
│   - light.entry_room_hue_color_lamp                                     │
│   - light.kitchen_lounge_lamp                                           │
│   - light.living_room_east_floor_lamp                                   │
│   - light.living_room_lounge_lamp                                       │
│   - light.very_front_door_hallway                                       │
├─────────────────────────────────────────────────────────────────────────┤
│ BEHAVIOR MATRIX:                                                        │
│                                                                         │
│ Condition          │ Auto-On      │ Max Bright      │ Hard Off          │
│ ───────────────────┼──────────────┼─────────────────┼─────────────────  │
│ School tomorrow    │ Dusk+motion  │ 100%→30%@21:30  │ 22:30             │
│ No school tomorrow │ Dusk+motion  │ 100%→30%@22:30  │ 23:30             │
│ Extended evening   │ Dusk+motion  │ 100%            │ 00:30             │
│ Nobody home        │ Motion only  │ Per AL          │ 30-45 min timer   │
│ Dad bedtime on     │ No auto-on   │ Fade→off 15min  │ Immediate         │
│ Hot tub mode       │ Red 5%       │ Red 5%          │ Manual/auto       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Files Created/Modified

| File | Purpose |
|------|---------|
| `/config/packages/adaptive_lighting_entry_lamp.yaml` | Entry room lamp + hot tub mode + extended evening helpers |
| `/config/packages/adaptive_lighting_kitchen_lounge_lamp.yaml` | Kitchen lounge lamp automation |
| `/config/packages/adaptive_lighting_living_room.yaml` | Living room lamps + global everyone-leaves |
| `/config/customize.yaml` | Door sensor friendly names added |
| `/config/dashboards/lovelace-mobile.yaml` | Hot Tub button added |

### New Entities

**Input Booleans:**
- `input_boolean.hot_tub_mode` - Privacy mode, deep red 5%
- `input_boolean.extended_evening` - Auto-set weekends/holidays/guests
- `input_boolean.living_room_manual_override` - Override for living room

**Input Numbers:**
- `input_number.entry_room_lux_threshold` - Default 50 lux
- `input_number.kitchen_lounge_lux_threshold` - Default 50 lux  
- `input_number.living_room_lux_threshold` - Default 50 lux

**Template Sensors:**
- `sensor.entry_room_average_lux` - Averages east/west nightlight sensors
- `sensor.kitchen_lounge_average_lux` - Averages available sensors
- `sensor.evening_lamp_off_time` - Dynamic: 22:30/23:30/00:30
- `sensor.evening_lamp_max_brightness` - 100% or 30% based on time

### Automations Created (17 total)

**Per-Room Pattern (Entry, Kitchen Lounge, Living Room):**
- `{room}_lamp_adaptive_lux_control` - Main motion/lux/mode logic
- `{room}_lamp_off_after_no_motion` - 30-45 min timeout
- `{room}_lamp_hard_off_at_evening_end` - Dynamic off time
- `{room}_lamp_off_when_everyone_leaves` - Presence-based

**Global:**
- `global_all_adaptive_lamps_off_when_everyone_leaves` - Master switch
- `extended_evening_auto_set_for_weekends_holidays` - Fri/Sat + holidays
- `extended_evening_auto_clear_at_4am` - Daily reset
- `hot_tub_mode_auto_reset_at_3am` - Safety reset
- `hot_tub_mode_auto_off_when_back_inside` - Door closed 10 min

### Door Sensor Mapping

| Entity | Location |
|--------|----------|
| `binary_sensor.aqara_door_and_window_sensor_door` | Back Patio Door |
| `binary_sensor.aqara_door_and_window_sensor_door_2` | Very Front Door |
| `binary_sensor.aqara_door_and_window_sensor_door_3` | Garage Walk-in Door |
| `binary_sensor.aqara_door_and_window_sensor_door_4` | Front Driveway Walk-in Door |
| `binary_sensor.aqara_door_and_window_sensor_door_5` | Garage South Bay Door |
| `binary_sensor.aqara_door_and_window_sensor_door_6` | Garage North Bay Door |

### Disabled/Deprecated

- `automation.first_person_home_after_dark_entry_lights_on` - Disabled (conflicts with new adaptive)
- `automation.everyone_away_all_lights_off` - Orphan entity (unavailable, never triggered)

### Issues Found

1. **Back yard camera** - `binary_sensor.back_yard_person_detected` not triggering on motion. UniFi Protect issue to investigate separately.

2. **Hot tub auto-off timing** - Fixed with periodic check backup (every 5 min) in addition to door state trigger.

### Testing Notes

- Hot tub mode: Both lamps go to red 5% ✓
- Hot tub off: AL restores (tested at 3076K warm white) ✓
- School tomorrow = on → evening off time = 22:30 ✓
- Extended evening auto-sets on Fri/Sat at 18:00

### Scaling Pattern

To add a new room:
1. Create `/config/packages/adaptive_lighting_{room}.yaml`
2. Add lux threshold input_number
3. Add average lux template sensor (if multiple sensors)
4. Add manual override input_boolean
5. Copy automation pattern: adaptive_control, no_motion_off, hard_off, everyone_leaves
6. Add lamp to `global_everyone_left_lamps_off` action
7. Add lamp to `adaptive_lighting.yaml` Living Spaces config (if not already)

### Next Steps / Future Improvements

- [ ] Fix back yard camera person detection
- [ ] Add kitchen lounge ceiling to AL (currently only Inovelli controlled)
- [ ] Consider adding very_front_door_hallway to motion-based control
- [ ] Review living room lux sensor options (currently using motion only, no lux)
- [ ] Test extended evening auto-set on Friday

---

## Updates - Later in Session

### Enhanced Logic Added

**Evening Off Time now factors kids presence:**
- Kids home + school tomorrow → 22:30
- Kids home + no school → 23:30
- Kids NOT home → 23:30 (regardless of school_tomorrow)
- Extended evening/guest → 00:30
- Hot tub mode → 01:00

**Hot Tub Mode additional off triggers:**
- Nobody home (`someone_home` = off) → immediate off
- Door closed 10 min (existing)
- 3am safety reset (existing)

**New Arrival Automation:**
`arrival_adaptive_lighting_welcome` triggers on:
- Person arrives home (John, Alaina, Ella)
- Garage door opens
- Front doors open (very front, front driveway walk-in)

Conditions: Dark + lux < 50 + not hot tub + not bedtime

**Global AL Off:**
`adaptive_lighting_global_off` turns off AL switch when:
- Nobody home
- Hard off time reached (unless hot tub mode)

### Final Automation Count: 19

| Automation | Purpose |
|------------|---------|
| `arrival_adaptive_lighting_welcome` | Welcome light on arrival |
| `adaptive_lighting_off_when_nobody_home_or_late_night` | Global AL switch control |
| `entry_room_lamp_adaptive_lux_control` | Entry lamp main logic |
| `entry_room_lamp_off_after_no_motion` | 30 min timeout |
| `entry_room_lamp_hard_off_at_evening_end` | Dynamic off time |
| `entry_room_lamp_off_when_everyone_leaves` | Presence based |
| `kitchen_lounge_lamp_adaptive_lux_control` | Kitchen lamp main logic |
| `kitchen_lounge_lamp_off_after_no_motion` | 30 min timeout |
| `kitchen_lounge_lamp_hard_off_at_evening_end` | Dynamic off time |
| `kitchen_lounge_lamp_off_when_everyone_leaves` | Presence based |
| `living_room_lamps_adaptive_control` | Living room main logic |
| `living_room_lamps_off_after_no_motion` | 45 min timeout |
| `living_room_lamps_hard_off_at_evening_end` | Dynamic off time |
| `living_room_lamps_off_when_everyone_leaves` | Presence based |
| `global_all_adaptive_lamps_off_when_everyone_leaves` | Master lamp switch |
| `extended_evening_auto_set_for_weekends_holidays` | Fri/Sat 18:00 |
| `extended_evening_auto_clear_at_4am` | Daily reset |
| `hot_tub_mode_auto_reset_at_3am` | Safety reset |
| `hot_tub_mode_auto_off_when_done` | Door/presence based |

### Disabled Automation
- `first_person_home_after_dark_entry_lights_on` - Replaced by `arrival_adaptive_lighting_welcome`

---

## Motion Aggregation & Progressive Dimming

### New Package Created
`/config/packages/motion_aggregation.yaml`

### Room-Level Motion Sensors (combined P1 + Third Reality)

| Sensor | Sources |
|--------|---------|
| `binary_sensor.entry_room_motion` | entry_room_east/west_wall_nightlight |
| `binary_sensor.kitchen_lounge_motion` | P1_1 + kitchen_lounge_east_wall nightlights |
| `binary_sensor.kitchen_motion` | kitchen_counter + kitchen_west nightlights |
| `binary_sensor.1st_floor_bathroom_hallway_motion` | P1_3 + 1st_floor_bathroom nightlight |
| `binary_sensor.front_door_hallway_motion` | P1_6 + very_front_door P1 |
| `binary_sensor.upstairs_hallway_motion` | P1_2 + upstairs_hallway nightlights |
| `binary_sensor.upstairs_bathroom_motion` | upstairs_bathroom nightlight |
| `binary_sensor.living_room_motion` | living_rm_loungemotionaware_area |

### Aggregate Sensors

| Sensor | Coverage |
|--------|----------|
| `binary_sensor.downstairs_motion` | All first floor rooms |
| `binary_sensor.upstairs_motion` | All second floor rooms |
| `binary_sensor.house_motion_any` | Entire house including basement |

### P1 Sensor Mapping

| Entity | Location |
|--------|----------|
| `aqara_motion_sensor_p1_occupancy` | Kitchen Lounge |
| `aqara_motion_sensor_p1_occupancy_2` | Upstairs Hallway |
| `aqara_motion_sensor_p1_occupancy_3` | 1st Floor Bathroom Hallway |
| `aqara_motion_sensor_p1_occupancy_6` | Front Door Hallway |

### Progressive Dimming Pattern
```
Motion detected     → Lamp ON at AL brightness
No motion 15-20 min → Dim to 20%
No motion 30-45 min → OFF
```

| Room | Dim Time | Off Time |
|------|----------|----------|
| Entry Room | 15 min | 30 min |
| Kitchen Lounge | 15 min | 30 min |
| Living Room | 20 min | 45 min |

### Final Automation Count: 23

**Per-Room (Entry, Kitchen Lounge, Living Room):**
- `{room}_lamp_adaptive_lux_control`
- `{room}_lamp_dim_after_Xmin_no_motion` (NEW)
- `{room}_lamp_off_after_no_motion`
- `{room}_lamp_hard_off_at_evening_end`
- `{room}_lamp_off_when_everyone_leaves`

**Global:**
- `arrival_adaptive_lighting_welcome`
- `adaptive_lighting_global_off`
- `global_all_adaptive_lamps_off_when_everyone_leaves`
- `extended_evening_auto_set/clear`
- `hot_tub_mode_auto_reset/auto_off`

### Best Practices Implemented

1. **Sensor Selection:** P1 for fast occupancy, Third Reality for motion+lux
2. **Aggregation:** Room-level combines multiple sensors, floor-level for presence
3. **30-second delay_off:** Prevents flapping on brief motion gaps
4. **Progressive dimming:** Gradual transition feels natural, saves energy
5. **No loop triggers:** Lights don't trigger sensors that control them
