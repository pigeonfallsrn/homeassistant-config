# HAC Claude MCP Integration Guide

**Version:** 1.0  
**Date:** 2026-02-16  
**Status:** ✅ Production Ready

## Quick Reference

**Desktop:** Open Claude → + → Connectors → Home Assistant ON  
**Code:** `cd /homeassistant && claude` → Enable connector  
**Test:** `curl http://localhost:8123/api/mcp`

## Configuration

**HA Integration:** mcp_server (installed 2026-01-22)  
**Desktop Config:** `%APPDATA%\Claude\claude_desktop_config.json`  
**Token:** HA → Profile → Security → Long-lived tokens (rotate q90d)

## HAC Workflow Integration

**MCP For:** Real-time states, device control, testing, verification  
**Files For:** Automation editing, config changes, git operations

**Pattern:**
1. Query state (MCP)
2. Analyze files (direct)
3. Edit (files)
4. Test (MCP)
5. Verify (MCP)
6. Commit (git)

## Example Workflows

**Troubleshoot:**
```
"MCP: entry room light + motion state"
Review entry_room.yaml
Edit automation
"MCP: trigger test"
Verify → commit
```

**Create:**
```
"MCP: list garage entities"
Review garage automations
"MCP: check patterns"
Draft automation
Create file
"MCP: test trigger"
```

## Troubleshooting

**Logs:** `notepad "$env:APPDATA\Claude\logs\mcp-server-home-assistant.log"`  
**Test Token:** `curl -H "Authorization: Bearer TOKEN" http://localhost:8123/api/states`  
**Config:** `notepad "$env:APPDATA\Claude\claude_desktop_config.json"`

## Commands
```bash
curl http://localhost:8123/api/mcp  # Test endpoint
cat /homeassistant/.storage/core.config_entries | grep mcp_server  # Check integration
cd /homeassistant && claude  # Start Code session
```

## System Info

- **Entities:** 146 lights + all others
- **Tools:** 91 (46 read-only, 45 write/delete)
- **Auth:** Bearer token (stored in password manager)
- **Network:** Local IP + Cloudflare tunnel
- **Status:** Desktop ✅ | Web ⏸️ (OAuth pending) | Code ✅

*Part of HAC v8.0+*

## Claude Code - Advanced Usage

### When to Use Claude Code vs Desktop

**Desktop MCP (Primary - 95% of work):**
- Real-time device queries and control
- Interactive troubleshooting  
- Single automation edits
- Daily HA maintenance
- Learning and exploration

**Claude Code (Specialized - 5% of work):**
- Large refactors (20+ files at once)
- Overnight autonomous tasks (1-4 hours)
- **Deep research on HA topics** (NEW capability)
- Systematic batch operations

### Deep Research Capability

**Use Case:** Comprehensive research on HA patterns, best practices, troubleshooting approaches.

**Example:**
```bash
cd /homeassistant && claude

"Deep research: Survey Home Assistant best practices for 
Adaptive Lighting + motion sensor conflict resolution. 
Include community patterns, common pitfalls, recommended 
automation structure. Generate report with citations."
```

**What Happens:**
- Runs 30-90 minutes autonomously
- Searches forums, GitHub, docs
- Verifies claims across sources
- Generates 10K-50K word report with citations
- You review, extract actionable insights

**Integration with HAC:**
1. Use Code for research → comprehensive report
2. Extract key patterns → promote to HAC knowledge
3. Implement solutions → document in automations
4. Test via Desktop MCP

### Test Command
```bash
cd /homeassistant && claude

"Quick research (15 min): Common patterns for preventing 
bathroom automation conflicts with Adaptive Lighting. 
Cite specific examples."
```

If valuable → use for future HA learning
If not → Desktop MCP sufficient for your workflow
