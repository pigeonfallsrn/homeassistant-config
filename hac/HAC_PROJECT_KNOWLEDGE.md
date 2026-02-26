# Home Assistant HAC - Project Knowledge
*John Spencer's HA system context and critical rules for Claude*

## System Overview
- **Platform:** HA Green, HA 2026.2.x
- **Scale:** ~4000 entities | 35 areas | 140 automations
- **Config path:** `/homeassistant/` (not `/config/`)
- **HAC version:** v9.1

## ⚠️ CRITICAL RULES

### Before Any Edit
```bash
hac backup <filename>   # NON-NEGOTIABLE
```

### Terminal (ZSH)
- **Escape `!`** or use single quotes: `echo 'Hello!'` not `echo "Hello!"`
- **Git errors** (`confused by unstable object`): Run `git gc --prune=now` first
- **Never chain after `python3 -c`** on same line
- **Paths**: Always `/homeassistant/` (not `/config/`)

### Motion Automations
- **Always `mode: restart`** for motion-triggered lights
- **Combined sensors need `delay_off: 60s`** minimum to prevent double-fires
- **Use combined binary_sensor**, not OR-ing individual sensors (race conditions)
- **Dual trigger pattern**: motion ON starts lights, motion OFF with wait turns off
- **Timeout by room type**: transition 5-10min, active 8-20min, relaxation 15-45min
- **Double-fire fix**: Check for orphan automation entities with same unique_id

### Inovelli Switches
- **Smart Bulb Mode**: Param 52=1 + LED bar params 95-98 for Hue bulbs
- **Smart Bulb Mode switches**: Entry Room Ceiling, Kitchen Chandelier, Kitchen Above Sink, 1st Floor Bathroom, Back Patio
- **Config button cycling**: Use input_number + modulo, not input_select
- **Parameters require toggle OFF→ON** in ZHA UI then air gap to write
- **fxlt blueprint fires ALL zha_events** - filter by device_id or use unified blueprint
- **VZM35-SN fans**: Param 12 (auto-off) = 2700s for hardware safety backup

### Adaptive Lighting
- **Create/delete via UI ONLY** - no API exists
- **Hue bulbs require ALL THREE settings**:
  - `separate_turn_on_commands: true`
  - `take_over_control: true`
  - `detect_non_ha_changes: false`
- **Same make/model bulbs** per AL instance
- **Sleep mode**: 1-5%, 2200K, 10pm-6am for bedrooms
- **Current instances**: living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway

### Entity Naming
- **ZHA gives generic entity_ids** (e.g., `inovelli_vzm35_sn_fan`)
- **Rename via `ha_rename_entity`** to location-based IDs
- **Device names are separate** from entity IDs

### Matter/Aqara
- **Recommission fix**: Remove stale fabric from BOTH HA Matter AND Aqara app
- **Use BOTH Matter + HomeKit** integrations (different devices exposed)
- **M3 IR blaster**: Does NOT expose to HA
- **Locks**: Matter only. Some sensors: HomeKit only.

## Never Edit Directly
- `.storage/core.config_entries`
- `.storage/core.entity_registry`
- `.storage/core.device_registry`
- Any `.storage/*.json` files

## UI-Only Operations (No API/CLI)
- Adaptive Lighting create/delete
- ZHA pairing
- Hue linking
- Matter commissioning

## Safe via API/MCP
- Automations, Scripts, Helpers
- Services, Entity settings
- Dashboards

## Double-Fire Prevention Checklist
1. Motion aggregation sensors have `delay_off`? (60s/60s/90s)
2. Using combined sensor, not individual sensors?
3. Check for orphan automations with duplicate unique_ids
4. Check for automations disabled in UI but still registered

## Session Workflow
1. Start with `hac mcp` for session context
2. `hac backup <file>` before any edits
3. `hac learn "CATEGORY" "insight"` to persist learnings
4. `hac active "task"` to update focus
5. Commit: `cd /homeassistant && git add -A && git commit -m "summary"`

## Learning Categories
MOTION, INOVELLI, AL, YAML, ZHA, HAC, MATTER, ENTITY

## Key Infrastructure
- **ZHA coordinator**: Sonoff 3.0 USB Dongle Plus (49 devices)
- **Hue**: Established groups for major rooms
- **Network**: UniFi Dream Machine Pro with VLANs
- **Presence**: UniFi access point data for room-level tracking

## Calendar IDs (for reference)
- Kids (Alaina/Ella): `2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com`
- Personal: `pigeonfallsrn@gmail.com`
- John/Michelle: `2aa2d81010ff6a637e674c2cd23eb3e7a80e9dd48e8e30c50d6784c3cab86043@group.calendar.google.com`
- Work: `8249v7qv8g2m6bjc8v37f78gs0@group.calendar.google.com`
- Lions Club: `333e072f891daea9a8ffaba89d8e67fb16e89b74fe0a5cc06ad9e1be2e2d5edf@group.calendar.google.com`
