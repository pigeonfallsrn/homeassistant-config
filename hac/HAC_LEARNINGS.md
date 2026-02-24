
## 2026-02-16: Claude Desktop MCP - Recommended Query Prompts

### SYSTEMATIC CONFIGURATION REVIEW PROMPTS

**Phase 1: System Baseline (10 min)**

1. **System Health Check**
```
Via MCP: Show me all unavailable entities, disabled automations, and any integration warnings. Provide a health score overview.
```

2. **Lighting Audit**
```
Via MCP: List all light entities grouped by area. For each area, show:
- How many lights
- Current Adaptive Lighting configuration
- Associated motion sensors
- Automation count affecting those lights

Identify areas with potential conflicts (>5 automations per light).
```

**Phase 2: Automation Health (30 min)**

3. **Automation Trigger Analysis**
```
Via MCP: Analyze my automation triggers over the last 24 hours. Show:
- Top 10 most-triggered automations
- Any automations that triggered >50 times (potential loops)
- Automations that haven't triggered in 7+ days (possibly broken)
- Automations with errors in last run
```

4. **Inovelli Optimization Check**
```
Via MCP: Find all Inovelli switches and check:
- Smart Bulb Mode status (param 52)
- Current configuration parameters
- Associated light entities
- Recent state changes

Compare against recommended settings for Smart Bulb Mode operation.
```

5. **Conflict Detection (Per Room)**
```
Via MCP: For [ROOM_NAME], show me:
- All entities (lights, motion, switches)
- All automations that affect lights
- Recent state changes (last hour)
- Current Adaptive Lighting configuration

Identify timing overlaps or conflicting automation triggers.
```

**Phase 3: Advanced Research**

6. **Pattern Research**
```
Using MCP to query my actual configuration:
Research common Home Assistant patterns for managing [AREA] with:
- Adaptive Lighting (color temp automation)
- Motion sensors (occupancy detection)
- Manual overrides (wall switches)
- [Additional requirements]

Compare my current implementation against community best practices. Show specific improvements I could make based on my actual entity states and automation structure.
```

7. **Performance Analysis**
```
Via MCP: Analyze my system for performance bottlenecks:
- Entity update frequency (which sensors update most?)
- Automation complexity (longest-running automations)
- ZHA network health (Sonoff coordinator statistics)
- Database size and recorder impact

Suggest specific optimizations based on my actual usage patterns.
```

### RECOMMENDED WORKFLOW

**Baseline → Deep Dive → Research → Implement**

1. Run System Health + Lighting Audit (prompts #1-2)
2. Document findings in HAC
3. Run Automation Health + Inovelli Check (prompts #3-4)
4. Cross-reference MCP data with YAML files
5. For complex issues: Use Pattern Research (prompt #6)
6. Make changes based on findings
7. Test via MCP
8. Document in HAC
9. Commit to git

### KEY LEARNINGS

**MCP Query Best Practices:**
- Start with system-wide health checks before drilling down
- Group entities by area for logical analysis
- Look for patterns (>50 triggers = potential loop)
- Cross-reference MCP state data with YAML config files
- Use MCP for current state, files for historical context
- Test changes immediately via MCP before committing

**Common Conflict Patterns to Check:**
- Adaptive Lighting + motion sensors in same room
- Multiple automations targeting same light entity
- Inovelli Smart Bulb Mode disabled when should be ON
- Automations without mode: restart (can double-fire)
- Motion sensors triggering <5 seconds apart

**Performance Red Flags:**
- Entity updating >1/minute (sensor polling too aggressive)
- Automation run time >5 seconds (need optimization)
- ZHA coordinator dropped packets (interference/distance)
- Recorder DB >2GB (purge needed)
- Unavailable entities >5% (integration issues)

**Optimization Opportunities MCP Can Reveal:**
- Unused entities (never change state)
- Orphaned automations (trigger entity doesn't exist)
- Inefficient triggers (state vs event)
- Missing Smart Bulb Mode on Inovelli + smart bulbs
- Lights without Adaptive Lighting in areas with routines

### PROGRESSIVE PROMPT SEQUENCE

**For New Users (Week 1):**
1. System Health Check
2. List all lights by area
3. Show recent automation triggers

**For Intermediate Users (Month 1):**
4. Automation health analysis
5. Per-room conflict detection
6. Inovelli configuration audit

**For Advanced Users (Ongoing):**
7. Pattern research with citations
8. Performance bottleneck analysis
9. Custom entity relationship mapping

### INTEGRATION WITH HAC WORKFLOW

**Before MCP Session:**
- Review HAC_CORE.md for current system state
- Identify specific areas of concern
- Load HA HAC System/Workflow Project in Desktop

**During MCP Session:**
- Run progressive prompts (simple → complex)
- Document findings in session notes
- Cross-reference with YAML files via terminal

**After MCP Session:**
- Update HAC_LEARNINGS.md with discoveries
- Commit config changes to git
- Test changes via MCP verification queries
- Schedule follow-up review if needed

**Quarterly Review Checklist (via MCP):**
- [ ] Run System Health Check
- [ ] Audit all Adaptive Lighting zones
- [ ] Review automation trigger counts
- [ ] Verify Inovelli Smart Bulb Mode status
- [ ] Check for unavailable entities
- [ ] Performance analysis
- [ ] Update HAC documentation


---
## Session 2026-02-23: Entry Room Inovelli + Hue Color Bulb Setup

### INOVELLI AUX SWITCH QUIRK
**Problem:** AUX DOWN button sends direct Zigbee `off` command instead of `button_4_press` scene event, even with "Aux switch scenes" enabled on main VZM31-SN.
**Solution:** Create separate automation to catch the `off` command:
```yaml
triggers:
  - platform: event
    event_type: zha_event
    event_data:
      device_ieee: "XX:XX:XX:XX:XX:XX:XX:XX"
      command: "off"
actions:
  - action: light.turn_off
    target:
      entity_id: light.target_light
```
**Note:** AUX UP (`button_5_press`) works correctly after toggling "Aux switch scenes" off/on.

### AUX SWITCH BUTTON MAPPING (VZM31-SN 3-way)
- `button_4_press` = AUX DOWN (may send `off` instead)
- `button_5_press` = AUX UP
- `button_6_press` = AUX CONFIG

### HUE ROOM VS ZONE TARGETING
**Problem:** Hue room scenes (e.g., `scene.entry_room_energize`) control ALL lights in room including lamps.
**Solution:** For ceiling-only control, target the specific Hue zone entity (`light.entry_room_ceiling_light`) instead of room-wide scenes.

### BULB REPLACEMENT WORKFLOW
When replacing Hue bulbs (e.g., white → color):
1. Old entity IDs become unavailable
2. New entities auto-created by Hue integration
3. Update Hue zones in Hue app to include new bulbs
4. Reload automations in HA (`automation.reload`)
5. Update any automations referencing old entity IDs
