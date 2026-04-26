# LEARNINGS — Accumulated across sessions
# Append-only. Never overwrite. Promote mature entries to Project Instructions.

---

## S51 (2026-04-21) — Green Deprecation + Dashboard Cleanup + Governance

### Green Deprecation Pattern
- Systematic: harvest configs → save creds to NordPass → verify on EQ14 → shutdown
- 59 integrations were actively conflicting — especially 4x Adaptive Lighting instances fighting EQ14's AL
- "No automations on old instance" does NOT mean "no interference" — integrations still poll/control devices
- PROMOTED S50, confirmed S51: after migration, remove ALL integrations on old instance that connect to devices the new instance manages

### HAC Workflow Review
- Green had hac.sh v9.1 (73KB) with learn/promote/health/table/doctor/route commands
- Most patterns superseded by Claude Project memory + HANDOFF.md + LEARNINGS.md
- Worth porting to EQ14: `hac health` — REST API query for unavailable entities, double-fires, integration status
- Not worth porting: gist-based context sharing (replaced by Claude Project), sanitization (no longer publishing)
- knowledge.yaml structured format (id, category, times_hit, promoted) was interesting but Claude memory handles this more naturally

### Dashboard Learnings
- auto-entities exclude filters: use glob patterns (light.adaptive_*, light.*inovelli*)
- Mushroom cards in 3-col grid still truncate entity names — consider 2-col or explicit name overrides
- show_empty: false hides entire auto-entities section when no matches — clean UX for "Lights On Now"
- Climate entity IDs: climate.1st_floor_nest_thermostat, climate.2nd_floor_nest_thermostat (not downstairs/upstairs)
- Front driveway light entity: light.front_driveway_2 (not light.front_driveway_inovelli)

### YAML Dashboard Removal
- configuration.yaml lovelace dashboards block: strip entire dashboards: section, keep lovelace: mode: storage
- Archive files before deleting: mkdir archive dir, mv files, rmdir original
- ha core restart required after configuration.yaml changes (not just reload)

## S52 — Full System Audit (2026-04-22)

### Adaptive Lighting entity naming pattern (CRITICAL)
- AL main switch entity IDs follow: switch.{instance_name}_adaptive_lighting_{instance_name}
- NOT switch.adaptive_lighting_{instance_name} (which is the old/intuitive format)
- Example: switch.living_spaces_adaptive_lighting_living_spaces (NOT switch.adaptive_lighting_living_spaces)
- adaptive_lighting.apply service requires the correct main switch entity_id or throws AssertionError
- This affected 4 automations with 16 recurring errors

### Hue migration entity renames — widened scope (3rd occurrence, PROMOTE)
- S42: Entry Room entities. S44: Bathroom + tablet. S52: Entry room lamp + kitchen + living room + master bedroom
- After Hue Bridge migration, entity names change unpredictably: light.entry_room_hue_color_lamp → light.entry_room_desk_lamp
- Also Inovelli entities: light.kitchen_ceiling_inovelli_vzm31_sn → light.kitchen_ceiling_can_led_lights_inovelli
- Midnight automation had 8 broken refs across kitchen, living room, and master bedroom lights
- RULE REINFORCEMENT: Entity ref verification before ANY review is mandatory. This is now a 3+ occurrence pattern.

### Ghost script rule confirmed (3rd occurrence)
- S45: kids scripts. S52: same pattern — ella_lights_off, ella_school_night, alaina_lights_off, alaina_school_night
- Scripts with restored:true and no config require ha_remove_entity, not ha_config_remove_script
- These survived from S45 cleanup — likely re-created by registry restore or missed in that session

### Template package YAML/UI collision pattern
- sensor.people_home_count (YAML template, unavailable) vs sensor.people_home_count_2 (UI template, working)
- YAML templates that fail to render on startup get restored:true and stay unavailable permanently
- If a UI replacement exists with _2 suffix, the fix is: remove YAML definition, rename UI entity to drop _2

