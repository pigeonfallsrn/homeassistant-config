# CRITICAL RULES - READ FIRST
*Hard-won lessons from 2000+ lines of learnings. Don't repeat them.*

## ⚠️ BEFORE ANY EDIT
```
hac backup <filename>   # NON-NEGOTIABLE
```

## TERMINAL (ZSH)
- **Git errors** (`confused by unstable object`): Run `git gc --prune=now` twice (HA Green/SD card limitation)
- **Escape `!`** or use single quotes: `echo 'Hello!'` not `echo "Hello!"`
- **Never chain after `python3 -c`** on same line
- **BusyBox grep** (HA Green): NO `--include`, NO long options. Use `-rEl` for recursive+extended+filenames. Never `--include=*.yaml` — use `grep -rEl 'pattern' /path/` instead
- **BusyBox sed** (HA Green): NO multi-line, NO complex scripts. Use `python3` heredoc for non-trivial file edits
- **Paths**: `/homeassistant/` (not `/config/`)

## MOTION AUTOMATIONS (Times Hit: 15+)
- **Always `mode: restart`** for motion-triggered lights
- **Combined sensors need `delay_off`**: 60s minimum to prevent double-fires
- **Use combined binary_sensor**, not OR-ing individual sensors (race condition)
- **Dual trigger pattern**: motion ON starts, motion OFF with wait turns off
- **Timeout by room type**: transition 5-10min, active 8-20min, relaxation 15-45min
- **Double-fire fix**: Check for orphan automation entities with same unique_id

## INOVELLI SWITCHES (Times Hit: 15+)
- **Smart Bulb Mode**: Param 52=1 + LED bar params 95-98 for Hue bulbs
- **Config button cycling**: Use input_number + modulo, not input_select
- **Parameters require toggle OFF→ON** in ZHA UI then air gap to write
- **fxlt blueprint fires ALL zha_events** - filter by device_id or use unified blueprint
- **VZM35-SN fans**: Param 12 (auto-off) = 2700s for hardware safety backup

## ADAPTIVE LIGHTING (Times Hit: 10+)
- **Create/delete via UI ONLY** - no API exists
- **Hue bulbs require ALL THREE**:
  - `separate_turn_on_commands: true`
  - `take_over_control: true`
  - `detect_non_ha_changes: false`
- **Same make/model bulbs** per AL instance
- **Sleep mode**: 1-5%, 2200K, 10pm-6am for bedrooms
- **Current instances**: living_spaces, entry_room_ceiling, entry_room_lamp_adaptive, kitchen_table, master_bedroom_wall_lamp, upstairs_hallway

## ENTITY NAMING
- **ZHA gives generic entity_ids** (e.g., `inovelli_vzm35_sn_fan`)
- **Rename via `ha_rename_entity`** to location-based IDs
- **Device names are separate** from entity IDs

## MATTER/AQARA (Times Hit: 5+)
- **Recommission fix**: Remove stale fabric from BOTH HA Matter AND Aqara app
- **Use BOTH Matter + HomeKit** integrations (different devices exposed)
- **M3 IR blaster**: Does NOT expose to HA
- **Locks**: Matter only. Some sensors: HomeKit only.

## DOUBLE-FIRE PREVENTION CHECKLIST
1. Motion aggregation sensors have `delay_off`? (60s/60s/90s)
2. Using combined sensor, not individual sensors?
3. Check `hac health` for orphan automations with duplicate unique_ids?
4. Check for automations disabled in UI but still registered?

## NEVER EDIT DIRECTLY
- `.storage/core.config_entries`
- `.storage/core.entity_registry`
- `.storage/core.device_registry`
- Any `.storage/*.json`

## UI-ONLY (No API/CLI)
Adaptive Lighting, ZHA pairing, Hue linking, Matter commissioning

## SAFE VIA API
Automations, Scripts, Helpers, Services, Entity settings, Dashboards

## Storage-Mode Dashboard Backup (NON-NEGOTIABLE)
Before ANY kitchen-wall-v2 edit:
  cp /homeassistant/.storage/lovelace.kitchen_wall_v2 /homeassistant/hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
hac backup does NOT work for storage-mode dashboards. Never attempt it.

## Dashboard Transform Rules (hard-won)
- ALWAYS force_reload:True before any transform to get current hash
- NEVER do piecemeal index-based transforms across multiple calls — indices shift silently
- For section[0] edits: do ONE comprehensive rebuild, not multiple surgical edits
- After ANY transform: reload tablet + verify before next edit
- python_transform list comprehension on root cards[] can silently wipe sections — always use direct index ops

## Sections View Gutter — CONFIRMED FIX (2026-03-19)
WORKING: card-mod-view-yaml in kitchen_wall theme. Confirmed by user 2026-03-19.

/homeassistant/themes/kitchen_wall.yaml MUST contain exactly:
  ha-view-sections-column-max-width: 2000px
  ha-view-sections-column-min-width: 300px
  ha-view-sections-column-gap: 8px
  card-mod-view-yaml: |
    hui-sections-view:
      $: |
        :host {
          --ha-view-sections-column-max-width: 2000px !important;
        }

WHY: card-mod-view-yaml runs AFTER component init, sets CSS var at shadow DOM
host level before HA sections view applies its default. card-mod-root-yaml runs
too early and loses. CSS resource files lose specificity race. FKB customCSS
cannot pierce shadow DOM.

After theme change: frontend.reload_themes + clear cache + reload tablet.
DO NOT change this. DO NOT use any other approach.


## Bubble Card Popup — Music Button Root Cause (FKB 1.60.1 confirmed)
FKB 1.60.1 supports hash navigation — version is NOT the issue.
All failed approaches: navigate tap_action, hash on section button,
browser_mod fire-dom-event, root-level hidden trigger button + navigate.
NEXT HYPOTHESIS TO TEST: kiosk_mode non_admin_settings:kiosk:true intercepts
hash navigation before Bubble Card sees it.
TEST: temporarily set kiosk_mode:{} in dashboard, reload, test popup, then restore.

## atomic-calendar-revive — Confirmed Working Settings (wall tablet)
compactMode: false  ← NEVER use true, collapses card height
maxDaysToShow: 3-5, maxEventCount: 12-15
dateSize: 200+, titleSize: 190+, timeSize: 160+
column_span:1 on BOTH sections + max_columns:2 = correct 50/50 split
dense_section_placement: false  ← true fights column_span, causes regression

## Dashboard Session Start Protocol (NON-NEGOTIABLE)
1. cp .storage/lovelace.kitchen_wall_v2 hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
2. Read hac/BACKLOG_kitchen_dashboard.md — work from top of blocking items
3. ha_config_get_dashboard force_reload:True — capture current hash before ANY edit
4. Single comprehensive transform — never piecemeal
5. Reload + verify on tablet after EVERY transform before proceeding
6. Commit + log learnings before ending session

## FKB Auto-Update — DISABLE THIS
FKB auto-updates cause random browser restarts and dashboard stuck-on-logo issues.
Disable: FKB Settings > General Settings > Auto-Update Fully Kiosk Browser = OFF
Control updates manually during maintenance windows only.

## FKB Configuration via HA Service (PREFERRED METHOD)
Use fully_kiosk.set_config — works cross-VLAN, no port 2323 needed.
device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b

Key config keys:
  autoUpdateApp: false        # DISABLE — prevents random restarts
  customCSS: "css string"     # Inject CSS directly into FKB browser

FKB port 2323 blocked: tablet on IoT VLAN 192.168.21.x, PC on 192.168.1.x
UniFi firewall blocks LAN->IoT inbound. HA has cross-VLAN access already.

---

