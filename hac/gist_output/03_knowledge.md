# System Knowledge - 2026-02-26 13:03

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
4. Consider ALSO adding via HomeKit Controller (exposes different device subset)

RESEARCH NOTES:
- Use BOTH Matter + HomeKit integrations (different devices exposed)
- M3 acts as Thread Border Router (extends mesh)
- IR blaster does NOT expose to HA
- Locks only via Matter, some sensors only via HomeKit
- Pet feeders need Zigbee2MQTT direct pairing
- 10:28: Matter recommission fix: Remove stale fabric from BOTH HA Matter integration AND Aqara Connected Ecosystems, then re-pair fresh. VLAN separation (IoT vs Default) not the issue - mDNS working across subnets.
- 10:55: Bathroom humidity fan best practice: Use derivative sensor (3 min window) for shower detection instead of absolute threshold. Triggers: rising >2%/min OR absolute >70%. Safety: 30 min max runtime, HA restart recovery, wait_for_trigger with timeout. Blackshome blueprint is community gold standard.
- 10:55: Entity naming: ZHA devices get generic entity_ids like inovelli_vzm35_sn_fan. Rename via ha_rename_entity to location-based IDs (e.g. fan.2nd_floor_bathroom_exhaust_fan) for maintainability. Device names are separate from entity IDs.
- 10:55: Matter recommission fix: Remove stale fabric from BOTH HA Matter integration AND Aqara Connected Ecosystems, then re-pair fresh. VLAN separation (IoT vs Default) not the issue - mDNS working across subnets.
- 11:59: VZM35-SN exhaust fan: Hardware auto-off (param 12) = 2700s provides firmware-level safety backup independent of HA. Community strongly recommends for defense-in-depth. Fan timer display (param 121) not needed when automation handles humidity - changes paddle UX. Inovelli in-switch humidity sensors inadequate for shower detection (8% vs 58% rise vs dedicated Aqara).
- [2026-02-26 12:40] GENERAL: INOVELLI Testing repeat detection for smart bulb mode
- [2026-02-26 12:40] GENERAL: TEST This is a test entry that should not trigger warning
- [2026-02-26 12:40] GENERAL: Simple learning without category
- [2026-02-26 12:41] INOVELLI: param 52 needs air gap after toggle
- [2026-02-26 12:44] HAC: v9.1 upgrade: CRITICAL_RULES.md at root, structured hac learn with categories and repeat detection, 67→10 root files, archive/sessions/projects/knowledge structure
- [2026-02-26 12:54] GIT: git gc --prune=now fixes confused by unstable object errors - happens frequently on HA Green
- [2026-02-26 12:56] GIT: Pre-commit hook at .git/hooks/pre-commit auto-runs git gc to prevent unstable object errors

## Historical Learnings (last 30 lines)
- 17:03: AL cleanup: removing entry_room_hue_color_lamp from Living Spaces (duplicate - has dedicated instance), fixing separate_turn_on_commands on Entry Room Lamp Adaptive
- 17:23: fxlt blueprint fix: added event_data.device_id filter to trigger - prevents firing on all 49 ZHA device events, now only fires for specific switch
- 19:21: Session complete: AL deduplication + fxlt blueprint event_data filter fix. Inovelli double-fires eliminated (132x/hr → 0)
- 19:26: Area cleanup: deleted empty sun_room area, keeping living_room_lounge as canonical name for that space
- 21:25: Inovelli Best Practices Audit (2026-02-24): Smart Bulb Mode switches require Output Mode=OnOff + Button Delay=0 for instant response. Fixed: 1st Floor Bath Ceiling (Dimmer→OnOff), Button Delay→0 on Entry Room, Kitchen Lounge, Kitchen Chandelier, Above Sink, 1st Floor Bath, Back Patio, 2nd Floor Bath Ceiling. Confirmed correct: Kitchen Bar Pendants/Under Cabinet/Ceiling Cans (dumb LEDs) have SBM=OFF + Dimmer mode. VZM35 exhaust fan correct with SBM=OFF + OnOff. Key insight: SBM=ON + Output=OnOff + Delay=0 = fastest smart bulb response.
- .storage files have strict internal schemas
- Validation happens at Core startup, NOT at write time
- File appeared valid but Core rejected it on load
- Result: Only 8 of 56 integrations loaded (degraded state)
- `.storage/core.config_entries` - Integration registry
- `.storage/core.entity_registry` - Entity definitions
- `.storage/core.device_registry` - Device definitions
- Adaptive Lighting: Create/delete entries
- ZHA: Device pairing, network settings
- Hue: Bridge linking
- Any integration config flow
- `hac_snapshot "name"` - Create backup before risky ops
- `hac_rollback` - List HAC snapshots for restore
- Entry Room Hue color bulbs installed but automation not updated
- Entry Room Adaptive Lamp needs light.entry_room_hue_color_lamp added via UI
- 21:19: Living Room A/V: Fire TV=media_player.living_room_tv, automations fixed, Klipsch settings applied, dashboard at /living-room
- 21:24: Entry Room Inovelli double-fire fix: mode queued→single, max_exceeded silent. ZHA sends duplicate events ~28ms apart.hac learn Entry Room Inovelli double-fire fix: mode queued→single, max_exceeded silent. ZHA sends duplicate events ~28ms apart.
- 21:24: Entry Room Inovelli double-fire fix: mode queued→single, max_exceeded silent. ZHA sends duplicate events ~28ms apart.
- 23:20: Switched AVR automations from Alexa (media_player.living_room_tv) to ADB (media_player.living_room_fire_tv_192_168_1_17) for local reliability
- 23:48: Fire TV ADB app launch: Working: YouTube (source), Netflix (am start), Hulu (monkey), Spotify (source), Plex (monkey com.plexapp.android), HDHomeRun (monkey com.silicondust.view), Peace Lutheran (Silk browser URL). NOT WORKING: Prime Video (source select fails), Hudl (monkey com.hudl.fanexperience fails). Tabled for later.
- 08:27: DOUBLE-FIRING ROOT CAUSE: fxlt Inovelli blueprint triggers on ALL zha_event, filters by device_id in condition. Each press fires all automations using that blueprint. 14x/hr = normal when 3 bathroom automations share blueprint. Fix: removed logbook.log noise. Future: migrate to per-device-id trigger or unified blueprint
- 11:31: AL YAML vs Storage: YAML defines config but AL stores runtime in .storage/core.config_entries. YAML changes need storage edit or delete/re-add integration. Direct edit: ha core stop, backup .storage/core.config_entries, sed lights array, ha core start.
- 11:36: AL Living Spaces expanded: 4→7 lights. Added west_floor_lamp, kitchen_lounge_lamp, kitchen_above_sink_light. Verified working 2026-02-21.
- 12:32: Phase 1 COMPLETE 2026-02-21: All 133 lights have area assignments. AP LED corrections: 2nd_floor_ap→master_bedroom, 1st_floor_ap→kitchen_lounge, tower_flex→back_patio, garage_ap→garage. Unavailable Hue triaged (power issues, not HA). Kitchen 3-way confirmed working (Smart Bulb Mode OFF for dumb loads). Phase 2 ready: entity renames, blueprint migration, AL expansion.
- 13:17: HAC v9 COMPLETE 2026-02-21: Implemented token-efficient 3-tier context system. CONTEXT.md+RESOURCES.md for structured loading. knowledge/ dir for patterns/gotchas/decisions. hac sync combines export+sheets. Recent Learnings tab adds parsed content to LLM Index. ~60% token reduction in hac mcp output.
