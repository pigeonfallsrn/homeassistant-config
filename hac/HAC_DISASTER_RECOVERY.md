# HAC Disaster Recovery Guide
**Last Updated:** 2026-01-22
**Purpose:** Enable any LLM to understand and help restore John's Home Assistant system

## What is HAC?
HAC (Home Assistant Context) is a CLI tool and workflow system for managing Home Assistant configuration with AI assistance. It maintains context across LLM sessions via GitHub Gists.

## Quick Recovery URLs
If HA is down but you need context for another LLM:
- **Status:** https://gist.githubusercontent.com/pigeonfallsrn/b8a59919b8f0b71942fc21c10398f9a7/raw/01_status.md
- **Index:** https://gist.githubusercontent.com/pigeonfallsrn/b8a59919b8f0b71942fc21c10398f9a7/raw/04_index.md
- **Full Gist:** https://gist.github.com/pigeonfallsrn/b8a59919b8f0b71942fc21c10398f9a7

## System Architecture

### Hardware
- **HA Green** at 192.168.1.3 (homeassistant.local)
- **Synology DS224+** at 192.168.1.52 (NAS, backups, Plex)
- **UniFi Network** - Switch port 8 = HA Green power

### Key Paths
```
/homeassistant/                  # HA config root
/homeassistant/packages/         # Modular YAML packages
/homeassistant/hac/              # HAC system files
/homeassistant/hac/hac.sh        # Main CLI tool
/homeassistant/hac/learnings/    # Session learnings by date
/homeassistant/hac/gist_output/  # Files synced to GitHub Gist
```

### HAC Commands
```bash
hac push    # Generate status files, sync to gist
hac q       # Display new session prompt with URLs
hac pkg X   # Show package file with line numbers
hac ids X   # Show automation IDs from file
hac learn   # Add learning note
hac status  # Quick system overview
hac health  # Full health check
```

## LLM Rules (STRICT)
1. **Terminal only** - Never suggest GUI actions
2. **&& chaining** - Combine commands: `cmd1 && cmd2 && cmd3`
3. **Backup before edit** - Always: `cp FILE FILE.bak_$(date +%Y%m%d_%H%M%S)`
4. **One block per response** - User pastes one output, AI responds with one command

## Recovery Procedures

### HA Unresponsive (ping works, web timeout)
1. UniFi Network Console → Devices → Switch → Port 8 → Power Cycle
2. Wait 2-3 minutes for boot
3. Verify at http://homeassistant.local:8123

### HA Unresponsive (ping fails)
1. Physical power cycle HA Green
2. Check UniFi for network issues

### Config Broken After Edit
```bash
# Restore from backup
cp /homeassistant/packages/FILE.bak_TIMESTAMP /homeassistant/packages/FILE
ha core check && ha core restart
```

### Automation Double-Triggers
Add debounce condition:
```yaml
- condition: template
  value_template: >-
    {{ (as_timestamp(now()) - as_timestamp(state_attr('automation.NAME', 'last_triggered') | default(0))) > 5 }}
```

## Key Integrations
- **Adaptive Lighting** - Living spaces lamp control
- **Presence** - input_boolean.john_home, someone_home, etc.
- **RATGDO** - Garage doors (North=fd8d8c, South=5735e8)
- **Inovelli** - Smart switches with scene support
- **UniFi** - Network + presence detection

## Contacts / Accounts
- **GitHub Gist:** pigeonfallsrn
- **HA User:** john_spencer

## If Starting Fresh
1. Restore latest backup from /backup/ or Synology
2. `source ~/.zshrc` to load hac alias
3. `hac push` to regenerate context
4. `hac q` to get session prompt for LLM
