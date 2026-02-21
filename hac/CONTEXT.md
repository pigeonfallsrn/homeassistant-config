# John Spencer's Home Assistant Context
*HAC v9 - Token-Efficient Session Management*

## System
- **Platform:** HA Green, HA 2026.2.x
- **Scale:** ~4000 entities | 35 areas | 140 automations
- **Config:** /homeassistant/ (packages/, automations/)
- **MCP:** Connected - query live states directly

## Active Work
<!-- Sourced from ACTIVE.md -->

## Resources (request as needed)
| Need | Command | Contains |
|------|---------|----------|
| Reusable configs | `cat /homeassistant/hac/knowledge/patterns.md` | AL settings, Inovelli params, motion patterns |
| Pitfalls learned | `cat /homeassistant/hac/knowledge/gotchas.md` | Hard-won lessons, breaking changes |
| Architecture | `cat /homeassistant/hac/knowledge/decisions.md` | Why things are built this way |
| Paused work | `cat /homeassistant/hac/tabled_projects.md` | Future projects with context |
| Recent learnings | `cat /homeassistant/hac/learnings/$(date +%Y%m%d).md` | Today's insights |
| Active issues | LLM Index Sheet → Active Issues tab | Prioritized action items |
| All entities | MCP `ha_search_entities` or Master Sheet | Entity lookup |

## Session Rules
1. **Before edits:** `hac backup <file>`
2. **Persist insight:** `hac learn "what you learned"`
3. **Update focus:** `hac active "new task"`
4. **Commit work:** `cd /homeassistant && git add -A && git commit -m "summary"`

## Terminal Rules (ZSH)
- Escape `!` in strings or use single quotes
- Never chain after `python3 -c` on same line
- Paths: /homeassistant/ (not /config/)
