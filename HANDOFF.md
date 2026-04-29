# HANDOFF — S73 → S74

**Last commit:** (S73 close, this session)
**Live counts:** 72 automations, 98 helpers, 14 template packages, 0 ghost scripts
**HA path:** EQ14 sole instance, ha.myhomehub13.xyz via Cloudflare

---

## S73 — carryforward refactor + 393-unavail diagnosis

**Goal:** Refactor carryforward into separate file; triage 393 unavail down via Apollo reboot + Inovelli filter promotion.

**Done (verified):**
- Created `/config/CARRYFORWARD.md` (20 lines) — 8 open multi-session items extracted from HANDOFF.
- Patched INSTRUCTIONS.md (95 lines, was 93): added AndroidTV to NEVER DO; updated POINTERS to include CARRYFORWARD.md; updated SESSION CLOSE PROTOCOL to reference CARRYFORWARD.md instead of duplicating.
- HANDOFF.md no longer carries unchanged 9-line carryforward block. Saves ~15 lines/session.

**Diagnosis (provenance: ha_get_state probe + grep audit, this session):**
- **Inovelli filter promotion: NOT VIABLE.** Pre-flight revealed `number.*` (77) and `select.*` (16) entities track real device problems (Apollo LD2412 thresholds, Yamaha not-yet-on-EQ14, ratgdo orphans, dual-plug unreachables). Filtering would hide signal. S71 v2 filter is well-targeted; pushing further hides real data.
- **Apollo MSR-1 (Entry Room R-PRO-1) — ~140 unavail entities:** ESP alive (uptime reporting fresh, ~7h), but LD2412 mmWave + SCD40 CO2 subsystems failed to re-establish after S72 HA restart. `button.entry_room_r_pro_1_esp_reboot` was pressed but did NOT restore subsystems (sensors still `unknown` post-press). Likely needs ESPHome integration reload OR direct dashboard reboot (not the HA-exposed button).
- **Template ghost pattern (NEW):** `binary_sensor.first_floor_hallway_motion`, `binary_sensor.adults_only_home`, `sensor.alaina_minutes_until_wake`, `binary_sensor.first_floor_main_motion`, others — registry says `platform: template`, attributes show `restored: true`, state `unavailable`. NO yaml definition exists in /config/packages/, /config/templates.yaml, or /config/configuration.yaml. These are template-platform analogs of S45 ghost-script pattern. Total ghost count: 22 (per REST API count of `state==unavailable && restored==true` entities).
- **Echo Dot — alexa_media platform:** `media_player.echo_dot_extra` truly `unavailable` (not unknown). Alexa Media Player integration broken or Echo unreachable. ~35 entities affected (alarms/timers/reminders chain).

**Counts:**
- Pre-S73: 393 unavail
- Post-S73: 394 unavail (+1 from a state flip)
- Net entities cleared: **0** — diagnosis-only session
- Diagnosis value: 3 wrong assumptions corrected, 1 new pattern discovered (template ghosts)

**Files touched:**
- `/config/CARRYFORWARD.md` (NEW, 20 lines)
- `/config/INSTRUCTIONS.md` (3 patches, 93→95 lines)
- `/config/HANDOFF.md` (this file, S73 close)
- `/config/LEARNINGS.md` (S73 entry)

---

## S74 priority queue

**Top of queue: Apollo MSR-1 deep debug.**
ESP is alive but LD2412 + SCD40 subsystems aren't streaming after HA restart. Try in order:
1. `homeassistant.reload_config_entry` for the ESPHome integration entry covering this device (need `ha_get_integration` tool). If integration-level reload restores subsystems, this is the fix path for any future Apollo-style failures and worth promoting.
2. ESPHome dashboard direct reboot (Settings → Add-ons → ESPHome → device → restart). This bypasses the HA-exposed button which appears non-functional.
3. If neither works: check ESPHome device logs at the dashboard for what's actually failing.
4. Once fixed, expect ~140 entities to clear.

**Second priority: Template ghost cleanup (22 entities).**
S45 playbook: `ha_remove_entity` for each. Need to first verify they have no consumers (no automation, dashboard, or other template references), then bulk-remove. Should be fast once verified.

**Third priority: Echo/Alexa Media Player investigation.**
~35 entities. Likely root cause: Alexa Media Player config entry needs reload or the underlying Amazon credentials need refresh.

**Fourth priority (deferred from S73): Yamaha cluster cleanup.**
Some Yamaha satellite entities now show ENTITY_NOT_FOUND while the main media_player shows `state: off`. Carryforward says "not yet added to EQ14" but partial entities exist. Investigate whether to remove orphans or complete the integration add.

**Open S74 candidates (lower priority, capture for governance review at S75):**
- `mcp_session_init` v2 (script file with ground-truth dump)
- `read_learnings_recent` (token-efficient last-N-lines)
- Promote "rule before tool" pattern to INSTRUCTIONS (1st occurrence — workflow-class, not credential-class, so two-occurrence default applies; wait for S74-S75 to see if it recurs)

---

## Carryforward
See `/config/CARRYFORWARD.md`. No changes this session.

## Blocked
- Apollo `button.entry_room_r_pro_1_esp_reboot` does not actually reboot the ESP (sensors stayed in pre-press state). Either the button's underlying ESPHome service is misconfigured or the ESP rejects the command. S74 needs to figure out why.

## Benchmark
- `shell_command.read_instructions`: returncode 0, returns INSTRUCTIONS.md (now 95 lines)
- `shell_command.mcp_session_init`: ~280 bytes per call (S72 trim holding)
- Health check: 394 unavail (no change, +1 vs S72 close due to state flip)
