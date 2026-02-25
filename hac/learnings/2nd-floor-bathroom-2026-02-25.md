# HAC Learnings: 2nd Floor Bathroom Inovelli Audit
**Date:** 2026-02-25

## Key Findings

### 1. Blueprint Compatibility (CRITICAL)
- **fxlt blueprint** ONLY supports VZM31-SN (Dimmer)
- **VZM30-SN (On/Off)** and **VZM35-SN (Fan)** require manual zha_event automations

### 2. VZM30-SN ZHA Event Commands
| Action | Command |
|--------|---------|
| Paddle Up Press | `on` |
| Paddle Down Press | `off` |
| Paddle Up Hold | `move_with_on_off` |
| Paddle Down Hold | `move` |
| Release | `stop_with_on_off` |

### 3. Broken Automation Diagnosis
- Config returning null via API = corruption indicator
- Traces showing `failed_conditions` = broken condition logic
- Fix: Replace with clean zha_event automation

### 4. Entity Naming
Device `0489781ef8d00419ecf1929bd865b2de` has 40+ entities still named `1st_floor_bathroom_vanity_lights_*`
TODO: Full rename needed

## Device Reference
- **Model:** VZM30-SN (On/Off)
- **IEEE:** `20:a7:16:ff:fe:01:8c:b8`
- **Lights:** `light.2nd_floor_bathroom_ceiling_1of2`, `light.2nd_floor_bathroom_ceiling_2of2`
