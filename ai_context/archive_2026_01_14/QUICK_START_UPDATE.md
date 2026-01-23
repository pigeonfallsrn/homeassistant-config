
---

## 🆕 NEW: HAC DIAGNOSTIC SYSTEM (2026-01-06)

### Quick Commands
```bash
hac                                 # Generate full diagnostic (replaces old system)
haclearn "what we figured out"      # Record learnings
bash /config/ai_context/create_baseline.sh  # Update baseline (quarterly)
```

### What Changed
- **Baseline system**: 1.5MB snapshot of all 2,912 entities (quarterly updates)
- **Fast exports**: 2-second diagnostic vs 2-5 minute gathering
- **Persistent learnings**: `session_learnings.txt` shared across all AIs
- **Cross-AI ready**: AI_INSTRUCTIONS.md guides ChatGPT/Gemini/Claude

### New Files in AI_Context
- `AI_INSTRUCTIONS.md` - Complete guide for all AI tools
- `AI_ONBOARDING.txt` - Quick onboarding text for new AI sessions
- `Get-AIOnboarding.ps1` - PowerShell helper (copies onboarding to clipboard)
- `BASELINE_20260106.json` - Full system snapshot
- `session_learnings.txt` - Cumulative learnings

### Updated Workflow
```bash
# 1. Generate context (2 seconds)
hac

# 2. Copy the ~40 line output

# 3. For ChatGPT/Gemini: Also copy AI_ONBOARDING.txt first

# 4. Paste to AI + describe issue

# 5. After solving: haclearn "solution description"
```

### PowerShell: New Onboarding Helper
```powershell
# Copy onboarding text to clipboard
cd "\\DS224plus\GoogleDrive\AI_Context"
.\Get-AIOnboarding.ps1
# Then paste to ChatGPT/Gemini, followed by hac output
```
