# HOME ASSISTANT CONTEXT - INOVELLI + HUE SYSTEM

## 🎯 QUICK START
I need help managing my Home Assistant system with Inovelli switches controlling Philips Hue bulbs.

**Current System Status:**
- 5 Working Inovelli+Hue setups
- 7 Total automations (rebuilt after disaster)
- 50 ZHA devices
- 418 Hue entities
- Enhanced HAC (Home Assistant Context) system installed

## 📁 CRITICAL FILES
- **Automations:** `/config/automations.yaml`
- **Entity Registry:** `/config/.storage/core.entity_registry`
- **Device Registry:** `/config/.storage/core.device_registry`
- **HAC Context:** `/config/ai_context/`
- **Learnings:** `/config/ai_context/learnings.txt`
- **Workflows:** `/config/ai_context/workflows/`

## ✅ WORKING INOVELLI SETUPS

### 1. Kitchen Chandelier (VZM30-SN)
- **Device ID:** `17a59d3c437c3475f22c29dd2b76777a`
- **Controls:** 5 Hue bulbs (light.kitchen_chandelier_1of5 through 5of5)
- **Smart Bulb Mode:** ✅ ON
- **Automation:** "Kitchen Chandelier - Inovelli Control"
- **TODO:** Add CONFIG button scene cycling

### 2. Entry Room Main Switch (VZM31-SN)
- **Device ID:** `d80c7fa6d013f0fd1cbdd6f67c6a1cac`
- **Controls:** light.entry_rm_ceiling_hue_white_1_2, light.entry_rm_ceiling_hue_white_2_2
- **Smart Bulb Mode:** ✅ ON
- **Automation:** "Entry Room - Inovelli Ceiling Lights"

### 3. Entry Room AUX Switch (VZM31-SN)
- **Device ID:** `9b3d7dc5b49055ed4d76b78eb2bd5e4e`
- **Controls:** Same lights as main switch
- **Smart Bulb Mode:** ✅ ON
- **Automation:** "Entry Room - AUX Switch Controls"

### 4. Back Patio (VZM30-SN)
- **Device ID:** `70c1c990c1792ade4fc2eb2fd0d8487a`
- **Controls:** light.back_patio_steps_light
- **Smart Bulb Mode:** ✅ ON
- **Features:** Scene cycling (Bright→Evening→Hot Tub→Off)
- **Automations:** Multiple scene automations

### 5. 1st Floor Bathroom (VZM31-SN)
- **Device ID:** `0600639e50d4e1ed71fdaa1ef789e678`
- **Controls:** light.1st_floor_bathroom_ceiling_1of2, light.1st_floor_bathroom_ceiling_2of2
- **Smart Bulb Mode:** ✅ ON
- **Automation:** "1st Floor Bathroom - Inovelli Control"

### 6. Kitchen Above Sink (VZM30-SN)
- **Device ID:** `89ca030d64760ad87512e97d13a2737d`
- **Controls:** light.kitchen_above_sink_light
- **Smart Bulb Mode:** ✅ ON
- **Automation:** "Kitchen Above Sink - Inovelli Control"

## 🔥 CRITICAL RULES (LEARNED THE HARD WAY)

### ❌ NEVER DO THIS:
1. **NEVER use `sed -i` for editing YAML files** - Lost 200+ automations this way
2. **NEVER use `sed` with `$d` (delete to end)** - Catastrophic data loss
3. **NEVER assume entity names** - Always verify first
4. **NEVER skip checking hidden_by/disabled_by** - Silent failures
5. **NEVER edit live configs without backup**

### ✅ ALWAYS DO THIS:
1. **ALWAYS backup first:** `cp file.yaml file.yaml.backup_$(date +%Y%m%d_%H%M%S)`
2. **ALWAYS use Python with proper YAML parsing** for config edits
3. **ALWAYS check Smart Bulb Mode is ON** for Hue+Inovelli setups
4. **ALWAYS verify entities exist and are enabled** before creating automations
5. **ALWAYS test manually in Developer Tools first**
6. **ALWAYS use haclearn to document discoveries**
7. **ALWAYS use device_id (not entity_id)** for ZHA event triggers

## 🛠️ HAC SYSTEM COMMANDS
```bash
# Context & Status
hac              # Full system context report
hacreport        # Summary of current state
Get-HAStatus     # PowerShell-style quick stats

# Logs & Errors
haclogs          # Last 50 log lines
hacerrors        # Last 20 errors only
Get-HACLogs      # PowerShell alias

# Learning & Documentation
haclearn "text"  # Record a learning
Add-HACLearning  # PowerShell alias

# Workflows
hacworkflow inovelli  # View Inovelli setup guide
Get-HACWorkflow       # PowerShell alias
```

