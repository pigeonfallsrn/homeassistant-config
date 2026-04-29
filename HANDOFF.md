# HAC HANDOFF — 2026-04-28 S70 Close

## Session Goal
Build `shell_command.health_check` on EQ14 using REST API pattern (S51 carryforward #1).

## Completed
- Built `/config/hac/scripts/health_check.py` (425 LOC) — 11 sections + inventory + area-less line
- Already-wired `shell_command.health_check` now points at the real script (was previously calling a 3KB inventory-only stub that silently failed on `.storage/automations`)
- Detail file at `/config/hac/health_check_detail.txt` (gitignored, added `hac/health_check_detail.txt` to `/config/.gitignore`)
- Patched `chk_double()` to detect ZHA-specific dupes (`zha_event` device_ieee + `platform: device` domain=zha) per TRIPLE-FIRE rule, not generic shared device_id (which would false-positive)
- Switched `count_autos()` from broken `.storage/automations` path to `automations.yaml` (real store on this box)
- Run time: ~0.6s. Commit: `9867ce4`.

## State Right Now
- HA: 2026.4.x, HAOS — running
- **Live counts (corrected from S69):** 72 automations, 98 helpers (S69 doc said 77/91 — drift confirmed both axes)
- 0 hand-edited YAML automations (HA UI manages `automations.yaml` automatically — corrected understanding from "0 YAML automations")
- 14 template packages, 19 calendars, 5 HACS cards, 3 storage-mode dashboards (no change)
- Last commit: `9867ce4` (S70: build health_check)

## First-Run Health Findings (real signal — see /config/hac/health_check_detail.txt)
- **CRIT:** 652 unavailable entities (~23% of active). Mostly `update.*_firmware` (Inovelli/ratgdo "no update available" false-positives) + real motion/occupancy template propagation. v2 should filter `update.*_firmware`.
- **WARN:** 1 active repair → `homeassistant :: config_entry_reauth_alexa_media_01K8HK9QB6ZXDCWEXRPTJ0SB70` (Alexa Media reauth, resolvable via UI Settings > Repairs)
- **WARN:** HANDOFF count drift confirmed both axes
- **OK:** PSI 0.0 across cpu/mem/io, disk 3% used, DB 0.26GB, 0 ZHA double-fires, 0 setup errors

## S71 Priority Queue
1. **Filter `update.*_firmware` from unavail check (v2 patch)** — drop ~30+ false-positive entries from CRIT count, then triage real signal. Quick chat-session fit.
2. **Triage remaining real unavailables** — motion/occupancy template propagation. Likely points at upstream sensor flapping. May span 2 sessions.
3. **Resolve Alexa Media reauth** — Settings > System > Repairs in UI. Trivial physical action.
4. **Extend `mcp_session_init` to include 1-line health summary** — surfaces drift at session start, not session end. Workflow lever.
5. **TIER 1 entry_room rename** — still gated on physical-layout question (carryforward).
6. **TIER 2/3/4 lighting work** — needs Hue app or battery hands-on.
7. **Full system audit post-Green shutdown** — long-tabled.

## Promotion Candidates Watch List
- BATTERY DEVICE: check manufacturer/model before destructive action on `unavailable` (S65) — promote on 2nd occurrence
- `ha_set_entity` supersedes S45 websocket entity rename (S63) — promote on 2nd occurrence
- Phase 0 "Adopt/Adapt/Build" dump pattern (S70) — promote on 2nd occurrence (next build-a-tool carryforward where existing partial impl found mid-build)
- Maximalist single diagnostic dump pattern (S70) — promote on 2nd occurrence (next investigation phase that exceeds 3 turns)

## Tabled Items (carryforward, no change)
- AndroidTV at 192.168.1.17 — DO NOT DELETE
- Music Assistant in setup_error state
- Michelle's device tracker missing (MAC 6a:9a:25:dd:82:f1)
- Ella: 20 entity_ids still named iphone_40_*
- Ratgdo north: clean physical IR sensor lenses
- Navien integration not yet added to EQ14
- Yamaha RX-V671 (192.168.21.171:50000) not yet added
- NordPass backlog cleanup
- Google Drive audit + DS224+ NAS reorganization
- Privacy/Security backlog: SSH password auth, CF Zero Trust, Git PAT plaintext, device_tracker recorder exclude

## Physical Updates
None this session.

## Benchmark
S70 = 13 chat turns. Discovery phase consumed ~5 turns (existing partial impl rediscovery — see LEARNINGS S70 candidate). Build + patch + verify + commit phase ~5 turns. Acceptance criteria met. Real findings logged for S71.

## Session Workflow Reminder
- `shell_command.health_check` is now the canonical pre-work signal — use it before any non-trivial change
- HANDOFF count drift is now a 2nd-occurrence promotion ready for PROMOTED RULES (see LEARNINGS S70)
- Project rule "0 YAML automations" was wrong; corrected to "0 hand-edited YAML automations"
