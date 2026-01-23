# HAC (Home Assistant Command-line Interface) System Guide
**Version:** 4.0  
**Last Updated:** 2026-01-17  
**Purpose:** Comprehensive reference for AI assistants working with John's Home Assistant system

---

## Overview

HAC is a menu-driven CLI tool that provides AI assistants with structured access to Home Assistant configuration, entity data, and accumulated knowledge. It bridges the gap between conversational AI and systematic automation management.

---

## Core Philosophy

**Transparency:** All data sources are explicit file paths  
**Discoverability:** Commands are self-documenting  
**Persistence:** Session learnings accumulate over time  
**Collaboration:** Multiple AIs can access the same knowledge base  

---

## Command Reference

### Entity Management
```bash
hac e <search_term>          # Search entities cache
hac e                         # Show all entities (paginated)
```
**Data Source:** `/config/.ha-context-cache/entities.yaml`  
**Refresh:** `/config/ha-context-tools/ha-export-all`  
**Last Updated:** Check file timestamp with `ls -lh /config/.ha-context-cache/entities.yaml`

### Automation Management
```bash
hac a [search_term]          # Search automations
hac a                         # List all automations
```
**Data Source:** `/config/automations.yaml`  
**Count:** Check with `hac a | wc -l`

### Context System (Entity Documentation)
```bash
hac context add "<entity_id>" "<context>"     # Document an entity
hac context lookup "<entity_id>"              # View entity context
hac context search "<keyword>"                # Search contexts
hac context list                              # List all documented entities
```
**Data Source:** `/config/ha-context-tools/ENTITY_CONTEXT_MAP.md`  
**Purpose:** Maps entities to real-world meaning, usage patterns, and learnings

### Session Collaboration
```bash
hac c          # Generate Claude collaboration package
hac g          # Generate ChatGPT package  
hac m          # Generate Gemini package
hac a          # AI menu (select assistant)
```
**Output:** Context-rich session handoff with recent learnings and priorities

---

## Key Data Locations

### Primary Knowledge Base
```
/config/ha-context-tools/
├── .learnings                    # Chronological session log (append-only)
├── ENTITY_CONTEXT_MAP.md        # Entity-to-context mappings
├── HAC_SYSTEM_GUIDE.md          # This file
├── .ha-context-cache/           # Cached entity data
│   └── entities.yaml            # All entities with current states
└── automation-audit/            # Automation documentation
    ├── AUTOMATION_INVENTORY.md  # Complete catalog
    ├── AUTOMATION_HIERARCHY.md  # Functional organization
    └── AUTOMATION_RECOMMENDATIONS.md  # Action items
```

### Configuration Files
```
/config/
├── automations.yaml             # All automations (22 active as of 2026-01-17)
├── configuration.yaml           # Main HA config
└── secrets.yaml                 # Credentials (encrypted)
```

---

## Reading the .learnings File

**Format:** `[YYYY-MM-DD HH:MM] <session summary or action taken>`

**Purpose:**
- Session continuity across multiple AI conversations
- Historical record of what was built and why
- Discovery of past solutions to similar problems

**Usage:**
```bash
# Recent sessions
tail -20 /config/ha-context-tools/.learnings

# Search for topic
grep -i "garage" /config/ha-context-tools/.learnings

# Full history
cat /config/ha-context-tools/.learnings
```

**Best Practice:** Always append new learnings at session end:
```bash
echo "[$(date +%Y-%m-%d\ %H:%M)] <what you accomplished>" >> /config/ha-context-tools/.learnings
```

---

## Reading ENTITY_CONTEXT_MAP.md

**Structure:**
```markdown
## entity_id
**Real-World:** <what it physically is>
**Purpose:** <why it exists>
**Usage:** <how it's used in automations>
**Learnings:** <discovered behaviors, quirks, fixes>
```

**Discovery Pattern:**
1. User mentions entity or automation
2. Check if entity exists: `hac e <entity_name>`
3. Check for context: `hac context lookup <entity_id>`
4. If missing context, ask user for details
5. Document: `hac context add "<entity_id>" "<learned_context>"`

---

## Automation Audit System

**Location:** `/config/ha-context-tools/automation-audit/`

**Files:**
- **INVENTORY:** Complete list with status (✅ keep, 🔧 update, ⚠️ review, 🗑️ delete)
- **HIERARCHY:** Functional grouping (Environmental, Presence, Media, Lighting)
- **RECOMMENDATIONS:** Prioritized action items with commands

**Usage Pattern:**
```bash
# When user asks about automations
cat /config/ha-context-tools/automation-audit/AUTOMATION_INVENTORY.md

# For specific category
grep -A 20 "GARAGE LIGHTING" /config/ha-context-tools/automation-audit/AUTOMATION_INVENTORY.md

# For action items
cat /config/ha-context-tools/automation-audit/AUTOMATION_RECOMMENDATIONS.md
```

