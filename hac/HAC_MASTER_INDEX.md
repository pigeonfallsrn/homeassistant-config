# HAC Master Index
## Quick Start for New Sessions

**For ANY AI (Claude, ChatGPT, Gemini):** Start with this context:
```
Read /config/hac/SYSTEM_KNOWLEDGE.md first, then run: hac claude
```

---

## File Structure
```
/config/hac/
├── HAC_MASTER_INDEX.md      ← YOU ARE HERE (start point for AI sessions)
├── SYSTEM_KNOWLEDGE.md      ← Architecture decisions, device IDs, diagnostics
├── hac.sh                   ← Main HAC script (v4.2)
├── contexts/                ← Auto-generated session contexts
│   ├── claude_*.md          ← Claude-formatted contexts
│   ├── chatgpt_*.md         ← ChatGPT-formatted contexts
│   ├── gemini_*.txt         ← Gemini-formatted contexts
│   └── session_learnings_*.md ← Deep-dive session notes
├── learnings/               ← Historical session learnings
│   ├── 20260118_comprehensive_audit.md
│   ├── CLEANUP_COMPLETE.md
│   ├── KITCHEN_TABLET_COMPLETE.md
│   └── disabled_entities.txt
└── SESSION_*.md             ← Major session summaries
```

---

## Current System State (Updated 2026-01-19)

### Automation Locations
| File | Count | What's There |
|------|-------|--------------|
| `/config/automations.yaml` | 11 | Switches, humidity, misc |
| `/config/main.yaml` | 7 | Inovelli controls, lights-off |
| `/config/packages/garage_lighting_automation.yaml` | 2 | Garage on/off |
| `/config/packages/presence_system.yaml` | 12 | Presence (input_booleans) |
| `/config/packages/occupancy_system.yaml` | 8 | Calendar, context |

### Critical Architecture Rules
1. **Presence:** Use `input_boolean.*_home`, NOT `binary_sensor.*_home`
2. **Garage lighting:** ONLY in package, not automations.yaml
3. **Inovelli:** `on/off` in main.yaml, `button_*_press` in automations.yaml

### Active Issues
- [ ] North garage door obstruction sensor (HARDWARE - needs physical fix)

---

## Session Workflow

### Starting a New Session
1. Run `hac claude` (or gpt/gemini)
2. Paste the output to the AI
3. Reference this file: "Read /config/hac/HAC_MASTER_INDEX.md"

### Ending a Session
Ask the AI to:
1. Create session learnings file: `/config/hac/contexts/session_learnings_YYYYMMDD.md`
2. Update `/config/hac/SYSTEM_KNOWLEDGE.md` if architecture changed
3. Note any TODOs for next session

---

## Key Files to Reference

| Need | File |
|------|------|
| System architecture, device IDs | `/config/hac/SYSTEM_KNOWLEDGE.md` |
| Database queries, diagnostics | `/config/hac/SYSTEM_KNOWLEDGE.md` |
| Entity cleanup history | `/config/hac/learnings/20260118_comprehensive_audit.md` |
| Kitchen tablet setup | `/config/hac/learnings/KITCHEN_TABLET_COMPLETE.md` |
| Disabled entities list | `/config/hac/learnings/disabled_entities.txt` |

---

## Common Commands
```bash
# Generate fresh context
hac claude    # For Claude
hac gpt       # For ChatGPT  
hac gemini    # For Gemini

# Check system
ha core check
hac check

# Reload after changes
curl -s -X POST http://supervisor/core/api/services/automation/reload -H "Authorization: Bearer $SUPERVISOR_TOKEN"

# View recent contexts
ls -lt /config/hac/contexts/ | head -10
```

---

## Change Log

### 2026-01-19
- Major automation cleanup (693→377 lines)
- Deleted orphaned presence.yaml
- Fixed duplicate automations (garage, entry, bathroom)
- Identified north garage door hardware issue
- Created SYSTEM_KNOWLEDGE.md

### 2026-01-18
- Entity cleanup (36 entities removed)
- HAC v4.2 verified working
- Ella's iPhone integration documented

### 2026-01-17
- Kitchen tablet automation created
- HAC system established
- Initial system audit
