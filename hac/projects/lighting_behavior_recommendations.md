# Lighting Behavior Recommendations - Family-Friendly Design

## Issue Analysis

### Alaina's LED Lights
**Current Problem:** Stays on indefinitely, manual Alexa control only
**User Pattern:** "Alexa, turn on Alaina's LED lights to X%"
**Challenge:** Needs auto-off but must respect manual Alexa control

### Upstairs Hallway
**Current Problem:** AL behavior inappropriate for early AM (too dark/red at 5:30am)
**User Feedback:** "Dad, this light is so stupid" (too dark in morning)
**Challenge:** Different needs at different times (2am bathroom vs 5:30am wake-up)

## Recommended Solutions

### Solution 1: Alaina's LED Lights - Smart Auto-Off

**Proposed Behavior:**
- **Manual Alexa control works normally** (no change to user experience)
- **Auto-off at midnight** IF lights are on
- **Exception:** If manually changed after 10pm, assume she wants them (skip auto-off)
- **Morning reset:** Ensure off at 7am (school prep time)

**Implementation:**
```yaml
# automation: Alaina LED Auto-Off Midnight
- alias: "Alaina LED - Auto Off Midnight"
  trigger:
    - platform: time
      at: "00:00:00"
  condition:
    - condition: state
      entity_id: light.alaina_s_led_light_strip_1
      state: 'on'
  action:
    - service: light.turn_off
      target:
        entity_id:
          - light.alaina_s_led_light_strip_1
          - light.alaina_s_led_light_strip_2
```

**Alternative (Smarter):**
If she's awake past midnight, don't turn off. Use motion sensor:
- If no motion in room for 30min after midnight → turn off
- Requires: Does Alaina's room have motion sensor?

### Solution 2: Upstairs Hallway - Time-Based Brightness

**Problem:** AL at 5:30am in winter = too dark (dark red/dim)
**Root Cause:** AL thinks it's "sleep time" because sun not up yet

**Proposed Behavior:**

**Nighttime (10pm-2am):** 
- Motion → Dim warm light (10% brightness, 2700K)
- Purpose: Bathroom trips without blinding

**Deep Sleep (2am-5am):**
- Motion → Very dim red (5% brightness, avoid waking)
- Purpose: Minimal disruption

**Morning Prep (5am-7am):**
- Motion → **BRIGHT neutral white** (60% brightness, 4000K)
- Purpose: Kids getting ready for school, need LIGHT
- Override AL completely during this window

**Day (7am-10pm):**
- Motion → Full brightness neutral white
- No AL control during day

**Implementation Strategy:**

**Option A: Disable AL, Use Custom Automation**
```yaml
# Replace AL with time-based motion automation
- alias: "Upstairs Hallway - Smart Motion"
  mode: restart
  trigger:
    - platform: state
      entity_id: binary_sensor.upstairs_hallway_motion
      to: 'on'
      id: 'motion_on'
    - platform: state
      entity_id: binary_sensor.upstairs_hallway_motion
      to: 'off'
      for: "00:03:00"
      id: 'motion_off'
  action:
    - choose:
        # Morning prep (5am-7am) - BRIGHT
        - conditions:
            - condition: trigger
              id: 'motion_on'
            - condition: time
              after: '05:00:00'
              before: '07:00:00'
          sequence:
            - service: light.turn_on
              target:
                entity_id: light.upstairs_hallway
              data:
                brightness_pct: 60
                kelvin: 4000
        
        # Nighttime (10pm-2am) - Dim warm
        - conditions:
            - condition: trigger
              id: 'motion_on'
            - condition: time
              after: '22:00:00'
              before: '02:00:00'
          sequence:
            - service: light.turn_on
              target:
                entity_id: light.upstairs_hallway
              data:
                brightness_pct: 10
                kelvin: 2700
        
        # Deep sleep (2am-5am) - Very dim red
        - conditions:
            - condition: trigger
              id: 'motion_on'
            - condition: time
              after: '02:00:00'
              before: '05:00:00'
          sequence:
            - service: light.turn_on
              target:
                entity_id: light.upstairs_hallway
              data:
                brightness_pct: 5
                rgb_color: [255, 0, 0]
        
        # Motion off - Turn off light
        - conditions:
            - condition: trigger
              id: 'motion_off'
          sequence:
            - service: light.turn_off
              target:
                entity_id: light.upstairs_hallway
```

**Option B: Keep AL, Override for Morning**
- Keep AL for evening/night
- Add override automation for 5am-7am only
- Simpler, less code

## Questions Before Implementation

1. **Alaina's room motion sensor:**
   - Does her room have a motion sensor?
   - Check: `binary_sensor.alaina*motion`

2. **Upstairs hallway light type:**
   - Are these Hue bulbs? (can do color/kelvin)
   - Or just dimmable white?

3. **School morning schedule:**
   - What time do kids wake up on school days?
   - 5am seems early - is 5:30am-6:30am better window?

4. **Weekend behavior:**
   - Should weekends be different?
   - Or same rules every day?