## ADAPTIVE LIGHTING — COLOR BEHAVIOR (Promoted 2026-03-22)
Times Hit: 10+

### Late-Night Red/Orange Lights
- **Root cause**: AL `living_spaces` pushes full circadian color to Hue color bulbs. At ~22:00 CST color reaches hue 10° / rgb(255,43,0) — deep red. This is correct AL behavior, not a scene bleed.
- **hot_tub_mode is NOT the cause** — always verify `input_boolean.hot_tub_mode` state before assuming scene bleed.
- **Manual override**: tap Hue switch or `light.turn_on` with explicit `color_temp_kelvin`. Holds until next on/off cycle (take_over_control:true).
- **Pending fixes**: (1) raise `min_color_temp_kelvin` floor on living_spaces AL instance; (2) disable adapt_color after time threshold via automation.

### hot_tub_mode Color Restore Gap
- Off automations (`auto_reset_at_3am`, `auto_off_when_back_inside`) do NOT explicitly restore light color.
- AL only corrects on next on/off cycle — lights can stay colored until then.
- **Fix needed**: add `adaptive_lighting.apply_to_lights` or explicit `light.turn_on color_temp_kelvin` in hot tub mode off actions.

---

## LIGHTING HYGIENE (Promoted 2026-03-22)

### Mode State Visibility Gap
- No dashboard indicator for active AL color mode or when special modes last ran.
- Backlog: Mushroom chips row on kitchen tablet — hot_tub_mode, sleep_mode, away state.

### Motion Lamp Automations — No Time Gate
- `automation.living_room_lamps_adaptive_control` fires on `binary_sensor.downstairs_motion` with no time-of-night condition.
- Color at turn-on = AL circadian value for that hour. Expected but can be surprising late at night.

### Unavailable Light Entities (audit 2026-03-22 — investigate)
- `light.upstairs_hallway_ceiling_1of3`, `2of3`, `3of3`
- `light.very_front_door_ceiling_hallway`
- `light.garage_opener_north_east`, `garage_opener_south_east`, `garage_opener_south_west`
- `light.upstairs_hallway_east_wall_night_light`

### Entity Naming Mismatches (audit 2026-03-22 — cleanup needed)
- `light.kitchen_west_wall_nightlight` friendly name → "Basement_Third Reality_Nightlight"
- `light.kitchen_counter_night_light` friendly name → "Stairwell_Night_Light"


## BINARY_SENSOR GROUP — delay_off NOT SUPPORTED (Times Hit: 1)
- `platform: group` binary sensors do NOT support `delay_off` parameter
- Adding `delay_off` to a group sensor causes the ENTIRE binary_sensor: block to fail silently
- The input_boolean: and automation: blocks in the same package file still load fine
- Fix: use `template:` binary_sensor instead — confirmed working in motion_aggregation.yaml
- Pattern: template OR-logic sensors have no delay_off either; put debounce on the automation
  (mode: restart + for: timer on the motion_off trigger is sufficient)
- DETECTION: new binary_sensor group entity = 404 after restart → strip delay_off and restart

## HAC CLI — PATH FIX (confirmed 2026-04-05)
- Script lives at: /homeassistant/hac/hac.sh
- Fix: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac && chmod +x /homeassistant/hac/hac.sh
- Permanent — survives reboots. Run once after any HAOS reinstall.
- Duplicate at /homeassistant/scripts/hac.sh — canonical is /homeassistant/hac/hac.sh

## HAC CLI — PATH FIX (confirmed 2026-04-05)
- Script lives at: /homeassistant/hac/hac.sh
- Fix: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac && chmod +x /homeassistant/hac/hac.sh
- Permanent — survives reboots. Run once after any HAOS reinstall.
- Duplicate at /homeassistant/scripts/hac.sh — canonical is /homeassistant/hac/hac.sh

## Session Promotions
- 2026-03-24: HAC: hac promote was silently writing to gist_output/03_knowledge.md which hac export overwrites on every run — fixed to write to CRITICAL_RULES.md under Session Promotions section
- 2026-03-24: HAC: hac wrap added as hardwired session-close ritual — prints 3-question checklist (gotcha/deadend/backlog) then calls hac close — run this instead of hac close going forward
- 2026-03-24: AUDIO: FireTV ADB chatters idle/playing/unavailable during Hulu — normal behavior. Fix: (1) add from:[off,standby,unavailable]+for:10s debounce to AVR-on trigger, (2) extend AVR-off timer to 20min, (3) add not-unavailable condition to off automation. Backup: fae184df.
- 2026-03-25: 1st floor hallway P1 automation: passthrough template, 8min shower guard, vanity immediate off, ceiling gated by sunset+override


## Ghost Entity Registry Surgery (CRITICAL)
- MUST use: ha core stop → edit /homeassistant/.storage/core.entity_registry → ha core start
- NEVER use ha core restart — HA flushes in-memory state back to .storage on shutdown, overwrites edits
- Pattern: filter data.data.entities by unique_id, write back, then ha core start

## ip_bans Self-Ban Pattern
- 192.168.1.3 (HA Green loopback) can be auto-banned if REST API fires with bad token 3x
- ip_bans.yaml is read at startup ONLY — editing file does not flush in-memory ban list
- Fix: edit ip_bans.yaml to remove self, then ha core restart
- Debug order: 1) check ip_bans.yaml for self-ban 2) verify token is populated 3) restart

## REST DELETE UI Automations (ZSH)
- Single-line curl required — multi-line heredoc splits incorrectly in ZSH
- Format: curl -s -o /dev/null -w "%{http_code}" -X DELETE "http://192.168.1.3:8123/api/config/automation/config/{unique_id}" -H "Authorization: Bearer TOKEN"
- Token must be real Long-Lived Access Token from HA Profile → Security tab
- Ghost entities from deleted YAML automations clear on next HA restart — REST DELETE is cosmetic only

## ⚠️  MCP BLIND SPOTS — TERMINAL REQUIRED FIRST (Times Hit: 5+)
*MCP sees entity states but NOT YAML source, deps, or config store origin.*

| Symptom in MCP | Why MCP lies | Fix |
|---|---|---|
| template binary_sensor = `unavailable` | Sees state not source/deps | `cat` defining YAML, check deps |
| `ha_config_get_automation` = RESOURCE_NOT_FOUND | Package YAML autos not in UI store | `cat packages/file.yaml` |
| `ha_deep_search` returns sub-IDs (north/south) | Stale cache index | terminal grep authoritative |
| notify target looks valid | Dead mobile_app targets persist in registry | `grep mobile_app_X .storage/` |
| Duplicate unique_ids same file | Second def silently wins, first = unavailable | `grep -c unique_id file.yaml` |
| Package auto + MCP edit = conflict | Both load on restart, stale YAML wins | Remove from YAML after MCP update |

**RULE: `unavailable` on YAML-owned sensor = `cat` the file FIRST, never diagnose from MCP state alone.**
**RULE: After MCP edits any package-file automation, always remove it from YAML before restart.**

## GARAGE/ARRIVAL AUTOMATIONS (Times Hit: 3+)
- **BT/sensor as TRIGGER not just condition** — if distance threshold already crossed when you get in vehicle, numeric_state never re-fires. Always add the connect event as a direct trigger.
- **mode: restart for arrival automations** — not mode: single. False-start connects (parking lots, brief stops) lock out the real arrival with single mode.
- **Door-opened race condition** — GPS lags 15-30s at zone boundary. Never use `binary_sensor.X_home` alone as condition on door-open trigger. Use recency template: `is_state('binary_sensor.john_home', 'on') or (as_timestamp(now()) - as_timestamp(states.person.john_spencer.last_changed)) < 120`
- **Package YAML + MCP edit = restart conflict** — after MCP writes an automation to UI store, remove it from package YAML before next restart or duplicate entity conflict occurs.

