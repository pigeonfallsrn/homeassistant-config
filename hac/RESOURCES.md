# HAC Resources Index
*Complete reference for what exists and how to access it*

## Quick Reference

### Google Sheets (Live Data)
| Workbook | Purpose | Link |
|----------|---------|------|
| LLM Index | Token-efficient summaries, active issues | https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk |
| Master | Full entity/device/automation data | https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w |

### LLM Index Tabs
- **Status Summary** - System health at a glance
- **Active Issues** - Prioritized action items  
- **Recent Changes** - What changed since last export
- **Quick Reference** - Key entity IDs
- **HAC Session Latest** - Current session context
- **Recent Learnings** - Last 14 days parsed (NEW)

### Local Files
| File | Purpose | Size |
|------|---------|------|
| `ACTIVE.md` | Current task/next/blocked | <20 lines |
| `CONTEXT.md` | Session startup context | <50 lines |
| `knowledge/patterns.md` | Reusable technical patterns | ~50 lines |
| `knowledge/gotchas.md` | Pitfalls, hard lessons | ~40 lines |
| `knowledge/decisions.md` | Architectural choices | ~30 lines |
| `tabled_projects.md` | Paused projects with rationale | ~25 lines |

### Learnings
| Location | Contents | Retention |
|----------|----------|-----------|
| `learnings/YYYYMMDD.md` | Daily session insights | Last 30 days |
| `archive/` | Old audits, large files | Permanent |

### Commands
| Command | Purpose |
|---------|---------|
| `hac mcp` | Start MCP session (loads CONTEXT.md) |
| `hac active "task"` | Set current task |
| `hac learn "insight"` | Log to today's learnings |
| `hac backup <file>` | Timestamped backup |
| `hac export` | Generate Excel exports |
| `hac sheets` | Sync to Google Sheets |
| `hac push` | Full sync (gist + sheets) |

### MCP Capabilities
- `ha_search_entities(query)` - Find entities
- `ha_get_state(entity_id)` - Get current state
- `ha_call_service(domain, service, data)` - Control devices
- `ha_config_set_automation(config)` - Create/update automations

## When to Use What

| Task | Primary Resource | Fallback |
|------|-----------------|----------|
| Check entity state | MCP `ha_get_state` | Master Sheet |
| Find entity ID | MCP `ha_search_entities` | Master Sheet Entities tab |
| Review active issues | LLM Index → Active Issues | `hac export` → Action Items |
| Get AL/Inovelli config | `knowledge/patterns.md` | Search learnings |
| Understand past decision | `knowledge/decisions.md` | Git history |
| Resume paused work | `tabled_projects.md` | Search learnings |
| Debug automation | MCP + terminal YAML review | Automation Analysis tab |
