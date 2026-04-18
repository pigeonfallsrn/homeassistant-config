# Privacy — Data Flow Map

## What goes where

### MCP (Claude via Cloudflare tunnel)
- Entity states (names, values, attributes)
- Automation configs (aliases, triggers, actions)
- Service calls (what we execute)
- Shell command outputs (git status, health checks)
- Does NOT see: .storage raw files, secrets.yaml values, network topology

### Gemini (manual paste only)
- Sanitized automation dumps (redacted IPs, no secrets)
- Entity naming inventories
- NEVER: raw .storage files, person tracker data, MAC addresses

### ChatGPT (manual paste only)
- Architecture proposals, tradeoff analysis
- Sanitized config excerpts
- Use Temporary Chat for presence/person data

## What stays local (never leaves EQ14/NAS)
- secrets.yaml values
- Long-lived access tokens
- Person tracker coordinates (lat/lon)
- MAC addresses (device trackers)
- Cloudflare tunnel credentials
- SSH keys
- Camera feeds (UniFi Protect)

## Rules
1. No raw .storage files to any cloud model
2. No person/presence data without Temporary Chat mode
3. PAT rotation: quarterly (next due: set after first rotation)
4. MCP token scope: review quarterly what's exposed
5. Git repo is private — but treat pushes as if public (no secrets in commits)
