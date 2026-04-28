# HANDOFF — S64 (2026-04-27)

## Last commit at session start
387ebb4

## S64 work — area cleanup + calendar verify

**Goal:** VZM30-SN area assignment + verify calendar re-auth + (extended) Very Front Door pollution cleanup.

**Completed:**
1. Front Driveway VZM30-SN device (16a22c25ead6b47a6b9666c539ff2509) → area=front_driveway
2. Renamed 2 stragglers from S63 carryforward (disabled-by-integration, missed by search):
   - sensor.front_drivay_..._rssi → sensor.front_driveway_inovelli_smart_bulb_mode_rssi
   - sensor.front_drivay_..._lqi → sensor.front_driveway_inovelli_smart_bulb_mode_lqi
3. Calendar re-auth confirmed (0 repairs) — physical re-auth done by John
4. Front Entryway Ceiling Hue device (b6c054c82b1f90ac71c99a7ea6c022b2) → area=entry_room
   - light.very_front_door_ceiling_hallway + zigbee_connectivity sensor
5. Stairway FOH Switch Hue device (b15d946ebaeec2ff5f4da06525831f67) → area=stairway_cubby
   - 4 button events: event.front_hallway_foh_button_1-4

## Verify
- VFD area pollution check: 0 ceiling/FOH leftovers ✓
- entry_room: light.very_front_door_ceiling_hallway present ✓
- stairway_cubby: 4 FOH button events present ✓
- VZM30-SN entity_count=45, all front_driveway_* prefix ✓

## S65 priority queue

### TIER 1 — Front Hallway physical-knowledge ambiguity (deferred from S64)
Need physical clarification: which area should these belong to?
- light.very_front_door_hallway ("Front Hallway") — currently in very_front_door
- scene.very_front_door_hallway_energize ("Front Hallway Energize")
- scene.front_hallway_relax_2 ("Front Hallway Relax")
- scene.front_hallway_nightlight_2 ("Front Hallway Nightlight")
No `front_hallway` area exists. Candidates: entry_room, stairway_cubby, or new area.
Ask John: where physically is the "Front Hallway" light? Same room as Stairway Cubby? Between Entry Room and Stairway?

### TIER 2 — Outside 4 West Lights area question
- light.outside_4_west_lights — currently in very_front_door
- scene.outside_4_west_lights_energize, _relax — same
Likely a Hue zone spanning multiple physical lights. Decide: leave at very_front_door, move to front_driveway, or new "Exterior West" area?

### TIER 3 — Hue Bridge duplicate zones
Physical task on Hue app — Claude can identify HA-side duplicates but not fix.
- All Exterior x2
- Garage Ceiling x2

### TIER 4 — Discovered side-questions (out of S64 scope)
- entry_room now has 5 ceiling-related lights (entry_room_ceiling_1, _2, very_front_door_ceiling_hallway, entry_room_ceiling_light, _inovelli_smart_dimmer_switch). Possibly Hue zone hierarchy + Inovelli SBM virtual + 2 individual bulbs. Worth a small audit for naming consistency.
- stairway_cubby has stairwell_night_light_* device fully unavailable (disconnected). Remove or revive?

## Carry-forward (from prior sessions, not addressed in S64)
- S57 deferred broader unification framing — replaced by S65 TIER 1-3 above
- Unrelated prior items: see LEARNINGS.md for context as needed

## Blocked
None new this session.

## Benchmark
- Read-handoff path tested clean at session start (S62 fix confirmed working).
- Two consecutive successful HANDOFF regenerations (S63, S64) — drift mitigated for now.