## 🔧 INOVELLI BUTTON COMMANDS

Both VZM30-SN and VZM31-SN use same button event structure:
- **UP button:** `button_2_press`
- **DOWN button:** `button_1_press`
- **CONFIG button:** `button_3_press`
- **Held UP:** `button_2_hold`
- **Held DOWN:** `button_1_hold`

## 📋 INOVELLI SETUP WORKFLOW

1. **Enable Smart Bulb Mode**
```
   Settings → Devices → [Switch] → Configure → Smart Bulb Mode: ON
```

2. **Find Hue Entity**
```bash
   # Search for entity
   grep -i "kitchen" /config/.storage/core.entity_registry | grep "hue" | grep "entity_id"
   
   # Check if hidden
   grep "light.entity_name" /config/.storage/core.entity_registry | grep "hidden_by"
   
   # Check if disabled
   grep "light.entity_name" /config/.storage/core.entity_registry | grep "disabled_by"
```

3. **Get Switch Device ID**
```bash
   grep "Switch Name" /config/.storage/core.device_registry -A 5 | grep '"id"' | head -1
```

4. **Create Automation (Python)**
```python
   import yaml
   # Use proper YAML parsing - NEVER sed!
```

5. **Test**
   - Developer Tools → Actions → Test light
   - Press switch buttons
   - Check automation traces

## 🚨 COMMON ISSUES & FIXES

### Issue: Automation doesn't trigger
**Check:**
1. Smart Bulb Mode enabled?
2. Entity exists and not disabled?
3. Entity not hidden by integration?
4. Correct device_id used (not entity_id)?
5. Adaptive Lighting commands removed?

### Issue: Hue bulb entity missing
**Check:**
```bash
# Find the device
grep "Bulb Name" /config/.storage/core.device_registry

# Look for disabled entity in UI
# Device page → "+1 disabled entity" → Enable it
```

### Issue: Entity hidden by integration
**Fix with Python:**
```python
import json
with open('/config/.storage/core.entity_registry', 'r') as f:
    data = json.load(f)
for entity in data['data']['entities']:
    if entity['entity_id'] == 'light.your_light':
        entity['hidden_by'] = None
with open('/config/.storage/core.entity_registry', 'w') as f:
    json.dump(data, f, indent=2)
```

## 📊 SYSTEM STATS

**Current Status:**
- Automations: 7 (rebuilt from disaster)
- ZHA Devices: 50
- Hue Entities: 418
- Working Inovelli Setups: 6
- Broken Automations: ~20 (need cleanup)

## 🎯 PENDING TASKS

### High Priority:
1. Add CONFIG scene cycling to Kitchen Chandelier
2. Clean up duplicate/dead automations
3. Test "never triggered" automations

### Medium Priority:
4. Add motion-based automations
5. Implement time-aware brightness
6. Clean up orphaned TP-Link entities

### Low Priority:
7. Document all working setups
8. Create backup/restore procedures

## 💾 RECENT DISASTER RECOVERY

**What Happened:** Used `sed -i '/pattern/,$d'` which deleted everything from match to end of file
**Lost:** 200+ automations
**Recovered:** 7 critical automations rebuilt from scratch
**Lesson:** NEVER use sed for YAML editing - always use Python with proper parsing

## 📚 DOCUMENTATION

**Workflow Guides:**
- `/config/ai_context/workflows/inovelli_setup.md` - Complete Inovelli setup guide
- `/config/ai_context/learnings.txt` - Session learnings and discoveries
- `/config/ai_context/SESSION_2026-01-14_INOVELLI_COMPLETE.md` - Full session summary

**Key References:**
- Inovelli Blue Series VZM31-SN (Dimmer with neutral)
- Inovelli Blue Series VZM30-SN (On/Off with neutral)
- Philips Hue Bridge integration
- ZHA (Zigbee Home Automation)

---

## 🎬 START NEW SESSION WITH:

"Hi! I'm working on my Home Assistant system. Please read `/config/ai_context/NEW_SESSION_PROMPT.md` to understand my setup. I need help with [describe task]."

**Available context files to reference:**
- `cat /config/ai_context/learnings.txt` - All learnings
- `cat /config/ai_context/workflows/inovelli_setup.md` - Setup workflow
- `hac` - Current system context
- `hacreport` - Quick status summary
