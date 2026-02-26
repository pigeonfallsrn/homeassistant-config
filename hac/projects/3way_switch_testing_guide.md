# 3-Way Switch Testing Guide - Determine If Power is Always Hot

## Safety First
⚠️ **Turn off breaker before touching any wires!**
⚠️ **Test with voltmeter to confirm power is off**

## What We Need to Know

**Question:** Does the 3-way switch cut power to the light/fan, OR does it just switch the control signal?

**Why it matters:**
- **Power cut** = HA can't control light when switch is "off" → Need Hue click
- **Always hot** = HA can control anytime → Automations work immediately

## Testing Method (Safest - No Wire Touching)

### Test 1: Switch Position Test (No Voltmeter Needed)

1. **With breaker ON:**
   - Flip the 3-way switch to OFF position
   - Try turning on `light.upstairs_hallway` via Home Assistant app
   
2. **Results:**
   - ✅ **Light turns on** = Power is always hot (switch just sends signal)
   - ❌ **Light doesn't turn on** = Switch cuts power (need Hue click)

### Test 2: Voltmeter Test (Confirms Test 1)

**Turn OFF breaker first!**

1. Remove switch cover plate
2. **Turn breaker back ON**
3. **DO NOT TOUCH WIRES** - just test with voltmeter probes
4. Flip 3-way to "OFF" position
5. Test voltage at light fixture:
   - Hot wire to neutral: Should read 120V if always hot
   - Hot wire to neutral: 0V if switch cuts power

**Turn breaker OFF before putting cover back!**

## Likely Scenario in Old House

Old houses typically have **power-cutting 3-way switches** because:
- Smart bulbs didn't exist
- Switches physically interrupt the hot wire
- "Dumb" wiring where switch controls power, not signal

**My prediction: Your switch cuts power → You'll need Hue click**

## Alternative: Check Current Behavior

**Easiest test - do this right now:**

1. Go flip the upstairs hallway 3-way switch to OFF
2. Open Home Assistant on your phone
3. Try to turn on `light.upstairs_hallway`
4. Does it turn on?

**If NO → Switch cuts power, proceed to Hue click installation**
**If YES → Switch is always hot, we can automate immediately**

