# HOME ASSISTANT AI CONTEXT SYSTEM
**Updated:** 2026-01-12 | **Status:** Production | **Version:** 2.0

## 🎯 QUICK START

### In HA Terminal:
```bash
hac                    # Quick diagnostic (20 lines)
haclogs                # Detailed errors (50 lines)
hacerrors              # Config validation
haclearn "solution"    # Record what you fixed
```

### Commands Explained:
- **hac** - Token-efficient context (system info, entity counts, errors)
- **haclogs** - Full error log for deep troubleshooting
- **hacerrors** - Shows config validation issues
- **haclearn** - Saves solutions for future AI sessions
- **hacfull** - Complete entity state JSON dump

---

## 📊 WHAT YOU GET FROM `hac`
```
SYSTEM: HA 2026.1.1 | Config: ✅ Valid
ENTITIES: 136 lights | 195 automations
ERRORS: 0 recent
✅ No recent errors
```

**Token savings:** 90% reduction (200 lines → 20 lines)

---

## 🔄 SYNC WORKFLOW

**Source of Truth:** Home Assistant `/config/ai_context/`  
**Mirror:** Google Drive `G:\AI_Context\` (via Synology DS224+)

### Sync from Windows PowerShell:
```powershell
robocopy "\\homeassistant.local\config\ai_context" "G:\AI_Context" /MIR /R:3 /W:5 /XD ".git"
```

**Never edit files on G: drive - always edit on HA, then sync!**

---

## 📁 FILE STRUCTURE
```
/config/ai_context/
├── generate_smart_context.sh    # Creates hac output
├── get_logs.sh                   # haclogs command
├── haclearn.sh                   # Learning recorder
├── session_learnings.txt         # All recorded solutions
├── AI_INSTRUCTIONS.md            # Full AI guide
├── BASELINE_20260106.json        # Complete entity snapshot
├── latest_session/               # Symlink to newest session
└── sessions/TIMESTAMP/           # Timestamped sessions
    ├── all_states.json           # All entities
    ├── recent_errors.txt         # Error log
    ├── config_check.txt          # Config validation
    └── system_info.json          # Version info
```

---

## 🤖 CROSS-AI COLLABORATION

- **Claude** - Reads from current chat context + past chats tools
- **ChatGPT** - Reads from pasted `hac` output
- **Gemini** - Indexes `G:\AI_Context\` automatically

**All learnings saved to `session_learnings.txt` are shared across all AI tools.**

---

## ✅ SYSTEM STATUS (2026-01-12)

- HA Version: 2026.1.1
- Config: Valid
- Lights: 136
- Automations: 195
- Errors: 0
- Commands: Operational

### Working Features:
- ✅ Inovelli switch automations (Entry, Bathroom, Kitchen Lounge)
- ✅ HAC diagnostic system
- ✅ Cross-AI learning persistence
- ✅ Google Drive sync

---

## 🔧 TROUBLESHOOTING

**Problem:** `hac` not working  
**Fix:** `source ~/.zshrc` then `hac`

**Problem:** Files not syncing to Google Drive  
**Fix:** Run sync command from Windows PowerShell

**Problem:** Need more detail than hac provides  
**Fix:** Use `haclogs` for full error log

---

**Last Updated:** 2026-01-12  
**Maintainer:** John Spencer  
**Location:** Strum, WI
