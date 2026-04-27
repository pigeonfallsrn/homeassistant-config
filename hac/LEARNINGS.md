# LEARNINGS LOG — Accumulated across sessions
# Format: S## | Category | Learning
# Promoted to CRITICAL_RULES after 2nd occurrence

S44 | kiosk-mode | Does NOT work on strategy dashboards — must use storage-mode
S44 | fkb | Tier 1 (native wake/sleep) vs Tier 2 (HA automations) pattern
S44 | fkb | set_config requires device_id, not entity_id
S44 | fkb | switch.*.motion_detection is a toggle, not a sensor
S44 | entity-refs | RULE PROMOTED: Always verify entity existence before trusting automation configs (2nd occurrence: S42 Entry Room, S44 bathroom+tablet)
S44 | triple-fire | Multiple automations on same ZHA IEEE all fire — must delete legacy, not just disable
S44 | dashboard | .storage/lovelace.* is gitignored — dashboard configs not version-controlled
S44 | google-cal | OAuth tokens don't transfer between HA instances — need fresh flow
S44 | tablet-user | Non-admin + kiosk_mode + FKB kiosk lock = full lockdown stack
S43 | yaml-migration | MCP returns 0 for YAML-defined entities — reliable signal, not error
S42 | entity-refs | Broken entity refs survive across sessions (1st occurrence)
# (paste LEARNINGS_S45_APPEND.md content here)  

---

## S58 (2026-04-27) — Token Rotation + IP Ban Diagnosis

### NEW LEARNING: HA's IP ban middleware returns plain-text "403: Forbidden" (14 bytes), not HA's JSON error format
**Diagnostic value: HIGH.** When debugging 403s on HA API:
- 403 with body `{"message": "Unauthorized"}` (JSON) → HA's auth subsystem rejected the request → token problem
- 403 with body `403: Forbidden` (plain text, 14 bytes, `Content-Type: text/plain`) → aiohttp ban middleware blocked BEFORE auth check → IP ban problem
- 401 → HA's auth subsystem replied, token format invalid or absent

Always run `curl -v` and inspect Content-Type + body, not just status code. Status alone is ambiguous between the two failure modes.

### NEW LEARNING: `curl localhost` resolves to `::1` (IPv6) before `127.0.0.1` (IPv4) on HAOS
HA tracks IP bans separately per address family. Banning `::1` blocks every "obvious" loopback test from the host even though `127.0.0.1` is clear. To force IPv4 in diagnostic curls: `curl -4 ...`. To target IPv6 explicitly: `curl http://[::1]:8123/...` (square brackets required).

### NEW LEARNING: Self-banning is possible via auth-retry loops from internal services
The EQ14 host (192.168.1.10) banned itself on 2026-04-26. The decommissioned Green (192.168.1.3) was banned. ::1 was banned. Pattern indicates internal HA components or local scripts repeatedly authenticating with stale credentials get IP-banned by HA's own ban middleware. Effects compound: ban → next request route → ban → etc.

### NEW LEARNING: HA does NOT have `requests` module in system Python
For standalone shell tests of HA API auth patterns: use `urllib.request` (stdlib, always present). The `requests` module is only available inside HA's own Python environment (custom_components, integrations).

### NEW LEARNING: HAOS Python heredocs with `'PYEOF'` (quoted) survive chat-client linkification
When pasting Python via heredoc from chat: quote the heredoc terminator (`<< 'PYEOF'` not `<< PYEOF`). Quoted heredocs disable shell expansion AND the linkified `[name](http://name)` markdown gets passed through to Python verbatim — Python ignores it because it's syntactically a list+function call that's never evaluated. Works as protection against chat paste corruption. **Caveat: fails if the linkified text appears inside an actual Python string or as a bare identifier the script needs to reference.**

### NEW LEARNING: Backup files named `*.bak.s58*` are auto-ignored by `.gitignore` `*.bak.*` pattern
Useful for ephemeral session backups: rename pattern `<file>.bak.s<NN>` → automatically excluded. No need to add per-session entries.

