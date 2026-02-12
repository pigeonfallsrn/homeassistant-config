# Next Session: Lighting Automation Debug

## Issues to Investigate

### Issue 1: Alaina's LED Lights Always On
**Symptom:** LED lights not auto-turning off
**Location:** Alaina's bedroom
**Entities:** 
- light.alaina_s_led_light_strip_1
- light.alaina_s_led_light_strip_2 (currently on at brightness 3)

**Investigation Steps:**
1. Check automation that controls these lights
2. Review triggers (motion? time? manual?)
3. Check for conflicting automations
4. Review automation traces

### Issue 2: Upstairs Hallway AL - Red Light at Dawn
**Symptom:** 5:30am motion triggers dark red light (should be dim/off)
**Location:** Upstairs hallway
**Entity:** light.upstairs_hallway
**Note:** AL was disabled to work around this

**Investigation Steps:**
1. Review AL sleep mode configuration
2. Check sunrise/sunset settings
3. Review motion automation interaction with AL
4. Check if automation is overriding AL

## Questions to Ask User

Before debugging, gather:
1. What SHOULD happen with Alaina's LED lights? (auto-off after X minutes?)
2. What SHOULD happen upstairs hallway at 5:30am? (no light? dim white? something else?)
3. Are there specific automations for these lights we should review first?
4. When did these issues start? (after AL cleanup? before?)

## Tools to Use

- Automation traces (check last 10 triggers)
- Logbook (filter by entity)
- AL adaptive_lighting.sleep_mode_switch status
- Check for duplicate/conflicting automations
