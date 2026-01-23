# iPhone Setup Tasks for Gemini

## TASK 1: Alaina iPhone 17 Setup
**Due**: Saturday, January 18, 2026 @ 1:00 PM
**Reminder**: Yes, at task time

**Task Title**: Setup Alaina's iPhone 17 in Home Assistant

**Task Description**:
Alaina needs to re-login to Home Assistant Companion app on her iPhone 17.

STEPS:
1. On Alaina's iPhone 17, open "Home Assistant" app
2. If not installed: Download from App Store first
3. Tap "Connect to Home Assistant"
4. Enter server URL: http://homeassistant.local:8123
   - If that doesn't work, use: http://192.168.1.XXX:8123 (get IP from John)
5. Log in with Home Assistant credentials
6. Grant location permissions when prompted (IMPORTANT for tracking)
7. Grant notification permissions

VERIFY IN HOME ASSISTANT:
1. SSH to HA or use terminal
2. Run: `hac entity "alaina" | grep device_tracker`
3. Should see: device_tracker.alaina_s_iphone - home (or not_home)

LINK TO PERSON ENTITY:
1. In HA web UI: Settings → People → Alaina Spencer
2. Verify device_tracker.alaina_s_iphone is added under "Track device"
3. If not there, click "Add" and select it
4. Click "Update"

FINAL CHECK:
Run: `hac person`
Alaina should show "home" or "not_home" (not "unknown")

---

## TASK 2: Ella iPhone 17 Setup  
**Due**: Sunday, January 19, 2026 @ 4:00 PM
**Reminder**: Yes, at task time

**Task Title**: Setup Ella's iPhone 17 in Home Assistant

**Task Description**:
Ella needs to install and setup Home Assistant Companion app on her NEW iPhone 17.

STEPS:
1. On Ella's iPhone 17, go to App Store
2. Search "Home Assistant Companion"
3. Install the app
4. Open app and tap "Connect to Home Assistant"
5. Enter server URL: http://homeassistant.local:8123
   - If that doesn't work, use: http://192.168.1.XXX:8123 (get IP from John)
6. Log in with Home Assistant credentials
7. Grant location permissions when prompted (CRITICAL for tracking)
8. Grant notification permissions

VERIFY IN HOME ASSISTANT:
1. SSH to HA or use terminal
2. Run: `hac entity "ella" | grep device_tracker`
3. Should see a NEW device_tracker (likely device_tracker.ella_s_iphone)

LINK TO PERSON ENTITY:
1. In HA web UI: Settings → People → Ella Spencer
2. Click "Track device" → "Add"
3. Select the new device_tracker.ella_s_iphone (or whatever it's called)
4. Click "Update"

FINAL CHECK:
Run: `hac person`
Ella should show "home" or "not_home" (not "unknown")

---

## CREDENTIALS NEEDED
- HA Server IP: 192.168.1.XXX (check with `ha core info | grep ip_address`)
- HA Username: [Ask John]
- HA Password: [Ask John]

## CONTEXT FILES
- Full guide: /config/ai_context/phone_setup_guide.md
- Person instructions: /config/ai_context/person_setup_instructions.md
