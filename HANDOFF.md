# HAC HANDOFF — 2026-04-28 S68 Close

## Session Goal
Tier 5 governance pass + CRITICAL_RULES path audit (option C from session start).

## Completed
- LEARNINGS audit S58–S67 → 4 promotions to Project Instructions:
  1. LINKIFICATION — drop "(2-occ candidate)" tag, durable since S58
  2. DIAGNOSTIC DISCIPLINE — 5 occurrences S58/S60/S61/S64/S65, durable
  3. EXIT-CODE CHAINING — `;` for diagnostic dumps, `&&` for sequential ops (S61/S62)
  4. BACKTICK TLD STRINGS — wrap `.school`/`.travel`/`.app` etc in inline code spans (S58/S62)
  5. SHELL RULES updated for bundled git_push (S67)
- BATTERY DEVICE rule honest defer (S65 single occurrence, Two-Occ Rule pending 2nd)
- ha_set_entity supersedes S45 honest defer (S63 single occurrence)
- CRITICAL_RULES collapse:
  - Old: hac/CRITICAL_RULES_CORE.md (12KB, 301 lines) + hac/CRITICAL_RULES.md (60KB, 1200+ lines)
  - New: /CRITICAL_RULES.md at repo root, 266 lines, deduplicated + stale content removed
  - Old files archived to hac/archive/critical_rules_pre_s68/
- shell_command updates:
  - read_critical_rules → /config/CRITICAL_RULES.md (was /config/hac/CRITICAL_RULES_CORE.md)
  - read_critical_rules_full → REMOVED (collapsed into single file)
- front_driveway entity inventory corrected: `light.front_driveway_inovelli_smart_bulb_mode` is Tier 1 SBM (was incorrectly listed as Tier 2 dumb load — S63 rename never propagated to docs)
- ha_restart applied; verified: read_critical_rules returns new content, read_critical_rules_full returns 400 (gone)

## State Right Now
- HA: 2026.4.x, HAOS — all green, Repairs=0
- Counts (unchanged from S67): 77 automations, 91 helpers, 0 YAML automations/helpers, 14 template packages, 0 ghosts, 19 calendars, 5 HACS cards, 3 storage-mode dashboards
- shell_command block loaded clean post-restart

## S69 Priority Queue
1. **Land Phase A Project Instructions edits** — outside-of-Claude task. Paste revised OPERATIONAL DEFENSES + revised SHELL RULES blocks (drafted in S68 chat) into project settings. Without this, the 4 promotions don't take effect.
2. **TIER 1 entry_room rename** — gated on physical-layout question: is the entry_room ceiling fixture the same physical fixture as entry_room_lamp, or a separate ceiling can? Answer unblocks rename + AL instance assignment.
3. **TIER 2/3/4 lighting work** — needs Hue app or battery hands-on, not chat-session fit.
4. **shell_command.health_check** — build on EQ14 using REST API pattern (carried forward since S51).

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
- Full system audit planned post-Green shutdown
- NordPass backlog cleanup
- Google Drive audit + DS224+ NAS reorganization
- Privacy/Security backlog: SSH password auth, CF Zero Trust, Git PAT plaintext, device_tracker recorder exclude

## Physical Updates
None this session.

## Benchmark
S68 = 1 session for governance + path audit (3 sessions overdue from S65/S66/S67). Future cadence: governance every 5 sessions, no slippage.

## Session Workflow Reminder
- read_critical_rules now points to /config/CRITICAL_RULES.md (single canonical file at repo root)
- read_critical_rules_full no longer exists
- shell_command edits in configuration.yaml require ha_restart (NOT reload_core) — S62
