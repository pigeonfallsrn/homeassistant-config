# HANDOFF — S72 → S73

**Last commit:** (S72 close, this session)
**Live counts:** 72 automations, 98 helpers, 14 template packages, 0 ghosts
**HA path:** EQ14 sole instance, ha.myhomehub13.xyz via Cloudflare

---

## S72 — INSTRUCTIONS.md governance foundation

**Goal:** Promote S71 learnings into permanent rules + create versioned INSTRUCTIONS.md as source of truth, replacing chat-starter-paste fragility.

**Done (verified):**
- Created `/config/INSTRUCTIONS.md` (93 lines, 8.4KB) — captures full chat-starter rule set + 4 weaved-in patches. Verified live via `shell_command.read_instructions` smoke-test.
- Promoted SECRET REQUEST PROTOCOL (credential-class carve-out, 1st-occurrence promotion) — under OPERATIONAL DEFENSES
- Promoted REGEX PRE-FLIGHT — under SHELL RULES
- Promoted DIAGNOSTIC DISCIPLINE provenance clause — extension of existing rule, OPERATIONAL DEFENSES
- Promoted CONFIG EDIT WORKFLOW (own-session promotion) — new section between SHELL RULES and SESSION STARTER PROTOCOL. Mandates `ha_check_config` → `ha_reload_core` or `ha_restart` after any yaml edit.
- Established Promotion tracking convention: each promoting session adds `### Promotions` subsection in LEARNINGS entry linking original learning header → INSTRUCTIONS section.
- Established credential-class carve-out: any failure mode leaking secrets/tokens/PII promotes on 1st occurrence (asymmetric cost rule), bypassing Two-Occurrence Rule.
- `configuration.yaml` line 98 trimmed: `mcp_session_init` no longer dumps HANDOFF.md (saves ~3KB per call forever — `read_handoff` already returns it). Verified live.
- `configuration.yaml` line 98: added `read_instructions: 'cat /config/INSTRUCTIONS.md'`. Verified live via MCP smoke-test.
- Full HA restart performed (required for shell_command binding registration). `ha_check_config` valid before restart. Restart took ~60-90s. Both new/changed bindings confirmed working post-restart.

**Files touched:**
- `/config/INSTRUCTIONS.md` (NEW, 93 lines)
- `/config/configuration.yaml` (lines 98-99: trimmed `mcp_session_init`, added `read_instructions`)
- `/config/HANDOFF.md` (this file, S72 close)
- `/config/LEARNINGS.md` (S72 entry + ### Promotions subsection)

**Provenance:**
- INSTRUCTIONS.md baseline: chat-starter text from S71 message turn 1, captured verbatim, then patches weaved in.
- All four patches verified live in INSTRUCTIONS.md via `shell_command.read_instructions` chat output (this session).
- Trimmed init verified: `mcp_session_init` output ends at "DISK ===" no HANDOFF block.

---

## S73 priority queue

**Top of queue: Triage the 393 unavail down to actionable list.**
(Carried from S72 priority queue — deferred for governance work this session.)
Post-S71 v2 filter domain breakdown:
- sensor 172, number 77, switch 55, button 32, select 16, binary_sensor 16, light 10, media_player 6, tts 2, notify 2, conversation 2, stt 1, input_button 1, image 1

Likely real-signal clusters to attack first:
- Template chain `binary_sensor._house_occupied` / `_kids_home` / `_home_alone` / `_john_home_alone` — probably cascading from one broken upstream (Michelle's missing device_tracker per carryforward?)
- Apollo MSR-1 entry_room presence sensor (`entry_room_r_pro_1_ld2412_*`) — multi-entity unavail suggests offline or just-flashed
- First-floor motion (`first_floor_hallway_motion`, `first_floor_main_motion`)
- Music Assistant 7 entries (known carryforward — setup_error)
- Inovelli `number.*` 77 + `select.*` 16 — likely diagnostic noise; promotion-to-EXCLUDE_RE candidates if clearly stateless

**Other S73 candidates (lower priority):**
- `mcp_session_init` v2: convert inline yaml to script file at `/config/hac/scripts/mcp_session_init.sh`, add ground-truth dump (live counts verification, latest health [1] summary line). Currently inline yaml — too brittle to extend cleanly.
- `read_learnings_recent`: tail-200 lines version of read_learnings for token efficiency (full file is 790+ lines).

**Suggested approach for top of queue:** terminal dump grouped by suspected root, then options A/B/C per cluster.

---

## Carryforward (unchanged)

- AndroidTV at 192.168.1.17 — DO NOT DELETE
- Music Assistant in setup_error state
- Michelle's device tracker missing (MAC `6a:9a:25:dd:82:f1`)
- Ella: 20 entity_ids still named `iphone_40_*` — need rename
- Ratgdo north: clean physical IR sensor lenses
- Navien integration not yet added to EQ14
- Yamaha RX-V671 not yet added to EQ14
- NordPass backlog cleanup
- Google Drive audit and reorganization

## Blocked
None.

## Benchmark
- `shell_command.read_instructions`: returncode 0, returns 8.4KB INSTRUCTIONS.md
- `shell_command.mcp_session_init`: returncode 0, output trimmed (~280 bytes vs ~3.3KB pre-S72 — ~91% reduction)
- HA restart cycle: ~60-90s, no automation impact noted