## TEMPLATE SENSOR AVAILABILITY (Times Hit: 3+)
- **Use OR not AND** in availability templates when either dep alone is sufficient. AND means one unavailable dep kills the whole sensor and everything downstream.
- **Ghost registry entries** — when template sensor YAML is deleted, entity registry entry survives. New YAML definition with same unique_id won't claim it cleanly. Fix: delete registry entry via Python, HA recreates on restart.
- **template.reload only reloads UI templates** — package YAML templates require `ha core restart` to re-register after changes.
- **Orphaned sensors = unavailable forever** — if sensor is `unavailable` for >24h with no state changes, YAML definition is likely missing. `grep -rn 'unique_id.*entity_name' packages/` to confirm.

## FAMILY CONTEXT — NEVER MIX THESE
- **Traci** = Alaina and Ella's mother. Lives Independence WI. `zone.traci_s_house` = at_mom_s for girls.
- **Michelle** = John's girlfriend. Lives 40062 US Hwy 53. `zone.michelles_house`. Mother of Jarrett and Owen.
- **at_mom_s sensors** must use `zone.traci_s_house` — never `zone.michelles_house`.
- BSSID `60:22:32`/`62:22:32` = Michelle's house WiFi. Never use for girls' mom detection.

## Ghost Entity Registry Surgery — AMENDED (2026-03-31)
Previous rule said `ha core stop/start`. Today's correct procedure:
1. Filter by `entity_id` NOT `unique_id` — unique_ids may not match entity_id stem
2. Scrub BOTH files in same python3 pass:
   - `/homeassistant/.storage/core.entity_registry` → remove from `data.entities`
   - `/homeassistant/.storage/core.restore_state` → remove from `data` by `state.entity_id`
3. `ha core check && ha core restart`
4. Verify with `integration_entities('template')` — NOT `states()` (stale restore_state fools it)
BusyBox grep: NEVER recurse from `/homeassistant/` root — times out on HA Green.
Scope to subdirectory (e.g., `/homeassistant/packages/`) or use targeted path list.

## GARAGE NOTIFICATION OVERLAP — MULTI-SYSTEM CONFLICT (Fixed 2026-04-02)
- THREE systems were all firing simultaneously on cover open: consolidated, alert, auto-close
- FIX 1: alert binary sensors MUST include presence check — door open AND not home
- FIX 2: alerts must use skip_first: true — false fires instantly, conflicts with auto-close
- FIX 3: garage_door_opened_close_option is DISABLED (initial_state: false) — redundant with alert system
- NEVER re-enable garage_door_opened_close_option without removing the alert system first
- Alert system (garage_door_alerts.yaml) is the ONLY "door is open" notification path
- Auto-close (garage_quick_open.yaml) is the ONLY departure notification path
- Verify before any garage edit: grep -n 'skip_first\|initial_state\|not is_state.*home' /homeassistant/packages/garage_door_alerts.yaml /homeassistant/packages/garage_notifications_consolidated.yaml


## GARAGE REMOTE/KEYPAD DEAD — ROOT CAUSE IS OBSTRUCTION (Not lock_remotes)
- RECURRING: Jan 2026, Feb 2026, Mar 2026, Apr 2026 — same root cause every time
- SYMPTOM: Van remote/keypad dead, solid orange keypad light, eyes completely dark
- lock_remotes IS A RED HERRING — has never been the actual cause, stop chasing it
- FIRST CHECK ALWAYS: ha_get_states on both obstruction sensors before anything else
  binary_sensor.ratgdo32disco_fd8d8c_obstruction (North — chronic)
  binary_sensor.ratgdo32disco_5735e8_obstruction (South — healthy)

## NORTH DOOR OBSTRUCTION — CORRECT DIAGNOSIS (revised 2026-04-02)
- PATTERN: off→on bouncing dozens of times/day every 1-2 seconds — NOT a wiring splice
- DB history confirms: 7 days of constant off→on in same second — intermittent wire
  would show extended off periods; this never does
- ROOT CAUSE: ratgdo32disco_fd8d8c firmware false-reporting obstruction continuously
  South board (5735e8) is identical hardware/wiring and is completely healthy
- EYES GOING DARK: power loss to sensor circuit — ratgdo board cutting sensor power
  during obstruction-check loop; cycling the door resets sensor power (LiftMaster
  cycles 12V to sensor circuit during door operation)
- WORKAROUND: Open/close door once to reset sensor power → eyes come back on
- HA COMMANDS STILL WORK when obstructed — only physical remotes/keypads are blocked
- ALERT: automation.garage_obstruction_alert fires after 30s sustained (filters
  the constant false bounces); South fires after 10s
- PERMANENT FIX OPTIONS (in order of likelihood to resolve):
  1. Flash ratgdo North board (fd8d8c) to latest ESPHome firmware — most likely fix
  2. Check/reseat North board wiring at opener terminals (not the sensor run itself)
  3. Replace North ratgdo board — South is healthy so it's board-specific
  4. Check ratgdo GitHub issues for obstruction false-positive reports on this chipset
- DO NOT: re-splice sensor wire runs — South is fine on same wiring

## GARAGE DIAGNOSTIC FAST-PATH — PASTE THIS FIRST IN ANY FUTURE SESSION
# Run this before ANY garage troubleshooting — answers 90% of questions immediately:
# ha_get_states: binary_sensor.ratgdo32disco_fd8d8c_obstruction
#                binary_sensor.ratgdo32disco_5735e8_obstruction
#                lock.ratgdo32disco_fd8d8c_lock_remotes
#                lock.ratgdo32disco_5735e8_lock_remotes
#                cover.ratgdo32disco_fd8d8c_door
#                cover.ratgdo32disco_5735e8_door
# Decision tree:
#   obstruction = ON  → firmware issue on North board, NOT wiring, NOT lock_remotes
#   lock = locked     → send lock.unlock to both (but verify obstruction first)
#   cover = open      → check auto_close automation fired correctly

## NEVER AUTO-CYCLE GARAGE DOOR FROM AUTOMATION (Hard lesson 2026-04-02)
- Auto-reset automation caused 9 unintended open/close cycles in 16 minutes
- FAILURE: obstruction bounces off->on every 1-2 seconds perpetually
  for: 2min debounce does NOT work — sensor never truly clears so automation loops
- RULE: NEVER trigger cover.open/close from obstruction sensor state — ever
- RULE: Any door-actuating automation MUST have ALL of:
  1. person.john_spencer == home condition
  2. time 07:00-22:00 guard
  3. input_boolean confirmation flag (human must enable it)
  4. mode: single + explicit cooldown
  5. max_runs counter helper to prevent looping
- Obstruction is a FIRMWARE problem — only safe HA response is NOTIFY, never actuate
- auto-reset automation (1775168359961) permanently deleted — DO NOT recreate

## RATGDO NORTH DOOR FIRMWARE FIX — CONFIRMED RESOLVED 2026-04-02
- Flashed v1394 (v32disco-esp32.ota.bin) via OTA at ~20:16 local time
- DB confirms: zero obstruction bounces after 20:16:35 — complete silence
- Before flash: dozens of off->on bounces per hour, every day, since Jan 2026
- After flash: board came back online, obstruction = on (static), no more bouncing
- Obstruction alert re-enabled post-flash (safe now — no more false bounce spam)
- If obstruction bouncing EVER returns: reflash to latest ratgdo firmware first
- South board (5735e8): healthy throughout, never touched, firmware unchanged

