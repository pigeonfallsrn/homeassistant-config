# HAC Patterns
*Reusable implementation patterns — confirmed working*
*Auto-referenced by CONTEXT.md | Updated via hac learn*

## Motion Lighting
- Always `mode: restart` for motion-triggered lights
- `mode: parallel` with `max: 2` for event-based notifications (doorbell, package)
- Combined `binary_sensor` with `delay_off: 60s` — never OR individual sensors
- Dual trigger: motion ON starts timer, motion OFF with wait turns off
- Timeouts: transition 5-10min, active 8-20min, relaxation 15-45min

## Inovelli + Hue
- Smart Bulb Mode: Param 52=1, LED params 95-98
- Parameters need toggle OFF→ON in ZHA UI + air gap to write
- SBM switches NEVER in `light.turn_off` actions — they power Hue bulbs
- AUX DOWN sends direct `off` command — needs separate automation to catch it
- Button mapping: button_4=AUX DOWN, button_5=AUX UP, button_6=AUX CONFIG

## Adaptive Lighting + Hue
- Three required settings (all or AL silently fails):
  - `separate_turn_on_commands: true`
  - `take_over_control: true`
  - `detect_non_ha_changes: false`
- Create/delete via UI only — no API
- Same make/model bulbs per AL instance
- Hue zones for ceiling-only control, not room-wide scenes

## Dashboard Transforms
- `ha_config_get_dashboard force_reload:True` before every transform
- One comprehensive transform per section — never piecemeal
- Direct index only: `config['views'][0]['sections'][0]['cards'][2]`
- Reload + verify on tablet after every transform before proceeding
- `python_transform` sandbox: no import, str(), enumerate(), any(), all(), try/except

## Presence
- Template `binary_sensor` — not `input_boolean` + automation
- Michelle: `binary_sensor.michelle_actually_home` only (no companion app)
- `delay_off` invalid on state-based template sensors — silently kills sensor
- Orphan entity IDs: fix via `ha_rename_entity` two-step rename

## Mobile → Desktop Handoff
Capture format:
```
[HA-IDEA] Where: [location] When: [time/context]
Noticed: [behavior] Idea: [improvement]
```
Process: `hac mcp` → paste capture → query state → implement or `hac table "idea"`

## LLM Task Routing
| Task | Tool | Why |
|------|------|-----|
| YAML editing | Claude Desktop + MCP | Direct entity access |
| Architecture | Claude Opus | Deep reasoning |
| Voice capture | ChatGPT Mobile | Fast voice mode |
| Research | Gemini | Long context, grounding |
| Quick lookup | Claude Haiku | Fast |
