================================================================================
HOME ASSISTANT LIGHTING SYSTEM - SESSION HANDOFF
================================================================================
Date: 2026-01-27
User: John Spencer (pigeonfallsrn@gmail.com)
Location: Strum, Wisconsin

## SYSTEM OVERVIEW
- Home Assistant 2026.1.3 on Home Assistant Green
- ZHA coordinator: Sonoff 3.0 USB Dongle Plus (49 devices)
- Philips Hue integration for color bulbs
- Inovelli switches (VZM31-SN, VZM36) via ZHA
- Adaptive Lighting integration (4 instances)
- HAC v7.3 for context management

## VERIFIED WORKING (2026-01-27)
- Distance sensor: `sensor.john_distance_to_home` working (was reported stuck)
- All arrival automations ENABLED (not disabled as previously noted)
- AL Upstairs Zone configured and firing
- 147 automations in registry

## ADAPTIVE LIGHTING INSTANCES
1. **Living Spaces** - Entry lamp, living room floor lamps, very front door
2. **Upstairs Zone** - Upstairs hallway, 2nd floor bathroom (night red mode)
3. **Entry Room Ceiling Lights** - Disabled
4. **Bedroom lighting test** - Master bedroom testing

## KEY AUTOMATION LOCATIONS
```
/homeassistant/
├── configuration.yaml          # Main config, includes packages
├── adaptive_lighting.yaml      # AL instances
├── automations/                # Automation YAML files
│   ├── bathroom_motion_lighting.yaml
│   ├── kitchen_tablet_wake.yaml
│   ├── tablet_power.yaml
│   └── ui_automations.yaml
└── packages/                   # 23 packages
    ├── adaptive_lighting_*.yaml
    ├── upstairs_lighting.yaml
    ├── lights_auto_off_safety.yaml
    ├── occupancy_system.yaml
    └── presence_system.yaml
```

## TODO - NEXT SESSION
1. **134/137 lights need area assignment** (UI task)
2. **Double-fire warnings** - entry_room_lamp, living_room_lamps, upstairs motion
3. **Test night mode** (10pm-6am) - verify red dim lighting upstairs

## HAC WORKFLOW
```bash
hac backup <file>              # Before edits
ha core check                  # Validate
hac learn "insight"            # Log learnings
cd /homeassistant && git add -A && git reset HEAD zigbee.db* && git commit -m "summary" && git push
```

## QUICK START NEW SESSION
```bash
hac mcp      # Claude Desktop with MCP
hac q        # Quick continue (gist URLs)
hac push     # Full sync + new session prompt
```