### WORKFLOW LESSON: Verify "confirmed broken" claims before acting on them
The S58 starter prompt stated the LLAT was "confirmed REVOKED" with "Google Sheets sync + REST commands silently failing." Audit found:
1. Old token's 403 was likely an IP ban (not revocation) — original verification was insufficient
2. `export_to_sheets.py` had ZERO callers in any automation/shell_command/python_script — it was never running on a schedule, so couldn't be "silently failing" in a way that mattered
3. The actual broken state was 5+ weeks of accumulated IP bans, completely unrelated to the LLAT

**Rule:** When a session opens with "X is confirmed broken, fix it" — re-verify the broken state with a clean diagnostic before treating it as established fact. Today: ~90 minutes of work that turned out to be solving the wrong problem (rotation was clean, but the urgency framing was wrong; the real issue was found incidentally).

This is the **second** occurrence of "starter-prompt claim turned out to be misdiagnosed on closer inspection." Promoting to two-occurrence-rule candidate. If a third occurrence happens in S59-S62, promote to CRITICAL_RULES.

### WORKFLOW LESSON: HANDOFF.md drifted across S55–S57 (3 sessions)
File on disk showed S54 content despite S55, S56, S57 closures. Recovery was possible only because S58 starter prompt and git log preserved state. Going forward: HANDOFF.md regeneration is mandatory at session-end. No exceptions, no "I'll do it next time."

### WORKFLOW LESSON: Chat-client linkification is real and must be defended against
Observed corruption in pasted commands during S58:
- `f.read` → `[f.read](http://f.read)`
- `yaml.safe_load` → `[yaml.safe](http://yaml.safe)_load`
- `notify.mobile_app_galaxy_s26_ultra` → linkified prefix
- Email-like patterns → mailto links
- `HANDOFF.md` → linkified

Defenses:
1. Quoted heredocs (`'EOF'`) — most robust for python/shell embedded scripts
2. Pre-paste into a plain text editor to inspect for `[...](...)` corruption
3. Re-type any line containing dots-with-words that auto-linkified
4. For long blocks, save to temp file via nano then `bash /tmp/script.sh`

### NEW LEARNING: `git rm --cached` removes from index without deleting on disk
Useful when `.gitignore` was added AFTER files were tracked. The files remain on disk (HA keeps writing to them), but git stops tracking changes. After `git rm --cached`, the file may show as untracked (`??`) on next status — that's correct, `.gitignore` will exclude it from staging.

### NEW LEARNING: `automations.yaml` may be drifting from `.storage` (architectural — pending S59 diagnosis)
S58 found uncommitted S57 content in `automations.yaml` despite S57 closing with a clean commit. UI-first architecture says `.storage` is canonical for automations and `automations.yaml` should be untouched. Either:
- HA dual-writes (config + .storage)
- Direct YAML edits happened (MCP tool? shell script?)
- File is symlinked or included from elsewhere

Investigation deferred to S59. Content was correct so committed, but the WRITE PATH needs auditing.


---

# BACKFILL: S46-S57 LEARNINGS (reconstructed S58, 2026-04-27)

The following entries were reconstructed from chat history during S58 cleanup
to fix the LEARNINGS.md drift. These are not contemporaneous logs — they are
distilled summaries of the durable technical patterns from each session. For
session-by-session detail, the original chats remain in the Claude project.

---

## S46 (2026-04-19) — Garage automation review

- Hue migration rule confirmed 2nd time: garage dimmer still referenced
  hue_dimmer_switch_4 instead of garage_dimmer_switch. After any Hue re-add,
  scan ALL automations for stale light.* / scene.* refs.
- 13 broken entity refs found in garage; nearly half of all garage refs were
  broken. Strong validation for batch ha_get_state verification before any
  config edit.
- python_transform tool does not support isinstance() — switching to full
  config replacement is cleaner anyway for multi-ref fixes.
- ESPHome reflash rename pattern observed: ratgdo32disco_fd8d8c renamed to
  garage_north_garage_door_ratgdo32disco after reflash (9 of 13 broken refs
  were this pattern). Equivalent of Hue migration renames for ESPHome side.
- Workflow gap: HANDOFF.md still showed S44 when S45 work started — drift
  acknowledged here as the precedent for the larger gap that S58 found.

## S47 (2026-04-20) — VZM36 IEEE mapping + entity rename mass operation

- REST API entity registry rename returns 404 — endpoint does not exist for
  individual entity renames. MUST use websocket: type
  config/entity_registry/update with entity_id and new_entity_id.
