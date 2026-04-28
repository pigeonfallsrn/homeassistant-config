# HAC HANDOFF — 2026-04-28 S69 Close

## Session Goal
Land Phase A Project Instructions edits (S68 carryforward #1).

## Completed
- Redrafted Phase A blocks in chat (S68 chat drafts not retrievable cross-session — see LEARNINGS S69)
- User pasted full replacement instructions into project settings, saved
- 4 substantive changes landed:
  1. SHELL RULES — `&&` vs `;` exit-code chaining nuance + `git_push` bundled add+commit+push wording with `{{ message }}` param
  2. OPERATIONAL DEFENSES — added BACKTICK TLD STRINGS bullet (S58/S62)
  3. OPERATIONAL DEFENSES — DIAGNOSTIC DISCIPLINE detagged, expanded session refs to S58/S60/S61/S64/S65
  4. (LINKIFICATION already lacked candidate tag — no change needed)
- No code/config/HA changes this session

## State Right Now
- HA: 2026.4.x, HAOS — all green, Repairs=0
- Counts unchanged from S68: 77 automations, 91 helpers, 0 YAML automations/helpers, 14 template packages, 0 ghosts, 19 calendars, 5 HACS cards, 3 storage-mode dashboards
- Last commit before S69: 09aee39 (S68 governance)
- Project Instructions now in sync with promotions — S70+ runs on current rules

## S70 Priority Queue
1. **shell_command.health_check** — build on EQ14 using REST API pattern (unavailable entities, double-fires, integration issues). Modeled on hac health pattern from Green. Chat-session fit. Carryforward since S51.
2. **TIER 1 entry_room rename** — still gated on physical-layout question: is the entry_room ceiling fixture the same physical fixture as entry_room_lamp, or a separate ceiling can?
3. **TIER 2/3/4 lighting work** — needs Hue app or battery hands-on, not chat-session fit.
4. **Full system audit post-Green shutdown** — long-tabled.

## Promotion Candidates Watch List
- BATTERY DEVICE: check manufacturer/model before destructive action on `unavailable` (S65) — promote on 2nd occurrence
- ha_set_entity supersedes S45 websocket entity rename (S63) — promote on 2nd occurrence

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
S69 = 1 short session, 4 chat turns. Pure governance landing — no terminal/MCP work. Phase A debt from S68 cleared.

## Session Workflow Reminder
- Project Instructions now reflect bundled `git_push`, `&&` vs `;`, BACKTICK TLD STRINGS, durable DIAGNOSTIC DISCIPLINE
- Future "outside-of-Claude paste tasks" must include full paste-ready payload in HANDOFF.md (see LEARNINGS S69)
