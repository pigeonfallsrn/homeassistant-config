# Home Assistant Automation Inventory
**Generated:** 2026-01-17  
**Total Automations:** 22 active  
**Audit Status:** Complete system review

---

## Status Legend
- ✅ **KEEP** - Active, essential, working well
- 🔧 **UPDATE** - Working but needs modification
- ⚠️ **REVIEW** - Unclear purpose or may be redundant
- 🗑️ **DELETE** - Deprecated, superseded, or broken
- 📋 **NEW** - Recently added (2026-01-17)

---

## BATHROOM & HUMIDITY MANAGEMENT

### 1. Bathroom Fan – Auto ON (RH ≥ 70% for 1 min)
**Status:** ✅ KEEP  
**ID:** `bathroom_fan_auto_on_humidity`  
**Trigger:** Humidity sensor ≥ 70% for 1 min  
**Action:** Turn on upstairs bathroom fan  
**Purpose:** Automatic humidity control during showers  
**Dependencies:** `sensor.aqara_temp_humidity_sensor_humidity_4`, `switch.upstairs_bathroom_fan`  
**Notes:** Essential comfort automation, working well

### 2. Bathroom Fan – Auto OFF (RH ≤ 60% for 10 min)
**Status:** ✅ KEEP  
**ID:** `bathroom_fan_auto_off_humidity`  
**Trigger:** Humidity ≤ 60% for 10 min  
**Action:** Turn off upstairs bathroom fan  
**Purpose:** Pairs with Auto ON, prevents over-drying  
**Dependencies:** Same as #1  
**Notes:** Perfect pairing with #1

### 3. Bathroom - Red Light (11pm-5:30am)
**Status:** ✅ KEEP  
**ID:** `bathroom_red_light_night`  
**Trigger:** Motion detected between 11pm-5:30am  
**Action:** Red light 8% brightness for 4 min, then fade off  
**Purpose:** Night-friendly lighting (preserves night vision)  
**Dependencies:** `binary_sensor.aqara_motion_sensor_p1_occupancy`, `light.2nd_floor_bathroom`  
**Notes:** Excellent circadian-friendly automation

---

## PRESENCE & ARRIVAL/DEPARTURE

### 4. Everyone Away → All Lights Off
**Status:** 🔧 UPDATE - Missing Michelle  
**ID:** `everyone_away_lights_off`  
**Trigger:** All persons change to not_home  
**Action:** Turn off all lights  
**Purpose:** Energy saving when house empty  
**Current Persons:** John, Alaina, Ella  
**ISSUE:** Missing `person.michelle` from condition check  
**Recommendation:** Add Michelle to person list

### 5. First Person Home After Dark → Entry Lights On
**Status:** 🔧 UPDATE - Should use arrival pattern  
**ID:** `first_person_home_lights_on`  
**Trigger:** Any person arrives home  
**Action:** Entry lamp 20% brightness  
**Purpose:** Welcome lighting  
**Current Logic:** Simple trigger on person.state = home  
**Issue:** Could integrate with your documented arrival pattern (2026-01-15 analysis)  
**Recommendation:** Enhance with multi-signal confirmation (presence + door + motion)

---

## MEDIA & ENTERTAINMENT

### 6. Living Room TV OFF → Full AV System OFF
**Status:** ✅ KEEP  
**ID:** `living_room_tv_off_trigger_av_system_off`  
**Trigger:** Living room TV plug off for 5 min  
**Action:** Turn off Yamaha receiver, Echo Show plug, TV LED strip  
**Purpose:** Comprehensive power management  
**Dependencies:** Multiple switches and media players  
**Notes:** Solid power-saving automation with proper delay

---

## GARAGE LIGHTING SYSTEM

