# HANDOFF — Session S57 (final)

## Last Session: S57 (2026-04-26 — extended)
## Last Commit: pending (post-Hue addendum)
## Baseline: 79 automations, 51 input_booleans, 15 input_numbers, 6 timers, 121 scenes (+3 new entryway), 0 ghosts

---

## WHAT HAPPENED IN S57

### Phase 1 — HA-side (committed 4dd90f8)
- **Back Patio Iconic** renamed via Hue CLIP v2; `light.back_patio` already grouped both bulbs via room exposure
- **Hot Tub Mode → Quiet Travel** clean replace: 6 hot_tub automations disabled, helper deleted, `input_boolean.quiet_travel` is canonical toggle
- **Back Patio Inovelli automation** rewritten: drops broken Dimmed scene ref, new button map with manual override + 90s motion-suppress + panic-reset
- **Companion timer-clear automation** created (`back_patio_clear_override_on_timer_finish`)
- **Quiet Travel suppression** verified on entry room, kitchen lounge, back patio motion
- **Auto-off at midnight** for Quiet Travel with phone notification

### Phase 2 — Front Hallway split (Hue Bridge only, no HA changes to commit)
- **5 device renames**: bulb 3 of 3 → Front Entryway Ceiling, bulbs 1+2 of 3 → Stairway Ceiling 1+2 of 2, FOH `de12236c` → Stairway FOH Switch, FOH `3d42422e` → Front Entryway FOH Switch
- **Zone cleanup**: deleted duplicate Front Hallway zone (`25a68a7b`), repurposed surviving (`22271fad`) as "Stairway" with 2 stairway bulbs, created new "Front Entryway" zone (`7c8cb7c5`) with 1 bulb
- **3 new scenes** for Front Entryway: Energize / Relax / Nightlight at house standard (156 / 370 / 454 mirek)
- **2 behavior_instance bindings**: each FOH bound to its zone, top buttons → Energize scene, bottom → all_off, hold → dim
- **Tested live**: both switches respond correctly, lights snap to scene on press
- **Logbook quirk noted**: "Front Hallway turned on" appears alongside Stairway events because Front Hallway is the parent room — cosmetic only, not a bug

### S55/S56 work discovered (HANDOFF drift)
HANDOFF said S54 but actual last commit was S56. Multiple staging items from S55/S56 (helpers, motion automation skip-conditions, zone scenes) were already in place — S57 was effectively a finishing pass. Caught and noted.

---

## CURRENT STATE — Hue Bridge

### Front Hallway area (post-S57)
- **Room**: Front Hallway (`a5bc471b`) — 3 bulbs + 1 FOH (Stairway)
- **Zone**: Stairway (`22271fad`) — Stairway Ceiling 1 + 2 of 2
- **Zone**: Front Entryway (`7c8cb7c5`) — Front Entryway Ceiling

### Switches (front area)
- `de12236c` Stairway FOH Switch → bound to Stairway zone, recalls scene `dc7e7749` (Energize)
- `3d42422e` Front Entryway FOH Switch → bound to Front Entryway zone, recalls scene `c2b6859b` (Energize)
- `9b3e8740` Very Front Door FOH Switch → controls exterior lights (untouched, working)

### Scenes (per zone, all at house standard)
- Stairway: dc7e7749 (E) / bef539d1 (R) / 0813de8f (N)
- Front Entryway: c2b6859b (E) / 8a6549b2 (R) / 676876cd (N)

---

## DUPLICATE ZONES STILL ON HUE BRIDGE (carry forward)

After Front Hallway dup cleanup, 2 dup pairs remain:
- "All Exterior" ×2 (`5ab3b908` + `6e661a7a`, both children=4)
- "Garage Ceiling" ×2 (`3e3e7939` + `ea986821`, both children=6)

Same cleanup pattern as Front Hallway: identify which zone is referenced by behaviors/scenes and DELETE the orphan.

---

## CARRIED FORWARD

### High priority
- **Rotate HA long-lived token** — confirmed REVOKED (curl returns 401). Internal scripts using `ha_api_token` from `secrets.yaml` are silently failing
- **Front Driveway + Very Front Door unification** (deferred TASK 5 from original prompt) — driveway + very front door, resolve duplicate entities + typo
- **Inovelli typo entity**: `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode` — rename via MCP
- **Stale generic Hue entities**: `light.hue_color_lamp_1` and `light.hue_color_lamp_2` (Front Hallway) — these likely auto-rename within hours after Hue integration polls; verify next session and clean any stragglers
- **HA stale automation refs**: scan dashboards + remaining automations for `light.front_hallway_ceiling_*` references that should now point at `light.front_entryway_ceiling` or `light.stairway_ceiling_*_of_2`

