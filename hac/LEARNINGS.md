# LEARNINGS LOG — Accumulated across sessions
# Format: S## | Category | Learning
# Promoted to CRITICAL_RULES after 2nd occurrence

S44 | kiosk-mode | Does NOT work on strategy dashboards — must use storage-mode
S44 | fkb | Tier 1 (native wake/sleep) vs Tier 2 (HA automations) pattern
S44 | fkb | set_config requires device_id, not entity_id
S44 | fkb | switch.*.motion_detection is a toggle, not a sensor
S44 | entity-refs | RULE PROMOTED: Always verify entity existence before trusting automation configs (2nd occurrence: S42 Entry Room, S44 bathroom+tablet)
S44 | triple-fire | Multiple automations on same ZHA IEEE all fire — must delete legacy, not just disable
S44 | dashboard | .storage/lovelace.* is gitignored — dashboard configs not version-controlled
S44 | google-cal | OAuth tokens don't transfer between HA instances — need fresh flow
S44 | tablet-user | Non-admin + kiosk_mode + FKB kiosk lock = full lockdown stack
S43 | yaml-migration | MCP returns 0 for YAML-defined entities — reliable signal, not error
S42 | entity-refs | Broken entity refs survive across sessions (1st occurrence)
# (paste LEARNINGS_S45_APPEND.md content here)  

---

## S58 (2026-04-27) — Token Rotation + IP Ban Diagnosis

### NEW LEARNING: HA's IP ban middleware returns plain-text "403: Forbidden" (14 bytes), not HA's JSON error format
**Diagnostic value: HIGH.** When debugging 403s on HA API:
- 403 with body `{"message": "Unauthorized"}` (JSON) → HA's auth subsystem rejected the request → token problem
- 403 with body `403: Forbidden` (plain text, 14 bytes, `Content-Type: text/plain`) → aiohttp ban middleware blocked BEFORE auth check → IP ban problem
- 401 → HA's auth subsystem replied, token format invalid or absent

Always run `curl -v` and inspect Content-Type + body, not just status code. Status alone is ambiguous between the two failure modes.

### NEW LEARNING: `curl localhost` resolves to `::1` (IPv6) before `127.0.0.1` (IPv4) on HAOS
HA tracks IP bans separately per address family. Banning `::1` blocks every "obvious" loopback test from the host even though `127.0.0.1` is clear. To force IPv4 in diagnostic curls: `curl -4 ...`. To target IPv6 explicitly: `curl http://[::1]:8123/...` (square brackets required).

### NEW LEARNING: Self-banning is possible via auth-retry loops from internal services
The EQ14 host (192.168.1.10) banned itself on 2026-04-26. The decommissioned Green (192.168.1.3) was banned. ::1 was banned. Pattern indicates internal HA components or local scripts repeatedly authenticating with stale credentials get IP-banned by HA's own ban middleware. Effects compound: ban → next request route → ban → etc.

### NEW LEARNING: HA does NOT have `requests` module in system Python
For standalone shell tests of HA API auth patterns: use `urllib.request` (stdlib, always present). The `requests` module is only available inside HA's own Python environment (custom_components, integrations).

### NEW LEARNING: HAOS Python heredocs with `'PYEOF'` (quoted) survive chat-client linkification
When pasting Python via heredoc from chat: quote the heredoc terminator (`<< 'PYEOF'` not `<< PYEOF`). Quoted heredocs disable shell expansion AND the linkified `[name](http://name)` markdown gets passed through to Python verbatim — Python ignores it because it's syntactically a list+function call that's never evaluated. Works as protection against chat paste corruption. **Caveat: fails if the linkified text appears inside an actual Python string or as a bare identifier the script needs to reference.**

### NEW LEARNING: Backup files named `*.bak.s58*` are auto-ignored by `.gitignore` `*.bak.*` pattern
Useful for ephemeral session backups: rename pattern `<file>.bak.s<NN>` → automatically excluded. No need to add per-session entries.

### WORKFLOW LESSON: Verify "confirmed broken" claims before acting on them
The S58 starter prompt stated the LLAT was "confirmed REVOKED" with "Google Sheets sync + REST commands silently failing." Audit found:
1. Old token's 403 was likely an IP ban (not revocation) — original verification was insufficient
2. `export_to_sheets.py` had ZERO callers in any automation/shell_command/python_script — it was never running on a schedule, so couldn't be "silently failing" in a way that mattered
3. The actual broken state was 5+ weeks of accumulated IP bans, completely unrelated to the LLAT

**Rule:** When a session opens with "X is confirmed broken, fix it" — re-verify the broken state with a clean diagnostic before treating it as established fact. Today: ~90 minutes of work that turned out to be solving the wrong problem (rotation was clean, but the urgency framing was wrong; the real issue was found incidentally).

This is the **second** occurrence of "starter-prompt claim turned out to be misdiagnosed on closer inspection." Promoting to two-occurrence-rule candidate. If a third occurrence happens in S59-S62, promote to CRITICAL_RULES.

### WORKFLOW LESSON: HANDOFF.md drifted across S55–S57 (3 sessions)
File on disk showed S54 content despite S55, S56, S57 closures. Recovery was possible only because S58 starter prompt and git log preserved state. Going forward: HANDOFF.md regeneration is mandatory at session-end. No exceptions, no "I'll do it next time."

### WORKFLOW LESSON: Chat-client linkification is real and must be defended against
Observed corruption in pasted commands during S58:
- `f.read` → `[f.read](http://f.read)`
- `yaml.safe_load` → `[yaml.safe](http://yaml.safe)_load`
- `notify.mobile_app_galaxy_s26_ultra` → linkified prefix
- Email-like patterns → mailto links
- `HANDOFF.md` → linkified

Defenses:
1. Quoted heredocs (`'EOF'`) — most robust for python/shell embedded scripts
2. Pre-paste into a plain text editor to inspect for `[...](...)` corruption
3. Re-type any line containing dots-with-words that auto-linkified
4. For long blocks, save to temp file via nano then `bash /tmp/script.sh`

### NEW LEARNING: `git rm --cached` removes from index without deleting on disk
Useful when `.gitignore` was added AFTER files were tracked. The files remain on disk (HA keeps writing to them), but git stops tracking changes. After `git rm --cached`, the file may show as untracked (`??`) on next status — that's correct, `.gitignore` will exclude it from staging.

### NEW LEARNING: `automations.yaml` may be drifting from `.storage` (architectural — pending S59 diagnosis)
S58 found uncommitted S57 content in `automations.yaml` despite S57 closing with a clean commit. UI-first architecture says `.storage` is canonical for automations and `automations.yaml` should be untouched. Either:
- HA dual-writes (config + .storage)
- Direct YAML edits happened (MCP tool? shell script?)
- File is symlinked or included from elsewhere

Investigation deferred to S59. Content was correct so committed, but the WRITE PATH needs auditing.

