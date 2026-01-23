# Home Assistant System Knowledge Base
## 40154 Hwy 53, Strum WI - John Spencer
**Last Updated:** 2026-01-19
**Generated from:** HAC session learnings and context files

---

# QUICK REFERENCE

## Current System Stats
| Component | Count | Location |
|-----------|-------|----------|
| Entities | ~4194 | Various |
| Automations | 39 | See breakdown below |
| Packages | 4 | /config/packages/ |
| Areas | 35 | Configured |

## Automation Distribution
| File | Count | Purpose |
|------|-------|---------|
| automations.yaml | 11 | Switches, fans, humidity, misc |
| main.yaml | 7 | Inovelli primary controls, lights-off |
| garage_lighting_automation.yaml | 2 | Garage lights on/off |
| presence_system.yaml | 12 | Presence detection (input_booleans) |
| occupancy_system.yaml | 8 | Calendar, context, night paths |

---

# ARCHITECTURE DECISIONS

## Presence Detection (IMPORTANT)
```
USE THIS:           input_boolean.john_home, input_boolean.someone_home
NOT THIS:           binary_sensor.john_home (DELETED - was orphaned)
```

**How it works:**
1. `person.john_spencer` (HA native) → triggers automation
2. `presence_system.yaml` automation → sets `input_boolean.john_home`
3. `occupancy_system.yaml` → reads input_booleans for context decisions

**Key entities:**
- `input_boolean.john_home`
- `input_boolean.alaina_home`
- `input_boolean.ella_home`
- `input_boolean.michelle_home`
- `input_boolean.someone_home` (composite)

## Inovelli Switch Architecture
Inovelli switches in Smart Bulb Mode send TWO types of events:

| Event Type | Handled By | Purpose |
|------------|------------|---------|
| `on`, `off`, `move_to_level` | main.yaml | Primary control + override flags |
| `button_1_press`, `button_2_press`, `button_3_press` | automations.yaml | Scene cycling, fan control |

**This is intentional** - same device can have automations in both files for different event types.

## Garage Lighting
**Single source of truth:** `/config/packages/garage_lighting_automation.yaml`

- 2 automations: ON and OFF
- Controls 8 bulbs (4 LiftMaster + 4 nightlights)
- Triggers: garage doors, walk-in door, ratgdo motion
- 6-minute timeout after last motion

---

# DEVICE REFERENCE

## Inovelli Switch Device IDs
| Device ID | Location | Notes |
|-----------|----------|-------|
| `d80c7fa6d013f0fd1cbdd6f67c6a1cac` | Entry Room | Main + AUX |
| `0600639e50d4e1ed71fdaa1ef789e678` | 1st Floor Bathroom | |
| `5e2d477e04d216ab91a0c2f1364ab118` | Kitchen Lounge | VZM31-SN Dimmer |
| `70c1c990c1792ade4fc2eb2fd0d8487a` | Back Patio | |
| `17a59d3c437c3475f22c29dd2b76777a` | Kitchen Chandelier | 5 bulbs |
| `89ca030d64760ad87512e97d13a2737d` | Kitchen Above Sink | |

## RATGDO Garage Door Controllers
| Device | Entity Prefix | Location |
|--------|---------------|----------|
| North door | `ratgdo32disco_fd8d8c` | Main garage (van side) |
| South door | `ratgdo32disco_5735e8` | Main garage |

## Climate Zones
```
climate.1st_floor_thermostat
climate.attic_mini_split
climate.basement_nest_thermostat
climate.garage_nest_thermostat
climate.kitchen_mini_split
climate.living_room_mini_split
climate.master_nest_thermostat
climate.pfp_east_nest_thermostat_control
climate.pfp_west_nest_thermostat_control
climate.upstairs
climate.upstairs_hallway_mini_split
```

## Family Presence Entities
```
person.john_spencer
person.alaina_spencer
person.ella_spencer
person.michelle
person.jarrett_goetting
person.jean_spencer
person.owen_goetting
```

---

# KNOWN ISSUES & HISTORY

## North Garage Door Obstruction (ACTIVE - 2026-01-19)
- **Status:** HARDWARE ISSUE - awaiting physical inspection
- **Symptom:** Obstruction sensor stuck ON
- **Evidence:** History shows constant ON since ~Jan 8, was fine Jan 1-7
- **Impact:** Must hold wall button to close door
- **Root cause:** Physical - beam sensors or wiring at LiftMaster
- **RATGDO is correctly reporting** what opener sees
- **MyQ app confirms** same obstruction alerts

