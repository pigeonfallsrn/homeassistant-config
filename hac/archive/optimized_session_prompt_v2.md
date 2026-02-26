# HAC Session Prompt v2 - Learnings-Integrated

## Terminal Absolute Rules (CRITICAL)
❌ NEVER: `cat << 'EOF'` heredocs (zsh quote hell)
✅ ALWAYS: `echo "text" > file` OR `printf '%s\n' "line" > file`
✅ Chain with &&, user prefers token-efficient back-and-forth
✅ Escape ! in zsh strings, don't chain after python3 -c

## Session Context Load
```
User: John Spencer | RN | Strum, WI | Tech-savvy
HA: Green 2026.2.1 | 146 lights | 49 ZHA devices | UniFi network
Terminal: zsh | /homeassistant/ working dir
Workflow: hac command → gist context → systematic commits
```

## MCP Privacy Model (Security-First)
**Exposed (290):** Motion/door sensors, temp/humidity, battery, lights, climate READ state
**BLOCKED (53):** Garage covers, locks, valves, network buttons
**Philosophy:** Knowledge (CSV) = all devices | Live (MCP) = safe sensors only

## HA Configuration Specifics
**Paths:** /homeassistant/ (NOT /config/) | .storage/ | hac/
**AL Instances:** 2 active (Living Spaces 4 lamps, Entry Room Ceiling 1 light)
**ZHA:** Sonoff 3.0 USB Plus coordinator | 49 devices
**Inovelli:** Smart bulb mode ON for: Entry Room, Kitchen fixtures, 1st Floor Bath
**Hue:** Use app groups (not HA groups) for multi-bulb fixtures

## Automation Best Practices (HA Community Aligned)
**Mode:** restart for motion automations (prevent overlap)
**Pattern:** Dual-trigger (on/off with IDs), NOT wait_for_trigger
**AL + Hue:** separate_turn_on_commands=true, take_over_control=true, detect_non_ha_changes=false
**Duplicates:** `grep "alias:" automations.yaml | sort | uniq -d`
**Descriptions:** ALWAYS add description field (what + why)

## Git Workflow (Automated)
**Before edits:** `hac backup <file>` OR `cp file file.bak.$(date +%Y%m%d)`
**Commit:** `cd /homeassistant && git add -A && git reset HEAD zigbee.db* && git commit -m "msg" && git push`
**HAC commit:** Includes hac/, excludes zigbee.db

## Known Issues/Quirks
**Unavailable entities:** 3 ghost automations (upstairs_hallway_*) - need cleanup
**HA CLI:** 'ha' command doesn't support 'services' - use REST API or UI
**Adaptive Lighting:** Entry Room has ghost entity conflicts (resolved)
**Upstairs hallway:** Needs 3-way switch test OR Hue click before automation

## Calendars & Presence
**John/Michelle:** 2aa2d81010ff6a637e674c2cd23eb3e7a80e9dd48e8e30c50d6784c3cab86043@group
**Alaina/Ella:** 2emio1oov9oq9u9115lv5oa05c@group
**Work:** 8249v7qv8g2m6bjc8v37f78gs0@group
**Lions:** 333e072f891daea9a8ffaba89d8e67fb16e89b74fe0a5cc06ad9e1be2e2d5edf@group
**Presence:** binary_sensor.anyone_home, *_at_school, *_at_moms
**Alarm:** input_select.alarm_mode (Disarmed = girls home)

## Current Priorities (Session Start)
1. **3-way switch test** → determines automation path
2. **Alaina LED auto-off** → midnight OR room exit (pending Apollo Pro)
3. **Upstairs hallway lighting** → time-based OR Hue click first
4. **Apollo Pro testing** → kitchen first, then bedrooms

## Session Types
**hac** → Load this prompt, status check, general debugging
**hac mcp** → MCP work (exposure, privacy, sensor optimization)
**hac debug** → Automation issues (traces, AL conflicts, timing)
**hac install** → New device setup (ZHA, ESPHome, integrations)

## Token Efficiency Protocol
1. Reference context docs (this file, gist CSVs) - don't repeat
2. Combine terminal commands with &&
3. Ask specific questions vs explaining everything
4. User pastes full output when requested
5. Use hac learn for new patterns immediately

## Learning Integration Rule
After each session:
- `hac learn "new pattern/insight"`
- Parse learnings for themes quarterly
- Update this prompt with critical patterns
- Remove outdated/superseded learnings
