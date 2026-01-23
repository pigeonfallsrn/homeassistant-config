# QUICK START GUIDE
**Updated:** 2026-01-12

## ⚡ THE WORKFLOW
```bash
# [HA TERMINAL]
hac                           # Get context
haclearn "what you fixed"     # Save solution

# [WINDOWS POWERSHELL]
robocopy "\\homeassistant.local\config\ai_context" "G:\AI_Context" /MIR /R:3 /W:5
```

---

## 📋 COMMAND REFERENCE

### HA Terminal Commands
| Command | Purpose | Output Size |
|---------|---------|-------------|
| `hac` | Quick diagnostic | ~20 lines |
| `haclogs` | Detailed errors | ~50 lines |
| `hacerrors` | Config issues | Variable |
| `haclearn "note"` | Save solution | Confirmation |
| `hacfull` | All entities JSON | Large |

### Windows PowerShell Commands
```powershell
# Sync HA to Google Drive
robocopy "\\homeassistant.local\config\ai_context" "G:\AI_Context" /MIR /R:3 /W:5

# Verify sync
Test-Path "G:\AI_Context\sessions\*.md"

# View recent files
Get-ChildItem "G:\AI_Context\sessions" | Sort-Object LastWriteTime -Descending | Select-Object -First 5
```

---

## 🎯 DAILY WORKFLOW

1. **[HA]** Run `hac`
2. **[Copy]** Paste output to AI (Claude/ChatGPT/Gemini)
3. **[Fix]** Apply AI's recommendations
4. **[HA]** Run `haclearn "description of fix"`
5. **[Windows]** Run sync command (when convenient)

---

## 🔍 FINDING THINGS
```bash
# [HA TERMINAL]
# Recent learnings
tail -10 /config/ai_context/session_learnings.txt

# Specific session
ls -lh /config/ai_context/sessions/ | tail -5

# Entity search
ha state list | grep "entity_name"
```

---

## 💡 PRO TIPS

- **Token efficiency:** Always start with `hac`, only use `haclogs` if needed
- **Sync timing:** Sync before starting new AI session for latest context
- **Edit location:** Always edit files on HA, then sync to Google Drive
- **Learning quality:** Be specific in `haclearn` messages - future you will thank you!

---

**Remember:** HA is source of truth, Google Drive is mirror!