## SESSION HANDOFF — 2026-04-02 (Long night — read this first)

### WHAT WAS FIXED TONIGHT
1. clickAction regression (3rd time) — /lovelace/garage added to departure notification
2. Garage notification overlap — 3-system conflict eliminated
3. ratgdo North board (fd8d8c) — flashed v1394, chronic obstruction bounce FIXED
4. Auto-cycling door disaster — automation I created caused 9 cycles, deleted+rules added
5. 3 orphaned automations disabled — departure_garage_open_alert, departure_handle_garage_actions, garage_door_close_action_handler

### SYSTEM STATE RIGHT NOW
- Both doors: closed
- Obstruction bouncing: STOPPED (post v1394 flash, confirmed by DB)
- Obstruction alert: ON and safe (30s debounce filters any residual)
- 3 disabled automations: off via MCP stub — survive restarts now
- All git commits: a5a35a8, 60c1029, 01b1bee, f0f3384, e7aa87d

### FIRST TEST TOMORROW
Van remote should work — obstruction firmware was the only blocker

### PENDING WORK (deferred, not urgent)
1. Kitchen lighting audit — motion snappiness, P1 sensor consolidation,
   manual override trumping automations. Questions were asked but not answered:
   - Which zones = "first floor P1" — kitchen+lounge+entry or add living room?
   - What feels awkward — passthrough flickering or slow response?
   - Manual override: Option A/B/C (see earlier in session)
   - Is binary_sensor.downstairs_motion a group sensor or physical?
2. hac CLI missing from PATH — find and fix (run: find / -name hac -type f 2>/dev/null)
3. Garage automation final cleanup — 3 disabled stubs still in package YAML,
   could be fully removed eventually but low priority

### MCP LIMITATIONS LEARNED TONIGHT
- ha_config_remove_automation ONLY deletes UI-created automations, not package YAML
- Package automations with unique_id survive restarts from YAML even if YAML edited
- ha_config_set_automation CAN overwrite package automations with stubs (initial_state:false)
- BusyBox sed does NOT support multiline {n;a\} syntax — use python3 for multi-line edits
- HA config check output swallows terminal verify output — always MCP-verify after restart
- Bouncing sensors (off->on same second) cannot be debounced with for: timers
- NEVER actuate garage door from automation without: home + time + boolean flag + single mode

### RATGDO STATUS
- North (fd8d8c): v1394 flashed 2026-04-02, obstruction bounce resolved
- South (5735e8): healthy, untouched, do not flash
- OTA URL: http://ratgdo32disco-fd8d8c.local
- Next firmware check: https://github.com/ratgdo/esphome-ratgdo/releases/latest

## RATGDO STATUS OBSTRUCTION TOGGLE — PERMANENT WORKAROUND (2026-04-03)
- Firmware 2026.3.1 still bounces obstruction every 1-2 hours (reduced from every few seconds)
- PERMANENT FIX: Toggle "Status obstruction" OFF in ratgdo web UI
- URL: http://ratgdo32disco-fd8d8c.local → Status obstruction row → toggle Off
- Physical LiftMaster safety beam still works independently — toggling this off is SAFE
- After any ratgdo restart/OTA: check Status obstruction is still OFF
- DO NOT rely on binary_sensor.ratgdo32disco_fd8d8c_obstruction in HA — always false-positive
- Root cause: North board hardware issue, not firmware-fixable

## SOUTH RATGDO FIRMWARE — NEEDS FLASH (2026-04-03)
- South board (5735e8) still on 2025.8.4 — same firmware that caused North issues
- North board (fd8d8c) on 2026.3.1 — flashed 2026-04-02, working correctly
- South board needs same v1394 flash: http://ratgdo32disco-5735e8.local
- File: v32disco-esp32.ota.bin from https://github.com/ratgdo/esphome-ratgdo/releases/latest
- South had ESPHome dropout 2026-04-03 — possibly firmware-related
- After flash: verify cover.ratgdo32disco_5735e8_door updates normally

## BOTH RATGDO BOARDS NOW ON 2026.3.1 (2026-04-03)
- South (5735e8): flashed successfully via ratgdo installer page OTA firmware
- North (fd8d8c): flashed 2026-04-02
- Both boards healthy, communicating, locks unlocked
- North still has hardware obstruction bounce — cosmetic only, door operates fine
- South obstruction: clean (off) post-flash

## GARAGE NOTIFICATION ARCHITECTURE — FINAL 2026-04-04
### One tag per scenario — no stacking
- ARRIVING (HFL/distance): tag=garage_arrival_dashboard, clickAction=/lovelace/garage
- ARRIVED HOME: tag=arrival_john, clickAction=/lovelace/garage
- DOOR OPENS AT ARRIVAL: tag=arrival_john (OVERWRITES welcome home — no stack)
- DEPARTURE+OPEN: tag=garage_auto_close, clickAction=/lovelace/garage
- ALERT (5min open, away): tag=garage_door_north/south, skip_first:true
- WALK-IN DOOR: tag=garage_quick_open, clickAction=noAction

### Tag ownership — never duplicate
- arrival_john: notifications_system.yaml arrival_notification_john
  + garage_door_opened_arrival_notification (overwrites)
- garage_arrival_dashboard: garage_smart_arrival_dashboard_popup only
- garage_auto_close: garage_auto_close_north_on_departure only
- garage_door_north/south: native alert system only
- garage_quick_open: garage_walk_in_door_quick_open only

### clickAction verify command
grep -rn 'clickAction' /homeassistant/packages/garage*.yaml \
  /homeassistant/packages/notifications_system.yaml

## SYSTEM AUDIT 2026-04-04 — SESSION HANDOFF

### Completed This Session
- Both ratgdo boards on 2026.3.1 ✅
- Notification architecture finalized — one tag per scenario ✅
- Garage automation audit complete — 21 active, 3 disabled stubs ✅
- Backup created: afd36e7c (Pre_System_Audit_2026-04-04)

### NEXT SESSION 1 — configuration.yaml fixes (HIGH PRIORITY)
Dead entity references silently breaking templates in configuration.yaml:
- Lines 38-39: person.alaina → person.alaina_spencer
                person.ella → person.ella_spencer
- Line 45: device_tracker.alaina_iphone → device_tracker.alaina_s_iphone
           device_tracker.ella_iphone → device_tracker.ellas_iphone
           device_tracker.john_s24 → device_tracker.sm_s948u1_john_s_s26_ultra
Real entity IDs confirmed: person.alaina_spencer, person.ella_spencer,
  device_tracker.alaina_s_iphone, device_tracker.alaina_s_iphone_17,
  device_tracker.ellas_iphone, device_tracker.sm_s948u1_john_s_s26_ultra

START NEXT SESSION WITH:
  grep -n 'person.alaina\|person.ella\|john_s24\|alaina_iphone\|ella_iphone' \
    /homeassistant/configuration.yaml

### NEXT SESSION 2 — Git push to GitHub (SAFETY CRITICAL)
- 229+ commits never pushed to remote — total loss if HA Green fails
- Need GitHub private repo + git remote add origin + git push
- START: cd /homeassistant && git remote -v && git log --oneline | wc -l

### NEXT SESSION 3 — Kitchen lighting audit
Questions already answered in prior session — ready to implement:
- Motion snappiness: transition:0 already set, investigate P1 sensor placement
- P1 zones: kitchen + lounge + entry as first floor combined
- Manual override: Option A (switch press → override on, resets after no motion)
- downstairs_motion: clarify if group or physical, been ON since yesterday