### python_transform string method restrictions
- python_transform in ha_config_set_automation does NOT allow .replace() on strings
- For multi-entity-ref fixes, full config replacement is required (not python_transform)
- Allowed string methods: startswith, endswith, lower, upper, split, join, strip

### hac.sh not on EQ14
- shell_command.hac_export calls hac.sh which was on Green, not ported to EQ14
- automation.hac_daily_master_context_export runs daily and generates return code 127 errors
- Either port hac.sh or disable the automation until ported

## S53 — 2026-04-22

### HUE MIGRATION RULE — 6th occurrence (PROMOTED)
Master Bedroom Tap Dial Switch automation had ALL 5 triggers referencing dead `event.hue_tap_dial_switch_3_*` entity IDs. Automation was 100% non-functional. Correct entities were `event.master_bedroom_tap_dial_switch_*`. This is the 6th confirmed occurrence of stale Hue generic entity refs surviving migration. Rule: after ANY Hue device review, scan all automations for `hue_` prefixed entity refs.

### Premature script anti-pattern
`script.apply_tablet_context` was built referencing 5 dashboard URLs that didn't exist yet (kitchen-guest, kitchen-away, kitchen-john, kitchen-kids, kitchen-family). It failed on every occupancy change since creation. Also used `entity_id` targeting for `fully_kiosk.load_url` which requires `device_id`. Lesson: don't build automations/scripts referencing resources that don't exist yet. Build the infrastructure first.

### VZM36 device rename creates ghost entity registrations
Renaming a VZM36 device from "Upstairs Hallway" to "Master Bedroom" created new entity registrations at `master_bedroom_vzm36_*` without removing the old `upstairs_hallway_vzm36_*` ones. Both sets exist in registry. The old-prefix entities are the live ones (have state), the new-prefix ones are stale ghosts. Attempting `new_entity_id` rename fails with "already registered." Low priority — diagnostic entities only.

### Master Bedroom Tap Dial layout pattern
Bedroom with FOH + Tap Dial: FOH at door = power states (ON/Energize/OFF/Nightlight). Tap Dial at nightstand = comfort from bed (Relax/Read/Nightlight/Fan, rotary=dim). Nightlight on both controllers because it's needed from either location. Fan on tap dial button 4 — only non-lighting need from bed.

## S54 — Hue Ecosystem Audit (2026-04-22)

### Hue Bridge Automation Switches — MCP 500 Error
- switch.hue_bridge_automation_* entities throw 500 Internal Server Error when toggled via MCP ha_call_service OR REST API
- Must be toggled in HA UI manually (Settings → Devices → Hue Bridge)
- Likely a Hue bridge API / behavior_instance endpoint issue, not an HA problem

### Bridge Automation Dual-Fire Pattern
- Bridge-side automations (switch.hue_bridge_automation_*) run independently of HA automations
- If HA also has automations for the same accessory, BOTH fire on every button press
- Rule: If HA handles scene cycling for an accessory, disable that accessory's bridge automation
- Keep bridge automation ON only for accessories with no HA automation (pure bridge control)

### Hue Scene Reliability — Bridge Native vs HA
- Hue bridge scenes send atomic group commands (all lights in one Zigbee message) — smoother, faster
- HA-created scenes send sequential commands to each light individually
- scene.turn_on on a Hue scene entity delegates to the bridge API — you get atomic group control
- Always prefer Hue bridge scenes for multi-bulb rooms, not HA-created scenes

### Hue Rooms vs Zones (confirmed)
- Rooms: exclusive (each bulb belongs to exactly one room), represent physical spaces
- Zones: flexible (bulbs can be in multiple zones), represent logical subsets
- Use zones for scene cycling on bulb subsets (e.g., Kitchen Chandelier zone = 5 chandelier bulbs only)
- 64 groups max per bridge (rooms + zones combined)

