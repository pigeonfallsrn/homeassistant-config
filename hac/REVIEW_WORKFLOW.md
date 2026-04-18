# HA REVIEW WORKFLOW — v1.0
# Terminal-First, Research-Backed, Decision-Documented
# Established S40 — 2026-04-18
#
# THE CYCLE:
# 1. BASELINE (terminal dump, paste to Claude)
# 2. SCOPE (agree on area)
# 3. DUMP (terminal configs, paste to Claude)
# 4. RESEARCH (Claude searches HA community best practices)
# 5. ANALYZE + OPTIONS (Claude presents A/B/C with tradeoffs)
# 6. DECIDE (John picks)
# 7. EXECUTE (MCP for small changes, terminal for bulk)
# 8. VERIFY (terminal confirms changes landed)
# 9. DOCUMENT + COMMIT (terminal writes HANDOFF + git)
# 10. BENCHMARK (before/after counts)
#
# RULES:
# - Never act on MCP-only context for audit work. Terminal dump first.
# - Always present OPTIONS before executing. John decides.
# - Research HA community best practices before recommending rebuilds.
# - Every session: BASELINE at start, BENCHMARK at end.
# - Learnings go in LEARNINGS.md every session.
# - Git commit via terminal, push via MCP shell_command.git_push.
