# HAC Workflow — John's Cheat Sheet
*Last updated: 2026-03-24*

---

## STARTING A SESSION — pick one

| Situation | Command | Why |
|-----------|---------|-----|
| Normal HA work (99% of the time) | `hac project` → opens claude.ai Project | No paste needed. Context already loaded. |
| Need to query live entities / debug state | `hac mcp` → paste output into Claude Desktop | Only use when you need real-time MCP access |
| Starting a Gemini session | `hac push` then `hac gem` → paste into Gemini | Refreshes gist, gives Gemini your full context |
| Starting a ChatGPT session | `hac push` then `hac gpt` → paste into ChatGPT | Same as above for GPT |

**Default: just open claude.ai and start typing. `hac project` is a shortcut to the URL.**

---

## DURING A SESSION — quick checks

| What you want | Command |
|---------------|---------|
| Who's home, last triggers | `hac status` |
| Something feels broken | `hac health` |
| Full system diagnostic (monthly) | `hac doctor` |
| Recent HA errors | `hac errors` |
| Find a past solution | `hac recall <topic>` |
| Review last week's learnings | `hac review 7` |

---

## BEFORE EVERY EDIT — non-negotiable
```
hac backup <filename>     <- ALWAYS FIRST, no exceptions
[make your edit]
hac check                 <- validate config
[restart if valid]
hac learn "CATEGORY" "what you discovered"
```

---

## ENDING A SESSION — always hac wrap
```
hac wrap
```

That's it. It will:
1. Print 3 questions (60 seconds to answer them honestly)
2. Auto-run hac close: git commit, backup pruning, export prompt

**Never end a session without running hac wrap. This is the habit.**

---

## KNOWLEDGE COMMANDS

| Command | What it does |
|---------|-------------|
| `hac learn "CATEGORY" "insight"` | Logs to today's file. Use every session. |
| `hac promote "text"` | Writes to CRITICAL_RULES.md permanently. |
| `hac deadend "what failed"` | Logs a dead end so you don't retry it. |
| `hac table "project idea"` | Saves something for a future session. |
| `hac recall <topic>` | Searches all past learnings. |

**Categories:** MOTION · YAML · AL · INOVELLI · DASHBOARD · PRESENCE · HAC · ENTITY · ZHA · MATTER

---

## LLM ROUTING — which AI for what

| Task | Use |
|------|-----|
| YAML editing, automation design, dashboard work | Claude Project (here) |
| Live entity queries, real-time debugging | Claude Desktop + MCP |
| Bulk entity cleanup, "what should I delete" | Gemini (hac gem) |
| Analyzing export xlsx with charts | ChatGPT Code Interpreter |

---

## THE 3-QUESTION WRAP (hac wrap prints these)

1. New YAML/tool gotcha? -> `hac promote "YAML: <lesson>"`
2. Hit a dead end? -> `hac deadend "<what failed and why>"`
3. Backlog changed? -> edit hac/BACKLOG_kitchen_dashboard.md

Take 60 seconds. Press Enter. Done.

---

## KNOWLEDGE FILE AUTHORITY

| File | Purpose |
|------|---------|
| hac/CRITICAL_RULES.md | Tier 1 — hard rules, dead ends, confirmed patterns |
| hac/KITCHEN_DASHBOARD_REFERENCE.md | Tier 1 — dashboard authority |
| hac/BACKLOG_kitchen_dashboard.md | Tier 1 — work queue, start here each session |
| hac/learnings/YYYYMMDD.md | Tier 2 — raw capture, promote good stuff to Tier 1 |
| Google Doc (old) | RETIRED — ignore, stale entity names |

---

## COMMANDS THAT EXIST BUT YOU DON'T NEED DAILY

- `hac push` — only before Gemini/GPT sessions or after major changes
- `hac q` — old, replaced by hac wrap workflow
- `hac doctor` — monthly hygiene only, slow
- `hac research` — deep context dump for complex multi-file problems
