# Home Assistant System Knowledge Base

## System Overview
- **Platform:** Home Assistant Green (2026.2.1)
- **Location:** Strum, Wisconsin
- **Network:** UniFi infrastructure with VLAN segmentation
- **Zigbee:** Sonoff 3.0 USB Dongle Plus (49 devices, ZHA)
- **Key Integrations:** Philips Hue, UniFi, Nest, Mitsubishi, Adaptive Lighting

## Family Context
- john_spencer, alaina_spencer, ella_spencer (primary residence)
- michelle, jarrett_goetting, owen_goetting (nearby, frequent presence)
- jean_spencer (monitoring)

## Architecture Decisions
$(cat /homeassistant/hac/notes/automation_architecture.md)

## Terminal Rules
- ZSH: Escape ! in strings, don't chain after python3 -c
- HA CLI: 'ha' command doesn't support 'services' - use REST/websocket
- Config path: /homeassistant/ (not /config/)
- Backup before edits: cp file file.bak.$(date +%Y%m%d)

## Automation Best Practices
- Dual-trigger pattern (on/off with IDs) over wait_for_trigger
- Always use mode: restart for motion automations
- Adaptive Lighting: separate_turn_on_commands=true, take_over_control=true
- Use Hue app groups (not HA groups) for multi-bulb fixtures

## Device Reference
$(grep -A 50 "## Device Inventory" /homeassistant/hac/03_knowledge.md | head -100)

## Model Selection Guide
- **Sonnet 4.5:** Default for YAML, automation work, debugging (80% of sessions)
- **Opus 4.6:** Architecture decisions, complex multi-system debugging (20%)
- **Haiku 4.5:** Quick syntax lookups only

## Recent Learnings
$(tail -200 /homeassistant/hac/learnings/*.md)