### 7. Garage All Lights OFF (OLD)
**Status:** 🗑️ DELETE - SUPERSEDED  
**ID:** `1767207374114`  
**Trigger:** Motion off for 6 min, doors closed  
**Action:** Turn off all garage lights (including unavailable LiftMaster bulbs)  
**PROBLEM:** Tries to control unavailable entities, conflicts with new system  
**Superseded By:** New 5-automation garage system (items #13-17)  
**Action Required:** SAFE TO DELETE - functionality replaced

### 8. Garage Hue Dimmer Switch
**Status:** ⚠️ REVIEW - May conflict  
**Purpose:** Manual garage light control via Hue remote  
**Potential Conflict:** May override new intelligent garage system  
**Recommendation:** Test interaction with new automations

---

## INOVELLI SWITCH CONTROLS

### 9. Entry Room - Inovelli Ceiling Lights
**Status:** ✅ KEEP  
**ID:** `1767461939171`  
**Type:** Blueprint-based (ZHA Inovelli VZM31-SN)  
**Function:** Up=On, Down=Off, Config=Scene cycle  
**Purpose:** Physical switch control for entry ceiling lights  
**Notes:** Blueprint automations are fine, no changes needed

### 10. Back Patio - Inovelli Scene Control
**Status:** ✅ KEEP  
**Function:** Multi-scene cycling (Bright→Warm→Dim→Red→Off)  
**Purpose:** Outdoor lighting control with multiple brightness levels  
**Notes:** Well-designed scene progression

### 11. Kitchen - Chandelier Control (5 Bulbs)
**Status:** ✅ KEEP  
**ID:** `kitchen_chandelier_switch_v2`  
**Function:** Up=On, Down=Off for all 5 chandelier bulbs  
**Purpose:** Unified kitchen chandelier control  
**Notes:** Simple, effective, no changes needed

### 12. Kitchen Above Sink - Inovelli Control
**Status:** ✅ KEEP  
**ID:** `kitchen_above_sink_inovelli`  
**Function:** Up=On (100%, 4000K), Down=Off  
**Purpose:** Task lighting control for sink area  
**Notes:** Appropriate color temp for task lighting

---

## NEW GARAGE LIGHTING SYSTEM (2026-01-17)

### 13. Garage: Arrival Lighting (Door Opens)
**Status:** 📋 NEW  
**Trigger:** Garage door opens  
**Condition:** Dark (lux < 10 OR 30min before sunset)  
**Action:** All garage lights 100%  
**Purpose:** Immediate lighting on arrival  
**Mode:** restart (motion resets timer)

### 14. Garage: House Exit Lighting (Walk-in Door)
**Status:** 📋 NEW  
**Trigger:** Walk-in door opens (from house to garage)  
**Condition:** Dark + lights currently off  
**Action:** All garage lights 100%  
**Purpose:** Light garage when exiting house (trash, car warmup)  
**Mode:** restart

### 15. Garage: Motion Keep-Alive
**Status:** 📋 NEW  
**Trigger:** Any motion sensor activates  
**Condition:** Dark  
**Action:** Lights on, wait 5min after last motion, then off if doors closed  
**Purpose:** Working in garage, continuous lighting during activity  
**Mode:** restart (each motion resets 5min timer)

### 16. Garage: Departure Auto-Off (Door Closes)
**Status:** 📋 NEW  
**Trigger:** Door closes for 20 seconds  
**Condition:** No motion, both doors closed  
**Action:** All lights off  
**Purpose:** Auto-off after driving away  
**Mode:** restart

### 17. Garage: False Alarm Cleanup
**Status:** 📋 NEW  
**Trigger:** Garage door opens  
**Action:** Wait 3min for walk-in door to open, if timeout and no motion → lights off  
**Purpose:** Turn off lights if door opened but no house entry (false start)  
**Mode:** restart

---

## SUMMARY & RECOMMENDATIONS

### Immediate Actions Required
1. **DELETE:** Garage All Lights OFF (ID: 1767207374114) - superseded
2. **UPDATE:** Everyone Away automation - add person.michelle
3. **UPDATE:** First Person Home - enhance with arrival pattern logic
4. **REVIEW:** Check Garage Hue Dimmer switch interaction with new system

### System Health
- **17 Essential Automations** - Keep as-is
- **3 Need Updates** - Minor modifications
- **1 To Delete** - Superseded by new system
- **5 New Today** - Garage lighting system deployed

### Automation Categories
**By Function:**
- Bathroom/Climate: 3 automations
- Presence/Security: 2 automations (need updates)
- Media/Entertainment: 1 automation
- Lighting Controls: 16 automations (includes Inovelli switches + garage system)

**By Priority:**
- Critical (Don't Touch): 15
- Needs Attention: 4
- Deprecated: 1