- Bulk rename pattern: python3 + websockets library (pip3 install websockets
  --break-system-packages). aiohttp is NOT available in HAOS.
- curl/REST approach silently fails (grep finds nothing, no error output) —
  so the failure mode is invisible without explicit verification.
- VZM36 EP2 endpoint creates BOTH a fan entity AND a light entity that
  control the same physical output. Disable the redundant light_2 entity on
  every VZM36 module — its brightness mirrors fan speed (33/66/100%).
- VZM36 wire colors: blue=EP1 (light), red=EP2 (fan). Swapped controls means
  physically reversed wires at canopy (no software fix possible).
- VZM36 naming convention: fan.{area}_fan, light.{area}_ceiling.
- ZHA cluster writes for VZM36: manufacturer param must be integer 4655 NOT
  hex string. Common gotcha when writing custom cluster attributes.
- Smart Bulb Mode dashboard tiles = on/off only, NO dimmer slider available.
- 87 entity renames performed in S47 — entity registry changes live in
  .storage/ (gitignored), so these survive reboots but are NOT version
  controlled. Same applies to dashboard configs.

## S48-S49 (2026-04-21) — Inovelli systematic optimization across 9 switches

PROMOTED RULES (all 3+ occurrences across S48-S49):

- SBM speed standard: button_delay=0, on_off_transition_time=0,
  local_ramp_rates=0 on every Smart Bulb Mode switch. Factory defaults
  (127 ramps, 30 transition) cause perceptible lag between paddle press and
  Hue bulb response.
- LED bar standard: on_intensity=33, off_intensity=1, color=170 (blue).
  Factory defaults vary 33-95; must normalize per gang box (3-gang especially
  noticeable when LEDs do not match).
- AUX switch config: button_6_press requires aux_switch_scenes=ON parameter.
  Up=button_5_press, down=button_4_press.

OPERATIONAL PATTERNS:

- Do NOT mix Adaptive Lighting with scene cycling on the same lights.
- Use Hue zones (not rooms) for targeting subsets of bulbs.
- 3 scenes max for config-press cycling — more is unusable.
- ha_bulk_control supports on/off/toggle ONLY — fails silently when given
  number.set_value or other domain-specific service calls.
- For multi-param Inovelli writes use individual ha_call_service with
  wait=False each.
- Derivative helper reconfigure via options flow returns 400 errors. Reliable
  pattern: ha_delete_config_entry, then recreate without entry_id, then
  immediately ha_set_entity to rename the auto-generated entity_id (which
  inherits the source device's full name = unusably long).
- ha_search_entities domain_filter does NOT accept comma-separated values.
  Use list format or separate calls per domain.
- Timer helpers created with name matching an existing broken automation
  reference auto-generate a matching entity_id, resolving the ref without
  any automation config edit.
- VZM31-SN built-in humidity sensor: accuracy +/- 5%, intended for
  rate-of-change detection not absolute. v4 system using absolute thresholds
  (>70 ON, <55 OFF) works because relative readings are consistent.

## S50 (2026-04-21) — Garage door Chamberlain Security+ 2.0 deep dive

- Ratgdo obstruction sensor stuck ON: rapid OFF to ON cycling on ~100ms cycle,
  never stays cleared. Matches ratgdo GitHub issue 568.
- Chamberlain opener refuses close commands when obstruction is active. The
  van's physical remote can override (Chamberlain allows second physical press
  to force-close past obstruction), but ratgdo close command via Security+ 2.0
  cannot.
- Chain: stuck obstruction sensor blocks HA-triggered close, opener perceives
  obstruction = active, close command ignored.
- Ratgdo north 192.168.21.111 (fd8d8c). South 192.168.21.21 (5735e8).

PROMOTED RULES (3+ occurrences):

- Never include ratgdo light.* entities in any HA automation. Chamberlain
  handles its own light. HA light commands via Security+ 2.0 cause
  obstruction sensor interference.
- After migration, remove ALL integrations on old HA instance that connect to
  devices the new instance manages. "No automations" does NOT equal "no
  interference" — the integration itself can interfere even when no
  automations are present.

## S51 (2026-04-22) — Green deprecation complete

