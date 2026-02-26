# HAC Optimized Session Prompt (Token-Efficient)

## Core Context (Always Include)
User: John Spencer, RN, tech-savvy, runs HA Green + 146 lights + 49 ZHA devices
Terminal: zsh (NO heredocs - use echo/printf only)
Workflow: hac command → gist URLs for context → systematic Git commits
Safety: MCP privacy model (290 safe sensors exposed, garage/locks/valves blocked)

## Session Types & Triggers

### `hac` (General)
Status check + recent issues + ready to debug

### `hac mcp` (MCP/Privacy work)
Load: MCP exposure policy, safety matrix
Focus: Entity exposure, privacy boundaries, sensor optimization

### `hac debug` (Automation issues)
Load: Recent automation traces, problematic entities
Focus: AL conflicts, motion lighting, timing issues
Common: Inovelli switches (smart bulb mode), ZHA coordinator, mode: restart pattern

### `hac install` (New devices)
Load: Device compatibility, integration guides
Focus: ZHA pairing, ESPHome setup, network config

## Critical Patterns (Learned Behaviors)

**Terminal:**
- NEVER use `cat << 'EOF'` heredocs (causes zsh quote hell)
- ALWAYS: `echo "text" > file` or `printf '%s\n' "line1" "line2" > file`
- Chain commands with && for efficiency
- User pastes full output when requested

**Git Workflow:**
- Backup before edits: `cp file file.bak.$(date +%Y%m%d)`
- Commit frequently with descriptive messages
- Always: `git add -A && git reset HEAD zigbee.db* && git commit && git push`

**HA Paths:**
- Config: `/homeassistant/` (not /config/)
- Storage: `/homeassistant/.storage/`
- HAC: `/homeassistant/hac/` (sessions, learnings, scripts)

**Automation Best Practices:**
- mode: restart for motion automations
- Dual-trigger pattern (on/off with IDs) preferred over wait_for_trigger
- AL: separate_turn_on_commands=true, take_over_control=true for Hue
- Check duplicates: `grep "alias:" automations.yaml | sort | uniq -d`

**MCP Privacy Model:**
- Knowledge layer: CSV context (all devices, no risk)
- Live state layer: MCP filtered (safe sensors only)
- Blocked: garage covers, locks, valves, network buttons
- Binary sensors for doors are SENSORS not CONTROLS (safe)

## Quick Reference

**Active AL instances:** Living Spaces (4 lamps), Entry Room Ceiling (1 light)
**ZHA Coordinator:** Sonoff 3.0 USB Dongle Plus (49 devices)
**Network:** UniFi (UDM-PRO, 2x switches) - buttons BLOCKED from MCP
**Calendars:** John/Michelle shared, Alaina/Ella shared, Work, Lions Club
**Presence:** Anyone Home, Girls at School/Mom's (binary sensors)

## Token Efficiency Rules

1. Reference this doc at session start: `view /homeassistant/hac/optimized_session_prompt.md`
2. Use HAC context CSVs via gist URLs (already in session header)
3. Don't repeat known context - reference it
4. Combine commands with && (user prefers efficiency)
5. Ask specific questions vs explaining everything

## Next Session Priorities (Updated per session end)
- 3-way switch test (determines Hue click need vs immediate automation)
- Alaina LED auto-off implementation
- Upstairs hallway time-based motion lighting
- Apollo Pro mmWave testing (kitchen first, then bedrooms)
