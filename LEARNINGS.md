
---

## S46 — 2026-04-20 — Garage Review + Quick Wins

### ESPHome reflash rename pattern (1st occurrence)
- ESPHome devices reflashed with new device names change ALL entity IDs
- ratgdo example: ratgdo32disco_fd8d8c → garage_north_garage_door_ratgdo32disco
- 9 of 13 broken garage refs were this pattern
- Analogous to Hue Migration Rule — when reviewing any area with ESPHome devices, check for entity ID shifts

### Entity Ref Rule — 4th occurrence (S42, S44, S45, S46)
- Garage: 13 of 27 entity refs broken (48%)
- Batch ha_get_state verification remains the gold standard

### Hue Migration Rule — 2nd occurrence
- Garage dimmer: hue_dimmer_switch_4_button_N → garage_dimmer_switch_button_N
- Same pattern as S45 kids dimmer switches

### python_transform does not support isinstance()
- Full config replacement is cleaner for multi-ref fixes — skip python_transform for these

### Motion light consolidation pattern
- Separate ON/OFF automations with overlapping triggers and targets → consolidate into matched ON/OFF pair
- Use combined motion sensor (binary_sensor.*_motion_combined) + helper timeout (input_number.*_timeout) for OFF
- Garage: 3 overlapping automations → 1 clean OFF automation

### Aqara sensor gaps confirmed
- binary_sensor.aqara_door_and_window_sensor_door_3 not found (garage walk-in door trigger)
- binary_sensor.garage_walk_in_door also not found
- Part of known Aqara sensor gap backlog (6 door + 4 motion sensors with entity ID mismatches)

### HANDOFF.md gap
- S45 never wrote HANDOFF.md — S46 started with S44 handoff
- Session close discipline: always verify HANDOFF.md was written before git push

### REST API vs websocket for entity registry (S47)
- REST API POST to /api/config/entity_registry/{entity_id} returns 404 — endpoint doesn't exist
- Entity registry renames MUST use websocket: type "config/entity_registry/update" with entity_id + new_entity_id
- Bulk rename pattern: python3 + websockets library (pip3 install websockets --break-system-packages)
- aiohttp is NOT available in HAOS — always use websockets module
- curl/REST approach will silently fail (grep finds nothing, no error output)

### VZM36 EP2 light entity (S47)
- EP2 creates both a fan entity AND a light entity — they control the same endpoint
- The light_2 entity brightness mirrors fan speed (33/66/100%)
- Disable light_2 on all VZM36 modules — it's redundant and confusing on dashboards

### Entity registry changes are not git-tracked (S47 — reinforces S44)
- Entity renames, disables, and area assignments live in .storage/ (gitignored)
- These survive reboots but are NOT version-controlled
- 87 entity renames this session exist only in HA's registry, not in git
- Dashboard configs also .storage/ — same pattern

## S48 — 2026-04-20

### Hue migration _2 suffix pattern (3rd occurrence — PROMOTE)
- Hue Bridge re-add to EQ14 caused _2 suffixes on entity IDs for lights, scenes, and groups
- Previous: S46 garage dimmer, S46 ratgdo. Now: front driveway (6 broken refs across 4 automations)
- RULE: After any Hue Bridge migration/re-add, proactively scan ALL automations for stale Hue entity refs (light.*, scene.*) without _2 suffixes

### Inovelli SBM + Hue Bridge best practice (community research)
- Two approaches: ZHA binding (direct, no scenes/AL) vs HA automation (scenes + AL, slight dimming lag)
- With bulbs on Hue Bridge: must use HA automation approach (binding requires bulbs on same ZHA network)
- Scene cycling: use direct light.turn_on with brightness/color_temp on Hue zone, not room-level Hue scenes (which affect all lights in room including lamp)
- Don't mix AL with scene cycling on same lights — AL overrides scenes, creates conflicts
- Clean separation: ceiling = manual/scene-driven, lamp = adaptive

### Inovelli LED normalization for multi-gang
- In SBM, switches mostly show their "off" LED (load entity stays off)
- off_intensity is what you see 90% of the time — match across all switches in a gang
- Best practice: on_intensity=33, off_intensity=1, matching color (170=blue)
- Check ALL switches in a gang, not just the ones being worked on

### Inovelli speed optimization for SBM + automation control
- button_delay=0 for instant single-tap (multi-tap still works via ZHA event commands)
- on_off_transition_time=0 for instant LED bar response
- local_ramp_rate_off_to_on=0 and local_ramp_rate_on_to_off=0 for instant LED ramp
- Remove all transition parameters from light.turn_off actions
- In SBM, ramp rate params only affect LED animation, not actual load

### AUX switch config button
- AUX switches with config buttons generate button_6_press ZHA events when aux_switch_scenes is enabled on the main Inovelli
- AUX up=button_5_press, down=button_4_press, config=button_6_press
- Can share the same scene index helper with the main switch for synchronized scene position

### Entry room ceiling Hue zone
- light.entry_room_ceiling_light is a Hue ZONE (not room) containing only ceiling bulbs 1+2
- Zone has no Hue scenes (hue_scenes: []) — must use direct light.turn_on with explicit values
- Room-level scenes (scene.entry_room_*) affect ALL lights including lamp — avoid for ceiling-only control

### Config press scene cycling best practice
- 3 scenes max for a foyer/entry: Energize (100%/6500K), Relax (56%/2200K), Nightlight (10%/2000K)
- Config hold = instant jump to ultra-dim (5%/2000K) — skips cycling for 2AM shortcut
- 2xUP/2xDOWN as shortcuts to commonly used scenes

---
## S49 — Inovelli Systematic Review (2026-04-21)

### Derivative helper source persistence
- Derivative integration stores source entity_id at creation time. If source entity disappears (e.g., Aqara sensor removed), derivative goes permanently unavailable
- Options flow reconfigure for derivative returned 400 errors — had to delete and recreate
- New entity ID auto-generated from source device name — rename immediately after creation

### Inovelli SBM speed standard (confirmed across 9 switches)
- S48 entry room pattern now validated house-wide: button_delay=0, local_ramp_rate_off_to_on=0, local_ramp_rate_on_to_off=0, on_off_transition_time=0
- Default factory values (127 for ramps, 30 for transition) cause noticeable lag in SBM mode — user perceives delay between paddle press and Hue light response
- This is now a 3+ occurrence pattern → promote to permanent rule

### Inovelli LED standard (confirmed across 9 switches)
- on_intensity=33, off_intensity=1, color=170 (blue) is the house standard
- Factory defaults vary wildly (33, 49, 69, 95 found across switches) — must normalize per gang box
- 3-gang boxes especially noticeable when LEDs don't match

### VZM31-SN built-in humidity sensor
- Inovelli docs: accuracy ±5%, intended for rate-of-change detection not absolute measurement
- For bathroom fan auto, community consensus is derivative (rate-of-change) approach via HA derivative integration
- The existing v4 system uses absolute thresholds (>70% ON, <55% OFF) which also works because the VZM31-SN consistently reads relative humidity even if absolute accuracy is ±5%

### ha_bulk_control limitations
- Only supports simple on/off/toggle actions — does NOT support number.set_value or other domain-specific service calls
- For Inovelli parameter writes, must use individual ha_call_service calls with wait=false for speed

### Kitchen override timer was missing
- automation.kitchen_manual_override_inovelli_2x_tap_set referenced timer.kitchen_override_timer which didn't exist
- Entity ref verification caught this — another validation of the S44 promoted rule
