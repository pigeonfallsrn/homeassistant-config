# HAC Modernization Review Session - 2026-02-13

## Decisions Made
- **Repo stays PRIVATE** — no need for pre-commit redaction, clean/smudge filters, or auto-redaction pipeline. Gitleaks audit tabled.
- **PII in gist is acceptable** — family names/presence in secret gist is comparable to social media exposure. Privacy audit tabled as non-urgent.
- **Default model switched to Sonnet 4.5** — Opus 4.6 reserved for architecture/complex debugging only (~20% of sessions). Haiku 4.5 for quick lookups.
- **Claude Projects to replace gist-based context** — upload knowledge base to Project for persistent RAG access, eliminates hac push for Claude sessions.

## Model Selection Guide (HARDWIRE THIS)
- **Sonnet 4.5** → Default. YAML editing, automation work, debugging, config reviews.
- **Opus 4.6** → Architecture decisions, complex multi-system debugging, research sessions.
- **Haiku 4.5** → Quick syntax lookups, simple questions.
- **Why:** Was burning through $20 Pro plan on Opus for everything. Sonnet handles 80% of HA work identically.

## Research Findings (3 AI models evaluated HAC modernization)
### All agreed:
- Privacy scanning (Gitleaks) is best practice but not urgent for private repo
- MCP Context Server replaces GDrive/Gist sync chain (local-first, faster, private)
- hac CLI Python rewrite is quality-of-life, not foundational — bash CLI works fine
- Pre-commit hooks deferred (only needed for public config sharing)

### Key research insight:
- MCP is now universal standard (Claude, ChatGPT, Gemini all support it)
- HA has official MCP Server integration since 2025.2 (4,300+ installations)
- Claude Projects with RAG can replace gist-based context delivery
- Markdown + YAML is most token-efficient format for LLM context (40-60% fewer tokens than JSON)
- Place device context at START of system prompt, rules at END (Lost in Middle effect)

### Phased implementation consensus:
1. Phase 1: MCP server + privacy scanning (parallel, ~80% of value)
2. Phase 2: CLI modernization
3. Phase 3: Pre-commit hooks (only if repo goes public)

## New HAC Commands Added
- `hac review [days]` — Categorized learning review (architecture, rules, tools, tabled, resolved)
- `hac promote "text"` — Promote a learning to 03_knowledge.md knowledge base

## Current Workflow Understanding
- `hac push` = generate context → audit → sync to secret GitHub gist → print prompt with URLs
- `hac mcp` = session prompt referencing gist URLs + HA MCP for live state (NOT running a custom MCP server)
- `hac learn` = append one-liner to daily learnings file
- Core pain points: (A) copy-paste friction between terminal and AI, (B) AI lacks full system context

## Tabled for Next Session
- [ ] Set up Claude Project "HA Config & Automation" with knowledge base files
- [ ] Upload key files to Project: SYSTEM_KNOWLEDGE.md, 03_knowledge.md, automation_architecture.md
- [ ] Add Project custom instructions with model selection guide and terminal rules
- [ ] Evaluate Claude Code for direct GitHub repo access (eliminates copy-paste entirely)
- [ ] Consider `hac consolidate` — automated weekly merge of learnings into knowledge base
- [ ] Consider unified `ai` command replacing push/q/gpt/gem/mcp (single entry point)
- [ ] Consider three-script self-improving loop (learn → consolidate → regen prompts)
- [ ] Set up HA MCP Server integration (Settings > Devices & Services > Add Integration > MCP Server)
- [ ] Fix that pre-push hook warning: chmod +x .git/hooks/pre-push

## Platform Capabilities Discovered
- Claude.ai: Projects, Memory (searches past chats), Google Drive/Calendar/Gmail connectors, Code feature
- Claude model selector: Opus 4.6, Sonnet 4.5, Haiku 4.5, plus extended thinking toggle
- Already have 6 Projects (several HA-related but likely unorganized)
- Claude Code (claude.ai/code): Can connect directly to GitHub repos — potential game-changer for HA workflow
