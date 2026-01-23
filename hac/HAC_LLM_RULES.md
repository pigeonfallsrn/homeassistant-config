# HAC LLM Operating Rules
**STRICT ADHERENCE REQUIRED - ALL AI ASSISTANTS**

## Command Protocol

### Rule 1: Terminal Commands Only
- ALL system interaction via bash commands
- NEVER suggest GUI actions
- NEVER say "go to Settings > ..."

### Rule 2: Command Chaining
```bash
# CORRECT - Chain with &&
cmd1 && cmd2 && cmd3

# WRONG - Separate commands
cmd1
cmd2
cmd3
```

### Rule 3: One Block, One Response
- User pastes ONE output at a time
- AI responds with ONE command block
- Back-and-forth until task complete

### Rule 4: Token Efficiency
- No verbose explanations mid-task
- Brief context only when architecture decisions needed
- Save detailed notes for session end

### Rule 5: Output Format
```bash
# Always prefix with what it does (one line)
command && command && command
```

## Quick Reference

### Database Queries (HA 2024+)
```bash
# States with entity names (JOIN required)
sqlite3 /config/home-assistant_v2.db "SELECT datetime(s.last_updated_ts,'unixepoch','localtime'),s.state,m.entity_id FROM states s JOIN states_meta m ON s.metadata_id=m.metadata_id WHERE m.entity_id LIKE '%PATTERN%' ORDER BY s.last_updated_ts DESC LIMIT 20;"
```

### API Calls
```bash
# Get state
curl -s "http://supervisor/core/api/states/ENTITY" -H "Authorization: Bearer $SUPERVISOR_TOKEN"|grep -o '"state":"[^"]*"'

# Call service
curl -s -X POST "http://supervisor/core/api/services/DOMAIN/SERVICE" -H "Authorization: Bearer $SUPERVISOR_TOKEN" -H "Content-Type: application/json" -d '{"entity_id":"ENTITY"}'

# Reload
curl -s -X POST http://supervisor/core/api/services/automation/reload -H "Authorization: Bearer $SUPERVISOR_TOKEN"
```

### File Operations
```bash
# Count automations
grep -c -e "^- " /config/automations.yaml

# Find entity refs
grep -rn "ENTITY" /config/*.yaml /config/packages/*.yaml 2>/dev/null

# Check config
ha core check
```

### Safe Editing Pattern
```bash
# Always backup, edit, verify
cp FILE FILE.backup_$(date +%Y%m%d_%H%M%S) && sed -i 'PATTERN' FILE && ha core check
```

## System Architecture (Current)

### Presence = input_boolean
```
USE:  input_boolean.john_home, input_boolean.someone_home
NOT:  binary_sensor.john_home (deleted)
```

### Automation Locations
```
automations.yaml     → Switches, button_*_press events, misc
main.yaml           → Inovelli on/off/dim + override flags  
packages/garage_*   → Garage lighting (ONLY source)
packages/presence_* → input_boolean management
packages/occupancy_*→ Calendar, context, night paths
```

### Device IDs (Inovelli)
```
d80c7fa6d013f0fd1cbdd6f67c6a1cac  Entry Room
0600639e50d4e1ed71fdaa1ef789e678  1st Floor Bathroom
5e2d477e04d216ab91a0c2f1364ab118  Kitchen Lounge VZM31
70c1c990c1792ade4fc2eb2fd0d8487a  Back Patio
17a59d3c437c3475f22c29dd2b76777a  Kitchen Chandelier
89ca030d64760ad87512e97d13a2737d  Kitchen Above Sink
```

### RATGDO
```
fd8d8c = North door (has obstruction issue - HARDWARE)
5735e8 = South door (working)
```

## Active Issues
- [ ] North garage obstruction sensor (physical fix needed)

## Session End Protocol
AI must create: `/config/hac/contexts/session_learnings_YYYYMMDD.md`
