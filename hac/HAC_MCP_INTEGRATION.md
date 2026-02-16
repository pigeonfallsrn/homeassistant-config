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
