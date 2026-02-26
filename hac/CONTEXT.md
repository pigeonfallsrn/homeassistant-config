# John Spencer's Home Assistant Context
*HAC v9.1 - Token-Efficient Session Management*

## ⚠️ FIRST: Read CRITICAL_RULES.md
**Before doing anything**, review `/homeassistant/hac/CRITICAL_RULES.md`
Contains hard-won lessons that cost real time to learn.

## System
- **Platform:** HA Green, HA 2026.2.x
- **Scale:** ~4000 entities | 35 areas | 140 automations
- **Config:** /homeassistant/ (packages/, automations/)
- **MCP:** Connected - query live states directly

## Active Work
<!-- `cat ACTIVE.md` for current task -->

## Resources (request as needed)
| Need | Command |
|------|---------|
| **CRITICAL RULES** | `cat /homeassistant/hac/CRITICAL_RULES.md` |
| Reusable patterns | `cat /homeassistant/hac/knowledge/patterns.md` |
| Known gotchas | `cat /homeassistant/hac/knowledge/gotchas.md` |
| Architecture decisions | `cat /homeassistant/hac/knowledge/decisions.md` |
| Paused projects | `cat /homeassistant/hac/tabled_projects.md` |
| Today's learnings | `cat /homeassistant/hac/learnings/$(date +%Y%m%d).md` |

## Session Rules
1. **Read CRITICAL_RULES.md** before starting work
2. **Before edits:** `hac backup <file>`
3. **Persist insight:** `hac learn "CATEGORY" "what you learned"`
4. **Update focus:** `hac active "new task"`
5. **Commit work:** `cd /homeassistant && git add -A && git commit -m "summary"`

## Terminal Rules (ZSH)
- Escape `!` or use single quotes
- Never chain after `python3 -c` on same line
- Paths: /homeassistant/ (not /config/)