### Entity Ref Audit — 4th occurrence (S42, S44, S45, S54)
- Entry Room tap dial: 5 stale refs (hue_tap_dial_switch_1_* → entry_room_tap_dial_switch_*)
- Living Room FOH: 8 stale trigger refs + 3 missing helpers (completely dead automation)
- All stale refs were generic Hue names from before bridge migration (works_with_hue_switch_1_*, hue_tap_dial_switch_1_*)
- HUE MIGRATION RULE confirmed again: After any Hue bridge re-add/migration, ALL automations must be scanned for stale hue_ prefixed entity refs

### Hue Bridge CLIP v2 API — Direct Scene Management
- Bridge API accessible at https://\<bridge-ip\>/clip/v2/resource/scene (requires -sk for self-signed cert)
- API key stored in /config/.storage/core.config_entries under hue domain data.api_key
- DELETE scenes: curl -sk -X DELETE "https://<ip>/clip/v2/resource/scene/<scene-id>" -H "hue-application-key: <key>"
- HA auto-removes deleted scene entities within ~60 seconds (bridge event stream)
- Always export full scene dump before bulk deletes: curl + python3 → JSON backup file

### Hue Scene Strategy — Standardized Pattern
- Default 3 per room: Energize (bright cool), Relax (warm moderate), Nightlight (very dim amber)
- Outdoor: add Nighttime (muted outdoor-specific)
- Kids bedrooms: add 1-2 fun color scenes (Malibu pink etc.)
- Zones for subset control (chandelier, vanity, ceiling, bedside) — scenes on zones enable independent cycling
- Room group entity (light.<room>) = atomic control of all bulbs — use for "all on/off"
- Zone group entity (light.<zone>) = atomic control of subset — use for scene cycling on subsets

### Hue Backup Best Practice
- Three-layer backup before bulk changes: HA snapshot + Hue cloud backup (app) + local API JSON export
- Local export includes full scene color/brightness data (can recreate any deleted scene)
- Force-add backup files to git if backup dir is gitignored: git add -f

## S55 — 2026-04-22

### Hue Bridge Behaviors (behavior_instance) — Dual-Fire Resolution
- Bridge behaviors are NOT HA automations — they live on the bridge as behavior_instance resources
- Query: GET /clip/v2/resource/behavior_instance
- Most dimmer/tap dial behaviors don't persist on bridge if "configure in another app" was selected
- Only behaviors explicitly configured in Hue app appear as behavior_instances
- S54 flagged 4 to disable but only 1 existed (LR Lounge) — the rest were never bridge behaviors

### Hue Outdoor Motion Sensors — "Configure in Another App" Pattern
- Adding sensors as "configure in another app" in Hue app means: bridge pairs them but assigns no room/behavior
- HA discovers them via Hue integration with generic names (hue_outdoor_motion_sensor_N)
- Must rename device in HA (ha_update_device) AND rename entity_ids (ha_set_entity with new_entity_id)
- Each sensor creates 7 entities: motion, battery, illuminance, temperature, zigbee_connectivity, 2 enable switches
- Illuminance sensor useful for lux-based automation conditions

### Outdoor Motion Automation Pattern (recommended)
- Mode: restart (new motion resets the off timer)
- Trigger: Hue motion sensor + UniFi person/vehicle detection (where camera exists)
- Condition: sun below horizon (with -15min offset for dusk)
- Action: Energize scene → wait_for_trigger (all motion clear for 5min) with 15min hard cap → light.turn_off with transition
- Single automation handles on+off (no separate auto-off automation needed)
- wait_for_trigger with continue_on_timeout: true ensures lights always turn off

### Outdoor Sunset Schedule Pattern
- 3 triggers in one automation: sunset (offset -15min), time 23:00, sunrise (offset +15min)
- Choose action branches per trigger ID
- Covers all outdoor rooms in each branch (Front Driveway, Very Front Door, Back Patio)
- Relax at dusk → Nightlight at late night → Off at dawn

