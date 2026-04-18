# Claude Project Instructions — HA Migration (EQ14)
# Source-controlled master. Sync to Claude Project manually when rules change.
# Target: <800 tokens. Last updated: S41 (2026-04-18)

## Environment
EQ14 Beelink (192.168.1.10) — bare metal HAOS, sole primary. DS224+ NAS (192.168.1.52) — backups. UI-first architecture: all automations/helpers/scripts/scenes in HA storage. YAML only for configuration.yaml + themes + blueprints + template packages.

## Truth Hierarchy
Behavior (runtime) > Config (YAML + .storage) > Git (versioned intent) > MCP (partial, never authoritative alone). Never conclude "X does not exist" from MCP — verify with terminal.

## Shell Rules
- && chain commands. GIT_PAGER=cat for git log. Paths: /homeassistant/ (never /config/).
- Git push ONLY via MCP shell_command.git_push. Terminal REST: curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/core/api/states
- notify service: notify.mobile_app_galaxy_s26_ultra

## Session Workflow
START: shell_command.read_handoff → shell_command.mcp_session_init → confirm goal → BASELINE (shell_command.health_check)
WORK: Terminal dump first → present A/B/C options → John decides → execute → verify
END: HANDOFF.md update → git commit → shell_command.git_push → verify log

## Rules
- NEVER use MCP one-at-a-time for audit work — terminal dump first
- ALWAYS present options before executing changes
- Two-occurrence rule: lessons become rules only after 2nd independent occurrence
- Every session: BASELINE at start, BENCHMARK at end
- Learnings → LEARNINGS.md. Rules → CRITICAL_RULES_CORE.md (only after 2nd occurrence)

## NEVER DO
- Commands on Green (192.168.1.3) — decommissioned
- Create UI automation before stripping YAML (causes _2 suffix)
- Auto-cycle garage door
- Edit .storage while HA running
- Execute changes without presenting options first

## Pointers
See HANDOFF.md for current state, tabled items, next priorities.
See REVIEW_WORKFLOW.md for 10-step review process.
See LEARNINGS.md for accumulated discoveries.
See PRIVACY.md for data flow rules.
