# HANDOFF — S41 complete | 2026-04-18

## Completed this session (S41)

### Governance synthesis from cross-model review
- Read and synthesized research from Claude, Gemini (deep research), and ChatGPT (deep research)
- Identified consensus: tiny instructions, two-occurrence rule, health check, privacy awareness
- Created PRIVACY.md — data flow map (what goes where, what stays local)
- Added two-occurrence promotion rule to REVIEW_WORKFLOW.md
- Created health_check_full.sh — registered as shell_command.health_check
- Drafted pruned project instructions as hac/claude_project.md (<800 tokens)
- Git tagged good-2026-04-18 as stable milestone

### Key consensus findings
- All models agree: MCP is partial visibility, never authoritative alone
- All models agree: project instructions should be <800 tokens
- All models agree: don't overbuild governance — boring infrastructure wins
- Gemini's area-less entity insight: entities without areas are invisible to AI spatial reasoning

## Current State

### Automation count: 99
- 52 confirmed active, 44 never triggered (flagged for review), 2 calendar disabled, 1 entry disabled

### Governance files
- HANDOFF.md — rolling session state (this file)
- LEARNINGS.md — accumulated discoveries
- REVIEW_WORKFLOW.md — 10-step process + two-occurrence rule
- PRIVACY.md — data flow map
- claude_project.md — source-controlled project instructions (<800 tokens)
- CRITICAL_RULES_CORE.md — hard rules (prune with two-occurrence rule)
- health_check_full.sh — registered as shell_command.health_check

## Next Priorities
1. Run health_check — establish new enriched baseline
2. Prune project instructions in Claude Project (sync from claude_project.md)
3. Entry Room — area review (first full cycle with improved workflow)
4. 2nd Floor Bathroom — simplify 12 automations
5. Kitchen tablet — 5/6 never fired
6. Kids bedrooms — blueprint standardization
7. Scenes/Scripts/Dashboard audit

## Tabled (carried forward)
- Person trackers: Ella (unknown), Michelle (MAC: 6a:9a:25:dd:82:f1)
- Jarrett & Owen: grades tracked, person entities not configured
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error
- North ratgdo: toggle obstruction OFF after OTA
- Apollo Kitchen 192.168.21.233: OTA pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66
- humidity_smart_alerts: UI rebuild pending
- Aqara sensor gap: 6 door + 4 P1 motion
- 2 unnamed Aqara Temp/Humidity sensors
- first_floor_hallway_motion delay_off bug
- 6 Ella bedroom scenes missing
- HA Green full config audit before wipe
- Security session: Cloudflare ZT + PAT rotation
- 6 repair issues: http://192.168.1.10:8123/config/repairs
