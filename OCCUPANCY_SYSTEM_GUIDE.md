# Occupancy System - Quick Reference Guide
**Created:** 2026-01-19  
**System:** Home Assistant with HAC 4.2

---

## 🏠 What You Have

### Presence Tracking
- **Individual**: `input_boolean.john_home`, `alaina_home`, `ella_home`, `michelle_home`
- **Groups**: `input_boolean.girls_home`, `both_girls_home`, `someone_home`
- **Combos**: `input_boolean.john_and_girls`, `john_and_michelle`, `full_house`

### Occupancy Modes
- **Auto-detected**: `sensor.occupancy_mode_auto`
- **Current**: `input_select.occupancy_mode`
- **Options**: Empty, John Only, Kids Only, John + Kids, Full House

### Calendar Awareness
- **School Tomorrow**: `input_boolean.school_tomorrow` (updates daily at 5pm)
- **School Now**: `binary_sensor.school_in_session_now`
- **Kids Expected Away**: `binary_sensor.kids_expected_away`

### Overlays
- **Night Vision**: `input_boolean.preserve_night_vision` (forces dim/red lights)
- **Guest Present**: `input_boolean.guest_present` (brightens living areas)
- **Bedtime Override**: `input_boolean.kids_bedtime_override` (skip bedtime dimming)

---

## 📱 Dashboards (S24 Ultra)

### Access in HA Mobile App:
1. Open Home Assistant app
2. Tap menu → **Kitchen** 
3. Views available:
   - **mobile-main** ← Use this on your S24 Ultra
   - kitchen-family
   - kitchen-john
   - kitchen-kids
   - kitchen-away
   - kitchen-guest

### Tablet Auto-Switching
Kitchen tablet automatically loads different dashboards based on:
- **Empty** → kitchen-away (security monitoring)
- **John Only** → kitchen-john (work schedule + controls)
- **Kids Only** → kitchen-kids (homework mode, fun controls)
- **Full House** → kitchen-family (everyone's schedule)
- **Guest** → kitchen-guest (simple, welcoming)

---

## 🎛️ How It Works

### Lighting Context Engine
**Script**: `script.apply_lighting_context`

Automatically adjusts Adaptive Lighting sleep modes based on:
1. **Who's home** (occupancy mode)
2. **Time of day** (morning/afternoon/evening/night)
3. **School tomorrow** (bedtime windows)
4. **Overlays** (night vision, guest present)

**Examples:**
- Empty house → All lights to sleep mode
- John only + evening → Living room normal, kids areas dim
- Kids only + bedtime window → Dim kids rooms, brighten living room
- Full house + night → All to sleep mode
- Guest present → Living room & entry always bright

### Night Path Lighting
**Motion-activated dim lights for nighttime:**

**Upstairs Hallway:**
- Trigger: `binary_sensor.upstairs_hallway_aqara_motion_sensor`
- Light: `light.upstairs_hallway`
- Behavior: 5% brightness, 2200K warm, auto-off after 2min

**2nd Floor Bathroom:**
- Same motion sensor (for now)
- Light: `light.2nd_floor_bathroom`
- Behavior: 5% deep red, auto-off after 2min

### Calendar Snapshots
**Updates automatically:**
- **Daily at 5pm** + on HA restart
- Checks `calendar.master_calendar` for:
  - "No School"
  - "School Closed"
  - "Holiday"
  - "Inservice"
- Sets `input_boolean.school_tomorrow` accordingly

---

## 🔧 Manual Controls

### Toggle Modes (Settings → Helpers)
```
Night Vision Mode → Forces all lights dim/red
Guest Present → Brightens living areas
Bedtime Override → Skip school night bedtime dimming
```

### Force Occupancy Mode
If auto-detection is wrong:
1. Settings → Helpers
2. Find "Occupancy Mode"
3. Select desired mode manually

### Disable Features
Turn off automation in Settings → Automations:
- "Occupancy → Update Mode" (stops auto-detection)
- "Context → Apply on Occupancy Change" (stops auto-lighting)
- "Calendar → Refresh School Tomorrow" (stops calendar checking)

---

## 🐛 Troubleshooting

### Lights not changing?
Check Adaptive Lighting instances are running:
```
Settings → Devices → Adaptive Lighting
Verify these are ON:
- Living Spaces
- Kids Rooms
- Entry Room Ceiling Lights
- Upstairs Hallway
- Kitchen Table
```

### Presence wrong?
Check person entities in HA app:
```
Settings → People
Verify each person shows correct location
```

### Tablet not switching views?
Check Fully Kiosk integration:
```
Settings → Devices → Kitchen Wall A9 Tablet
Verify "Current Page" sensor
```

### Calendar not updating?
Check Google Calendar integration:
```
Settings → Integrations → Google Calendar
Verify calendar.master_calendar is connected
```

---

## 📊 Monitoring

### Check System Status
**In HA UI:**
- Developer Tools → States
- Search for: `input_boolean`, `sensor.occupancy`, `binary_sensor.school`

**View logs:**
- Settings → System → Logs
- Filter: "occupancy" or "presence"

### Useful Entities to Watch
```
sensor.house_occupancy_state → "Empty", "John Only", etc.
sensor.people_home_count → 0-4
sensor.time_context → "morning", "evening", "night"
sensor.bedtime_window_active → "on" during bedtime
```

---

## 🎯 Next Steps / Enhancements

### Add More Night Paths
Edit `/config/packages/occupancy_system.yaml`
Copy the upstairs hallway automation, change:
- Motion sensor entity
- Light entity
- Brightness/color preferences

### Customize Bedtime Windows
Currently:
- School nights: 8pm-10pm
- Non-school: 9pm-11pm

Edit in `sensor.bedtime_window_active` template

### Add Sports Calendar Detection
Extend calendar snapshots to check:
- `calendar.whitehall_middle_school_volleyball_calendar`
- Look for "Practice" or "Game" keywords
- Create `input_boolean.late_practice_tonight`
- Use in bedtime logic

### Create Scenes
Instead of just AL sleep modes, create full scenes:
- Movie night
- Homework mode  
- Dinner time
- Morning routine

---

## 📞 Support Files

**Location**: `/config/packages/`
- `presence_system.yaml` - Presence detection
- `occupancy_system.yaml` - Context engine

**Dashboards**: `/config/dashboards/`
- `kitchen_dashboards.yaml` - All views

**Backups**: `/config/backups/archive/`
- Organized by year and category

---

**Built with HAC 4.2 and Claude AI - 2026-01-19**