### Medium priority
- **Curated outdoor scene library** (deferred TASK 2) — 10 scenes for Back Patio (Galaxy/Northern Lights/Disco/etc.), needs Hue app work first
- **Hue Bridge duplicate zone cleanup** — All Exterior + Garage Ceiling pairs (2 remaining)
- **Physical hot_tub_mode automation removal** from `.storage` (6 disabled + `_2` quiet_travel duplicate) — cosmetic
- **Ella companion app rename** (sensor.iphone_40_* → sensor.ella_s_*)
- **Music Assistant** setup_error
- **Michelle person tracker** missing (MAC `6a:9a:25:dd:82:f1`)

### Low priority / blocked
- `binary_sensor.house_occupied` (unavailable — template package issue)
- `sensor.2nd_floor_bathroom_humidity_derivative` (unavailable)
- Garage opener Hue bulbs unreachable (power circuit issue)
- Very Front Door Hallway bulb sockets — physically disconnected, awaiting rewire + 2 new A19s
- `automations.yaml` is being modified despite UI-first architecture — investigate next session
- Phase B Hue items from S54 (Master Bedroom Ceiling zone, Ella scenes, etc.)

---

## OPPORTUNITIES NOTED THIS SESSION

1. **Pattern: full FOH wiring via CLIP v2** is now proven and reusable. Apply to:
   - Re-binding the 2 disconnected Very Front Door bulbs after rewire
   - Any future Inovelli SBM + FOH companion setups (driveway approach lights backlog)

2. **Zone-as-switch-target architecture** scales cleanly. Consider for:
   - Back Patio (currently controlled via Inovelli targeting room) — could split into "Back Patio Iconic only" + "Back Patio All" zones
   - Living Room (multiple lamps, currently one room) — could create zones per furniture group

3. **House-standard scene values are now locked** (156/370/454 mirek for E/R/N). Next zone created should use these values without fresh review.

4. **Hue logbook stale-name confusion** is real and will recur. Add session checklist item: when reviewing activity log, note that names reflect time-of-event, not current device names.

---

## BENCHMARK

| Metric | S54 | S57 (final) |
|--------|-----|-------------|
| Automations | 76 | 79 |
| input_booleans | — | 51 |
| input_numbers | — | 15 |
| timers | — | 6 |
| Hue Bridge zones | n/a | 21 (incl. 2 remaining dup pairs) |
| Hue Bridge scenes | n/a | 121 |
| Hue Bridge FOH switches bound | n/a | 11 |
| Front Hallway / Entryway / Stairway split | one fixture, one switch | 2 fixtures, 2 switches, 2 zones, 6 scenes ✓ |
| Ghosts | 0 | 0 |
| hot_tub_mode automations active | 6 | 0 |
| Hot tub helper | exists | DELETED |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68
- Hue API key: `.storage/core.config_entries` → domain=hue → data.api_key
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`

### Hue Bridge IDs (S57)
- Front Entryway zone: `7c8cb7c5-0d26-4200-a239-6ae412e0f054`
- Stairway zone: `22271fad-8853-4a3f-b517-88c0d31df259`
- Stairway FOH Switch: `de12236c-9aac-42d6-80ea-0ccd9a002fbc`
- Front Entryway FOH Switch: `3d42422e-0b77-421b-9532-a56858844084`
- Hue FOH script_id: `67d9395b-4403-42cc-b5f0-740b699d67c6`
- House Energize standard: brightness=100, mirek=156

---

## NEXT SESSION SUGGESTED FOCUS

Pick ONE:
1. **Rotate HA long-lived token** — confirmed broken, fix the 401 + audit what was using it
2. **Front Driveway + Very Front Door unification** (deferred TASK 5) — applies the S57 Hue split pattern
3. **HA-side stale entity ref scan** — `light.front_hallway_ceiling_*` cleanup post-rename
4. **Curated outdoor scene library** (deferred TASK 2) — needs Hue app work first
5. **Hue Bridge duplicate zone cleanup** (All Exterior + Garage Ceiling pairs)
