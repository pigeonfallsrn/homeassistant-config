# Inovelli Smart Bulb Setup Workflow

## Quick Reference
**When setting up Inovelli switch to control Hue bulbs:**

### 1. Enable Smart Bulb Mode on Switch
```bash
# Via UI:
Settings → Devices → [Switch Name] → Configure → Smart Bulb Mode: ON
```

### 2. Identify Correct Hue Entity
```bash
# Find Hue entities in area:
grep -i "[AREA_NAME]" /config/.storage/core.entity_registry | grep "hue" | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | grep "^light\."

# Check if entities are hidden:
grep "[ENTITY_ID]" /config/.storage/core.entity_registry | grep "hidden_by"

# Unhide if needed (use Python script from session)
```

### 3. Get Switch Device ID
```bash
# Find switch device:
grep "[SWITCH_NAME]" /config/.storage/core.device_registry -A 5 | grep '"id"' | cut -d'"' -f4
```

### 4. Create Automation Structure

**VZM31-SN (Dimmer) - Uses button events:**
```yaml
- id: [unique_id]
  alias: "[Area] - [Description]"
  trigger:
    - platform: event
      event_type: zha_event
      event_data:
        device_id: [DEVICE_ID]
  action:
    - choose:
        - conditions: "{{ trigger.event.data.command == 'button_2_press' }}"
          sequence:
            - service: light.turn_on
              target:
                entity_id: [HUE_ENTITY]
        - conditions: "{{ trigger.event.data.command == 'button_1_press' }}"
          sequence:
            - service: light.turn_off
              target:
                entity_id: [HUE_ENTITY]
  mode: queued
```

**VZM30-SN (On/Off) - Uses button events:**
Same structure as VZM31-SN (button_2_press / button_1_press)

### 5. Common Issues Checklist
- [ ] Smart Bulb Mode enabled on switch?
- [ ] Hue entity name correct? (not a broken group)
- [ ] Hue entities unhidden? (check hidden_by)
- [ ] Device ID matches in automation?
- [ ] Button commands correct? (button_2_press not move_to_level)
- [ ] Automation enabled in UI?
- [ ] No Adaptive Lighting conflicts?

### 6. Testing Workflow
```bash
# 1. Test manual control
Developer Tools → Actions → light.turn_on → [entity_id]

# 2. Test ZHA events
Developer Tools → Events → Subscribe to zha_event → Press switch button

# 3. Check automation traces
Settings → Automations → [Automation] → Traces tab

# 4. Verify with logs
ha core logs | grep -i "[switch_name]" | tail -20
```

## Completed Setups (Reference)
### Kitchen Chandelier
- Switch: VZM30-SN (device_id: 17a59d3c437c3475f22c29dd2b76777a)
- Entities: light.kitchen_chandelier_1of5 through 5of5
- Smart Bulb Mode: ✅ Enabled
- Status: ✅ Working

### Entry Room
- Switch: VZM31-SN (device_id: d80c7fa6d013f0fd1cbdd6f67c6a1cac)
- Entities: light.entry_rm_ceiling_hue_white_1_2, light.entry_rm_ceiling_hue_white_2_2
- Smart Bulb Mode: ✅ Enabled
- Issues Fixed: Hidden entities, wrong entity names, Adaptive Lighting conflicts
- Status: ✅ Working (both main and AUX)

### Back Patio
- Switch: VZM30-SN (device_id: 70c1c990c1792ade4fc2eb2fd0d8487a)  
- Entity: light.back_patio_steps_light (NOT light.back_patio)
- Smart Bulb Mode: ✅ Enabled
- Issues Fixed: Wrong entity name
- Status: 🔄 Testing

## Critical Lessons Learned
1. **NEVER use `sed -i '/pattern/,$d'`** - Lost 200+ automations this way
2. **Always use Python with YAML parsing** for config edits
3. **Check for hidden_by: integration** when entities don't respond
4. **Hue creates groups but hides individuals** - unhide them
5. **Remove disabled Adaptive Lighting commands** from automations
6. **VZM30-SN and VZM31-SN both use button_X_press** commands

### Back Patio (UPDATED - Scene Cycling)
- Switch: VZM30-SN (device_id: 70c1c990c1792ade4fc2eb2fd0d8487a)  
- Entity: light.back_patio_steps_light
- Smart Bulb Mode: ✅ Enabled
- Features: Scene cycling for outdoor/hot tub use
  - UP: 100% Bright White (4000K)
  - CONFIG: Cycles Bright→Evening(60%/2700K)→Hot Tub(20%/amber)→Off
  - DOWN: Off
- Status: ✅ Working with scene cycling