- Green shutdown via "ha host shutdown" — 59 conflicting integrations stopped.
- Harvested Navien creds (NordPass), Yamaha YNCA config at 192.168.21.171:50000.
- All YAML dashboards archived to hac/archive/dashboards_yaml_s51/.
  configuration.yaml left with clean "lovelace: mode: storage" only.
- HACS dashboard stack settled: Mushroom + auto-entities + card-mod +
  mini-graph-card + Kiosk Mode.
- auto-entities exclude pattern for "lights on now" views:
  light.adaptive_*, light.*inovelli*, light.*smart_bulb*, light.*ep2_*,
  light.*identify*.
- 3 storage dashboards: map, kitchen-tablet, arriving-home (all sections-view,
  all storage-mode).
- Identified shell_command.health_check pattern worth building: REST API for
  unavailable entities, double-fires, integration errors.
- Green available for future garage repurpose (fresh HAOS install).

## S52-S54 (2026-04-22 cluster) — Hue ecosystem audit + scene cleanup

- Full Hue Bridge inventory: 95 devices (47 bulbs, 8 accessories, 17 rooms,
  14 zones).
- Scenes cleaned via Hue CLIP v2 API: 148 to 101 (47 deletions, 0 failures).
- All rooms standardized to Energize / Relax / Nightlight (plus room-specific
  exceptions like Alaina's Malibu pink).
- Bridge backup exported to /homeassistant/hac/backup/ (git-tracked).
- Multi-ref fix pattern reconfirmed: full config replacement, not
  python_transform — same conclusion as S46.
- Motion light consolidation pattern: merge ON/OFF automations into a single
  matched pair with combined sensor + timeout helper. Cleaner than two
  separate automations sharing a sensor.

## S55 (2026-04-24) — 2nd floor bathroom rebuild + Living Room dimmer

- 2nd floor bathroom motion lighting rebuilt with bathroom_ceiling zone.
- Living Room dimmer config completed.
- Alaina's Kasa smart plug companion device setup.
- Started Aqara mini switch work but deferred — M3 hub Matter bridging not
  exposing the device to HA.
- HANDOFF drift incident: HANDOFF.md still at S54 content.

## S56 (2026-04-26) — Best-practice scorecard + registry cleanup

- Best-practice audit done against LIVE data (not HANDOFF text). Pattern
  worth repeating periodically.
- Cleanup: 7 redundant entities (4 disabled, 3 removed), 1 duplicate config
  entry deleted.
- 3 canonical entity_ids restored: weather.forecast_home,
  tts.google_translate_en_com, todo.shopping_list.
- VZM36 EP2 firmware redundancy now confirmed across 4 occurrences (S47-S56)
  — promoted-to-rule candidate via 2-occurrence threshold.
- Recorder still on SQLite with only ~4 days of history. Phase 22 MariaDB-on-NAS
  migration never executed — flagged as highest-impact single session left
  in the original master plan.

## S57 (2026-04-26 extended) — Front Hallway split via Hue CLIP v2

- Back Patio Iconic + Quiet Travel: Hot Tub Mode deprecated (6 automations
  disabled, helper deleted). input_boolean.quiet_travel is canonical
  travel-suppression toggle. Auto-off at midnight with phone notification.
- Back Patio Inovelli automation rewrite: drops broken Dimmed scene ref,
  paired override pattern (input_boolean + 2hr timer), 90s motion-suppress,
  panic-reset on config-hold.
- Front Hallway split via Hue CLIP v2 (no HA changes): 5 device renames,
  zone cleanup (deleted dup 25a68a7b, repurposed 22271fad as Stairway,
  created 7c8cb7c5 as Front Entryway), 3 new scenes per house standard,
  2 behavior_instance bindings (each FOH bound to its zone).
- Tested live: switches respond correctly.
- House standard scene values LOCKED across 35 scenes: Energize brightness
  100 / mirek 156, Relax brightness 56 / mirek 370, Nightlight brightness 2 /
  mirek 454.
- Hue FOH behavior_instance script_id: 67d9395b-4403-42cc-b5f0-740b699d67c6.
- Hue logbook quirk: shows stale names at time-of-event (not current names) —
  cosmetic only, do not "fix."

---

# END BACKFILL BLOCK
