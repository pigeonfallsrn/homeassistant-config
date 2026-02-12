# MCP Exposure Policy - Last Updated: 2026-02-12

## Safety Rules (Committed to HAC Memory)

### ✅ SAFE TO EXPOSE (Read-Only Context)
- `binary_sensor.*_motion` - All motion sensors
- `binary_sensor.*_door` - Door/window sensors  
- `sensor.*_temperature` - Temperature sensors
- `sensor.*_humidity` - Humidity sensors
- `light.*` - All lights (low risk)
- `binary_sensor.*_presence` - Presence detection

### 🚫 NEVER EXPOSE (Critical Controls)
- `cover.garage_*` - Garage door CONTROLS
- `lock.*` - All locks
- `switch.*_valve*` - Water valve controls
- `button.usw_*` - Network equipment reboots
- `switch.*_avr_*_reset` - Equipment hard resets

## Current Exposure Status
(Run audit to populate)

## CLI Commands
- Audit: HA UI > Settings > Voice Assistants > Assist > Exposed Entities
- NO reliable CLI method for exposure check
- Use `hac mcp` to see live MCP status

## Learnings Committed
- MCP uses HA Assist exposure settings
- Context CSVs = full knowledge, MCP = live state subset
- Blocked devices acknowledged from context, not queried live
