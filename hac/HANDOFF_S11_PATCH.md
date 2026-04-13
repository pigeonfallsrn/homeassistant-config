# S11 PATCH - Post-Green Fixes (2026-04-10/13)
## Final commit: b754c75

## Fixes completed
- Ella B1 toggle: top button now toggles off when lights on
- Bathroom ceiling switch: WORKING - VZM30-SN uses data.command single string
- Exhaust fan: stale bathroom_fan_paused boolean cleared
- lights_auto_off_safety: dead switch.upstairs_bathroom_fan fixed
- CRITICAL_RULES: ZHA event triggers, terminal chaining

## Root cause captured
- VZM30-SN ZHA: data.command = button_2_press (NOT button+press_type)
- ZHA triggers require device_ieee, NOT device_id
- Python content.replace() strips indentation - always verify YAML after
- MCP ha_config_set_automation unreliable for package YAML - use terminal

## Still outstanding S12
- Vanity slow fade: LOCAL_RAMP_RATE params to 0 on vanity VZM30-SN
- humidity_smart_alerts unpause: as_datetime silently fails, boolean stuck
- Combined UI automation bathroom_vanity_inovelli: wrong device_id triggers
- Migration Mini PC: backup 28389353 (S10C Final, 158.5MB Apr 9 21:39)
- Run s11_ghost_registry_cleanup.py BEFORE first HA start on Mini PC
- person.john_spencer: swap to device_tracker.galaxy_s26_ultra post-migration
- Kitchen Apollo R-PRO-1: zone config + occupancy wiring
