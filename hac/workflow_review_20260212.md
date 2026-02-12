# HAC Workflow Review - 2026-02-12

## Current HAC Structure

### Directory Layout
```
/homeassistant/
├── hac/
│   ├── session_YYYYMMDD.md (daily sessions)
│   ├── mcp_exposure_policy.md (MCP safety rules)
│   ├── mcp_entity_safety_matrix.md (risk classifications)
│   ├── mcp_complete_audit_report.md (audit results)
│   ├── current_exposure_baseline.txt (final exposure state)
│   ├── add_sensors_checklist.md (safe sensor list)
│   ├── scripts/
│   │   └── expose_all_safe_sensors.sh (batch exposure)
│   └── exports/ (Excel context exports)
├── hac_learnings.md (consolidated learnings)
└── python_scripts/
    ├── parse_learnings.py
    └── export_to_sheets.py
```

### HAC Commands Available
- `hac` - Launch session with status
- `hac mcp` - MCP-specific session start
- `hac learn "text"` - Log learning to session + consolidated file
- `hac backup <file>` - Backup before edits (assumed)

### Current Workflow Gaps

1. **Session Management:**
   - ✅ Daily sessions created automatically
   - ✅ Learnings logged to both session and consolidated file
   - ⚠️ No automated session cleanup (old sessions accumulate)
   - ⚠️ No session search/grep utility

2. **MCP Integration:**
   - ✅ Privacy policy documented
   - ✅ Exposure audit complete
   - ✅ Safety matrix established
   - ⚠️ No automated exposure drift detection
   - ⚠️ No monthly safety audit script

3. **Context Management:**
   - ✅ Excel exports in hac/exports/
   - ✅ Gist URLs in session header
   - ⚠️ No automated context refresh workflow
   - ⚠️ No validation that context is current

4. **Git Integration:**
   - ✅ Manual commits working
   - ⚠️ No pre-commit hooks for validation
   - ⚠️ No automated daily backups

## Recommended Optimizations

### 1. HAC Command Enhancements
Add these to /root/.local/bin/hac:

- `hac search "term"` - Grep all sessions for term
- `hac audit` - Run MCP exposure safety check
- `hac context` - Refresh and upload context to gist
- `hac cleanup` - Archive sessions older than 30 days

### 2. Automated Safety Monitoring
Create: /homeassistant/hac/scripts/monthly_audit.sh
- Check critical entities remain blocked
- Alert on new entities added to HA
- Verify exposure count (~290)
- Email/notify if drift detected

### 3. Session Organization
- Archive sessions older than 30 days to hac/archive/
- Keep only current month in active hac/ directory
- Maintain searchable index

### 4. Context Pipeline
- Automated nightly context export
- Push to gist automatically
- Validate no sensitive data in exports

## Issues to Debug (Next Session)

### Lighting Issues Noted:
1. **Alaina's LED lights always on** - Not auto-off
2. **Upstairs hallway AL issue** - 5:30am dark red on motion (should be off/dim)
3. **AL disabled for upstairs** - Why was this necessary?

### Investigation Plan:
1. Review Alaina's LED automation triggers
2. Check upstairs hallway AL configuration
3. Verify motion sensor behavior at dawn
4. Review automation traces for both issues

## Session Handoff Notes

**Completed This Session:**
- MCP privacy audit: ✅
- 290 safe sensors exposed: ✅
- Critical controls verified blocked: ✅
- Workflow documentation: ✅

**Next Session Priorities:**
1. Debug Alaina's LED lights (always on issue)
2. Debug upstairs hallway AL (5:30am red light issue)
3. Implement HAC workflow optimizations
4. Create automated safety audit script

**Context for Next Session:**
- User has comprehensive HA setup (146 lights, 49 ZHA devices)
- HAC workflow established and documented
- MCP privacy model: Knowledge (CSV) + Live State (MCP filtered)
- All critical safety items properly blocked