### FOH Switch Hybrid Architecture — Bridge vs HA Decision Tree (S55)
- If target is ONLY Hue lights + simple on/off/scene: bridge-direct (fast, reliable, HA-independent)
- If target includes non-Hue devices (ZHA fans, Inovelli): HA automation required
- If need cross-system actions (whole home off): HA automation for that specific button/event
- Hybrid: bridge handles short_release for Hue targets, HA handles long_release for complex actions
- No dual-fire: bridge only fires on_short_release, HA filters for long_release only
- Bridge behaviors created via POST /clip/v2/resource/behavior_instance using script_id "67d9395b" (Hue Accessories)
- behavior_instance schema: buttons keyed by button service rid, each with on_short_release + on_repeat + where (group target)
- "configure in another app" = bridge pairs but assigns no behavior → HA gets events → automation handles

### FOH Button Layout Reference
- B1 = upper left, B2 = lower left, B3 = upper right, B4 = lower right
- Natural mapping: left side = one function (fan), right side = another (lights)
- Up = on/cycle, Down = off — matches physical wall switch mental model

### Fan Speed Cycling Pattern (VZM36 via HA)
- percentage_step 33.33% = 3 speeds (33=low, 66=med, 100=high)
- Template: check current percentage, set next level, wrap at 100→33
- Long press = jump to high (100%) — power user shortcut
- fan.set_percentage with template value, not fan.turn_on (which uses last speed)

### Hue Entity Rename After FOH Reassignment
- Device rename via ha_update_device does NOT cascade to entities
- Must rename each event.* entity individually via ha_set_entity(new_entity_id=...)
- Plan entity naming before creating automations to avoid double-rename

### Hue Bridge Device Name Limit (S55)
- Hue CLIP v2 API enforces 32 character max on device metadata.name
- "Living Room Lounge Ceiling 1 of 3" = 33 chars → rejected
- Keep abbreviated names like "LR Lounge Ceiling" when full name exceeds limit

### Hue Tap Dial Bridge Behavior — FOHSWITCH Workaround (S55)
- Tap dial (RDM002) behavior_instance creation fails with native model_id
- FOHSWITCH model_id works for button behaviors but ignores rotary
- Solution: bridge handles buttons (snappy), HA handles rotary dimming as companion
- Rotary dimming: target Hue room group (light.living_room) not individual zones
- Individual zone targeting causes inconsistent dimming (each bulb at different level)

### Hue Zone Strategy — Final Architecture (S55)
- Zones = subsets of room lights for targeted control (ceiling vs lamps vs vanity)
- Don't create single-bulb zones (pointless, just use the light entity)
- Don't mix rooms in zones (Garage & Front Driveway was confusing)
- Standardize 3 scenes per zone minimum: Energize, Relax, Nightlight
- Outdoor zones get Nighttime scene addition
- "All Exterior" super-zone for whole-outdoor control (seasonal, security)

### FOH Switch Architecture Decision Tree (S55, promoted)
- Pure Hue targets → bridge-direct (fastest, HA-independent)
- ZHA/non-Hue targets → HA automation required
- Mixed → hybrid (bridge for Hue buttons, HA for non-Hue buttons)
- Cross-system actions (whole-home-off) → HA on long_release only
- Bridge behavior_instance uses script_id 67d9395b (Hue Accessories)
- FOHSWITCH model_id works for both FOH clicks and tap dials (buttons only)

### Hue Room Naming — Avoid Confusing Similarities (S55)
- "Very Front Door" (exterior) vs "Very Front Door Hallway" (interior) caused confusion
- Renamed hallway to "Front Hallway" — clearly distinct from exterior room
- Rule: if two room names share a prefix, one needs renaming

### Scene-Based vs Toggle-Based Switch UX (S55)
- Toggle (press=on, press again=off) is bad for multi-group rooms
- User must remember which buttons they pressed to undo
- Scene-based (each button = whole-room mood, one button = off) is best practice
- This is how Hue designed the tap dial — match the mental model

## S56 — 2026-04-25 — Best-practice scorecard + duplicate cleanup