---

## Common Workflows

### Workflow 1: User Asks About Garage Lighting
```bash
# 1. Search entities
hac e garage

# 2. Check context
hac context search garage

# 3. Review automations
hac a | grep -i garage

# 4. Check audit documents
cat /config/ha-context-tools/automation-audit/AUTOMATION_INVENTORY.md | grep -A 10 "GARAGE"
```

### Workflow 2: Building New Automation
```bash
# 1. Check what entities exist
hac e <relevant_search>

# 2. Review existing automations for patterns
hac a | grep <similar_function>

# 3. Check for conflicts
cat /config/ha-context-tools/automation-audit/AUTOMATION_HIERARCHY.md

# 4. After building, document
hac context add "<entity_used>" "<how you used it>"
echo "[$(date)] Built automation for <purpose>" >> /config/ha-context-tools/.learnings
```

### Workflow 3: Troubleshooting Issue
```bash
# 1. Check recent learnings for similar issues
grep -i "<keyword>" /config/ha-context-tools/.learnings | tail -10

# 2. Check entity context for known quirks
hac context search "<entity_name>"

# 3. Check current state
hac e "<entity_name>"

# 4. After fixing, document solution
hac context add "<entity_id>" "Issue: <problem>. Fix: <solution>."
```

---

## Best Practices for AI Assistants

### DO:
✅ Always check .learnings for past solutions  
✅ Use hac e before assuming entities exist  
✅ Document new learnings in ENTITY_CONTEXT_MAP  
✅ Append session summary to .learnings  
✅ Reference audit documents when discussing automations  
✅ Use explicit file paths (not "your system has...")  

### DON'T:
❌ Assume entity names without checking  
❌ Create automations without checking for conflicts  
❌ Forget to document what you built  
❌ Ignore existing context when available  
❌ Claim knowledge you don't have in cache  

---

## Integration with Other AIs

**HAC is designed for multi-AI collaboration.** Each AI assistant (Claude, ChatGPT, Gemini) can:

1. **Read the same knowledge base** - All data in plain files
2. **Contribute learnings** - Append to .learnings and ENTITY_CONTEXT_MAP
3. **Pick up where others left off** - Session packages (hac c/g/m)
4. **Avoid duplicate work** - Check learnings before starting

**Handoff Pattern:**
```
Session 1 (Claude): Builds garage automation, documents in learnings
Session 2 (ChatGPT): Reads learnings, sees garage work, continues with presence tracking
Session 3 (Claude): Reads both sessions' work, integrates systems
```

---

## Extending HAC

**To add new functionality:**

1. Create data file in `/config/ha-context-tools/`
2. Add command to HAC menu (if interactive)
3. Document in this guide
4. Add to .learnings: "Extended HAC with <feature>"

**Example:** The context system was added 2026-01-16:
- Created ENTITY_CONTEXT_MAP.md
- Added hac context commands
- Documented in learnings

---

## Troubleshooting HAC

### Entity cache is stale
```bash
/config/ha-context-tools/ha-export-all
# Check timestamp: ls -lh /config/.ha-context-cache/entities.yaml
```

### Can't find learnings file
```bash
ls -la /config/ha-context-tools/.learnings
# If missing, create: touch /config/ha-context-tools/.learnings
```

### HAC command not found
```bash
# HAC is a bash script, check path:
which hac
# Should be in PATH or aliased
```

---

## Version History

**v4.0 (2026-01-17):**
- Added automation audit system
- Created AUTOMATION_INVENTORY.md
- Created AUTOMATION_HIERARCHY.md  
- Created AUTOMATION_RECOMMENDATIONS.md
- Documented HAC system comprehensively

**v3.x (2026-01-16):**
- Added context system (ENTITY_CONTEXT_MAP.md)
- Added hac context commands (add/search/lookup/list)
- Standardized learnings format

**v2.x:**
- Entity cache system
- Multi-AI collaboration packages
- Basic hac e and hac a commands

---

## Quick Reference Card
```bash
# Discovery
hac e <search>              # Find entities
hac context search <word>   # Find documented entities
grep <topic> .learnings     # Find past work

# Documentation
hac context add "<id>" "<context>"          # Document entity
echo "[$(date)] <note>" >> .learnings       # Log session

# Automation Review
cat automation-audit/AUTOMATION_INVENTORY.md     # Full catalog
cat automation-audit/AUTOMATION_RECOMMENDATIONS.md  # Action items

# Collaboration
hac c/g/m                   # Generate handoff package
```

---

## Support

**Primary User:** John Spencer  
**System Location:** 40154 US Highway 53, Strum, Wisconsin  
**Home Assistant:** Home Assistant Green  
**Network:** UniFi UDM-PRO  

**For questions about HAC usage:** Check this guide first, then .learnings for examples
