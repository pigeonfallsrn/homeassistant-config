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

## S57 Addendum — Front Hallway Split via Hue CLIP v2 (2026-04-26 evening)

### Hue Bridge work pattern: full FOH switch wiring without HA touching anything
Successfully built a complete FOH-controlled fixture from scratch using only CLIP v2 PUTs/POSTs:
- Device renames (5 PUTs)
- Zone restructure (DELETE dup, PUT to repurpose, POST new zone)
- Scene creation (POST x3 per zone for full house standard set)
- behavior_instance binding (POST x1 per switch — this is what makes the switch DO something)
This is the canonical "switch controls scene" pattern, all bridge-side, zero HA round-trip latency.

### House-standard scene values (locked S57 — verified across 35 zones)
- **Energize**: brightness=100, mirek=156 (≈6410K cool/blue, mimics morning daylight — Hue stock template)
- **Relax**: brightness=56, mirek=370 (≈2700K warm)
- **Nightlight**: brightness=2, mirek=454 (warmest, dimmest — circadian-friendly)
**Pre-flight check:** When creating a new scene named "Energize/Relax/Nightlight", first dump existing scenes by that name across the bridge — match the dominant value before creating. Picking arbitrary values without a survey causes house-wide inconsistency.

### Hue behavior_instance: device→script→buttons→where→scene chain
Script `67d9395b-4403-42cc-b5f0-740b699d67c6` is the canonical "FOH switch" handler. To bind a switch to a scene:
1. Get the device's button service IDs (4 for 4-button FOH, also 4 for cosmetically-single-rocker — bridge always exposes 4)
2. Each button's control_id maps to physical position (1=top-left, 2=bottom-left, 3=top-right, 4=bottom-right)
3. POST behavior_instance with config containing `device.rid`, `model_id: FOHSWITCH`, and `buttons` dict keyed by button service UUID (NOT control_id)
4. Each button entry: `on_short_release` action (recall scene OR all_off), `on_repeat` (dim_up/dim_down), `where` (zone or room target)
5. **For consistent UX:** bind both top buttons (1 & 3) to the same recall, both bottom (2 & 4) to all_off — physical layout doesn't matter

