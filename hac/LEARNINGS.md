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

## S42 — Entry Room Review (2026-04-18)

### YAML automations/ directory discovery
- `automation manual: !include_dir_merge_list automations/` on line 51 of configuration.yaml loads YAML automations from `/homeassistant/automations/` directory
- These automations have descriptive unique_ids (not timestamp IDs) and don't appear in `automations.yaml`
- 6 files still remain — future migration target
- Sequence: delete YAML file → restart → remove ghost entity → verify

### Automation consolidation best practice
- HA community consensus: one automation per room per function, dual triggers (on/off with for: delay), mode: restart, choose blocks for time-based branching
- Anti-pattern: automation A toggling automation B on/off for mode changes. Better: use conditions in automation B that check the mode state directly
- Separate concerns: motion-triggered behavior vs mode-triggered overrides are different automations because they have fundamentally different trigger types

### Entity ID staleness in YAML automations
- YAML files from older sessions may reference entity IDs that were since renamed
- entry_room_aux.yaml referenced `light.entry_rm_ceiling_hue_white_1_2` — stale, correct is `light.entry_room_ceiling_light`
- Always verify entity IDs when migrating YAML to UI

### Ghost cleanup after YAML removal
- After deleting YAML automation files, entities become restored=True ghosts
- Restart required to detect missing YAML, then ha_remove_entity cleans registry
- Strict sequence: delete file → restart → verify ghost → remove entity
