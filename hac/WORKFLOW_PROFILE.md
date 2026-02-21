# John's Multi-LLM Smart Home Workflow
*Created: 2026-02-21 | Evolves continuously*

## Your Ecosystem

| Device | Role | Integration |
|--------|------|-------------|
| Samsung Phone | Voice capture, presence, mobile LLM | HA Companion, Claude/ChatGPT |
| Girls' iPhones | Presence tracking | HA Companion |
| Desktop | Primary HA work | Claude Desktop + MCP |
| UniFi APs | Network presence | UniFi Integration |
| UniFi Protect | Cameras, motion | Future: motion events |

## LLM Task Routing

| Task | Primary | Why |
|------|---------|-----|
| YAML editing | Claude Desktop + MCP | Direct entity access |
| Automation creation | Claude Desktop + MCP | Test templates live |
| Architecture decisions | Claude Opus 4.5 | Deep reasoning |
| Voice idea capture | ChatGPT Mobile | Fast voice mode |
| Research (blueprints) | Gemini | Long context, grounding |
| Quick lookups | Claude Haiku | Fast, cheap |

## Mobile → Desktop Handoff

### Capture Format
```
[HA-IDEA] Where: [location] When: [time/context]
Noticed: [behavior] Idea: [improvement]
```

### Process at Desktop
1. `hac mcp` - load context
2. Paste mobile capture
3. Claude queries state, proposes implementation
4. Implement or `hac tabled "idea"`

## Session Workflow

### Start
```bash
hac mcp                    # Context
cat tabled_projects.md     # Pending ideas
```

### During
```bash
hac learn "insight"        # Capture
hac active "current task"  # Focus
```

### End
```bash
hac active "next: [future task]"
git add -A && git commit -m "summary"
```

## Automation Mining

Pattern: Notice → Capture → Analyze logs → Implement

Example queries via MCP:
- ha_get_history(entity_id="input_boolean.hot_tub_mode")
- ha_get_states(["light.living_room_lounge_lamp", "input_boolean.hot_tub_mode"])

## Evolution

Tag workflow learnings: `hac learn "WORKFLOW: [insight]"`
Review monthly, update LLM assignments based on experience.
