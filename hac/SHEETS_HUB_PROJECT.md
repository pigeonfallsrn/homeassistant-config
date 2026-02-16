# Google Sheets Knowledge Hub Project
*Started: 2026-02-16 | Status: Phase 1 Complete*

## Quick Resume
```bash
hac recall "sheets knowledge hub"
```

## Workbook Links
- **Master:** https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w
- **LLM Index:** https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk

## Progress

### ✅ Phase 1 - Foundation (COMPLETE)
- [x] Fixed `hac sheets` with python venv
- [x] Added `hac recall <topic>` command
- [x] Created 7 tabs: _Config, HA_Health, NET_VLANs, NET_IPs, NET_Devices, AI_Memory, AI_Preferences
- [x] Populated _Config with validation lists
- [x] Added headers to all new tabs

### 🔲 Phase 1B - Manual Setup (10 min)
- [ ] HA_Health tab: Paste QUERY formulas per instructions in sheet

### 🔲 Phase 2 - Gemini Integration
- [ ] Get API key: https://aistudio.google.com
- [ ] Add Apps Script with callGemini() function
- [ ] Create custom menu: 🏠 HA Tools → Analyze Entities
- [ ] Add =AI() prompt buttons to Dashboard

### 🔲 Phase 3 - Automation
- [ ] HA automation: daily hac sheets at 3am
- [ ] Apps Script trigger: weekly Gemini analysis

### 🔲 Phase 4 - Expansion
- [ ] Populate NET_* tabs (UniFi VLANs, IPs)
- [ ] Backfill AI_Memory from sessions
- [ ] Create HA_Entities_AI (token-optimized export)
- [ ] Add `hac memory "insight"` command

## Key Architecture Decisions
1. Single workbook (49K cells << 10M limit)
2. Tab prefixes: HA_, NET_, AI_
3. Apps Script for bulk Gemini (bypasses =AI() limits)
4. Full refresh export (2 API calls)
5. CSV format for LLM context (61% token savings vs JSON)

## Key Files
- `/config/python_scripts/export_to_sheets.py` - Export script
- `/config/python_scripts/venv/` - Python venv
- `/config/ha-service-account.json` - Google API creds
- `/homeassistant/hac/hac.sh` - HAC commands

## Next Session Prompt
"Continue Google Sheets Knowledge Hub project. Phase 1 complete. 
Ready for Phase 2 (Gemini integration) or Phase 1B (manual QUERY formulas).
See /homeassistant/hac/SHEETS_HUB_PROJECT.md for full status."
