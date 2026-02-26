# Home Assistant System Knowledge Base
*For Claude Project: HA HAC System/Workflow*
*Owner: John Spencer | Last Updated: 2026-02-13*

---

## System Overview

- **Platform:** Home Assistant Green (HA 2026.2.x)
- **Config Path:** `/homeassistant/` (not `/config/`)
- **Storage:** `/homeassistant/.storage/`
- **Architecture:** Package-based organization in `/homeassistant/packages/`
- **Version Control:** Git repo, private, committed regularly

### Key Integrations
- **Zigbee:** ZHA with Sonoff 3.0 USB Dongle Plus (~49 devices)
- **Lighting:** Philips Hue (via Hue Bridge, NOT direct Zigbee)
- **Switches:** Inovelli Blue Series (ZHA)
- **Network:** UniFi (presence detection via APs)
- **Climate:** Nest thermostats, Mitsubishi mini-splits
- **Garage:** ratgdo controllers
- **Remote Access:** Cloudflare tunnel

---

## Terminal Rules (CRITICAL)

### ZSH Escaping
- **Always escape `!`** in strings: `echo "Hello\!"` or use single quotes
- **Never chain after `python3 -c`** on the same line

### HA CLI Limitations
- `ha` command does NOT support `services` subcommand
- Use REST API, websocket, or UI for service calls from terminal

### Command Efficiency
- Combine commands with `&&` for token-efficient back-and-forth
- User pastes results one at a time

### Backup Before Edits
```bash
cp file file.bak.$(date +%Y%m%d)
```

---

## Model Selection Guide

| Model | Use Case | ~% of Sessions |
|-------|----------|----------------|
| **Sonnet 4.5** | Default. YAML editing, automation work, debugging, config reviews | 80% |
| **Opus 4.6** | Architecture decisions, complex multi-system debugging, research | 20% |
| **Haiku 4.5** | Quick syntax lookups, simple questions | As needed |

---

## Adaptive Lighting Configuration

### Active Instances
- Living Spaces
- Entry Room Ceiling Lights
- Bedroom lighting test
- Kitchen Chandelier

### Best Practices for Hue Integration
```yaml
separate_turn_on_commands: true
take_over_control: true
detect_non_ha_changes: false
```

**Important:** Use Hue app groups (not HA groups) for multi-bulb fixtures.

### Hue Groups (defined in Hue app)
- upstairs_hallway
- master_bedroom
- entry_room
- kitchen_lounge
- kitchen_chandelier
- living_room_lounge
- garage
- 2nd_floor_bathroom
- back_patio
- very_front_door

---

## Inovelli Switch Configuration

### Smart Bulb Mode (Parameter 52)
Confirmed ON for:
- Entry Room Ceiling
- Kitchen Chandelier
- Kitchen Above Sink
- 1st Floor Bathroom

### Configuration Method
- Use ZHA UI for cluster 64561 parameters
- NOT via automation or service calls

---

## Motion Automation Best Practices

### Dual-Trigger Pattern (Preferred)
```yaml
automation:
  - id: 'room_motion_on'
    alias: "Room Motion - Lights On"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.room_motion
        to: 'on'
    action:
      - service: light.turn_on
        target:
          entity_id: light.room

  - id: 'room_motion_off'
    alias: "Room Motion - Lights Off"
    mode: restart
    trigger:
      - platform: state
        entity_id: binary_sensor.room_motion
        to: 'off'
        for: "00:05:00"
    action:
      - service: light.turn_off
        target:
          entity_id: light.room
```

### Check for Duplicates
```bash
grep "alias:" automations.yaml | sort | uniq -d
```

---

## HAC Workflow

### Path
- HAC is at `/homeassistant/hac` (not `~/hac`)

### Git Commit Pattern
```bash
cd /homeassistant && git add -A && git reset HEAD zigbee.db* && git commit -m "summary" && git push
```

### Key Commands
- `hac push` - Generate context, audit, sync to gist, print prompt
- `hac mcp` - Session prompt with MCP for live state
- `hac learn "insight"` - Log to daily learnings
- `hac backup <file>` - Create timestamped backup
- `hac review [days]` - Categorized learning review
- `hac promote "text"` - Move learning to knowledge base

---

## Presence Detection

### Person Entities
- person.john_spencer
- person.alaina_spencer
- person.ella_spencer
- person.michelle
- person.jarrett_goetting
- person.owen_goetting
- person.jean_spencer

### Source
UniFi integration via access point device tracking

---

## Calendar IDs

| Calendar | ID |
|----------|-----|
| John Spencer (default) | pigeonfallsrn@gmail.com |
| Alaina and Ella | 2emio1oov9oq9u9115lv5oa05c@group.calendar.google.com |
| John/Michelle | 2aa2d81010ff6a637e674c2cd23eb3e7a80e9dd48e8e30c50d6784c3cab86043@group.calendar.google.com |
| Work (RN shifts) | 8249v7qv8g2m6bjc8v37f78gs0@group.calendar.google.com |
| Lions Club | 333e072f891daea9a8ffaba89d8e67fb16e89b74fe0a5cc06ad9e1be2e2d5edf@group.calendar.google.com |

---

## Known Issues / Active Work

### Double-Firing Automations
- Symptom: Same automation triggers multiple times at identical timestamp
- Check: `hac triggers` shows repeated entries
- Common causes: Multiple trigger conditions, UI+YAML duplicates

### Orphaned Entities
- ~49 entities flagged for potential cleanup
- Review with `hac doctor` or entity registry inspection

---

## File Organization

### Package Structure
```
/homeassistant/packages/
├── lighting/
├── climate/
├── presence/
├── notifications/
└── ...
```

### Why Packages
- Industry standard for large HA systems
- Enables git version control per-domain
- Easier to find/edit related automations

---

## Google Sheets Exports

Run `hac sheets` to export current data to:
- **Master Workbook**: https://docs.google.com/spreadsheets/d/11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w
- **LLM Index**: https://docs.google.com/spreadsheets/d/1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk

Contents: Entity registry, device registry, area mappings, current states

### Inovelli Automation Pattern (CRITICAL)
- **Always use blueprint:** `fxlt/zha-inovelli-vzm31-sn-blue-series-2-1-switch.yaml`
- **Never use raw zha_event** - catches attribute_updated, dimmer changes, causing 100+ false triggers/hour
- **Main switch buttons:** button_1 (down), button_2 (up), button_3 (config)
- **Aux switch buttons:** button_4_press (down), button_5_press (up)
- **Aux not working?** Toggle "Aux switch scenes" OFF/ON in ZHA device page to re-sync parameter

### MCP Limitations
- `ha_config_get_automation` only sees UI-created automations (stored in .storage/)
- YAML automations in `automations/*.yaml` or `packages/*.yaml` must be read via terminal

---

## Git Troubleshooting

### "Unstable object source data" Error
HA writes to database files mid-commit. Fix:
```bash
git reset HEAD zigbee.db* home-assistant_v2.db*
git commit -m "message"
```

### SSH Push Fails on Port 443
Duplicate `Host github.com` in `~/.ssh/config` - later entry overrides. Should have ONE block only.

### Standard Commit Pattern
```bash
git add -A && git reset HEAD zigbee.db* home-assistant_v2.db* && git commit -m "message" && git push
```
