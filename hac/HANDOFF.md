# HAC Handoff — 2026-04-04 (Workflow Audit Session)

## Last 3 commits
  a7ab930 workflow: fix shell_commands - replace read_file template with static read_critical_rules + read_handoff
  (earlier commits from 2026-04-04 system audit session — see git log)

## MCP SESSION OPENER (use this instead of terminal cat)
Step 1 — Status check (no backup needed for read-only):
  shell_command.mcp_session_init  (return_response=True)
  → shows pending commits + last commit hash

Step 2 — Pre-edit backup (required before ANY config change):
  hassio.backup_partial(homeassistant=True, homeassistant_exclude_database=True,
    compressed=True, name="PreSession_YYYY-MM-DD")

Step 3 — Load context:
  shell_command.read_critical_rules  (return_response=True)
  shell_command.read_handoff         (return_response=True)

Step 4 — Work. Follow CRITICAL_RULES.md. Package changes = ha core restart.

Step 5 — Commit + push:
  terminal: git add -A && git commit -m "description"
  MCP:      shell_command.git_push (return_response=True)
  verify:   shell_command.git_last_commit — confirm hash matches

## Active tasks
  TASK: configuration.yaml dead entity reference fixes (HIGH PRIORITY — silently
    breaking templates). Lines 38-39, 45. See CRITICAL_RULES.md NEXT SESSION 1.
  NEXT: grep -n 'person.alaina\|person.ella\|john_s24\|alaina_iphone\|ella_iphone' /homeassistant/configuration.yaml
  BLOCKED: None

## Top backlog items (priority order)
  1. [ ] configuration.yaml dead entity refs — person.alaina/ella, device_tracker.john_s24
         Fix: sed/python replace with confirmed real IDs (see CRITICAL_RULES.md)
  2. [ ] South ratgdo firmware flash — http://ratgdo32disco-5735e8.local — v1394 OTA
  3. [ ] Kitchen lighting audit — P1 zones, manual override Option A, downstairs_motion group?
  4. [ ] Aqara sensor relocation — garage_north_door + garage_south_door
  5. [ ] Recorder: exclude cover.ratgdo* glob (per-second ESPHome polling)
  6. [ ] Remove 8 .bak files from packages/ (git is the backup)
  7. [ ] Automation categories in HA UI (159 automations, no organization)
  8. [ ] Doorbell popup: browser_mod.popup on tablet. Needs browser_mod installed first.
  9. [ ] Calendar: verify right column fills with dense_section_placement:false on tablet
  10.[ ] Presence tracker cleanup: verify/remove stale S24 tracker

## System state (2026-04-04)
  HA 2026.4.0, OS 17.1 — both current
  3,206 entities, 159 automations, 30 packages, 560MB DB
  Disk: 19GB/28GB used (71%)
  Both ratgdo boards: 2026.3.1 ✅
  North obstruction: toggle OFF in ratgdo web UI (hardware issue, not firmware)
  Git: pushed to github.com/pigeonfallsrn/homeassistant-config

## shell_command registry (all working as of 2026-04-04)
  git_push, git_status, git_last_commit, read_critical_rules, read_handoff, mcp_session_init
  NOTE: No Jinja2 {{ }} templates in shell_command values — causes silent load failure

## Start next session
  MCP: shell_command.mcp_session_init  ← replaces terminal cat
  MCP: shell_command.read_critical_rules
  MCP: shell_command.read_handoff
