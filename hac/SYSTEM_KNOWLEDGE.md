# Home Assistant System Knowledge Base
*Owner: John Spencer | Updated: 2026-04-14 (S17)*

## Platform
- Hardware: Beelink EQ14 (Intel N150, 16GB, 1TB NVMe)
- OS: Home Assistant OS 17.2 — bare metal, generic-x86-64
- Core: 2026.4.2
- Config path: /homeassistant/ (NOT /config/ — container alias only)
- IP: 192.168.1.10 (static DHCP in UniFi)
- External: https://ha.myhomehub13.xyz (Cloudflare tunnel)
- Cold spare: HA Green at 192.168.1.3 — ethernet disabled

## Architecture State (S17)
- 141 automations in UI storage ✅
- ~55 helpers still in YAML ❌ — S18 priority
- 27 package files still loading ❌
- 3 areas only, no floors/labels ❌
- Target: UI-first, zero packages, zero YAML helpers

## Key Integrations
- ZHA: Sonoff 3.0 USB Dongle (~49 devices)
- Hue Bridge: bulbs + FOH EnOcean PTM215Z (Green Power, NOT ZHA)
- ESPHome: ratgdo North fd8d8c, ratgdo South 5735e8, Apollo Entry 748020
- UniFi + Protect, Nest, Kumo Cloud, Navien, TP-Link x6, Sonos, Alexa Media
- Adaptive Lighting: 5/6 instances loaded

## Terminal / SSH
- Windows SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Browser terminal: http://192.168.1.10:8123 → Terminal sidebar (fastest)
- Git push always: GIT_TERMINAL_PROMPT=0

## LLM Routing
- Claude Desktop MCP: live HA work — helpers, automations, integrations
- Claude Web + Project: architecture, planning, blueprint writing, large file review
- Gemini 2.5 Pro: bulk triage (automation dumps, entity cleanup)
- Terminal: file edits, one-time audits only
