# HA MIGRATION — EQ14 PROJECT INSTRUCTIONS

## TRUTH HIERARCHY
Behavior (runtime) > Config (YAML + .storage) > Git (versioned intent) > MCP (partial, never authoritative alone). Never conclude "X does not exist" from MCP alone — verify with terminal.

## SHELL RULES
- Chain commands with `&&` for sequential ops where exit code matters (commits, file writes, restarts); use `;` for diagnostic dumps where you want all sections to print regardless of individual failures.
- `GIT_PAGER=cat` for git log (BusyBox).
- Paths: `/homeassistant/` from terminal, `/config/` in shell_commands.
- Git push ONLY via MCP `shell_command.git_push` (bundles add + commit + push in one call — pass message via `{{ message }}` param), never from terminal.
- Notify service: `notify.mobile_app_galaxy_s26_ultra`.
- HAOS `shell_command` does NOT support stdin piping — file writes require browser terminal heredoc paste with full content (no placeholders).
- **REGEX PRE-FLIGHT (S71-promoted):** When writing a regex/awk/sed pattern against text whose structure is unverified, do a 1-line existence check first (e.g., `grep -c PATTERN /path`). If it returns 0, the pattern is wrong — re-inspect structure before building a multi-step pipeline. Cost-free safeguard.

## CONFIG EDIT WORKFLOW (S72-promoted)
After ANY edit to `configuration.yaml` or files referenced from it (packages, includes, etc.), the next two MCP calls are mandatory:
  1. `ha_check_config` — must return `valid:true`. Skipping this risks bricking the instance on next restart.
  2. Apply changes:
     - `ha_reload_core(target=<scope>)` for hot-reloadable scopes: automations, scripts, scenes, groups, input_*, timers, counters, templates, persons, zones, themes, core (customize/packages)
     - `ha_restart(confirm=true)` for changes that load only at startup: shell_command bindings, integrations, device tracker platforms, sensor platforms, custom components
   Skipping check risks brick. Skipping reload/restart leaves changes inert. Verify the change took effect via a smoke-test call before declaring done.

## SESSION STARTER PROTOCOL
User pastes ≤3 lines per session: `S<NN>. <focus or "top of HANDOFF queue">. Physical: <updates or "none">.`

On EVERY session start, Claude executes without asking:
  1. `shell_command.read_handoff`
  2. `shell_command.mcp_session_init`
  3. Confirm chosen focus in 1 line; recommend if user said "top of queue"
  4. Wait for "go"/"continue" before terminal dumps

`shell_command.read_instructions` is also available if Claude needs to re-check the rules mid-session.

## WORK PHASE
Terminal dump first → present A/B/C options with rationale → John decides → execute → verify. Never use MCP one-at-a-time for audit work.

## 10-STEP REVIEW WORKFLOW (when reviewing a system/area)
BASELINE → SCOPE → DUMP → RESEARCH → ANALYZE+OPTIONS → DECIDE → EXECUTE → VERIFY → DOCUMENT+COMMIT → BENCHMARK.

## SESSION CLOSE PROTOCOL
On EVERY close, Claude executes without being asked. If user says "close" / "wrap" / signals end:
  1. Verify acceptance criteria for goal
  2. Generate HANDOFF.md heredoc (overwrites — captures S<NN> only)
  3. Generate LEARNINGS.md heredoc (appends — new learnings + workflow lessons + any `### Promotions` subsection)
  4. User pastes both in browser terminal
  5. After confirmation: stage, commit, push via MCP `shell_command.git_push`
  6. Verify git log shows new commit

HANDOFF.md must be regenerated every session-end. NO EXCEPTIONS. S58 found drift across S55-S57 because closes were skipped.

LEARNINGS.md is append-only with `## S<NN> (date) — <topic>` header.

## GOVERNANCE
Every 5 sessions: review LEARNINGS.md to promote mature learnings into INSTRUCTIONS.md.

**Two-Occurrence Rule (default):** A technical learning becomes a permanent rule only after the second independent occurrence. First occurrence → LEARNINGS.md only. Second → promote here.

**Credential-class carve-out (S72-established):** Any learning describing a failure mode that leaks or risks leaking secrets, tokens, credentials, PII, or other sensitive data promotes on FIRST occurrence. The asymmetric cost of credential exposure (mandatory revoke + recreate + risk window) eliminates any benefit to waiting for a second instance.

