# LEARNINGS LOG

## S40 — 2026-04-18
- MCP context blindness: terminal dumps >> MCP one-at-a-time for audit work
- Websocket bulk delete: REST cant delete entity registry. WS config/entity_registry/remove works. pip3 install websockets. Use max_size=2**22
- Hybrid REST+WS: REST for reads (no size limit), WS for writes (registry ops)
- 42 ghosts accumulated from earlier migrations — periodic sweeps needed
- notify service naming: phone name in mobile app registration = service name. After re-registration all old refs silently break
- Never-triggered != broken: timer resets, button handlers, condition-dependent automations show Never until conditions are met
- calendar.get_events is correct name but action doesnt register without calendar entities. Disable dont fix
- Garage notification anti-pattern: 7-automation chain is over-engineered. Use one automation with inline wait_for_trigger + choose

## S41 — Governance Synthesis (2026-04-18)

### Cross-model consensus (Claude + Gemini + ChatGPT)
- All three agree: MCP partial visibility is #1 risk. Never authoritative alone.
- All three agree: project instructions must be tiny (<800 tokens). Volatile data belongs in HANDOFF/LEARNINGS.
- All three agree: don't add Frigate, local LLM, vector stores, or extra services.
- All three agree: 3-tier export strategy (compact/readable/Gemini bundle) is directionally right.
- All three agree: infrastructure should be earned, not assumed.

### Key disagreement resolved
- Compass/Claude report assumed YAML-first architecture (packages by area). We're UI-first. Their YAML-specific recommendations don't apply.
- Gemini recommended Frigate on EQ14 — contradicts our Protect decision. Ignored.

### Adopted this session
- Two-occurrence promotion rule (prevents instruction bloat)
- Health check script (shell_command.health_check)
- PRIVACY.md (data flow map)
- Pruned project instructions draft (claude_project.md, <800 tokens)
- Git tagging for milestones