### Diagnostic commands:
```bash
# Check current state
curl -s "http://supervisor/core/api/states/binary_sensor.ratgdo32disco_fd8d8c_obstruction" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | grep -o '"state":"[^"]*"'

# Check history
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts, 'unixepoch', 'localtime') as time, s.state FROM states s JOIN states_meta m ON s.metadata_id = m.metadata_id WHERE m.entity_id = 'binary_sensor.ratgdo32disco_fd8d8c_obstruction' ORDER BY s.last_updated_ts DESC LIMIT 20;"

# Force sync
curl -s -X POST "http://supervisor/core/api/services/button/press" -H "Authorization: Bearer $SUPERVISOR_TOKEN" -H "Content-Type: application/json" -d '{"entity_id": "button.ratgdo32disco_fd8d8c_sync"}'
```

## Double Triggers (FIXED - 2026-01-19)
- **Was:** Automations firing 2x-4x due to duplicates in multiple files
- **Fixed:** Removed duplicates from automations.yaml
- **Affected:** Entry room, bathroom, garage lighting

---

# DIAGNOSTIC COMMANDS

## Database Queries (HA 2024+ schema)
```bash
# Check automation triggers for doubles
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts, 'unixepoch', 'localtime') as time, s.state, m.entity_id FROM states s JOIN states_meta m ON s.metadata_id = m.metadata_id WHERE m.entity_id LIKE 'automation.%' AND s.state = 'on' ORDER BY s.last_updated_ts DESC LIMIT 50;"

# Entity state history (replace ENTITY_ID)
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts, 'unixepoch', 'localtime') as time, s.state, m.entity_id FROM states s JOIN states_meta m ON s.metadata_id = m.metadata_id WHERE m.entity_id = 'ENTITY_ID' ORDER BY s.last_updated_ts DESC LIMIT 30;"

# Find all entities matching pattern
sqlite3 /config/home-assistant_v2.db "SELECT DISTINCT m.entity_id FROM states_meta m WHERE m.entity_id LIKE '%PATTERN%' ORDER BY m.entity_id;"
```

## Service Calls
```bash
# Reload automations
curl -s -X POST http://supervisor/core/api/services/automation/reload -H "Authorization: Bearer $SUPERVISOR_TOKEN"

# Check config
ha core check

# Get entity state
curl -s "http://supervisor/core/api/states/ENTITY_ID" -H "Authorization: Bearer $SUPERVISOR_TOKEN"

# Call any service
curl -s -X POST "http://supervisor/core/api/services/DOMAIN/SERVICE" -H "Authorization: Bearer $SUPERVISOR_TOKEN" -H "Content-Type: application/json" -d '{"entity_id": "ENTITY_ID"}'
```

## File Operations
```bash
# Count automations
grep -c -e "^- " /config/automations.yaml
grep -c -e "- id:" /config/packages/PACKAGE.yaml

# Find duplicates by device_id
grep -e "device_id:" /config/main.yaml /config/automations.yaml

# Check for entity references
grep -r "ENTITY_NAME" /config/*.yaml /config/packages/*.yaml
```

---

# SESSION HISTORY

## 2026-01-19: Major Automation Cleanup
**Changes made:**
1. Removed 5 duplicate garage automations from automations.yaml (kept package)
2. Deleted orphaned `/config/packages/presence.yaml`
3. Updated main.yaml: `binary_sensor.anyone_home` → `input_boolean.someone_home`
4. Removed duplicate "Everyone Away → All Lights Off" automation
5. Removed duplicate Entry Room Inovelli automation
6. Removed duplicate 1st Floor Bathroom automation

**Result:** 693 → 377 lines in automations.yaml, 39 total automations

**Backups:** `/config/automations.yaml.backup_20260119_*`

---

# USER PREFERENCES

- Combine terminal commands with `&&` for token efficiency
- Paste results one at a time
- Prefers terminal-based solutions over GUI
- Uses HAC system for AI context management
- Technical expertise: high (RN by profession, advanced home automation)

---

# TODO / FUTURE SESSIONS

1. [ ] Verify north garage door after physical sensor fix
2. [ ] Review presence_system.yaml (12 automations, 423 lines) for unused code
3. [ ] Review occupancy_system.yaml (8 automations, 587 lines) for unused code
4. [ ] Consider automation to auto-sync RATGDO after WiFi reconnect
5. [ ] Kitchen tablet automation (Fully Kiosk + wake-on-motion)