### LEARNING: Stale Green→EQ14 restore artifacts have unique_id prefix `01KP4*`
The TTS and Shopping List "duplicates" I cleaned up weren't really duplicates — they were stale entity registry records left over from the Green→EQ14 backup restore. Pattern:
- Old entity (`tts.google_translate_en_com`) had unique_id starting `01KP4FQ7*`
- New entity (`tts.google_translate_en_com_2`) had unique_id matching live config entry (e.g., `01K3HJC*`)
- The `01KP4*` unique_id had no live config entry behind it → orphan
- Symptom: entity shows as `unavailable` permanently, while `_2` works

**Detection pattern for future audits:** When you see `entity` and `entity_2` both in the registry, check unique_ids against active config entry IDs. If the non-_2 has a unique_id with no live config entry, it's a stale restore artifact, not a true duplicate.

**Safe action:** ha_remove_entity on the orphan, then ha_set_entity new_entity_id to rename `_2` → canonical. Both ops are entity-registry-only; no device touched.

### LEARNING (4-OCCURRENCE PROMOTION CANDIDATE): VZM36 EP2 firmware redundancy is universal
Project memory documented "VZM36 EP2 entities redundant — disable, don't delete" for the Master Bedroom switch. This session confirmed the pattern applies to ALL VZM36 instances:
- Master Bedroom: `update.master_bedroom_vzm36_firmware_2` ✅ disabled
- Kitchen Lounge: `update.kitchen_lounge_vzm36_firmware_2` ✅ disabled
- Living Room: `update.living_room_vzm36_firmware_2` ✅ disabled
- Upstairs Hallway: `update.upstairs_hallway_vzm36_firmware_2` ✅ disabled

The VZM36 has two endpoints (EP1 light, EP2 fan) but a single physical firmware. ZHA exposes the same firmware update on both endpoints. Always disable EP2 firmware update entity.

**Promote to CRITICAL_RULES if seen one more time?** Already at 4 occurrences across 4 distinct devices — this should promote to CRITICAL_RULES now under "VZM36 device pattern."

### LEARNING: Triage at integration-level FIRST when chasing unavailable entities
The instinct is to filter all entities by `state: unavailable` and walk the list. That gives ~283 lines for a system this size and feels overwhelming.

Better workflow:
1. `ha_get_integration` (no filter) → see which integrations are NOT `state: loaded`
2. For loaded integrations with many unavailable entities, `ha_get_device` → check radio_metrics (LQI/RSSI null = gone from mesh)
3. Cluster unavailables by device, not by entity

Result: ~283 unavailable entities collapse into ~12 device-level clusters, of which ~6 are normal/expected behavior (Alexa idle, switch port empty, AVR standby).

### LEARNING: `source` field disambiguates duplicate config entries
When you see two config entries for the same integration (Met.no "Home" ×2), the `source` field tells you which is canonical:
- `source: "onboarding"` → created at first-run, the canonical one
- `source: "user"` → manually added later, often by mistake
Prefer deleting `user`-source duplicates over `onboarding`-source.

### PATTERN CONFIRMED: Registry-only changes don't touch git
The 7 entities + 1 config entry I modified all live in `.storage/` (gitignored). After the session: `git status` returned empty stdout. This is correct and expected — registry changes persist in HA but not in version control. The HANDOFF.md update IS the audit trail for these changes.

### LEARNING: `ha_set_entity(enabled=False)` is registry-level, REQUIRES integration reload
Per the tool description: setting `enabled=False` removes the entity from the state machine entirely. The entity will not appear in state queries until re-enabled AND the integration is reloaded. This is fine for redundant entities (like VZM36 EP2 firmware) where you don't want the entity at all, but DON'T use it as a substitute for `automation.turn_off` or `script.turn_off`.


## S57 — Back Patio Iconic + Quiet Travel + Hot Tub Deprecation (2026-04-26)

