# Lighting Audit Handoff
*Created: 2026-02-18 | Last Updated: 2026-02-18*

## Current State (as of session start)
- **Total light entities:** 140
- **Areas defined:** 35
- **Many lights already have area assignments** (spot-checked 5, 4 had areas)

## Priority Issues Identified

### 1. Typo Entity IDs (CRITICAL - blocks voice control)
- `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode` → needs rename
- `light.living_room_tv_smart_ligjt_strip` → typo "ligjt"

### 2. Generic Hue Names (still have original Hue defaults)
Entity IDs are generic but friendly_names are descriptive:
- `hue_color_lamp_3/4/5` → 2nd Floor Bathroom Vanity 1/2/3 of 3
- `hue_color_candle_1/2` → 2nd Floor Bathroom Ceiling 1/2of2
- `hue_color_candle_3/4` → Alaina's Bedroom Ceiling 1/2 of 2
- `hue_color_candle_3_2/4_2/5` → Upstairs Hallway Ceiling 1/2/3 of 3
- `hue_color_lamp_10/11/12` → Very Front Door lights
- `hue_color_downlight_1_2/1_3`, `hue_color_lamp_1_3/1_5/2_3/2_4` → Garage lights

### 3. Unavailable Entities (11+ lights)
- Echo Glows (3) - expected if not powered
- Garage LiftMaster lights (4) - integration issue?
- Govee lamps (2) - moved/offline
- Aqara LED strips (2) - possibly removed
- Some Hue groups marked unavailable

### 4. Area Assignment Gaps
- Need full audit of which lights lack area_id
- Focus on: nightlights, LED strips, UniFi AP LEDs

## Phase 1 Plan
1. ✅ Backup registry files
2. ✅ Query current state via MCP
3. □ Fix typo entity_ids (ha_rename_entity)
4. □ Bulk area assignments for unassigned lights
5. □ Git commit checkpoint

## Phase 2 Plan (future session)
- Entity_id cleanup (rename generic hue_ prefixes)
- Unavailable entity triage
- Blueprint migration for Inovelli controls

## Git Commits
- (pending first changes)
