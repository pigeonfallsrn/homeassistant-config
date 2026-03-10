# System Knowledge - 2026-03-10 09:52

## Architecture Quick Ref
- **Packages:** /config/packages/*.yaml
- **Presence:** input_boolean.john_home (NOT binary_sensor)
- **North garage door:** cover.ratgdo32disco_fd8d8c_door
- **South garage door:** cover.ratgdo32disco_5735e8_door  
- **Walk-in door sensor:** binary_sensor.aqara_door_and_window_sensor_door_3
- **Motion aggregation:** /config/packages/motion_aggregation.yaml
- **Automations:** /homeassistant/automations/ (NOT automations.yaml) - uses include_dir_merge_list
- **Config paths:** /homeassistant/ (not /config/), storage at /homeassistant/.storage/

## Critical Rules (from past disasters)
- NEVER use raw sed on YAML without backup
- ALWAYS use `hac sed` or `hac backup` first
- Check `ha core check` before restart
- Inovelli+Hue: Smart Bulb Mode must be ON
- ZSH: escape ! in strings, dont chain after python3 -c on same line
- HA CLI: ha command doesnt support services - use REST API, websocket, or UI

## Tabled Projects
# Tabled Projects
*Updated: 2026-02-21*

## Infrastructure
- [ ] SSH key auth to Synology for gdrive sync (ha_to_synology.pub → admin@[IP])
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

## Recent Session Learnings
- [2026-03-10 07:06] HAC: hac alias was missing from .zshrc after system update - fix: echo 'alias hac="/homeassistant/hac/hac.sh"' >> ~/.zshrc && source ~/.zshrc
- [2026-03-10 07:06] YAML: BusyBox grep on HA Green does not support --include flag - use: find /homeassistant/packages -name '*.yaml' | xargs grep pattern
- [2026-03-10 07:06] HAC: UI-created automations on HA Green are NOT in /homeassistant/.storage/ from terminal - storage is only accessible via MCP API or HA UI. ha_config_get_automation via MCP also fails for these - must use ha_config_set_automation to update by entity_id
- [2026-03-10 08:29] MOTION: Driveway motion lights need sunset+time cutoff condition - without it fires all night on wind/animals. Fix: add sun after:sunset AND time before:23:00 conditions
- [2026-03-10 08:55] MOTION: Garage lights auto-off uses dual automation pattern: Garage All Lights OFF (Fixed) on door-close + Garage Auto Off After No Motion with ~5min delay. Both working correctly - motion clears then 5min delay fires off. Do not fix what isnt broken.
- [2026-03-10 08:55] HAC: Garage ThirdReality motion sensors aggregate into binary_sensor.garage_motion_combined with delay_off - this is the correct pattern for garage auto-off. Motion cleared 8:30am, lights off 8:35am = 5min delay confirmed working.
- [2026-03-10 08:55] MOTION: Driveway camera has vehicle_detected and object_detected binary sensors in addition to motion - these fired correctly on arrival. Future: could use vehicle_detected as smarter trigger vs raw motion to reduce false positives from wind/animals overnight.
- [2026-03-10 08:58] MOTION: UniFi Protect vehicle_detected + person_detected = correct exterior trigger. 163:0 ratio vs raw motion overnight. AI filter eliminates wind/animals completely. Belt+suspenders: AI detection + sunset-23:00 window.
- [2026-03-10 08:58] MOTION: object_detected fires on animals/birds - not useful as primary trigger. Use vehicle_detected OR person_detected for driveways. motion sensor kept as fallback only.
- [2026-03-10 09:43] MOTION: Doorbell ring automation uses event.* entity trigger not binary_sensor — more reliable, carries confidence + zone metadata in attributes
- [2026-03-10 09:43] HAC: notify.mobile_app_sm_s928u = John's Galaxy S24 Ultra (S928U model) — verify in Companion App settings
- [2026-03-10 09:45] MOTION: Package detection uses binary_sensor (not event entity) — no simultaneous-detection conflict risk for package, and no event.* equivalent exists

## Historical Learnings (last 30 lines)
- [2026-02-26 12:56] GIT: Pre-commit hook at .git/hooks/pre-commit auto-runs git gc to prevent unstable object errors
- [2026-02-26 21:54] ENTITY: After renaming entities (e.g. fan.inovelli_vzm35_sn_fan → fan.2nd_floor_bathroom_exhaust_fan), grep ALL yaml files AND check API-based automations for stale references
- [2026-02-26 21:54] MOTION: Bathroom fan override: Use state-based reset (bool on for 30min) not timer-based - simpler, one automation vs two
- [2026-02-26 21:54] HAC: Ghost entities (unavailable/restored) persist after YAML removal due to recorder DB - use recorder.purge_entities service AND hac purge, may need multiple restarts
- [2026-02-26 22:55] HAC: System audit 2/26: 75 orphan scripts, 19 orphan helpers, 4 dead automations. Presence refactor + Inovelli blueprint opportunities identified
- [2026-02-26 22:55] HAC: hac backup needs a filename to back up, not a label. Use HA backup for pre-phase snapshots
- [2026-02-26 22:58] HAC: System audit 2/26: 75 orphan scripts, 19 orphan helpers, 4 dead automations. Presence refactor + Inovelli blueprint opportunities identified
- [2026-02-26 22:58] HAC: hac backup needs a filename to back up, not a label. Use HA backup for pre-phase snapshots
- [2026-02-26 23:09] HAC: Migrated garage_motion_combined from legacy platform:template to modern template: syntax. Added unique_id. Fixes 2026.6 deprecation.
- 1x press → 33% (low)
- 2x press → 66% (medium)
- 3x press → 100% (high)
- Hold → off
- 16:27: 1st Floor Bathroom Inovelli automation was missing (ghost entity in registry). Created blueprint automation targeting light.1st_floor_bathroom Hue group with brightness_pct:100 on up-paddle.
- 16:27: Dumb light switches (direct load control) should have button_delay=0 for instant response - no need for multi-tap scene detection. Applies to: Kitchen Ceiling Cans, Under Cabinet, Bar Pendants.
- 16:27: Blueprint Inovelli automations calling light.turn_on without brightness_pct will restore last dimmed state. Always include brightness_pct:100 in up-paddle action to ensure full brightness on single press.
- 16:33: Inovelli VZM31-SN sends 3 zha_events per button press: level cluster (on/off) + scene cluster (button_X_press). Blueprint triggers on all but only matches scene commands. mode:single + max_exceeded:silent prevents actual duplicate actions. 'Double-fire' warnings are phantom triggers - harmless noise, not real duplicates.
- 16:45: Config button best practices: 1) Fan control (1x/2x/3x=speeds, hold=off), 2) Robot vacuum trigger, 3) Scene cycling, 4) Secondary device toggle. EP3 supports Zigbee binding for hub-independent control.
- 16:45: Kitchen dumb switch flicker/slow fix: Ceiling Cans had on_off_transition_time=5 (5 sec!), Bar Pendants had min_dim=1 causing turn-off flicker. Fix: transition_time=0 for instant, min_dim=15+ to avoid LED driver flicker zone.
- 16:50: Inovelli dumb switch slow on/off fix: on_off_transition_time controls Zigbee commands, but LOCAL_RAMP_RATE controls physical paddle. Ceiling Cans had local_ramp_rate_on_to_off=102 (102 sec!). Set all local_ramp_rate params to 0 for instant response.
- 16:50: Inovelli LED flicker at turn-off: caused by minimum_load_dimming_level too low. LED drivers flicker in low-dim zone. Bar Pendants fixed by raising min_dim from 1 to 25. Start at 15, increase if still flickering.
- 16:54: Inovelli dumb switch slow on/off fix: on_off_transition_time controls Zigbee commands, but LOCAL_RAMP_RATE controls physical paddle. Ceiling Cans had local_ramp_rate_on_to_off=102 (102 sec!). Set all local_ramp_rate params to 0 for instant response.
- 16:54: Inovelli LED flicker at turn-off: caused by minimum_load_dimming_level too low. LED drivers flicker in low-dim zone. Bar Pendants fixed by raising min_dim from 1 to 25. Start at 15, increase if still flickering.
- 16:54: fxlt blueprint hold actions fire once per hold - use brightness_step_pct for single 10% step. For smooth continuous dimming, need repeat loop with input_boolean controlled by hold/release events. Ratoka blueprint (github.com/Ratoka/home-assistant-hue-inovelli-blueprints) provides this plus auto scene cycling.
- 16:58: Git "confused by unstable object source data" fix: run git gc --prune=now before commit. Caused by zigbee.db changing during git add. Prevention: add zigbee.db* to .gitignore or reset before AND after git add -A. Always use single quotes in ZSH commit messages to avoid ! expansion.
- 17:03: AL cleanup: removing entry_room_hue_color_lamp from Living Spaces (duplicate - has dedicated instance), fixing separate_turn_on_commands on Entry Room Lamp Adaptive
- 17:23: fxlt blueprint fix: added event_data.device_id filter to trigger - prevents firing on all 49 ZHA device events, now only fires for specific switch
- 19:21: Session complete: AL deduplication + fxlt blueprint event_data filter fix. Inovelli double-fires eliminated (132x/hr → 0)
- 19:26: Area cleanup: deleted empty sun_room area, keeping living_room_lounge as canonical name for that space
- 21:25: Inovelli Best Practices Audit (2026-02-24): Smart Bulb Mode switches require Output Mode=OnOff + Button Delay=0 for instant response. Fixed: 1st Floor Bath Ceiling (Dimmer→OnOff), Button Delay→0 on Entry Room, Kitchen Lounge, Kitchen Chandelier, Above Sink, 1st Floor Bath, Back Patio, 2nd Floor Bath Ceiling. Confirmed correct: Kitchen Bar Pendants/Under Cabinet/Ceiling Cans (dumb LEDs) have SBM=OFF + Dimmer mode. VZM35 exhaust fan correct with SBM=OFF + OnOff. Key insight: SBM=ON + Output=OnOff + Delay=0 = fastest smart bulb response.
