# Lighting Fixes - Ready to Implement

## Fix 1: Alaina's LED Auto-Off

**Current:** Only toggle control, no auto-off
**Solution:** Add midnight auto-off automation
```yaml
- id: alaina_led_auto_off_midnight
  alias: "Alaina LED - Auto Off Midnight"
  description: "Turn off Alaina's LED strips at midnight if on"
  trigger:
    - platform: time
      at: "00:00:00"
  condition:
    - condition: state
      entity_id: light.alaina_s_led_strips
      state: 'on'
  action:
    - service: light.turn_off
      target:
        entity_id: light.alaina_s_led_strips
  mode: single
```

## Fix 2: Upstairs Hallway - Time-Based Motion Lighting

**Current:** Ghost automations (unavailable), no active control
**Solution:** New time-based motion automation

**Before I create this, I need answers to 4 questions:**

1. **Alaina's motion sensor:** Does her room have one?
   - Run: `curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/core/api/states | jq -r '.[] | select(.entity_id | test("binary_sensor.alaina")) | .entity_id'`

2. **Upstairs hallway main light:** What entity controls the CEILING light?
   - Is it `light.upstairs_hallway`?
   - Or something else?

3. **Wake-up time:** What time should "morning bright mode" start?
   - 5:30am? 6:00am? 6:30am?

4. **Weekend difference:** Should weekends be different?
   - Or same behavior every day?

