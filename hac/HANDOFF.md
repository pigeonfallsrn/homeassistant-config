# HANDOFF — S25 complete | 2026-04-16

## Completed this session (S25)

### Group 3 — hue_switches.yaml COMPLETE
hue_switches.yaml deleted (automation-only, 396 lines)
6 automations migrated to UI storage via create->remove_ghost->rename:
  automation.entry_room_tap_dial_switch
  automation.master_bedroom_tap_dial_switch
  automation.alaina_s_bedroom_dimmer_switch
  automation.ella_s_bedroom_dimmer_switch
  automation.garage_dimmer_switch
  automation.2nd_floor_bathroom_ceiling_switch_vzm30_sn
All 6 verified state:on with clean numeric UI storage IDs.

## S26 — START HERE

### Priority 1: Group 5 — upstairs_lighting.yaml
grep -n "^  - id:\|^    alias:" /homeassistant/packages/upstairs_lighting.yaml

## Package files remaining (6)
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml
Template-only stubs (not pending): kitchen_tablet_dashboard.yaml, lighting_motion_firstfloor.yaml

## Tabled (carried forward)
- Person trackers: Alaina, Ella, Michelle — none assigned. Michelle MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen 192.168.21.233: OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 -> Group 5
- humidity_smart_alerts unpause bug -> Group 7
- input_text alaina/ella WAYA softball calendar IDs -> Group 6
- Aqara sensor gap: 6 door + 4 P1 motion sensors need EQ14 entity ID hunt
- first_floor_hallway_motion delay_off bug in lighting_motion_firstfloor.yaml
- 6 Ella bedroom scenes missing -> Group 6
- HA Green full config audit before wipe