### Hue CLIP v2 device rename works cleanly via PUT
PUT `/clip/v2/resource/device/{id}` with `{"metadata":{"name":"new name"}}` returns
`{"data":[{"rid":"...","rtype":"device"}],"errors":[]}` and the rename propagates to
HA's Hue integration on next poll. No reload required. Confirmed with Iconic rename.
**Pattern:** `curl -sk -X PUT -H "hue-application-key: $KEY" -H "Content-Type: application/json" -d '{"metadata":{"name":"X"}}' "https://$BRIDGE/clip/v2/resource/device/$ID"`

### Hue Bridge stores API key in core.config_entries, not anywhere obvious
`grep` against `hac/backup/` failed because the bridge backups don't contain the key.
The actual key lives in `.storage/core.config_entries` under `domain=hue`,
field `data.api_key`. Use:
`python3 -c "import json; d=json.load(open('.storage/core.config_entries')); [print(e['data']) for e in d['data']['entries'] if e.get('domain')=='hue']"`

### Hue rooms vs zones — HA exposure
A Hue **room** with multiple bulbs already creates a usable HA group entity
(`light.back_patio` covered both Iconic + Steps Light without any zone work).
**Zones are not needed for basic HA grouping** — only useful for grouping bulbs
across multiple rooms. The S57 prompt's "create a Back Patio zone" assumption
was wrong; the room already handles it.

### "TASK is already partially done" detection pattern
S57 prompt assumed green-field, but reality:
- Helpers (`quiet_travel`, `back_patio_manual_override`, `timer.back_patio_override`,
  `input_number.back_patio_scene_index`) all already existed from S55/S56
- 3 motion automations already had `quiet_travel` skip-conditions wired
- `back_patio_motion_lighting` description literally said "S57 changes"
**New rule:** Before any rewrite, search for the entity_ids the rewrite would create.
If they already exist, this is a finishing pass, not a build. Adjust scope accordingly.

### HANDOFF.md drift causes wasted reasoning
HANDOFF said S54, but actual last commit was S56. Project Memory said "post-S45"
which was further out of date. Effect: I assumed work hadn't been done that had been.
**New rule:** mcp_session_init shows last commit — if commit number > HANDOFF session,
the HANDOFF is stale. Pull recent git logs to fill the gap before assuming the prompt's
baseline.

### Timer + boolean override pattern (canonical for outdoor manual override)
Pair: `input_boolean.X_manual_override` + `timer.X_override`. Both must be set together.
- UP/config press: turn ON boolean + start timer 2hr
- DOWN press: turn OFF boolean + start timer 90s (motion-suppress cooldown)
- Config hold: turn OFF boolean + cancel timer (panic reset)
- Companion automation needed: when timer.finished event fires → turn off boolean
- Motion automation conditions: `boolean off AND timer idle` (covers both 2hr claim + 90s cooldown with one timer)

**Single timer doing double duty (claim + cooldown) is simpler than two timers.**
Outcome: motion is suppressed during both 2hr claim period and 90s post-DOWN cooldown.

### Disabling hot_tub_mode automations: turn_off (not delete)
`ha_config_set_automation` with config=null returns 400. There's no clean MCP primitive
to delete UI-managed automations. Workaround: `automation.turn_off` keeps them inert
+ visible in registry for forensics. Physical removal needs `.storage/automations`
surgical edit. Acceptable trade-off — the boolean they trigger on was deleted, so
they're double-defended against firing.

### Hue Behaviors API for motion-binding audit
`/clip/v2/resource/behavior_instance` returns all bridge-side automations (FOH switches,
motion bindings, time-of-day routines). Pre-flight check before any HA outdoor motion
automation: confirm no `enabled: true` behavior is bound to the same motion sensor.
Otherwise dual-fire / double-control conflicts are possible.

### Bash heredoc + python3 -c in single commands
- Use `2>&1 | head -N` to limit output and merge stderr
- Use `python3 -c "..."` for inline JSON parsing — avoids jq dependency
- Pipe `curl -sk` to python3 for both pretty-print and structured filtering
