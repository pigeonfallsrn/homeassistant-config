# Tabled Projects - Updated 2026-02-05

## Active
- **2026-01-22: HA MCP Server Integration** - Enable official HA MCP Server (2025.2+) for Claude Desktop control. Settings → Devices & Services → Add Integration → Model Context Protocol Server.
- **2026-01-23: Phase 2 family_activities** - Connect winddown sensors to kids_bedroom_automation.yaml. WAYA softball calendars when season starts.
- **2026-01-23: Infrastructure** - UniFi Protect motion events to HA. Synology backups BLOCKED by SSH key.
- **2026-01-28: Add 3 lights to Living Spaces AL via UI** - living_room_west_floor_lamp, kitchen_hue_color_floor_lamp, kitchen_lounge_lamp.

## Blocked
- **2026-01-22: SSH key auth to Synology** - Add ha_to_synology.pub to admin@[IP]:~/.ssh/authorized_keys. Then integrate gdrive sync into hac push.

## Completed 2026-02-05
- Double-trigger issue - FIXED 2026-02-02. Added delay_off (60s/60s/90s), removed orphan entities.
- Cleanup duplicate garage automations - Rebuilt 2026-02-05. garage_quick_open.yaml is canonical.
- Delete orphan automations - DONE 2026-02-05. Removed 2 garage_all_lights_off orphans from entity registry.
