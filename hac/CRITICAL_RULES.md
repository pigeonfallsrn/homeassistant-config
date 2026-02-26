# CRITICAL RULES - READ FIRST
*These cost real time/money to learn. Don't repeat them.*

## BEFORE ANY EDIT
```
hac backup <filename>   # NON-NEGOTIABLE
```

## TERMINAL (ZSH)
- **Escape `!`** or use single quotes: `echo 'Hello!'` not `echo "Hello!"`
- **Never chain after `python3 -c`** on same line
- **Paths**: `/homeassistant/` (not `/config/`)

## INOVELLI SWITCHES (Times Hit: 15+)
- **Smart Bulb Mode**: Param 52=1 + LED bar param 95-98 if controlling Hue
- **Config button scene cycling**: Use input_number + modulo, not input_select
- **Parameters require toggle OFF→ON** in ZHA UI then air gap to write
- **fxlt blueprint fires ALL zha_events** - filter by device_id or use unified blueprint

## ADAPTIVE LIGHTING (Times Hit: 10+)
- **Create/delete via UI ONLY** - no API exists
- **Settings**: `separate_turn_on_commands: true`, `take_over_control: true`, `detect_non_ha_changes: false`
- **Hue groups**: AL controls the GROUP, individual bulbs follow

## MOTION AUTOMATIONS (Times Hit: 8+)
- **Always use `mode: restart`** for motion-triggered lights
- **Dual trigger pattern**: motion ON starts, motion OFF with delay turns off
- **Lux conditions**: Check at trigger time, not in condition block

## MATTER/AQARA (Times Hit: 5+)
- **Recommission fix**: Remove stale fabric from BOTH HA Matter AND Aqara Connected Ecosystems
- **Use BOTH Matter + HomeKit** integrations (different devices exposed)
- **M3 IR blaster**: Does NOT expose to HA
- **Locks**: Matter only. Some sensors: HomeKit only.

## NEVER EDIT DIRECTLY
- `.storage/core.config_entries`
- `.storage/core.entity_registry`  
- `.storage/core.device_registry`
- Any `.storage/*.json`

## UI-ONLY (No API/CLI)
Adaptive Lighting, ZHA pairing, Hue linking, Matter commissioning

## SAFE VIA API
Automations, Scripts, Helpers, Services, Entity settings, Dashboards
