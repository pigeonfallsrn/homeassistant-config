# Immediate Action Plan - Next 30 Minutes

## Step 1: Answer Physical Setup Questions

**Critical question:**
Does your current 3-way switch cut power to `light.upstairs_hallway`?
- If YES → Automations won't work, need Hue click switch first
- If NO → Can implement automations immediately

## Step 2: Temporary Simple Solution (Tonight)

While you plan Apollo Pro installation, let's fix the immediate problems:

### For Alaina's LEDs:
Add midnight auto-off automation (already created in /tmp/new_lighting_automations.yaml)

### For Upstairs Hallway:
**Option A** (if 3-way allows automation):
Use time-based automation with alarm integration:
- 5:30-7:30am: Bright IF `input_select.alarm_mode = "Disarmed"`
- 2am-5:30am: Dim red (deep sleep)

**Option B** (if 3-way blocks automation):
Install Hue click switch first, THEN automate

## Step 3: Apollo Pro Testing (This Weekend)

1. Install one Apollo Pro in kitchen
2. Configure zones via ESPHome
3. Test occupancy detection for 2-3 days
4. If satisfied → proceed to bedroom installs

## Decision Time

**Tell me:**
1. Does 3-way switch cut power to upstairs hallway ceiling light? (YES/NO)
2. Do you want to install Hue click switch this week? (YES/NO/LATER)
3. Should I create temporary automations for tonight? (YES/NO)
4. When will you install Apollo Pro in kitchen? (THIS WEEK/NEXT WEEK/LATER)

**Then I'll create the exact automations you need based on your answers.**