### NEXT SESSION 4 — Cleanup
- Remove 8 .bak files from packages/ (git is the backup)
- Recorder: add cover.ratgdo* glob to exclude per-second ESPHome polling
- Automation categories in HA UI (159 automations, no organization)
- Presence tracker cleanup: verify/remove stale S24 tracker

### SYSTEM STATE RIGHT NOW
- HA 2026.4.0, OS 17.1 — both current
- 3,206 entities, 159 automations, 30 packages, 560MB DB
- All updates current, no errors in logs
- Disk: 19GB/28GB used (71%)

## GIT PUSH — PERMANENT METHOD (2026-04-05)
- NEVER use web terminal for git push — HAC zsh precmd hook intercepts ALL git output
- NEVER redirect to /tmp/git_push.log — HAC hook pollutes that file
- CORRECT METHOD: MCP → ha_call_service(shell_command, git_push, return_response=True, wait=True)
- shell_command.git_push must use: 'bash -c "GIT_TERMINAL_PROMPT=0 git -C /homeassistant push origin main"'
- GIT_TERMINAL_PROMPT=0 is REQUIRED — without it git silently exits 1 with no output
- Token is embedded in remote URL — verify with: git -C /homeassistant remote get-url origin
- shell_command runs in HA Core container — /homeassistant path works (NOT /config)
- shell_command returns stdout/stderr via return_response=True — always use this to debug

## GIT PUSH ROOT CAUSE — PRE-PUSH HOOK (2026-04-05)
- .git/hooks/pre-push was running hac.sh + ha CLI on every push
- Both commands unavailable outside SSH terminal = silent exit 1
- DISABLED: chmod -x /homeassistant/.git/hooks/pre-push
- WORKING METHOD: MCP → ha_call_service(shell_command, git_push, return_response=True)
- shell_command.git_push = 'bash -c "cd /config && GIT_TERMINAL_PROMPT=0 git push origin main"'
- GIT_TERMINAL_PROMPT=0 required or git fails silently with no output


## MCP SHELL_COMMANDS — REGISTERED COMMANDS (2026-04-04)
All callable via ha_call_service(shell_command, <name>, return_response=True, wait=True)

| Command | Does |
|---|---|
| git_push | push origin main — ALWAYS use via MCP, never terminal |
| git_status | list commits pending vs origin/main |
| git_last_commit | HEAD hash + message (--oneline) |
| read_critical_rules | cat /config/hac/CRITICAL_RULES.md |
| read_handoff | cat /config/hac/HANDOFF.md |
| mcp_session_init | git_status + git_last_commit in one call |

## SHELL_COMMAND YAML — HARD RULES (Times Hit: 3+ this session)
- NEVER use {{ }} Jinja2 templates in shell_command values in configuration.yaml
  HA resolves templates at config load time — undefined var = silent registration
  failure for the ENTIRE shell_command block. Use static paths only.
  WRONG: read_file: 'cat {{ filepath }}'
  RIGHT: read_critical_rules: 'cat /config/hac/CRITICAL_RULES.md'
- ha core check returns NON-ZERO for "Successful config (partial)" due to
  map/packages integration warnings. This BREAKS && chains. Never use
  ha core check as a gate: cmd && ha core check && ha core restart
  Instead: run ha core check to validate visually, then restart in separate step.
- After any restart, test NEW commands first (not git_push — it persists from old
  load). If new commands return 400 Bad Request, config did NOT load. Restart again.
- Restart via MCP: ha_call_service(homeassistant, restart, wait=False) → expect
  504 timeout (normal — HA cuts connection). CONNECTION_FAILED on next call = still
  booting. 400 on new command = booted but config load failed.
## SECURITY/PRIVACY (Audited 2026-04-04)

