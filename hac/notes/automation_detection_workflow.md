# Automation Detection Workflow - Definitive Guide

## Problem
HAC's `ui-automations` detector reported "176 UI automations" when they were actually YAML-based package automations.

## Root Cause
1. Looking for `id:` fields instead of `alias:` fields
2. Not scanning the `packages/` directory  
3. Comparing wrong data: entity_id vs automation id

## Actual Architecture

### Entity ID Generation
```
alias: "Kitchen Lounge - Lamp Off When Everyone Leaves"
    ↓
entity_id: automation.kitchen_lounge_lamp_off_when_everyone_leaves
```

## Quick Commands

### Accurate Count
```bash
python3 /homeassistant/hac/scripts/count_automations.py
```

### Search for Automation
```bash
grep -r "alias.*pattern" /homeassistant/packages /homeassistant/automations
```

### Entity Registry Count
```bash
python3 -c "import json; data=json.load(open('/homeassistant/.storage/core.entity_registry')); print(len([e for e in data['data']['entities'] if e['entity_id'].startswith('automation.')]))"
```

## Our System
- **151 automations in YAML**
  - 121 in packages/ (80%) - Feature-based
  - 25 in automations/ (17%) - Room-based  
  - 4 in automations.yaml (3%) - UI-created
  - 1 in configuration.yaml (<1%) - Inline

- **200 entities in registry**
  - 49 difference = disabled/orphaned/deleted

## Best Practices
1. Use packages/ for feature-based organization
2. Use automations/ for room-based controls
3. Reserve automations.yaml for UI-created
4. Inline in configuration.yaml only for system automations

## Reference
- Entity Registry: `/homeassistant/.storage/core.entity_registry`
- Packages: https://www.home-assistant.io/docs/configuration/packages/
