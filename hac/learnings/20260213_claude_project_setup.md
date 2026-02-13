# Claude Project Setup Session - 2026-02-13

## Completed
- Created Claude Project "HA HAC System/Workflow" in browser (claude.ai)
- Uploaded SYSTEM_KNOWLEDGE.md (218 lines) as persistent knowledge base
- Added custom instructions with terminal rules, paths, model selection
- Added `hac project` command - outputs link + workflow guidance
- Added `hac` (no args) smart menu - replaces basic help with workflow-oriented guidance
- Fixed pre-push hook (was using `hac` alias, needed full path)

## Key Decisions
- Claude browser Project is now PRIMARY for HA work (not hac mcp/push)
- hac gpt/gem still needed for ChatGPT/Gemini (no persistent context)
- Sonnet 4.5 default (80%), Opus 4.6 for architecture (20%)

## Files Created/Modified
- /homeassistant/hac/SYSTEM_KNOWLEDGE.md - knowledge base for Project upload
- /homeassistant/hac/hac.sh - added cmd_menu(), project(), updated case statement
- /homeassistant/.git/hooks/pre-push - simplified to health + core check

## Workflow Change
OLD: hac mcp → paste gist URLs → chat
NEW: hac project → click link → chat (context persists)

## Opportunities Identified
- [ ] Fix upstairs hallway motion automation 5x firing issue
- [ ] Clean up 49 orphaned entities (hac doctor flagged)
- [ ] Fix hac audit exit code issue (arithmetic in ash shell)
- [ ] Archive redundant Claude Projects (workflow improvement, HAC review, etc.)
- [ ] Update SYSTEM_KNOWLEDGE.md when adding new integrations/patterns
- [ ] Consider adding `hac sync-knowledge` to auto-upload to Project (future)

## Terminal Rules Hardwired
- BACKUP FIRST: hac backup <file> before ANY edit
- ZSH ESCAPE: Use single quotes or escape ! in strings
- CHAIN COMMANDS: cmd1 && cmd2 (token efficient)
- HA PATHS: /homeassistant/ (not /config/)
- AFTER EDITS: hac check → restart if valid
