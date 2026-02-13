# Garage Automation System - Cleanup Summary

## What Was Fixed
1. Removed 23 ghost/unavailable automations from entity registry
2. Deleted duplicate automations from `automations/` directory
3. Consolidated to package-based system in `packages/`
4. Fixed package naming: `garage_lighting_automation_FIXED.yaml` → `garage_lighting_automation_fixed.yaml`

## Current Working Automations
Located in `packages/`:
- **garage_quick_open.yaml** - Auto-open/close with arrival/departure detection
- **garage_notifications_consolidated.yaml** - Door open/close notifications
- **garage_door_alerts.yaml** - Native alert system with snooze
- **garage_lighting_automation_fixed.yaml** - Motion-based lighting

## Key Features
- Auto-open north door when approaching home (60s cancel window)
- Auto-close on departure (3-min cancel window)
- Actionable notifications for manual door control
- Persistent reminders if doors left open
- Motion-activated lighting

## Entity References
- North Door: `cover.ratgdo32disco_fd8d8c_door`
- South Door: `cover.ratgdo32disco_5735e8_door`
- Door Sensors: `binary_sensor.aqara_door_and_window_sensor_door_5/6`
- Notify: `notify.mobile_app_john_s_phone`