### POST to behavior_instance with same device replaces existing binding
When POSTing a new behavior_instance for a device that already had one, the new POST inherits the existing UUID (or replaces silently). Net effect: one binding per device-script combo. This is convenient (you don't need to DELETE the old one first) but can be confusing when verifying — the "new" binding's UUID may match what was previously on the device.

### Hue scenes stay attached to a zone after zone rename
When zone `22271fad` was renamed from "Front Hallway" → "Stairway", its 3 existing scenes (S54-era Energize/Relax/Nightlight) **kept their group reference** to that zone. They became "Stairway scenes" automatically. No need to recreate scenes after zone rename — only after zone DELETE.

### CLIP v2 identify action = bulb breathing flash
PUT `/clip/v2/resource/device/{id}` with `{"identify":{"action":"identify"}}` triggers a brief breathe/dim. **Only visible if the bulb is already on.** Use the off-one-at-a-time approach (turn off N-1 bulbs, leave 1 on, observe) for unambiguous physical mapping. Identify is unreliable for "which bulb is which" mapping.

### Device renames don't propagate to HA logbook history
After a Hue device rename, HA's logbook continues to show events under the OLD name for events that occurred before the rename was polled. Activity views look like a stale device fired — actually it's just historical labeling. Wait for the integration to poll, then events going forward use the new name.

### Rooms vs Zones for HA exposure (canonical, S57 confirmed twice)
- A Hue **room** with multiple bulbs creates a single HA group entity (`light.front_hallway`)
- A Hue **zone** with multiple bulbs creates a separate HA group entity (`light.stairway`)
- Both can coexist — `light.front_hallway` covers the whole room (3 bulbs); `light.stairway` covers just 2 of those 3
- Zone is the right tool for "subset of a room with its own switch"; room is the right tool for "all lights in this physical space"

### Activity log "X turned on" with no obvious cause = parent group reflection
When a zone turns on, any room containing those zone-member bulbs ALSO logs "turned on" because some members are on. This is correct/expected — not a bug, not a stray automation. Only worry if the change includes lights that AREN'T members of any expected group.

## S59 (2026-04-27) — Auth-retry loop hunt: false-alarm diagnosis, LLAT cleanup, configuration.yaml stale-block strip

### Substantive learnings

- **Diagnostic discipline — second occurrence (PROMOTE).** S58 starter said "token REVOKED, scripts failing silently" — actual root cause was a `::1` IP ban predating any token issue. S59 starter said "auth-retry loop generating ~14 bans/week" — actual state was zero new bans for 13 days; the storm had ended on its own at the EQ14 cutover stabilization point. Pattern: starter framings inherit S(N-1)'s in-the-moment confidence and become stale by S(N) start. Always verify ground truth (count, timestamp, current vs. historical) before acting on starter premise. This is now a promoted rule.

- **`error_log` source returns 404 via ha_get_logs MCP.** Only `system` source works for log retrieval over MCP. system surfaces only structured WARNING/ERROR entries — INFO-level events ("Login attempt failed", successful auth) do not appear. For INFO/DEBUG retrospective, terminal grep on /homeassistant/home-assistant.log + .log.1 is authoritative.

- **HA log rotates aggressively.** 13-day-old entries are gone from home-assistant.log + .log.1 combined. Plan retrospective forensics for ≤1 week windows; for older state rely on persisted artifacts (ip_bans.yaml timestamps, .storage/auth refresh_token created_at/last_used_at).

- **`http.ban` logger at default level already includes URL + user-agent.** WARN-level "Login attempt or request with invalid authentication from <ip>. Requested URL: '<url>'. (<user-agent>)" — DEBUG isn't required for retrospective enrichment, only for per-request granularity. DEBUG remains cheap insurance for live capture.

- **LLAT `last_used_at` is NOT a reliable in-use indicator.** Tokens validating clients via JWT signature verification do not necessarily update the auth store on every request. The `Claude Desktop MCP` LLAT showed last_used_at 2026-04-14 yet MCP-served HA tools answered cleanly today. Conclusion: never revoke an LLAT based purely on stale last_used_at — probe with an authenticated tool call after a controlled revoke of any other LLAT first, verify in-flight auth still works.

- **Pre-revoke probe pattern (NEW workflow rule).** Before revoking ANY LLAT that might be the in-flight auth token, (1) revoke a different unambiguously-stale token first, (2) immediately call any authenticated MCP tool, (3) confirm response, only then proceed. Caught a near-mistake in S59 where I almost recommended revoking the LLAT that may be authenticating MCP itself.

- **WHOIS-on-external-IP triage shortcut.** Pattern "datacenter ASN (AS262287 Latitude.sh) + Cyber Assets FZCO London abuse contact" in IPinfo lookup = commercial VPN egress, almost certainly user's own VPN client. Don't escalate "unknown external IP touching token" without first asking the user "do you run a VPN on that device?" — VPN-on-phone is the high-prior explanation.

- **Migration-induced ban storms.** Green→EQ14 host cutover (S51) generated 71 bans across 23 days from T-Mobile/Verizon CGNAT IPv6 ranges before stabilizing. Mobile companion apps holding old-host tokens retry through cellular IPv6, each retry rotates to a new IP, each IP gets banned at 5-fail threshold. Future host migrations: rotate all mobile-issued tokens BEFORE re-pointing the tunnel, not after. Add to migration runbook.

### Workflow lessons

- **`&&` chain breaks at `diff` when files differ.** `diff` returns exit code 1 on difference (the success case for our use). For chains where diff is mid-pipeline and we want to continue regardless, use `;` separator after diff or append `|| true`. S59 lost the `ha core check` step at the end of the configuration.yaml edit chain because of this. Fix: separate the validation step into its own command, or use `;` between "show diff" and "validate."

- **Pattern-based sed (anchor-line to anchor-line) safer than line-number sed.** `sed -i '/^# Trusted networks for tablet auto-login$/,/^    - type: homeassistant$/d'` survives line-count drift between read and edit. Line-number sed (`sed -i '88,91d'`) does not.

- **Always backup before sed -i.** `cp file file.s<NN>-bak` immediately before, `rm file.s<NN>-bak` immediately after `ha core check` confirms validity. Costs nothing, saves a session if the edit goes wrong.

- **Pre-close one-click side-quests.** Repairs UI 1-click fixes (OAuth re-auths) and configuration.yaml logger suppressions are perfect tack-on items at session close — low cognitive load, knock items off the queue without changing scope.


## S60 (2026-04-27) — automations.yaml architecture correction + regen-template bug + diagnostic discipline 2nd occurrence

### Architecture correction: automations.yaml IS canonical for UI automations on this system

Long-held assumption in Project Instructions and prior HANDOFFs: "UI-first means all automations live in .storage/." S60 diagnostic disproved this.

Evidence:
- configuration.yaml:52: `automation ui: !include automations.yaml`
- .storage/: no automation files
- automations.yaml: 79 alias entries (matches HA automation count exactly)
- Mixed ID styles confirm UI editor + ha_config_set_automation MCP writes both land in the YAML

Rule: When `automation: !include X.yaml` is in configuration.yaml, that YAML file IS the canonical UI storage layer. There is no parallel .storage/automations on this system. Both UI edits and MCP-set automations write here.

Corollary: helpers, scripts, scenes, and other entity types may behave differently — each include directive needs individual verification before generalizing. Don't say "X lives in storage" without checking configuration.yaml for `X: !include`.

Implication: S58's "automations.yaml drift confirmed" finding was based on the faulty assumption. Content arriving via UI was correct behavior, not drift.

### Regen-template bug: session header bump is mandatory, not optional

S59 commit 2e0033a rewrote 197 lines of HANDOFF.md but `## Last Session: S58` header stayed unchanged. Content was current; metadata was stale. The drift wasn't visible until S60 session-init compared git log (S59 last commit) against HANDOFF header (S58).

Rule: HANDOFF regeneration must update session header AND content. Add to session-close protocol checklist:
- `## Last Session: S<NN>` matches current session
- `## WHAT HAPPENED IN S<NN>` matches current session
- Benchmark table gets a new column for S<NN>
- Last Commit gets filled post-push

### DIAGNOSTIC DISCIPLINE — 2nd occurrence confirmed, promote to PROMOTED RULES

S58 was the candidate; S60 is the second occurrence.

- S58: starter said LLAT was REVOKED. Diagnostic found `::1` IP ban. Token was likely working; rotation was a side effect of misdiagnosis.
- S60: prior HANDOFF said automations.yaml drift was "confirmed." Diagnostic found no drift — the file is canonical by design.

Both cases: treating the starter/handoff claim as established fact would have led to wasted execution (rotating a working token; "fixing" a non-broken architecture). Brief verification before action saved both sessions.

Promoted rule (apply in next governance update): When a session starter, prior HANDOFF, or LEARNINGS entry says "X is broken / confirmed / revoked / drifted," verify ground truth with a clean diagnostic before treating the claim as established. Especially for architectural or security claims where the cost of acting on a wrong assumption is high.

### Two-Occurrence candidate: chat-paste shell hygiene

S58 first occurrence: LINKIFICATION (chat-client mangling foo.bar patterns into hyperlinks).
S60 second occurrence: zsh history expansion on `!include` pattern → `zsh: event not found: include`.

Same root cause: text pasted from chat into interactive shell goes through layers of interpretation (chat-client formatting + shell history/glob expansion) before execution. Single-quoting strings containing shell-special characters (!, $, *, ~, URL-like foo.bar patterns) avoids both classes of failure.

This counts as 2nd occurrence under the same root-cause umbrella. Candidate for promotion to OPERATIONAL DEFENSES on next governance cycle as: CHAT-PASTE SHELL HYGIENE — single-quote anything in pasted commands containing !, $, *, ~, or foo.bar patterns to neutralize chat-client linkification AND shell history/glob expansion.


## S61 (2026-04-27) — HANDOFF regen-template-bug fix + diagnostic discipline 3rd occurrence

### Substantive learnings

- **Diagnostic discipline — 3rd consecutive occurrence (S58, S60, S61).** Already promoted at S60. S61 reinforced: read_handoff returned S58-headed file, "top of HANDOFF queue" appeared to mean #1 auth-retry hunt, but `git log` revealed S59 had already closed it and S60 had closed #2. Treating starter premise as truth would have wasted the session re-doing solved work. Pattern is now entrenched across 3 sessions; promoted rule is correctly placed.

- **mcp_session_init enrichment proposal.** Current init dumps git log + working tree + HANDOFF body. Body alone doesn't surface header/commit drift in the visible scroll. Proposal for S62: add `head -3 HANDOFF.md` and `git log --oneline -5` side-by-side at the top of init output so `## Last Session: S<X>` is visible next to the actual recent commits. Drift becomes unmissable.

- **Full overwrite > surgical edit for HANDOFF regen.** S59 attempted partial edits (body content correct, header stale). S60 documented the rule but did not rebuild the file. S61 demonstrated the only reliable shape: full `cat > HANDOFF.md << 'EOF' ... EOF` overwrite at every close. The file is small (~5KB), regen cost is trivial, partial-edit risk is real. Surgical edits to HANDOFF are now banned by convention.

- **`hac/` directory contains legacy artifacts, not active files.** `/homeassistant/hac/HANDOFF.md` and `/homeassistant/hac/LEARNINGS.md` exist with recent mtimes (Apr 27 11:44 and 12:43). Both are leftovers from pre-EQ14 `hac.sh` tooling era. The active files are `/homeassistant/HANDOFF.md` and `/homeassistant/LEARNINGS.md` at the repo root. Do not edit `hac/`-prefixed copies.

### Workflow lessons

- **`grep -c PATTERN file` returns exit 1 on zero matches.** S61 dump #1 chained through `&&`; output stopped at "IP_BANS TOTAL: 0" because grep -c returning 0 matches set `$?` = 1 and `&&` aborted the rest. Same root cause as S59 `diff`-on-difference. **Two-occurrence candidate: exit-code-aware chaining** — promote next governance cycle as: in diagnostic dumps, separate sections with `;` not `&&`, terminate complex one-liners with `; true`, and wrap optional/may-be-empty greps with `|| true`.

- **`; true` terminator confirmed.** Dump #2 used `; true` at end-of-line and ran to completion despite intermediate `awk`/`find` returning empty. Pattern is reliable; adopt as default for diagnostic one-liners.

- **`HA_MASTER_PROJECT_PLAN.md` was archived in S58** (commit `e9ca905`) but cached references in dump templates can cause `ls` chains to break when one path is missing. When chains include file paths, prefer `ls -la X Y Z 2>/dev/null` (with redirect on the whole `ls`) over assuming all paths exist.

## S62 (2026-04-27) — hot_tub deprecation completion + linkification depth + exit-code-aware chaining 2nd-occurrence

### LINKIFICATION REACHES DEEPER, BUT IS PURELY CHAT-DISPLAY
Chat-client autolinks `boolean.school_tomorrow` as `[boolean.school](http://boolean.school)_tomorrow` because `.school` is a registered TLD. The autolink wraps only the matchable substring; surrounding `input_` prefix and `_tomorrow` suffix stay outside the link boundary. When user copy-pastes from chat into terminal, the terminal's paste handler strips markdown to display text, reproducing the original plain-text string. **Linkification is a chat-display artifact only when surrounding chars stay outside the autolink boundary.** Don't panic-rewrite based on chat appearance — verify file content via grep/diff. S62 burned ~10 min on a recovery script that wasn't needed.

### EXIT-CODE-AWARE CHAINING (PROMOTED — 2nd occurrence)
`&&`-chained `grep -c "pattern"` returning 0 (zero matches) is exit code 1 and kills the rest of the chain. **Rule:** diagnostic/verification dumps where every part should run regardless of individual results use `;` separator. Reserve `&&` for sequential ops where each step's success is a precondition for the next (file edits, deploys, installs). First occurrence S61, second S62 — promote to operational defenses.

### HELPER DELETION RETURNS ENTITY_NOT_FOUND WHEN ALREADY ORPHANED
`ha_config_remove_helper` returns ENTITY_NOT_FOUND when helper was never in (or was previously removed from) entity registry, even if YAML/automation refs persist. Refs are inert: Jinja `is_state(missing_entity, 'on')` gracefully evaluates False with no error or warning. **Implication:** absence of HA error logs is NOT proof referenced entities exist. Verify via ha_search_entities or ha_get_state before assuming refs are live.

### DEPRECATION FRAMING ≠ DEPRECATION EXECUTION (1st-occurrence — track for promotion)
S57 commit "Hot Tub deprecation" actually only deleted the helper; left 6 automations + 2 package template branches live. S62 finished the actual deprecation. **Rule candidate:** when a session frames work as "deprecation"/"removal", the audit must verify full scope of refs gets removed in the same pass — not just the headline entity. Distinct from entity-ref-hygiene (which is about broken refs to existing entities); this is dangling refs to deleted entities.

### TWO-WRITE EQUIVALENCE
First heredoc rewrote packages/adaptive_lighting_entry_lamp.yaml with clean `|` block scalars; Python recovery from .s62.bak restored original ugly serialized format minus hot_tub branches. Both produce functionally identical sensor outputs (HA strips whitespace from template state). No retry needed for cosmetic improvement; HA's parser is format-agnostic for template state.

### HANDOFF REGEN BUG STILL UNRESOLVED AS OF S62 START
S61 commit message claimed "HANDOFF regen-template-bug fix (full rebuild)" but S62 session-init found HANDOFF.md still showing S58 baseline content. S61's fix did not stick. S62 close uses standard heredoc paste workflow with explicit verification (head/grep) to test whether the regen process now works.

## S62 (2026-04-27) — RETROSPECTIVE: workflow improvements

### SURGICAL EDITS STAY SURGICAL (1st occurrence — track)
S62 package edit task was "remove 2 hot_tub branches" but Claude delivered "rewrite full file with clean block scalars AND remove 2 branches". Two writes for net-zero formatting change. Recovery from .bak reverted formatting anyway. **Rule:** when task says "remove X", edit removes X only. Cosmetic improvements are separate sessions, separate commits. Mixing concerns inflates blast radius and complicates rollback.

### FILE-CONTENT VERIFY BEFORE PIVOTING TO RECOVERY (1st occurrence — track)
S62 chat displayed `[boolean.school](http://boolean.school)_tomorrow` (autolinked TLD) and Claude declared "linkification disaster" without grep/diff verification of the actual file. The file was always correct. ~10 min lost to recovery script for a non-problem. **Rule:** when chat display looks corrupted, run grep/diff on file content (2 seconds) before declaring failure. Chat display is suspect; the file is truth.

### PRE-FLIGHT REGISTRY CHECK BEFORE ANY ha_*_remove (PROMOTABLE — high leverage)
`ha_config_remove_helper("hot_tub_mode")` returned ENTITY_NOT_FOUND in S62 because helper had been orphaned in a prior session. A 1-second `ha_search_entities("hot_tub_mode")` upfront would have skipped the failed delete entirely. **Rule:** always `ha_search_entities` before any `ha_*_remove` call. The query is effectively free; the failed delete is not.

### EDIT-VIA-PYTHON-READING-ORIGINAL > FULL HEREDOC REWRITE (workflow shift)
For existing files: pattern is `read .bak → string-replace → assert old_str in src → assert new_str in out → write`. Asserts catch bad replacements, preserves byte-for-byte non-target content, no retyping. **New default:** full heredoc only for NEW files. For existing-file edits, read-replace-assert pattern. Bonus: side-steps linkification entirely because chat only renders the small replacement strings, not the whole file.

### BACKTICK TLD-BEARING STRINGS IN CHAT CONTENT (PROMOTED — 2nd occurrence with S58 chain)
When writing entity names containing `.school`, `.hot`, `.travel`, `.app`, `.dev`, `.com`, etc. into chat output, wrap in inline code spans. Chat clients do not autolink inside backtick code spans. Costs nothing, avoids the entire S58/S62 linkification panic class. First occurrence S58 (single-quoted heredoc terminators), second S62 (TLD strings in heredoc body) — promote to operational defenses.

### GITIGNORE HARDENING NEEDED — *.bak *.corrupted *.orig *.tmp BASELINE
S62 caught .bak commit leakage at last second via amend. Audit revealed 6 pre-existing `.bak` files in `hac/` already tracked from prior sessions. Pattern recurs. **S63 micro-task:** audit `git ls-files | grep -E "\.(bak|corrupted|orig|tmp)$"`, untrack matches, harden gitignore. Done as one-shot, not as recurring overhead.

### HANDOFF REGEN BUG WAS WORKFLOW DRIFT, NOT TEMPLATE BUG
S58 found drift, S61 claimed template fix that didn't take, S62 close used manual heredoc paste with inline verification (head/wc/grep before commit) and committed cleanly. **Reframe:** the close ritual IS the fix. Stop engineering a template; document the ritual once and follow it every time. Required ritual: heredoc paste, then `head -3 HANDOFF.md` (confirms session number), `grep -c "^## WHAT HAPPENED IN S<NN>"` (confirms = 1), `grep -c "^## S<NN>" LEARNINGS.md` (confirms = 1, no double-append), then commit.

### DIAGNOSTIC DISCIPLINE PAYING DIVIDENDS (4th occurrence — durable)
S58: starter said "REVOKED" — wrong. S60: starter said "drift detected" — was non-drift. S62: starter said "top of queue" — queue 80% stale (S59/S60 burned through). Verifying ground truth (git log, file grep) before executing has now saved meaningful rework in 3+ consecutive sessions. Already promoted at S60; surface this rule MORE often when session starters make claims of state.

### DROP STRAWMAN OPTIONS (style — Claude side)
When offering A/B/C/X/Y/Z, every option must be a genuine path. S62 closed with X/Y/Z where Z was "close + note something we already do automatically" = filler. Two real options is enough. Trust user's binary decision-making.

### S62 SESSION QUALITY READ
Task delivered cleanly (72 automations, 0 hot_tub refs, clean push). ~15 of ~90 minutes lost to self-inflicted overhead (formatting rewrite, linkification panic, failed helper delete). Strong: diagnostic discipline, verify-before-push, amend-before-push catch on .bak leakage. Weak: destructive-action ergonomics, edit-scope discipline, panic threshold on chat-display artifacts.

## S62 (2026-04-27) — HANDOFF drift root cause: read path bug, not regen template

### The actual bug
For 5 sessions (S58-S62) we believed HANDOFF.md was being regenerated from a template at session init. S58 named it "regen-template-bug", S60 "diagnostic discipline" learning came from re-investigating it, S61 attempted "full rebuild" fix that didn't take. **There was no template. There was no regenerator.** `shell_command.read_handoff` was defined as `cat /config/hac/HANDOFF.md`. Every session's close ritual wrote `/config/HANDOFF.md`. Two real files, both on disk, divergent for 5 sessions. Reading the wrong file every session start created the appearance of "drift" because the read returned an older real handoff that never got updated.

### Fix
- Edited configuration.yaml: read_handoff and mcp_session_init paths from `/config/hac/HANDOFF.md` to `/config/HANDOFF.md`
- HA full restart required (shell_command not affected by reload_core target=all)
- Archived 7 stale handoff files (hac/HANDOFF.md, hac/HANDOFF_S11_PATCH.md, root S32-S36_HANDOFF.md) to hac/archive/handoffs_pre_s62/
- Verified: post-restart `read_handoff` returns S62 content

### PROMOTABLE RULE — read-path-vs-write-path asymmetry
When a "drift" or "regen" persists across multiple alleged fixes, audit the **read path** before fixing the **write path** again. Asymmetry between where data is read and where data is written is a common drift source — and it hides because both files are real, both have plausible content, and the close ritual updates the one you're looking at while session-init reads the one you're not. **Symptom:** "we keep fixing it but it keeps coming back." **Diagnostic:** `grep -rn "ACTUAL_PATH" configuration.yaml shell_commands.yaml` to confirm the read path matches what your write ritual produces. Generalizes beyond HANDOFF.md to any periodic-update document, log, or state file. Add to operational defenses on next governance review.

### shell_command reload behavior
`ha_reload_core(target="all")` reloads 16 components (automations, scripts, scenes, groups, helpers, templates, persons, zones, core, themes) but NOT shell_command. shell_command definitions are loaded at HA startup only — changes require full ha_restart. Counter to S40+ "prefer reload over restart" preference for shell_command edits.

### Other reads still pointing at hac/
`read_critical_rules` and `read_critical_rules_full` still point at `/config/hac/CRITICAL_RULES_CORE.md` and `/config/hac/CRITICAL_RULES.md`. Files exist there. Whether they're stale or current is unaudited as of S62 close. **S63 priority candidate:** verify these or migrate them to repo root for parity with HANDOFF.md.

## S63 (2026-04-27) — MCP ha_set_entity wraps the websocket; S45 bulk-rename rule obsolete

### Finding
S45 promoted rule said: "Entity registry renames: REST API returns 404 — must use websocket (config/entity_registry/update). Bulk renames: python3+websockets script (aiohttp unavailable in HAOS)". This was true at the time. It is no longer true.

`ha_set_entity` (MCP) accepts `new_entity_id` and internally calls the websocket `config/entity_registry/update` op. ZHA child entities renamed cleanly, one call per entity, state preserved, friendly names preserved. No SSH, no python script, no token handling.

### Confirmation
43 ZHA entities under one VZM30-SN renamed across 7 domains (light, button, number, select, sensor, switch, update). All succeeded. No rollbacks. Verification: `ha_search_entities("drivay")` returned 0; new prefix returned 43.

### New rule (promote to Instructions on 2nd occurrence)
For ZHA / integration-managed entity registry renames, prefer MCP `ha_set_entity(entity_id=old, new_entity_id=new)` over SSH websocket scripts. Combine `new_device_name=...` on any one call to rename the device in the same op.

### Workflow lesson
When a starter or HANDOFF cites a constraint from older sessions ("needs websocket script"), spend one MCP call to test the modern path before scripting. The 30-min budget for this rename collapsed to ~2 min of MCP calls. Two-Occurrence Rule says next confirmation promotes this — filing as candidate.

### Side note
House convention for Inovelli SBM switches confirmed: `{area}_{fixture}_inovelli_smart_bulb_mode_*`. Verified against the two existing 2nd-floor bathroom switches. The VZM30-SN's prior slug (`front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode_*`) was the outlier in both spelling and verbosity. Fixing both at once cost no additional effort because all 43 had to be touched anyway.

## S64 (2026-04-27) — area cleanup + search-filter learning

### NEW — ha_search_entities silently excludes disabled-by-integration entities
S63 verify-rename search reported "drivay → 0 hits ✓" but two RSSI/LQI sensors with
disabled_by="integration" remained. They were caught only at S64 baseline by reading
the device's full entity list via `ha_get_device(detail_level=full)`.

Pattern fix: when renaming a device's child entities, the post-rename verify must use
`ha_get_device(device_id)` to enumerate ALL children (including disabled) — NOT a
substring search of `ha_search_entities`. The latter has a hidden filter that drops
disabled-by-integration entities from default results.

### CONFIRMED 2nd occurrence — Diagnostic Discipline rule (PROMOTE: drop candidate tag)
S58 first-occurrence: starter claim contradicted ground truth.
S64 second-occurrence: HANDOFF claimed `area_id=null` for VZM30-SN device; baseline
`ha_get_device` showed `area_id=entry_room`. Verifying at baseline prevented an
unnecessary "move null → front_driveway" framing that would have masked the actual
state ("move from entry_room → front_driveway").

Recommend in next governance review: drop "(S58 — 2-occurrence candidate)" tag from
DIAGNOSTIC DISCIPLINE in OPERATIONAL DEFENSES — now a permanent promoted rule with
S58 + S64 evidence.

### NEW — Device-area-move is the durable pattern for Hue cross-area pollution
Hue platform entities have `area_id=null` at entity level and inherit area from device.
Use `ha_update_device(area_id=...)` not `ha_set_entity(area_id=...)`. Benefits:
- Connectivity / zigbee_connectivity sensors come along automatically (same device)
- 4 FOH button events handled in 1 device update vs 4 entity updates
- No fragile entity-level override that can de-sync from device

### WORKFLOW — Mid-session scope discovery is OK
S64 starter scope was "VZM30-SN area + calendar". Baseline surfaced (a) 2 missed
stragglers and (b) 6+ misplaced entities in VFD. Expanding scope mid-session was
correct because (i) baseline data made the additional moves trivially safe, (ii) the
extra moves were verifiable in-session, (iii) deferred-ambiguous items got documented
explicitly for S65. Counter-rule: scope creep is OK when the new work is bounded,
testable, and the unbounded portion is captured as deferred — not when chasing
unbounded threads.

## S65 (2026-04-27) — Hue Room/Zone semantics, device-level area cascade, diagnostic discipline 2nd occurrence

### Hue Room vs Hue Zone — device.model is the deciding signal
When deciding area assignment for a Hue grouping, check device.model:
- model="Room" = single physical room in Hue app. Standard pattern: 1 light + 3 scenes (Energize/Relax/Nightlight). Maps cleanly to one HA area.
- model="Zone" = cross-room logical grouping. Standard pattern: 1 light + 2 scenes (Energize/Relax). Spans multiple physical rooms — area choice is judgment, not deterministic.
Collapses the "one room or multiple" gating question without physical knowledge.

### ha_update_device(area_id=...) cascades to entities when entity-level area_id is null
Default state for Hue (and most integration-discovered) entities is area_id=null at entity level — they inherit from device. Updating device area propagates to all child entities in one call. Verified S65: 7 entities across 2 devices migrated with 2 device-level calls. Default to device-level area update; only use ha_set_entity when entities explicitly override device area.

### DIAGNOSTIC DISCIPLINE — 2nd occurrence (promotion candidate fulfilled)
First occurrence S58 (starter claims "X is broken/confirmed/revoked" need verification before treating as fact). Second occurrence S65: recommended removing Stairwell_Night_Light based on "12 unavailable entities" alone; checked device.manufacturer/model before executing and found Third Reality 3RSNL02043Z battery-powered nightlight — battery depletion is more likely than physical removal. Reversed recommendation before destructive action.
**Generalized rule:** Before recommending destructive action on an "unavailable" device, check device.manufacturer + device.model. Battery-powered Zigbee devices (Third Reality, Aqara battery, etc.) have legitimate offline states that don't warrant removal.
**Per Two-Occurrence Rule: ready for promotion to PROMOTED RULES** on next governance pass.

## S66 (2026-04-28) — Entity stack "redundancy" is usually role separation

When auditing an area with multiple entities sharing a name root (entry_room_ceiling_*, light.entry_room, light.entry_room_ceiling_light, etc.), the default mental model "5 lights for 1 fixture = redundant" is wrong more often than right. Resolve the topology first via:
1. ha_get_entity batch → device_id and platform per entity
2. ha_get_device(area_id=...) full → device hierarchy + Hue model field (Room vs Zone vs color lamp)
3. ha_get_state on rollups → is_hue_group, hue_type, lights[] reveals what's a container vs a leaf
4. ha_deep_search per entity_id → who actually consumes it

In S66, 6 "ceiling-related" entities resolved to: 2 physical fixtures (3 bulbs total) + 1 Inovelli SBM virtual + 1 Hue Zone (functional bulb-subset) + 1 Hue Room rollup. Zero true redundancy. Renaming work gated on a separate architectural question (room split). Don't reach for ha_set_entity or rename scripts until topology + consumer references are mapped.

Workflow lesson: when the goal is "audit + rename if useful", split decisively. Audit produces a topology document; rename is a separate session with explicit physical-layout assumptions stated up front. Mixing them risks half-renaming based on an unconfirmed merge.

## S67 (2026-04-28) — Workflow improvements: bundled git_push + git_status surfaces dirty tree + read_learnings

### shell_command.git_push was push-only, project memory said it bundled
For multiple sessions, project memory described the close ritual as "stage, commit, push via shell_command.git_push" — implying one call did all three. S66 close demonstrated otherwise: `git_push` ran `git push origin main` only. Tree stayed dirty, no commit, push reported "Everything up-to-date" (because there were no new commits to push). Took 3 retries and a `read_handoff` ground-truth check to diagnose.

Patched the shell_command in configuration.yaml to actually bundle: `git add -A && (git diff --cached --quiet || git commit -m "$1") && git push origin main`. The empty-commit guard means it's safe to call with no pending changes — push succeeds, no fake commit. Live test on the configuration.yaml patch itself: one call, clean commit, clean push.

**Generalized rule:** When project memory describes a tool's behavior, verify the actual implementation before relying on it across sessions. Especially for tools that wrap multi-step workflows — "X does A+B+C" descriptions are easy to write and hard to falsify without testing edge cases.

### shell_command.git_status was unpushed-commits-only, hid dirty working tree
Original `git_status` was `git log origin/main..HEAD --oneline` — only showed local-but-unpushed commits, not modified-but-uncommitted files. S66 close: `git_status` returned empty stdout while user's prompt clearly showed `✗`. The MCP and the human were looking at different parts of git state.

Fixed: `git status --short` first (working tree), then `git log origin/main..HEAD` (unpushed). Both now visible from MCP without needing terminal access. The dirty-tree blind spot is closed.

### Withdrawing LINKIFICATION 2-occurrence flag from S66 close
S66 close raised "linkification reaches command lines, not just heredoc bodies" as 2-occurrence material. Wrong. S62 LEARNINGS already documented: linkification is purely chat-display, terminal paste-handler strips markdown back to plain text on the way in. The `[HANDOFF.md](http://HANDOFF.md)` formatting John saw in `git status --short` output was the chat client rendering the output, not the file or commit being corrupted. File contents and commits were always correct.

S62 already promoted the right defense (backtick TLD-bearing strings in chat output). No additional rule needed. The S66 flag was real-time over-reaction without checking past LEARNINGS first.

**Workflow lesson:** Before raising a 2-occurrence governance flag, search LEARNINGS for the same phenomenon. The Two-Occurrence Rule counts independent occurrences across sessions, not "I noticed something twice in one session." S58/S62 had already counted; S66 was a third sighting of the same already-promoted phenomenon, not a new candidate.

### HA shell_command parameter passing — the `_ "{{ message }}"` trick
To pass a Jinja template variable as `$1` into `bash -c "..."`, the pattern is:
```yaml
git_push: 'bash -c "cd /config && ... commit -m \"$1\" ... " _ "{{ message }}"'
```
The `_` is a positional placeholder for `$0` (program name), then `{{ message }}` becomes `$1`. Inside `bash -c`, escape `\"$1\"` so YAML's outer single-quoted scalar passes through to bash with the actual quote characters. Without quoting `$1`, shell word-splitting would fragment any commit message with spaces.

## S68 (2026-04-28) — Governance pass + CRITICAL_RULES collapse

### Workflow lessons
- Two-Occurrence Rule + HANDOFF queue can disagree. When HANDOFF flags "promote X" but X has only 1 occurrence in LEARNINGS, the rule wins. Honest defer + add to a watch list. This protects Project Instructions from accumulating low-evidence rules. (Applied to BATTERY DEVICE S65 + ha_set_entity supersedes S63.)
- Governance pass slippage compounds. Missed S65/S66/S67 = 3 sessions of staleness, made S68 take longer than it would have on cadence. Strict every-5-sessions, no exceptions, no "I'll catch it next time."
- Two redundant canonical files (CORE + full) doubled read cost without doubling value. One canonical file at repo root + archive of predecessors is the right shape. Total content shrunk from ~73KB to ~13KB by removing: session-history blocks, decommissioned-Green sections, hac.sh references, superseded workflow rituals (now in Project Instructions), security/privacy backlog (now in HANDOFF), session promotion log (now LEARNINGS' job).
- Post-restart 400 Bad Request on existing shell_command may NOT mean config failure. S62 rule was: "If new commands return 400, config did NOT load." S68 observed: existing `git_status` returned 400 immediately after CONNECTION_FAILED resolved, then succeeded on retry 30s later — shell_command integration hadn't finished loading yet. Refinement: 400 once → wait 30s and retry; 400 twice in a row → real config failure.

### Tactical lessons
- Device renames silently rot inventory documentation. front_driveway VZM30-SN was renamed S63 to `light.front_driveway_inovelli_smart_bulb_mode` (Tier 1 SBM), but the inventory in CRITICAL_RULES_CORE.md INOVELLI ECOSYSTEM AUDIT block kept circulating it as Tier 2 dumb load. Caught only because S68 governance pass forced re-verification. Rule: when a device is renamed, update entity registry + CRITICAL_RULES inventory + any HANDOFF references in the SAME session.
- ha core check returning "Command completed successfully" with no error block = exit 0 = clean (different signal than the S62 "partial success" non-zero exit). Both are green; the 0-exit case is unambiguous.

### Promotion candidates (watching for 2nd occurrence)
- BATTERY DEVICE: check manufacturer/model + battery state before destructive registry action on `unavailable` device. S65 was first occurrence (Aqara P1 reported unavailable but had dead battery, not orphaned).
- ha_set_entity supersedes S45 websocket workflow for entity renames (S63 first occurrence).

## S69 (2026-04-28) — Outside-of-Claude paste tasks: payload must live in HANDOFF, not chat

**Context:** S68 HANDOFF queue item #1 was "Land Phase A Project Instructions edits — drafted in S68 chat." S69 loaded stale Project Instructions (DIAGNOSTIC DISCIPLINE still tagged "(2-occurrence candidate)", BACKTICK TLD STRINGS absent, `git_push` bundled wording absent). The S68 drafts were referenced but not retrievable — chat history does not carry into the next session.

**Problem:** When a queued action requires the user to paste content drafted by Claude into an outside-of-Claude surface (project settings, NordPass, NAS config UI, etc.), and the session closes before the paste happens, the drafted content is effectively lost. Next session must re-derive it from HANDOFF + LEARNINGS + memory pointers — costs a session turn or more, and any nuance from the original drafting conversation is gone.

**Rule:** Outside-of-Claude paste tasks must include the full paste-ready payload as a fenced code block inside HANDOFF.md (or, if too large, saved to `hac/pending/<topic>.md` and referenced by path). "Drafted in S<NN> chat" is not a valid pointer.

**Workflow lesson — close discipline:** S68 closed with the Phase A drafts in chat but not in HANDOFF. The close protocol verified acceptance criteria for the *session goal* (governance pass + CRITICAL_RULES collapse) but did not verify that *queued items requiring user action* had their payloads persisted. Add to close checklist: for every S<NN+1> queue item that depends on user paste/upload/manual action, confirm the payload is reachable from HANDOFF.md (inline or path reference) before generating the heredoc.

**Cost this time:** ~1 session turn re-deriving the drafts. Cheap because the source-of-truth (HANDOFF S68 list of 4 promotions + memory user_memories S67 update) was rich enough to reconstruct. Could have been worse if the drafts had nuance not preserved elsewhere.

**Promotion status:** Single occurrence (S69). LEARNINGS only. Promote on 2nd occurrence of an outside-of-Claude task losing its payload across a session boundary.

## S70 (2026-04-28) — health_check build + workflow refinements

### TECHNICAL — health_check.py architecture (DOCUMENTED)
- 11 sections, single source of truth at `/config/hac/scripts/health_check.py`
- Wired via existing `shell_command.health_check` (already in shell_command block since pre-S70 — was pointing at a 3KB inventory-only stub)
- Detail at `/config/hac/health_check_detail.txt` (gitignored)
- Section list: [1] unavail entities (excl device_tracker, person, *_battery*), [2] PSI cpu/mem/io avg10, [3] disk %, [4] DB GB, [5] active repairs (from `.storage/repairs.issue_registry`), [6] integration setup errors (log grep), [7] recent ERROR/CRIT in last 1000 log lines, [8] ZHA double-fire (zha_event device_ieee + platform:device domain:zha), [9] HANDOFF count drift, [10] git working tree, [11] last commit age
- Inventory + area-less summary appended
- Thresholds: disk WARN 85% / CRIT 95%, DB WARN 1GB / CRIT 3GB, PSI WARN 10.0 / CRIT 50.0, unavail WARN ≥1 / CRIT ≥10
- Run time ~0.6s

### TECHNICAL — UI automation storage on EQ14 (CORRECTED)
- `.storage/automations` does NOT exist on this box. UI-managed automations live in `/config/automations.yaml` (HA's default behavior with no `automation:` integration override)
- Same for scripts: `/config/scripts.yaml`, helpers split across `.storage/input_*` files
- Project rule "0 YAML automations/helpers" was wrong; corrected to "0 hand-edited YAML automations/helpers"
- Affects all future scripts that read automation config — use `yaml.safe_load(open(AUTOS_YAML))` not `.storage/automations`

### TECHNICAL — ZHA double-fire detection pattern
- For `automations.yaml` (UI-managed): scan triggers for `platform: event` + `event_type: zha_event` + matching `event_data.device_ieee`, AND `platform: device` + `domain: zha` + matching `device_id`
- Generic shared `entity_id` triggers are NOT a useful signal (intentional shared state triggers are normal); ZHA-specific is the right granularity per TRIPLE-FIRE PROMOTED RULE

### WORKFLOW [CANDIDATE] — Phase 0 "Adopt/Adapt/Build" dump
- This session lost ~5 turns to progressive rediscovery of existing partial implementation (`shell_command.health_check` already wired, `health_check.py` already existed but was a stub, `health_check.sh` was an unused alternate, `health_automations.py` was a third companion, `.storage/automations` path was wrong on this box)
- Pattern fix: any "build a tool" carryforward gets a single Phase 0 terminal dump as turn 1 covering: `ls /config/hac/scripts/ /config/scripts/ /config/python_scripts/`, `grep configuration.yaml for the relevant feature`, `find . -name '*<keyword>*'` under `/config/hac/`, HACS-installed integration scan, plus a 5-min web pattern survey
- Promote-on: second carryforward where existing partial impl discovered mid-build

### WORKFLOW [CANDIDATE] — maximalist single diagnostic dump
- Issued 5 separate diagnostic dumps across S70 (turns 4, 6, 8, 9, 11) instead of one comprehensive one. Each dump answered just enough to need the next.
- Pattern fix: investigation-phase dumps default to maximalist — existing files, schemas, paths, env, smoke test of existing thing, 2-3 representative samples — single block, single paste
- Promote-on: second investigation phase that exceeds 3 turns

### WORKFLOW [OBSERVATION] — auto-verify project rules at session start
- "0 YAML automations" rule survived ~50 sessions because nothing checked it against the file system. Now that health_check.py exists with the count-drift section, this is free.
- Action: extend `mcp_session_init` shell_command to `&&` chain a 1-line health_check summary
- Surfaces drift at session start, before work begins, not at session close

### WORKFLOW [OBSERVATION] — every CANDIDATE entry needs a "promote-on" line
- S69 added a watch list but promotion-trigger criteria were implicit. S70 hit at least one watch-list item but the promotion was manual.
- Format adopted in this entry: `Promote-on: <specific second-occurrence trigger>`
- At session close, grep LEARNINGS.md for `[CANDIDATE]` and verify whether this session triggered any promotion. Turns governance review from "every 5 sessions manual" to "every session automatic."

### WORKFLOW [OBSERVATION] — community pattern survey paid off
- HAGHS (HACS) provided the score+advisor structure that made [each section's output one-line + remediation hint]
- System Monitor PSI > raw % for "actually struggling" signal
- Watchman's ignore-class concept informed the device_tracker/person/_battery_ exclusions
- Pattern: any monitoring/audit/health build is improved by a 5-min HA community search before designing from spec. Cost: 1 web_search call. Benefit: avoid local re-invention.

### PROMOTION CANDIDATES UPDATE (for S75 governance review)
- HANDOFF DRIFT (S58 first, S70 second) — **READY TO PROMOTE** to PROMOTED RULES: count drift in HANDOFF is real and unflagged without explicit cross-check; health_check.py [9] now does this automatically

## S71 (2026-04-28) — health_check filter v2, MCP path repair, two governance learnings

### Technical

**HA Core shell_command auth scope (NEW PROMOTION CANDIDATE — 2nd occurrence, S70 bare hac/health pattern was 1st):**
- `SUPERVISOR_TOKEN` IS injected into shell_command subprocess env (length 112, confirmed) but its scope is Supervisor API only, NOT Core REST API
- All three Core endpoints (`http://supervisor/core/api`, `http://localhost:8123/api`, `http://homeassistant:8123/api`) return HTTP 401 with that token
- Fix pattern: long-lived access token (LLAT) created via HA UI → Profile → Security, stored at `/config/.health_check_token` (chmod 600, gitignored), script falls through env → file
- Use `http://localhost:8123/api` when authenticating with LLAT (script subprocess in Core container reaches Core directly); use `http://supervisor/core/api` when using SUPERVISOR_TOKEN (addon path)
- Script reads both, tries env first (so terminal path keeps working), file second

**Filter design — health_check chk_unavail v2:**
- "unavailable" + "unknown" states across all entities are dominated by domains that are unknown-by-design until first interaction
- Promote to EXCLUDE_DOMS: `event` (zha_event etc., unknown until first fire), `scene` (unknown until first activation)
- Promote to EXCLUDE_RE: `button.*_(identify|restart|power_cycle|reset_*)` (stateless action buttons), `update.*_firmware` (unavailable when no update pending — Inovelli/ratgdo pattern)
- Result: ~40% noise reduction (653 → 393) without losing any actual diagnostic signal
- Conservative leftovers: `number.*` and `select.*` Inovelli config endpoints (77+16) — could be promoted later but some are real

### Workflow / governance

**S70 close note misdiagnosis (NEW PROMOTION CANDIDATE — 2nd occurrence after S58/60/61/64/65 diagnostic-discipline cluster):**
- S70 close note claimed "30+ false positives are firmware updates" — actually 9 out of 653 (1.4%)
- S70 close note implied `shell_command.health_check` was working — actually [1] always errored 401 from MCP path; "first-run findings" came from terminal where SSH addon has different auth
- Lesson: **S70 close note had two factual errors that S71 caught only because we did a fresh terminal dump before patching**. If we had trusted the handoff and patched only `_firmware`, we'd have shipped a fix that dropped 9 entries instead of 260.
- Promotion: any S<NN> close note diagnosis must come from a fresh dump in that same session, not from older memory or assumption. If the diagnosis isn't backed by a `=== ... ===` block dumped during the session that wrote the note, it doesn't go in the close note.

**Secret-channel ambiguity (NEW LEARNING):**
- Said "paste here when ready (or paste into /tmp/llat.txt via terminal)" — the "or" allowed user to interpret the easier option as paste-into-chat
- LLAT was leaked into chat session, browser console history, and any conversation logs
- Required full revoke + recreate cycle, costs ~5 min and a NordPass churn
- Lesson: when asking for a secret, the prompt MUST specify exactly one channel and that channel MUST be terminal-only. Phrase: "Open browser terminal, run `nano /path`, paste, save, then tell me 'done'." Never include "paste here" or "send me the token" anywhere in the request.
- Promote to OPERATIONAL DEFENSES on next governance review.

**Linkification / backtick TLD strings — confirmed working under stress (S58/S62 rule held):**
- LINKIFICATION rule survived three nested heredocs in this session — no failures attributable to that rule
- BUT: chat client inserted stray `\;` inside heredoc body when a URL string was followed by `]:` on same line — first time this manifested *inside* a heredoc rather than in prose
- Workaround applied: list URLs with trailing commas, closing bracket on its own line, no `]` adjacent to URL string
- Not promotion-worthy yet (1st occurrence of inside-heredoc form), but worth noting if it recurs

## S72 (2026-04-28) — INSTRUCTIONS.md foundation, governance promotions, session-init trim

### Technical

**INSTRUCTIONS.md as versioned source of truth:**
- Pre-S72 state: project rules lived only in chat-starter paste — not in git, not versioned, no diff history. Every chat session re-pasted ~6KB rule block from somewhere outside the repo.
- S72 fix: rules captured verbatim into `/config/INSTRUCTIONS.md`, exposed via new `shell_command.read_instructions`. Future sessions can `cat` from inside-repo source instead of relying on external paste.
- Session-starter paste still works (3-line minimal form per protocol), but now there's a versioned target for promotions and a single source of truth.

**HA shell_command binding lifecycle:**
- `homeassistant.reload_core_config` reloads customize/packages but does NOT re-register shell_command bindings — those load only at startup.
- For shell_command additions/edits: full `ha_restart` is required. `ha_reload_core(target='core')` is insufficient.
- Hot-reloadable: automations, scripts, scenes, groups, input_*, timers, counters, templates, persons, zones, themes, core (customize/packages). Everything else needs restart.
- Confirmed by: adding `read_instructions` line to configuration.yaml, calling reload_core (no effect on binding), then ha_restart (binding registered).

**MCP `ha_call_service` parameter shape:**
- Param name is `data`, not `service_data`. Cost one extra tool call to discover.
- Pattern for shell_command with parameters: `ha_call_service(domain="shell_command", service="git_push", data={"message": "..."}, return_response=true)`.

### Workflow / governance

**Token-efficiency wins this session:**
- Trimmed `mcp_session_init`: removed redundant HANDOFF.md dump from inline yaml. Output went from ~3.3KB to ~280 bytes per call (~91% reduction). HANDOFF is already returned by `read_handoff` which runs immediately before init — the duplication was waste.
- Net: every future session start saves ~3KB.

**Building infra vs. workflow rules:**
- John raised: should we build a `safe_restart` shell_command that wraps check + restart atomically?
- Decision: NO. The MCP tools `ha_check_config` and `ha_restart` already work cleanly. Building shell_command-as-orchestrator adds brittleness (restart kills script mid-execution; need fire-and-forget; can't easily return validity status). The real value was the *rule* "never restart without checking" — and that's a discipline patch, not infra.
- Captured as CONFIG EDIT WORKFLOW in INSTRUCTIONS.md.

**Pattern: when in doubt, rule before tool.** Workflow rules cost 8 lines of markdown. Tools cost a script + yaml binding + restart cycle to register + ongoing maintenance. Choose rules unless the rule is being violated repeatedly despite being known.

### Promotions

This session promoted four learnings from LEARNINGS.md into INSTRUCTIONS.md:

| Original learning | Original session | Promoted to INSTRUCTIONS section |
|---|---|---|
| HA Core auth scope (LLAT for shell_command path) | S71 | (kept in LEARNINGS — instance-specific technical knowledge, not a behavioral rule) |
| S70 close-note misdiagnosis → DIAGNOSTIC DISCIPLINE provenance clause | S71 | OPERATIONAL DEFENSES → DIAGNOSTIC DISCIPLINE → Provenance clause |
| Secret-channel ambiguity → SECRET REQUEST PROTOCOL | S71 | OPERATIONAL DEFENSES → SECRET REQUEST PROTOCOL (1st-occurrence under credential-class carve-out) |
| Regex pre-flight check pattern | S71 retro | SHELL RULES → REGEX PRE-FLIGHT |
| CONFIG EDIT WORKFLOW (check_config → reload/restart) | S72 (own session) | New section between SHELL RULES and SESSION STARTER PROTOCOL |

Plus governance additions to INSTRUCTIONS.md GOVERNANCE section:
- Credential-class carve-out (1st-occurrence promotion for secret-leak failure modes)
- Promotion tracking convention (this `### Promotions` subsection pattern)


## S73 (2026-04-29) — carryforward refactor + 393-unavail diagnosis (no entities cleared)

### Technical

**Apollo MSR-1 ESP-button-not-rebooting (1st occurrence — note for promotion if recurs):**
- ESPHome devices expose a `button.<device>_esp_reboot` entity that should restart the ESP.
- This session: pressed `button.entry_room_r_pro_1_esp_reboot` via `ha_call_service(button.press)`, service returned success with new last_changed timestamp, but the ESP's uptime sensor did NOT reset and downstream sensors stayed in their pre-press state.
- Possible causes: (a) ESPHome firmware on the device has the reboot button defined but its action is misconfigured/no-op; (b) HA→ESPHome auth lapsed; (c) device rejects the command at firmware layer.
- Workaround paths for S74: try integration-level config entry reload first; if that fails, hit dashboard direct reboot.
- Watch for this pattern on other ESPHome devices in S74+. If 2nd occurrence: promote to INSTRUCTIONS as "ESPHome reboot via HA button is unreliable; use integration reload or dashboard."

**Template ghost pattern (NEW — analog of S45 ghost script):**
- Template entities with `platform: template`, `attributes.restored: true`, and state `unavailable` AND no yaml definition in `/config/packages/`, `/config/templates.yaml`, or `/config/configuration.yaml` are GHOSTS.
- Origin: a previous package refactor renamed/removed the yaml that defined them; their entity registry entries persist with last-known state (loaded from recorder DB on each restart, never refreshed by source).
- Fix: same as S45 ghost-script pattern — `ha_remove_entity`. NOT yaml work, NOT package work; the yaml is already correct (no definition exists).
- Detection query: REST API `/api/states`, filter `state == "unavailable"` AND `attributes.restored == true`. Confirmed 22 ghosts in this session.
- 1st occurrence of TEMPLATE-platform variant of this pattern. S45 was script-platform. Likely promotable to a generic "GHOST ENTITY pattern" rule when 2nd occurrence happens.

**Carryforward refactor (S72-flagged retro item, executed S73):**
- Single-instance carryforward block was being copy-pasted across HANDOFF.md every session — three sessions of identical text in different commits.
- Fix: extract to `/config/CARRYFORWARD.md`, lightly versioned, edited only when items resolve. HANDOFF references it instead of duplicating.
- AndroidTV "DO NOT DELETE" was MIS-classified as carryforward — it's a standing rule, moved to INSTRUCTIONS.md NEVER DO.
- Net: ~15 lines saved per HANDOFF, single source of truth for open items, pattern transfers cleanly to other long-running projects.

**Pre-flight assumption-checking (S71 REGEX PRE-FLIGHT rule paying off):**
- This session: my "Inovelli config" hypothesis for `number.*`/`select.*` filter promotion was WRONG. Pre-flight (listing actual entity_ids) showed they track real device problems. Filtering would hide signal.
- Cost of pre-flight: one extra terminal dump (~15 sec). Cost of skipping: would have shipped a filter that hides Apollo, Yamaha, ratgdo, and dual-plug failure modes.
- This is the second time pre-flight saved a wrong move (S71 was the first — `=== UNAVAIL ===` regex was wrong header). 2nd occurrence on the value of pre-flight; the rule itself is established (S71-promoted) so this just confirms it's working.

### Workflow / governance

**Diagnosis-only sessions are valid sessions:**
- S73 ended with NET ZERO entities cleared from 394. That looks bad in a benchmark column.
- But: 3 wrong assumptions corrected (filter promotion non-viable, Apollo not "device offline", Yamaha partial-state mid-air), 1 new pattern discovered (template ghosts), 1 unblock-needed item identified (ESP-button broken).
- The DIAGNOSTIC DISCIPLINE rule (S71-promoted, provenance clause) means: a session that shifted understanding without changing state isn't a wasted session — it's the foundation that lets the NEXT session ship a real fix.
- HANDOFF needs a "Diagnosis value" framing alongside numerical reductions, otherwise diagnosis-heavy sessions look like failures. Worth noting for HANDOFF template iteration.

**Tool-loading cost (1st occurrence — note for promotion if recurs):**
- This session needed: `ha_call_service`, `ha_get_state`, `ha_get_entity`, `ha_get_integration`. Loaded them in three separate `tool_search` calls instead of one batch.
- Ideal pattern: at session start, after init, do ONE batched `tool_search` covering all anticipated tool categories.
- Counter-pattern observed this session: `ha_get_integration` was not surfaced even when I searched for it specifically, suggesting tool_search ranking is keyword-sensitive in non-obvious ways.
- Promotion candidate if this recurs in S74. For now, just a note.
