# HAC Session Prompt v3 - Entity Verification & YAML Safety

## Terminal Absolute Rules (CRITICAL)
❌ NEVER: `cat << 'EOF'` heredocs (zsh quote hell)
❌ NEVER: sed for multi-line YAML edits (breaks nested structures)
❌ NEVER: `view` tool on files (opens vim, risks accidental edits)
✅ ALWAYS: `echo "text" > file` OR `printf '%s\n' "line" > file`
✅ ALWAYS: `cat` or `less` for read-only terminal viewing
✅ ALWAYS: python3 with readlines()/writelines() for YAML modifications
✅ Chain with &&, user prefers token-efficient back-and-forth
✅ Escape ! in zsh strings, don't chain after python3 -c

## Automation Creation Workflow (MANDATORY)
**BEFORE creating ANY automation targeting lights/devices:**

1. **Verify ALL matching entities exist:**
```bash
python3 -c "import json; [print(f\"{e['entity_id']}: hidden={e.get('hidden_by')}, disabled={e.get('disabled_by')}\") for e in json.load(open('.storage/core.entity_registry'))['data']['entities'] if 'SEARCH' in e['entity_id'].lower()]"
```

2. **If entity platform='group', check membership:**
```bash
python3 -c "import json; entity=[e for e in json.load(open('.storage/core.entity_registry'))['data']['entities'] if e['entity_id']=='ENTITY_ID'][0]; print('Platform:', entity['platform'], '| Config Entry:', entity.get('config_entry_id'))"
```

3. **Get group members if applicable:**
```bash
python3 -c "import json; entry=[e for e in json.load(open('.storage/core.config_entries'))['data']['entries'] if e['entry_id']=='ENTRY_ID'][0]; print('Members:', entry['options'].get('entities', []))"
```

4. **Create automation in temp file:**
```bash
cat > /tmp/automation_name.yaml << 'EOF'
- id: unique_id
  alias: "Description"
  ...
EOF
```

5. **Validate YAML structure:**
```bash
grep -A 15 "id: unique_id" /tmp/automation_name.yaml
```

6. **Append to automations.yaml:**
```bash
cat /tmp/automation_name.yaml >> /homeassistant/automations.yaml
```

7. **Verify and commit:**
```bash
grep -A 10 "id: unique_id" automations.yaml && cd /homeassistant && git add automations.yaml && git commit -m "Add automation_name" && git push
```

## Session Context Load
```
User: John Spencer | RN | Strum, WI | Tech-savvy
HA: Green 2026.2.1 | 146 lights | 49 ZHA devices | UniFi network
Terminal: zsh | /homeassistant/ working dir
Workflow: hac command → gist context → systematic commits
```

## MCP Privacy Model (Security-First)
**Exposed (290):** Motion/door sensors, temp/humidity, battery, lights, climate READ state
**BLOCKED (53):** Garage covers, locks, water valve, network buttons
**Philosophy:** Knowledge (CSV) = all devices | Live (MCP) = safe sensors only

## HA Configuration Specifics
**Paths:** /homeassistant/ (NOT /config/) | .storage/ | hac/
**AL Instances:** 2 active (Living Spaces 4 lamps, Entry Room Ceiling 1 light)
**ZHA:** Sonoff 3.0 USB Plus coordinator | 49 devices
**Inovelli:** Smart bulb mode ON for: Entry Room, Kitchen fixtures, 1st Floor Bath
**Hue:** Use app groups (not HA groups) for multi-bulb fixtures
**Light Groups:** UI-created groups stored in core.config_entries (domain='group'), NOT separate files

## Automation Best Practices (HA Community Aligned)
**Mode:** restart for motion automations (prevent overlap)
**Pattern:** Dual-trigger (on/off with IDs), NOT wait_for_trigger
**AL + Hue:** separate_turn_on_commands=true, take_over_control=true, detect_non_ha_changes=false
**Duplicates:** `grep "alias:" automations.yaml | sort | uniq -d`
**Descriptions:** ALWAYS add description field (what + why)
**Entity targets:** Verify existence, check hidden/disabled status, confirm group membership BEFORE creating automation

## Git Workflow (Automated)
**Before edits:** `hac backup <file>` OR `cp file file.bak.$(date +%Y%m%d)`
**Commit:** `cd /homeassistant && git add -A && git reset HEAD zigbee.db* && git commit -m "msg" && git push`
**HAC commit:** Includes hac/, excludes zigbee.db
**Recovery:** `git checkout HEAD -- filename` restores last committed version

## Known Issues/Quirks
**Unavailable entities:** 3 ghost automations (upstairs_hallway_*) - need cleanup
**HA CLI:** 'ha' command doesn't support 'services' - use REST API or UI
**Adaptive Lighting:** Entry Room has ghost entity conflicts (resolved)
**Upstairs hallway:** Needs 3-way switch test OR Hue click before automation
**Vim trap:** If stuck in vim from accidental `view` command: ESC then :q! to quit

## Calendars & Presence
**John/Michelle:** 2aa2d81010ff6a637e674c2cd23eb3e7a80e9dd48e8e30c50d6784c3cab86043@group
**Alaina/Ella:** 2emio1oov9oq9u9115lv5oa05c@group
**Work:** 8249v7qv8g2m6bjc8v37f78gs0@group
**Lions:** 333e072f891daea9a8ffaba89d8e67fb16e89b74fe0a5cc06ad9e1be2e2d5edf@group
**Presence:** binary_sensor.anyone_home, *_at_school, *_at_moms
**Alarm:** input_select.alarm_mode (Disarmed = girls home)

## Current Priorities (Session Start)
1. **Alaina LED auto-off** → COMPLETE (midnight automation added)
2. **3-way switch test** → determines automation path for upstairs hallway
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

## Vim Safety Reminder
If stuck in vim (from accidental `view` tool usage):
1. Press ESC
2. Type :q!
3. Press Enter
Never use `view` tool - use `cat` or `less` instead for read-only viewing
