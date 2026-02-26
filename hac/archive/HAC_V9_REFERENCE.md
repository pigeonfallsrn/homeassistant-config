# HAC v9 Reference Guide
*Token-Efficient Multi-Session Context Management*
*Created: 2026-02-21*

## Overview

HAC v9 implements a three-tier context loading system optimized for Claude sessions:
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ TIER 1: ALWAYS LOADED (~500 tokens)                                        │
│ ─────────────────────────────────────                                      │
│ • ACTIVE.md - Current task/next/blocked                                    │
│ • System identity - HA version, scale                                      │
│ • Resource index - Where to find what                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ TIER 2: ON DEMAND (~2000 tokens each)                                      │
│ ─────────────────────────────────────                                      │
│ • knowledge/patterns.md - AL, Inovelli configs                             │
│ • knowledge/gotchas.md - Hard-won lessons                                  │
│ • knowledge/decisions.md - Architectural choices                           │
│ • tabled_projects.md - Paused work                                         │
│ • LLM Index Sheet tabs - Active issues, learnings                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ TIER 3: DEEP CONTEXT (explicit research)                                   │
│ ─────────────────────────────────────────                                  │
│ • Full learnings archive                                                   │
│ • Master Sheet (all entities/devices)                                      │
│ • Git history                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## File Structure
```
/homeassistant/hac/
├── ACTIVE.md              # Current task (always in prompt)
├── CONTEXT.md             # Session startup context
├── RESOURCES.md           # Full resource index
├── tabled_projects.md     # Paused projects
├── knowledge/
│   ├── patterns.md        # Reusable configs
│   ├── gotchas.md         # Pitfalls learned
│   └── decisions.md       # Architecture choices
├── learnings/
│   └── YYYYMMDD.md        # Daily insights (last 30 days)
├── archive/               # Old audits, large files
├── handoffs/              # Session handoff docs
└── exports/               # Excel exports
```

## Commands

| Command | Purpose |
|---------|---------|
| `hac mcp` | Start MCP session (token-efficient) |
| `hac sync` | Full export + sheets update (NEW) |
| `hac active "task"` | Set current task |
| `hac learn "insight"` | Log to today's learnings |
| `hac backup <file>` | Timestamped backup |
| `hac push` | Sync to gist |
| `hac export` | Generate Excel files |
| `hac sheets` | Sync to Google Sheets |

## Google Sheets

| Workbook | Purpose | Link |
|----------|---------|------|
| LLM Index | Token-efficient summaries | https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk |
| Master | Full data export | https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w |

### LLM Index Tabs
- **Status Summary** - System health
- **Active Issues** - Prioritized action items
- **Recent Changes** - What changed
- **Quick Reference** - Key entity IDs
- **HAC Session Latest** - Current session
- **Recent Learnings** - Last 14 days parsed (NEW)

## New Session Workflow

1. **You:** Paste `hac mcp` output into Claude
2. **Claude:** Reads ACTIVE.md, knows current task
3. **Claude:** Requests specific resources as needed
4. **You:** Run commands Claude suggests
5. **End:** `hac learn "what we accomplished"`

## Claude Access to Data

### What Claude CAN access directly:
- MCP: Live entity states via `ha_search_entities`, `ha_get_state`
- Terminal: All files via `cat`, `grep`, etc.
- Gist: Published context files

### What requires you to share:
- Google Sheets (Claude can't read spreadsheets directly)
- Excel files (upload to conversation)

### Workaround for sheets:
Publish LLM Index tabs as CSV → Claude can fetch via URL
(Future enhancement: auto-publish CSV on `hac sync`)

## Session Rules

1. `hac backup <file>` before ANY file edit
2. `hac learn "insight"` to persist knowledge
3. `hac active "task"` to update focus
4. MCP for live state, terminal for file ops
5. Git commit after significant changes

## Terminal Rules (ZSH)

- Escape `!` in strings or use single quotes
- Never chain after `python3 -c` on same line
- Paths: `/homeassistant/` (not `/config/`)

## Model Selection

| Model | Use Case |
|-------|----------|
| Sonnet 4.5 | Default - YAML editing, automation work (80%) |
| Opus 4.5 | Architecture decisions, complex debugging (20%) |
| Haiku 4.5 | Quick lookups |

## Changelog

- **v9.0** (2026-02-21): Token-efficient redesign
  - Added CONTEXT.md, RESOURCES.md
  - Created knowledge/ directory
  - Streamlined `hac mcp` output
  - Added `hac sync` command
  - Added Recent Learnings to LLM Index
  - Archived old system audits