**Promotion tracking:** Because LEARNINGS.md is append-only, promoting sessions add a `### Promotions` subsection in their own LEARNINGS entry listing each promoted learning by its original `## S<NN> — <topic>` header and the section in INSTRUCTIONS.md where it now lives. This preserves append-only AND maintains a search-friendly audit trail in both directions.

## PROMOTED RULES (do not violate)
- **ENTITY REF (S44/45/45):** Verify entity existence for ALL referenced entities in an automation group before trusting configs. Use batch `ha_get_state`.
- **TRIPLE-FIRE (S44):** Multiple automations on same ZHA `device_ieee` all fire — delete legacy duplicates, don't just disable.
- **GHOST SCRIPT (S45):** Scripts with `restored:true` and no config in registry require `ha_remove_entity`, NOT `ha_config_remove_script` (returns 400).
- **HUE MIGRATION (S45):** After Hue Bridge migration, scan for `hue_` prefixed entity refs in automations. Old generic names (`hue_dimmer_switch_N`) become stale.
- **KIOSK MODE (S44):** Does NOT work on strategy dashboards. Storage-mode + `kiosk_mode` config block + non-admin user = reliable lockdown.
- **FKB (S44):** Tier 1 native wake/sleep (Screen Off Timer + camera motion, no HA automations). Tier 2 HA automations for brightness/doorbell/presence/URL. `set_config` requires `device_id` not `entity_id`.

## OPERATIONAL DEFENSES
- **LINKIFICATION (S58):** All multi-line python/heredoc blocks use single-quoted terminators (`<< 'PYEOF'`). Chat-client linkification of `foo.bar` patterns then becomes harmless to execution.
- **BACKTICK TLD STRINGS (S58/S62):** When chat content contains domain-like tokens with non-`.com` TLDs (`.school`, `.travel`, `.app`, `.xyz`, etc.) outside of code blocks, wrap them in inline code spans so the chat client doesn't auto-linkify them. Prose-side counterpart to LINKIFICATION.
- **DIAGNOSTIC DISCIPLINE (S58/S60/S61/S64/S65/S71):** When starter or HANDOFF says "X is broken/confirmed/revoked/working", verify ground truth with a clean diagnostic before treating as established fact. Misdiagnosis costs whole sessions.
  - **Provenance clause (S71-promoted):** Close-note findings must cite the dump that produced them. Each "Done" or finding in HANDOFF should reference either a `=== block ===` from the same session's chat or a file path with line numbers. Findings without provenance get marked `(unverified)` and the next session must verify before acting on them.
- **SECRETS HANDLING:** Never print tokens/passwords/API keys to chat. Use temp-file + env-var pattern: paste into `/tmp/X.txt` via nano, read into env var, pass via `os.environ` to python heredoc, `shred -u` after use.
- **SECRET REQUEST PROTOCOL (S71-promoted, credential-class carve-out):** When asking John for any secret (token, password, API key, credentials), the request MUST: (a) specify exactly one channel, (b) that channel MUST be terminal-only, (c) MUST NOT include phrases like "paste here", "send me", "or paste in chat", or any optional chat-channel paste. Standard phrasing: *"Open browser terminal, run `nano /path/to/file`, paste, save (Ctrl+O Enter Ctrl+X), then reply 'done'."* Violations require revoke + recreate of the leaked secret.

## NEVER DO
- Commands targeting Green (`192.168.1.3`) — decommissioned
- Create UI automation before stripping any conflicting YAML
- Auto-cycle garage door (no automation should toggle it without explicit human trigger)
- Edit `.storage/*` while HA is running
- Execute destructive changes without presenting options first
- Git push from terminal — only via MCP `shell_command.git_push`
- Echo tokens/secrets to chat or shell history
- Ask for secrets via any channel that includes "paste in chat" as an option

## POINTERS (current state lives in files, not here)
- **INSTRUCTIONS.md** (this file): permanent rules, promoted from LEARNINGS via Two-Occurrence Rule + credential-class carve-out
- **HANDOFF.md** (overwritten each session): current state, S<NN> work, S<NN+1> priority queue, carryforward, blocked, benchmark
- **LEARNINGS.md** (append-only): all accumulated learnings by session, with `### Promotions` subsections noting what each session promoted to INSTRUCTIONS.md
- **HA_MASTER_PROJECT_PLAN.md** (project file): long-term migration plan
- All session-specific state (current automation count, blocked items, etc.) is in HANDOFF.md — do not duplicate here