### Cloudflare Tunnel
- trusted_proxies: 172.30.33.0/24 = standard Cloudflared Docker range (internal only) OK
- use_x_forwarded_for: true required — verify this is present in configuration.yaml http: block
- Zero Trust Access: NOT configured — HA login page exposed directly to internet
  FIX: CF dashboard > Zero Trust > Access > Add Self-hosted > ha.myhomehub13.xyz
       Policy: allow email=pigeonfallsrn@gmail.com
       Bypass rule: path=/api/* (required for mobile app background webhooks)
- WAF rate limiting: NOT configured — add rule: /api/auth/* 5 req/min/IP (CF > Security > WAF)
- Country blocking: optional free-tier hardening in CF Security > WAF

### SSH Add-on (a0d7b954_ssh v23.0.6, port 2222)
- Port 2222 OK  protected: true OK  password auth: STILL ENABLED — FIX REQUIRED
- FIX: Add-on Config tab — set password: "" (empty string disables password auth entirely)
  Add authorized_keys list with your ed25519 public key
  Generate on PC: ssh-keygen -t ed25519 -C "ha-ssh"
  Paste ~/.ssh/id_ed25519.pub content into the authorized_keys field in add-on config
  Apply + restart add-on + test connection before confirming password is disabled

### Long-Lived Access Tokens
- Git PAT lives in /config/.git/config in plaintext — visible to anyone with shell access
  FIX: Replace with fine-grained PAT (GitHub Settings > Developer Settings > Fine-grained PATs)
       Scope: pigeonfallsrn/homeassistant-config ONLY, Contents=Read+Write, 1-year expiry
       Update URL: git -C /config remote set-url origin https://NEW_TOKEN@github.com/pigeonfallsrn/homeassistant-config.git
  Set calendar reminder to rotate PAT annually
- Audit all LLATs via HA Profile > Security tab — name/describe each, revoke unused
- Token audit command (terminal): cat /homeassistant/.storage/auth.json | python3 -c "import sys,json; d=json.load(sys.stdin); [print(t.get('name','?'), t.get('created_at','?')) for t in d.get('data',{}).get('refresh_tokens',[]) if t.get('token_type')=='long_lived_access_token']"

### Webhooks
- Default local_only: true since HA 2023.9 — not on Nabu Casa so SniTun CVE does not apply OK
- One-time audit: grep -rn 'local_only\|webhook_id' /homeassistant/packages/
- RULE: NEVER create webhooks that trigger cover.* or lock.* actions (HA official guidance)
- RULE: Webhook IDs = treat like passwords — unique, non-guessable, never copy from public blueprints

### Recorder PII / DB Size
- 92 device_tracker.* entities log GPS coordinates, MACs, IPs — HIGH PII, high poll rate
- cover.ratgdo* and sensor.ratgdo*: ~1 state/sec ESPHome polling inflating DB (already in backlog)
- Recommended recorder exclude (configuration.yaml — requires ha core restart after adding):
    recorder:
      exclude:
        entity_globs:
          - cover.ratgdo*
          - sensor.ratgdo*
          - device_tracker.*
          - sensor.sun*
          - weather.*
        entities:
          - sensor.last_boot
          - sun.sun
          - sensor.date
- person.* entities: LOW volume (only changes on zone entry) — OK to keep for history
- DB at 560MB / 19GB disk (71%) — excluding above will meaningfully slow DB growth rate

### External Integrations Posture
- Spotify Connect add-on: local LAN only OK
- Music Assistant: local OK
- ESPHome (ratgdo): local OK
- No Nabu Casa, no Google Assistant cloud, no Alexa cloud bridge OK
- Local-first architecture = minimal external cloud attack surface — good posture

### CVE Verification
- CVE-2026-34205 (2026-03-27): Unauthenticated add-on endpoints via host network mode
  Fixed in Supervisor 2026.03.2 — verify: ha supervisor info | grep version (expect >= 2026.03.2)
  HAOS 17.1 / Core 2026.4.0 should already include this fix

## COMMUNITY AUDIT 2026-04-04 — CONFIRMED CLEAN (don't re-audit these)
- configuration.yaml dead entity refs: grep -n confirms ZERO hits — config is clean
- Legacy template syntax (platform: template): grep -rn confirms ZERO hits in packages/
  All template entities already use modern template: syntax — no 2026.6 migration needed
- .bak files in packages/: all 8 deleted, committed 16cf433, pushed
- Recorder: purge_keep_days:7 + commit_interval:30 + entity_glob excludes = optimal for HA Green
- auto_repack: true (default) confirmed — DB compacts every 2nd Sunday automatically
- LEGACY TEMPLATE DEADLINE: 2026.6 (June 2026) — platform:template stops working entirely
  Detection: grep -rn 'platform: template' /homeassistant/packages/ (should return zero)
  Fix syntax: sensor: - platform: template → template: - sensor: - name: ...
  ESPHome platform:template is NOT affected — only HA internal config files

## KASA INTEGRATION — AUTH EXPIRY PATTERN
- TP-Link Kasa cloud tokens expire periodically — shows as Repair error
- Fix: Settings > Devices & Services > TP-Link Kasa > Re-authenticate (UI only, 2 min)
- Not a security issue, not urgent, but clutters Repairs dashboard
- Affected devices this session: Basement_Hallway HS200, Kitchen_Table_Chandelier HS220

## TRIAGE — YAML FILE DELETION CREATES REPAIR ENTRIES (2026-04-06)
- Deleting a YAML package file without restarting creates "failed to set up" Repairs
- This is cosmetic — all entries from deleted files clear on next restart
- Pattern: delete files → commit → push → restart → verify repairs count drops
- Do NOT interpret post-deletion Repairs as new problems — count vs deleted automations first
- adaptive_lighting_entry_lamp.yaml: 14 automations ALL failing as of 2026-04-06
  File exists but ALL broken — surgery required, this is S2 first task

## ha core check — KeyError: triggers (FALSE POSITIVE, 2026-04-06)
- `ha core check` run from SSH terminal while HA is starting returns
  `KeyError: 'triggers'` for ALL automations — NOT a real config error
- This is a timing issue: trigger registry not populated when check validator runs
- REAL signal is at the BOTTOM of output:
  "Successful config (partial)" + General Warnings: map + packages only = GREEN
- The massive "Failed config: automation:" dump is the false positive — ignore it
- NEVER use `ha core check && ...` as a gate — always returns non-zero, breaks chains
- Correct workflow: run check → read bottom → restart separately if green

## input_boolean SUB-FIELDS IN YAML — KILLS ENTIRE FILE (Times Hit: 2)
- If input_boolean is registered in config store AND defined in YAML with sub-fields
  (name:, icon:, initial:), the ENTIRE package file fails to load
- ALL automations in that file show "failed to set up" / "unavailable"
- Root cause: duplicate registration conflict between YAML definition and config store
- Fix: strip sub-fields from YAML definition — leave only `helper_id:` with no children
  WRONG: `hot_tub_mode:\n  name: Hot Tub Mode\n  icon: mdi:hot-tub`
  RIGHT: `hot_tub_mode:`
- Detection: multiple automations in same file all fail → check input_boolean block first
- One-liner fix: python3 replace old block with stripped version

## EMPTY YAML AUTOMATION STUB — CONFIG ERROR (2026-04-06)
- A YAML automation block with only `- id: some_id` and no alias/trigger/action
  causes config validation errors for that file
- Detection: search for `- id: ` lines with nothing following in same block
- Fix: single-line removal — `lines = [l for l in lines if 'stub_id' not in l]`
- Found: `humidity_alert_2nd_floor` in notifications_system.yaml line 460

## TRIAGE INSIGHT — MCP "unavailable" ≠ BROKEN SYSTEM (2026-04-06)
- Large numbers of "unavailable" automations in MCP are almost always ghost registry
  entries from old YAML-based automations that were renamed/moved/deleted
- The actual YAML automations load fine — only the stale registry entries show unavailable
- Confirmed: config dump showed full system working while MCP showed ~40 unavailable
- Ghost entries self-clear on restart — DO NOT attempt MCP deletes on unavailable autos
  without first checking YAML ownership with grep
- Pattern: if ALL autos in one file are unavailable → file-level issue (helpers, syntax)
  If random autos across files → ghost registry entries, clear on restart

## TRIAGE — REVISED AUTOMATION COUNT (2026-04-06)
- System has more working automations than triage inventory suggested
- Config dump revealed working automations previously thought dead:
  arrival_notification_john, arrival_notification_ella, arrival_notification_actions
  bedtime_first_floor_lights_off_prompt, bedtime_lights_notification_actions
  kitchen_manual_override_auto_clear (NOT broken — was ghost)
  safety_all_lights_off_nobody_home, safety_main_areas_no_motion_off, safety_midnight_all_lights_off
  update_occupancy_mode, apply_context_*, apply_context_on_time_change
  refresh_school_tomorrow, refresh_school_in_session_now
  ella/alaina: sleep_timer, night_path, gentle_wake, school_night, lights_off, weekend_midnight_off
  garage: all 7 kept automations confirmed working
  google_sheets: all 3 confirmed working
  humidity: smart_shower_alert, smart_actions, fan_unpause, fan_block_when_paused
  upstairs_hallway_motion_lighting_v2 confirmed working
- Triage categories remaining: upstairs lighting, occupancy deep-dive, safety confirm,
  Google Sheets verify, HAC/utility

## ADAPTIVE_LIGHTING_ENTRY_LAMP.YAML — ARCHITECTURE SUMMARY (2026-04-06)
- 560-line file contains FOUR systems:
  1. Entry Lamp Chain (motion/lux/time/mode control) — all automations WORKING post-fix
  2. Hot Tub Mode (auto-reset, auto-off, living room lamp, notification + actions)
  3. Extended Evening Mode (auto-set Fri/Sat/holiday at 18:00, auto-clear at 04:00)
  4. Arrival AL Welcome (entry lamp on arrival, 3 triggers: person/garage/front door)
- Template sensors in file: evening_lamp_off_time, evening_lamp_max_brightness,
  entry_room_average_lux — all required by lamp chain automations
- Hot tub mode turn_off/turn_on refs stale entity IDs (15min vs 5min in alias) — cosmetic bug
- DO NOT delete this file — all 14 automations are functional and desired

## LUX SENSORS — THIRD REALITY NIGHTLIGHTS (2026-04-06)
- Every Third Reality nightlight exposes illuminance to HA via Zigbee
- Entity pattern: sensor.*_nightlight_illuminance or sensor.*_night_light_illuminance
- 12 lux sensors confirmed live across the house — kitchen, entry, living room, upstairs, garage
- Use these for motion automation lux gating — no additional hardware needed
- Key kitchen sensor: sensor.kitchen_counter_night_light_illuminance (reads ~53 lux at dusk)
- Recommended threshold for lights-on: below 200 lux
- Aqara P1 lux: exists in Aqara app but NOT exposed to HA via HomeKit/Matter bridge
  Fix: re-pair P1s directly to Sonoff ZBT-1 Zigbee to get illuminance in HA (loses Aqara app)

## MOTION LIGHTING — TIER ARCHITECTURE (2026-04-06)
- Tier 1 (Adaptive): Hue color bulbs — turn_on with NO brightness/color params, AL takes over
- Tier 2 (Fixed): Inovelli dimmers, LED cans, pendants — turn_on with explicit brightness_pct
- Never mix tiers in same light.turn_on call — AL fights explicit params
- Build Tier 1 first, validate feel, add Tier 2 in second pass
- Lux gate preferred over sunset condition — use local TR nightlight sensor

## OPEN CONCEPT MOTION ZONES — SHARED FATE PATTERN (2026-04-06)
- Connected rooms with no door between them = single combined motion sensor + single automation pair
- Off timer resets on any motion anywhere in zone — no half-dark open concept
- Kitchen + kitchen lounge = one zone, one fate (first_floor_main_motion)
- Entry room stays independent — its own system (adaptive_lighting_entry_lamp.yaml)
- Entry P1 is IN first_floor_main_motion — walking entry→kitchen keeps kitchen zone alive
- Hallways stay isolated — first_floor_hallway_motion is a separate zone

## MCP ha_config_set_automation — INJECTS unique_id INTO PACKAGE YAML (HA 2026.4.x BREAKING)
- Every call to ha_config_set_automation embeds `unique_id: auto_*` into the target YAML block
- HA 2026.4.1 schema validation REJECTS `unique_id:` as a top-level automation key — causes "failed to set up" Repairs for every affected automation
- SYMPTOM: Repairs list floods with "X failed to set up" errors after any MCP automation edit session
- DETECTION: grep -rEl 'unique_id: auto_' /homeassistant/packages/
- FIX: python3 /homeassistant/hac/fix_pkg_unique_id.py (strips all unique_id: auto_ lines from packages/)
  Fix script lives at /homeassistant/hac/fix_pkg_unique_id.py — permanent, reusable
- After fix: git add packages/ && git commit && git push via MCP → restart → verify Repairs = 0
- RULE: After ANY session using ha_config_set_automation on package files, run the detection grep before wrap

## INOVELLI ECOSYSTEM AUDIT 2026-04-07 — FULL INVENTORY

### Device Inventory (confirmed via ha_get_entity, 2026-04-07)

VZM31-SN Smart Bulb Mode (Tier 1 — controls Hue bulbs, load always-on):
- light.entry_room_ceiling_light_inovelli_smart_dimmer_switch  device_id: d80c7fa6
- light.kitchen_lounge_inovelli_smart_dimmer                   device_id: 5e2d477e
- light.kitchen_above_table_chandelier_inovelli                device_id: 17a59d3c
- light.above_kitchen_sink_inovelli_switch                     device_id: 89ca030d

VZM31-SN Dumb Load (Tier 2 — direct dimmer control, cuts power to load):
- light.kitchen_ceiling_inovelli_vzm31_sn      kitchen ceiling can LEDs
- light.kitchen_bar_pendant_lights             kitchen bar pendants (device_id: da86388f)
- light.kitchen_under_cabinet_lights_inovelli      kitchen under cabinet LEDs (renamed S5 2026-04-07)
- light.1st_floor_bathroom_ceiling_lights_dimmer_switch_inovelli_vzm31_sn
- light.back_door_patio_light_inovelli_switch
- light.front_driveway_inovelli

VZM35-SN Fan Switch:
- light.inovelli_vzm35_sn_light (friendly: 2nd Floor Bathroom Fan) device_id: 3eed85f7

VZM36 Fan/Light Canopy Modules:
- light.kitchen_lounge_light_fan_inovelli_vzm36_light + _2 (Kitchen Lounge)
- light.inovelli_vzm36_light_3 + _4 (Living Room — two instances, investigate)

### RECOMMENDED BLUEPRINT (2026-04-07)
Use Rohan unified blueprint — supports VZM31-SN + VZM35-SN + VZM30-SN (updated Dec 2024)
https://community.home-assistant.io/t/zha-inovelli-blue-series-switch-for-dimmer-vzm-31-fan-vzm-35-and-on-off-vzm-30-switches/627953
REPLACES fxlt blueprint (VZM31-SN only, fires ALL zha_events — DO NOT USE)
One automation per switch handles all multi-tap/hold/release actions
Queued variant available if double-event firing occurs

### TWO ARCHITECTURES — NEVER MIX
Smart Bulb Mode (Tier 1 — Hue bulbs):
- Param 52 = 1: load always-on, paddle sends Zigbee commands
- Bind switch EP2 to ZHA group with Hue bulbs (direct, no HA needed)
- HA/AL controls the HUE entity, NOT the switch entity
- AL works perfectly — load never cuts so bulb always receives

Dumb Load (Tier 2 — cans, pendants, under-cabinet):
- Param 52 = 0: switch cuts/restores power
- HA sends explicit brightness_pct to SWITCH entity
- NEVER add to AL instance — AL fights native dimmer level control
- LOCAL_RAMP_RATE (param 1/7) = physical paddle speed
- min_dim_level too low = LED flicker; tune per fixture

### AL CONFLICT — CURRENT VIOLATIONS (fix via Kitchen Table pencil edit)
These Tier 2 dumb-load switches are wrongly inside Kitchen Table AL:
  light.kitchen_ceiling_inovelli_vzm31_sn
  light.kitchen_bar_pendant_lights
  light.inovelli_vzm31_sn_4
Remove them, keep only: kitchen_chandelier, kitchen_above_sink_light, kitchen_lounge, kitchen_lounge_lamp

### ZHA ENDPOINTS (VZM31-SN)
EP1 = receives commands FROM HA
EP2 = transmits commands (bind to ZHA group for bulb control)
EP3 = config button (fw 2.17+, bind to fan/second device)

### FIRMWARE
Latest stable: v3.04 (Dec 2025)
Check: https://community.inovelli.com/t/blue-series-2-1-firmware-changelog-vzm31-sn/12326
After any firmware update: re-verify param 52 Smart Bulb Mode setting

## PRE-BUILD AUTOMATION AUDIT — MANDATORY (2026-04-07)
Before building ANY new automation for a zone/area/entity:
1. grep packages for existing automations touching same entities:
   grep -rn 'entity_id' /homeassistant/packages/ | grep 'light.ENTITYNAME'
2. ha_deep_search for UI automations: ha_deep_search("ENTITY_OR_ZONE", exact_match=False)
3. Check HA UI automation list filtered by area/name keyword
4. Confirm no conflicts before writing YAML

WHY: 138 automations exist. MCP only sees UI-registered ones.
Package YAML automations are invisible to MCP without cat/grep.
Building without auditing = silent conflicts, double-fires, fighting automations.

WRAP RITUAL ADDITION — always at session close:
- Summarize what was built/changed this session
- Note any discovered conflicts or hidden automations
- Promote learnings to CRITICAL_RULES before commit
- Run: grep -rEl 'unique_id: auto_' /homeassistant/packages/
- Update HANDOFF with what's live, what's pending, what was learned

## GREP PATTERNS — automations.yaml vs packages/ (S6 confirmed)
- automations.yaml: `^- id:` (column 0, no indent)
- packages/*.yaml: `^  - id:` (2-space indent)
- ALWAYS search BOTH when hunting for automation source:
  grep -rn 'PATTERN' /homeassistant/packages/ /homeassistant/automations.yaml
- BusyBox grep: scope to specific files/dirs, never recurse from / or /homeassistant/

## GHOST AUTOMATION STATES — TWO KINDS (S6 confirmed)
- `unavailable` = automation in registry but not loaded (package YAML renamed/moved/deleted)
  → RESOURCE_NOT_FOUND from config store, Repairs=0 = harmless, clears on restart
- `off` = automation was intentionally disabled, then source-deleted
  → registry preserves last known state; also RESOURCE_NOT_FOUND, also harmless
- RULE: never attempt MCP deletes on unavailable/off ghosts without grep confirming
  the automation still exists in source. If grep returns nothing = already gone.
- DETECTION COMMAND: grep -rn 'automation_id' /homeassistant/packages/ /homeassistant/automations.yaml

## HAOS AUTO-UPDATE — MCP DROPS ON OS UPGRADE (S6 observed)
- HAOS updated 17.1→17.2 silently mid-session; HA MCP connection dropped
- Symptom: tool_search returns only Gmail/Calendar, no HA tools
- Fix: HA MCP reconnects automatically after HAOS reboot completes (~2-3 min)
- After HAOS update: verify Repairs=0 and run ha_get_overview before proceeding
- S7 note: HAOS 17.2 is the current version — confirm at session start

## BACKUP MANAGER BUSY — PATTERN (S6 observed)
- ha_backup_create fails with "Backup manager busy: create_backup" if
  auto-backup is already running (common at session start if HA just restarted)
- Wait 60-90s and retry — do NOT skip backup entirely
- S5 backup (0a4a97ce) was same-day safety net when S6 backup failed
- Add retry logic mentally: if busy → wait → retry once before proceeding

## SESSION EFFICIENCY — TOKEN IMPROVEMENTS (S6 lessons)
- read_critical_rules is 250KB+ and burns large context on every session open
  FUTURE: split CRITICAL_RULES into CRITICAL_RULES_CORE.md (rules only, ~50KB)
  and CRITICAL_RULES_HISTORY.md (session promotions/history). Load core only at start.
- ha_get_overview with max_entities_per_domain=1 is sufficient for health checks
  (state summary gives counts; only load full domain when working in that area)
- hac backup failure should NOT block all work — S5 backup same-day is valid safety net
- MCP tool_search wastes tokens when HA tools drop; add note to session prompt:
  if tool_search returns only Gmail/Calendar = HA MCP offline, wait for reconnect

## SESSION NAMING CONVENTION — HARDWIRED
- Backups: Pre_S{N}_{YYYY-MM-DD}  (e.g., Pre_S7_2026-04-07)
- Commits: "feat:", "chore:", "fix:", "docs:" prefix — always include session tag
- HANDOFF: always "HAC Handoff — {date} S{N} Close"
- Session IDs: S1, S2... are per-day sessions (S6 = 6th session on 2026-04-07)

## HACS AUTO-UPDATES — COMMIT PATTERN (S6 observed)
- HACS updates custom_components/ silently while HA runs
- Modified files appear in `git status` unstaged — NOT a dirty config
- Pattern: yamaha_ynca updated during S6 (24 files, 174 ins / 38 del + __pycache__ deletes)
- __pycache__ .pyc files: always deleted by HACS updates — normal, not an error
- Commit immediately when seen: git add custom_components/COMPONENT/ && git commit -m "chore: COMPONENT auto-update via HACS"
- NEVER leave HACS updates uncommitted — they clutter git status and obscure real changes

## PRIVACY / SECURITY BACKLOG — UNCHANGED (carry forward every session)
- SSH password auth: STILL ENABLED — set password: "" in SSH add-on config
  Add authorized_keys with ed25519 public key. Test before disabling password.
- Cloudflare Zero Trust: NOT configured — HA login page exposed to internet
  Fix: CF dashboard > Zero Trust > Access > ha.myhomehub13.xyz
  Bypass: path=/api/* for mobile app webhooks
- Git PAT in plaintext at /config/.git/config
  Fix: replace with fine-grained PAT (pigeonfallsrn/homeassistant-config only)
- 92 device_tracker entities logging GPS/MAC/IP — high PII in DB
  Fix: recorder exclude glob device_tracker.* (already in configuration.yaml)

## WRAP RITUAL — MANDATORY CHECKLIST (every session close)
1. grep -rEl 'unique_id: auto_' /homeassistant/packages/   ← injection check
2. grep -rn 'PATTERN' both packages/ AND automations.yaml  ← use both paths
3. Promote any new learnings to CRITICAL_RULES
4. Update HANDOFF.md with: state, completed, new learnings, backlog
5. git add + commit with session tag
6. git push via MCP shell_command.git_push (NEVER terminal)
7. Verify push: git log --oneline -3 shows origin/main at HEAD

## AL vs TIER 2 — LIVE DETECTION METHOD (S4 2026-04-08)
- If Tier 2 lights are wrongly in an AL instance, ha_get_states will show identical
  parent_id context on multiple rapid updates to that entity = AL fighting the automation
- Detection: ha_get_states on suspect light → check last_updated timestamps clustering
  within seconds + same parent_id = AL ownership conflict
- Fix: AL pencil edit UI only — remove Tier 2 entities from AL instance
- Kitchen Table AL correct lights: chandelier, above-sink, lounge, lounge-lamp, under-cabinet
  NEVER: kitchen_ceiling_inovelli_vzm31_sn, kitchen_bar_pendant_lights

## INOVELLI DIMMERS — TRANSITION:0 REQUIRED ON MOTION AUTOMATIONS (S4 2026-04-08)
- All motion automations sending brightness_pct to Inovelli VZM31-SN dumb-load switches
  MUST include transition: 0 in the light.turn_on data block
- Without it: mode:restart re-fires the brightness command and LOCAL_RAMP_RATE causes
  a visible lamp ramp/flicker even when lights are already on at target brightness
- Applies to: lighting_motion_firstfloor.yaml Tier 2 section (fixed ee4473a)
- Pattern: EVERY explicit brightness_pct sent to a VZM31-SN dumb load = add transition: 0

## HUE BRIDGE BULBS ≠ ZHA — INOVELLI EP2 BINDING IMPOSSIBLE (S4 confirmed)
- Hue bulbs live on Hue bridge's own Zigbee network, NOT the Sonoff ZBT-1 coordinator
- Inovelli EP2 ZHA group binding only works for devices on the SAME ZHA coordinator
- You CANNOT directly bind an Inovelli switch to Hue bridge bulbs via ZHA group
- ONLY working architecture for Hue + Inovelli:
  1. Param 52 = 1 (Smart Bulb Mode — load always-on, paddle sends ZHA events)
  2. HA automation listens for ZHA device_id events from that specific switch
  3. Automation calls light.turn_on/off or scene.turn_on on the Hue group entity
- Do NOT attempt EP2 binding for any Hue-bridge room switch

## UPSTAIRS HALLWAY MOTION AUTOMATION — AL FIGHT (S4 identified, not yet fixed)
- upstairs_lighting.yaml sends explicit brightness_pct + color_temp_kelvin to
  light.upstairs_hallway (Hue group = Tier 1)
- This fights the Upstairs Hallway AL instance which also controls those bulbs
- Fix: replace explicit params with scene.turn_on (scene.upstairs_hallway_energize etc)
  OR remove brightness/color params and let AL handle it
- File: /homeassistant/packages/upstairs_lighting.yaml lines 45-80

## REGISTRY EDITS (Times Hit: 3+)
- **Never edit .storage files while HA is running** — HA writes its in-memory registry to disk on clean shutdown, overwriting changes
- **Correct procedure**: stop HA → edit → start HA. On Mini PC: run cleanup script BEFORE `ha core start`
- **Race condition symptom**: python3 script reports "Removed N entries" but entities reappear after restart

## GREP ON HA GREEN (Times Hit: 2+)
- **BusyBox grep ignores `--include`** silently — never use `--include=*.yaml`
- **Correct pattern**: `grep -rEl 'pattern' /homeassistant/ 2>/dev/null | grep -v '.git'`
- **For yaml-only searches**: pipe through `grep '\.yaml'` on the filenames or search all and filter

## CONFIGURATION.YAML INLINE AUTOMATIONS
- **Never define automation: blocks inline in configuration.yaml** — they load before automations.yaml and steal entity_ids, causing _2 suffix on the real automation
- **All automations belong in**: packages/*.yaml or automations.yaml with an `id:` field
- **Symptom**: automation shows as entity_id_2, never-triggered, original still running with old service: syntax
