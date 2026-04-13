# CRITICAL RULES — EQ14 Beelink
# Distilled from 12 sessions. Green-specific items removed.

## BEFORE ANY EDIT
  hac backup <filename>   # NON-NEGOTIABLE

## TERMINAL
- Paths: /homeassistant/ (not /config/)
- Git push: ONLY via shell_command.git_push (GIT_TERMINAL_PROMPT=0)
- HAC CLI: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
  (re-run after power cycle — symlink doesn't survive HAOS reboot)
- Escape ! in zsh: use single quotes

## MOTION AUTOMATIONS
- Always mode: restart
- Combined binary_sensor (template OR-logic), not individual sensors
- delay_off on template sensors: 60s minimum
- binary_sensor group does NOT support delay_off — use template instead
- Dual trigger: motion ON starts, motion OFF + wait turns off
- Timeouts: transition 5-10min, active 8-20min, relaxation 15-45min
- Apollo LD2450 zone fix: Zone-1 X1=-4000,X2=4000,Y1=500,Y2=6000,timeout=60s

## INOVELLI SWITCHES (ZHA)
- Smart Bulb Mode: Param 52=1 + LED bar params 95-98
- Config button cycling: input_number + modulo (not input_select)
- Parameters: toggle OFF→ON in ZHA UI then air gap to write
- VZM35-SN fans: Param 12 (auto-off) = 2700s safety backup
- VZM36 dual endpoints: EP1/EP2 are raw ZHA — use Hue group, hide EPs

## ADAPTIVE LIGHTING
- Create/delete via UI ONLY — no API exists
- Hue bulbs require ALL THREE:
    separate_turn_on_commands: true
    take_over_control: true
    detect_non_ha_changes: false
- Same make/model bulbs per instance
- 6 instances: living_spaces, entry_room_ceiling, entry_room_lamp_adaptive,
  kitchen_table, master_bedroom_wall_lamp, upstairs_hallway
- autoreset: bedrooms=0, kitchen/living=3600, hallways/baths=1800
- Late-night red/orange is CORRECT AL behavior (not scene bleed)
- hot_tub_mode off actions need explicit color restore (backlog fix)

## ENTITY NAMING
- ZHA gives generic entity_ids — rename via ha_rename_entity
- Convention: domain.area_descriptor (light.kitchen_chandelier)
- 55 entities flagged for rename (see Google Sheets audit)

## HUE BRIDGE
- FOH switches use Zigbee Green Power — ZHA cannot support them
- FOH/dimmers stay on Hue Bridge → hue_event (never mix with zha_event)
- 12 accessory limit per bridge — monitor count
- Bulb power state: set to "Last on" for AL compatibility

## DASHBOARDS
- Storage-mode backup BEFORE any edit:
  cp .storage/lovelace.NAME hac/backups/NAME-$(date +%Y%m%d-%H%M).json
- Single comprehensive transform — never piecemeal index edits
- kitchen_wall theme gutter fix: card-mod-view-yaml (see themes/)

## FULLY KIOSK BROWSER
- Disable auto-update: FKB Settings > Auto-Update = OFF
- Configure via HA: fully_kiosk.set_config (works cross-VLAN)
- device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b

## NEVER EDIT DIRECTLY
- .storage/core.config_entries
- .storage/core.entity_registry
- .storage/core.device_registry

## UI-ONLY (No API/CLI)
Adaptive Lighting, ZHA pairing, Hue linking, Matter commissioning

## SAFE VIA API/MCP
Automations, Scripts, Helpers, Services, Entity settings, Dashboards

## DOUBLE-FIRE PREVENTION
1. Motion sensors have delay_off? (60s minimum)
2. Using combined sensor, not individual?
3. Automation mode: restart?
4. No orphan entities with duplicate unique_ids?

## BACKUP MANAGEMENT (EQ14 has 1TB — much less pressure than Green)
- Auto backup: daily, keep 7, NAS_Backups destination
- Manual backups: clean up after each session block
- NAS path: 192.168.1.52:Backups/HomeAssistant/

## SESSION PROTOCOL
1. hac mcp (session context)
2. ha core check (ignore known 2026.4 KeyError bug)
3. df -h (disk — less critical on 1TB but good habit)
4. git status (clean working tree)
5. hac backup before file edits
6. [do work]
7. ha core check (no new errors)
8. git add -A && git commit
9. shell_command.git_push
10. Update HANDOFF.md
