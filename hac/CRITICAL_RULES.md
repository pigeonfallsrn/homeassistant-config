# CRITICAL RULES - READ FIRST
*Hard-won lessons from 2000+ lines of learnings. Don't repeat them.*

## ⚠️ BEFORE ANY EDIT
```
hac backup <filename>   # NON-NEGOTIABLE
```

## TERMINAL (ZSH)
- **Git errors** (`confused by unstable object`): Run `git gc --prune=now` twice (HA Green/SD card limitation)
- **Escape `!`** or use single quotes: `echo 'Hello!'` not `echo "Hello!"`
- **Never chain after `python3 -c`** on same line
- **BusyBox grep** (HA Green): NO `--include`, NO long options. Use `-rEl` for recursive+extended+filenames. Never `--include=*.yaml` — use `grep -rEl 'pattern' /path/` instead
- **BusyBox sed** (HA Green): NO multi-line, NO complex scripts. Use `python3` heredoc for non-trivial file edits
- **Paths**: `/homeassistant/` (not `/config/`)

## MOTION AUTOMATIONS (Times Hit: 15+)
- **Always `mode: restart`** for motion-triggered lights
- **Combined sensors need `delay_off`**: 60s minimum to prevent double-fires
- **Use combined binary_sensor**, not OR-ing individual sensors (race condition)
- **Dual trigger pattern**: motion ON starts, motion OFF with wait turns off
- **Timeout by room type**: transition 5-10min, active 8-20min, relaxation 15-45min
- **Double-fire fix**: Check for orphan automation entities with same unique_id

## INOVELLI SWITCHES (Times Hit: 15+)
- **Smart Bulb Mode**: Param 52=1 + LED bar params 95-98 for Hue bulbs
- **Config button cycling**: Use input_number + modulo, not input_select
- **Parameters require toggle OFF→ON** in ZHA UI then air gap to write
- **fxlt blueprint fires ALL zha_events** - filter by device_id or use unified blueprint
- **VZM35-SN fans**: Param 12 (auto-off) = 2700s for hardware safety backup

## ADAPTIVE LIGHTING (Times Hit: 10+)
- **Create/delete via UI ONLY** - no API exists
- **Hue bulbs require ALL THREE**:
  - `separate_turn_on_commands: true`
  - `take_over_control: true`
  - `detect_non_ha_changes: false`
- **Same make/model bulbs** per AL instance
- **Sleep mode**: 1-5%, 2200K, 10pm-6am for bedrooms
- **Current instances**: living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway

## ENTITY NAMING
- **ZHA gives generic entity_ids** (e.g., `inovelli_vzm35_sn_fan`)
- **Rename via `ha_rename_entity`** to location-based IDs
- **Device names are separate** from entity IDs

## MATTER/AQARA (Times Hit: 5+)
- **Recommission fix**: Remove stale fabric from BOTH HA Matter AND Aqara app
- **Use BOTH Matter + HomeKit** integrations (different devices exposed)
- **M3 IR blaster**: Does NOT expose to HA
- **Locks**: Matter only. Some sensors: HomeKit only.

## DOUBLE-FIRE PREVENTION CHECKLIST
1. Motion aggregation sensors have `delay_off`? (60s/60s/90s)
2. Using combined sensor, not individual sensors?
3. Check `hac health` for orphan automations with duplicate unique_ids?
4. Check for automations disabled in UI but still registered?

## NEVER EDIT DIRECTLY
- `.storage/core.config_entries`
- `.storage/core.entity_registry`
- `.storage/core.device_registry`
- Any `.storage/*.json`

## UI-ONLY (No API/CLI)
Adaptive Lighting, ZHA pairing, Hue linking, Matter commissioning

## SAFE VIA API
Automations, Scripts, Helpers, Services, Entity settings, Dashboards
