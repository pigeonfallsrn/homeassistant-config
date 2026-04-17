# S37: LABELING EXECUTION PLAN + LEARNINGS

## OBJECTIVE
Label 456 entities (145 from S36 + 311 backlog from S35) + bulk area assign 1,200 total.

## PHASE 1: S36 LABELING (145 entities)

### Batch 1: S36 Lights (10 entities)
**Entity IDs:**
- light.master_bedroom
- light.master_bedroom_wall_light
- light.master_bedroom_led_light_strip
- light.upstairs_hallway
- light.upstairs_hallway_ceiling_1_of_3
- light.upstairs_hallway_ceiling_2_of_3
- light.upstairs_hallway_ceiling_3_of_3
- light.basement
- light.basement_workout_area_ceiling
- light.basement_third_reality_nightlight_motion

**Label:** lighting
**API Call:** ha_set_entity([...], labels=["lighting"])

### Batch 2: S36 Switches (33 entities)
**Breakdown:**
- Master Bedroom AL switches: 4
- Master Bedroom Hue Bridge: 1
- Master Bedroom Echo: 3
- Master Bedroom TV: 3
- Upstairs Hallway AL: 4
- Basement Hallway Switch: 4
- Basement Echo: 3
- Basement AVR: 1
- Basement Plugs: 7
- Basement Yamaha: 4

**Label:** switches
**API Call:** ha_set_entity([...], labels=["switches"])

### Batch 3: S36 Sensors + Binary Sensors + Numbers (100 entities)
- 69 sensors
- 7 binary_sensors
- 25 numbers

**Label:** sensors (all consolidated)
**API Calls:** 2-3 calls (50 entities each)

---

## PHASE 2: S35 BACKLOG LABELING (311 entities)

### Kitchen + Living Room Pending
- 45 Kitchen sensors
- 13 Living Room sensors
- 10 Kitchen binary_sensors
- 3 Living Room binary_sensors
- 174 Kitchen numbers
- 16 Living Room numbers

**Label:** sensors (all)
**API Calls:** 7 calls (50 entities each)

---

## PHASE 3: BULK AREA ASSIGNMENT (1,200 entities across 8 pools)

### Strategy: Batch by Area, Not Domain
1. **Garage** (~71) → area_id=garage
2. **Entry Room** (~185) → area_id=entry_room
3. **1st Floor Bathroom** (~106) → area_id=1st_floor_bathroom
4. **2nd Floor Bathroom** (~205) → area_id=2nd_floor_bathroom
5. **Alaina's Bedroom** (~57) → area_id=alaina_s_bedroom
6. **Ella's Bedroom** (~35) → area_id=ella_s_bedroom
7. **Kitchen** (386) → area_id=kitchen
8. **Living Room** (56) → area_id=living_room
9. **Master Bedroom** (27) → area_id=master_bedroom
10. **Upstairs Hallway** (10) → area_id=upstairs_hallway
11. **Basement** (108) → area_id=basement

**Batch Size:** 20 entities per call
**Total Calls:** ~60

---

## LEARNING POINTS CAPTURED

### 1. Smart Plug Pattern
**Finding:** 5-7 smart plugs per major area (Kitchen: 5+, Basement: 7)
**Entity Ratio:** 1 plug = 9 entities (1 switch + 7 sensors + 2 numbers)
**Implication:** Smart plugs are NOT lightweight entities; they're full monitoring devices
**Future Planning:** When deploying new plugs, budget 9 entities per plug

### 2. AL Instance Standardization
**Finding:** Every AL-enabled light = 4 AL switches (on/off toggle + 3 config switches)
**Consistency:** Pattern holds across all areas (Hallway, Master Bedroom, Living Room, etc.)
**Opportunity:** Create AL deployment template with predictable entity count

### 3. Media Device Control Overhead
**Finding:** Echo Show + TV = 6 switches + 6 sensors (18 entities per media device pair)
**Areas Affected:** Master Bedroom, Kitchen (Echo + TV)
**Implication:** Media-rich areas have hidden entity overhead

### 4. Sensor Consolidation Win
**Finding:** Grouping sensors, binary_sensors, numbers under single `sensors` label is viable
**Rationale:** All are read-only monitoring entities (not state-control like lights/switches)
**Benefit:** Reduces label fragmentation from 12 to single `sensors` catch-all

### 5. Ghost Area Detection
**Finding:** Laundry area exists but contains 0 entities
**Root Cause:** Washer/dehumidifier devices are hardcoded to basement
**Resolution Strategy:** Post-labeling audit of all 12 areas for empty/orphaned areas

### 6. MotionAware Redundancy
**Finding:** Upstairs Hallway has 2 motion sensors (standard + MotionAware)
**Question:** Are they redundant automations or complementary (one for local, one for zone)?
**Action:** S37 investigation → may reveal opportunity to consolidate

---

## OPPORTUNITY LOG

| # | Opportunity | Category | Priority | Owner | Status |
|---|---|---|---|---|---|
| 1 | Entity naming standardization | Quality | Medium | Post-S37 | Queued |
| 2 | Laundry area resolution | Cleanup | Low | Post-S37 | Pending audit |
| 3 | AL instance documentation | Process | Medium | Post-S37 | In CRITICAL_RULES.md |
| 4 | Smart Plug device profile | Documentation | High | Post-S37 | New pattern |
| 5 | Media device control pattern | Documentation | Medium | Post-S37 | Emerging pattern |
| 6 | MotionAware redundancy audit | Optimization | Low | S37 | Investigate |
| 7 | Sensor label consolidation | Simplification | High | S37 | Implemented |

---

## S37 EXECUTION STEPS

1. **Backup:** `ha_backup_create("S37_Pre_Label_145_Entities")`
2. **Label S36 (145):** 5 API calls (10L + 33S + 100 Sensors/BS/N)
3. **Label S35 Backlog (311):** 7 API calls (all sensors)
4. **Area Assign (1,200):** 60 API calls (20 entities per call)
5. **Verify:** Sample check across 5 areas (completeness)
6. **Commit:** S37_LABELING_SUMMARY.md with stats + learnings
7. **Final:** `git log -5` showing S36→S37 progress chain

---

## CUMULATIVE PROGRESS TRACKING

**Before S37:**
- Discovered: 1,200
- Labeled: 747 (62%)
- Area-assigned: ~500 (42%)

**After S37 (Target):**
- Discovered: 1,200 (100%)
- Labeled: 1,200 (100%)
- Area-assigned: 1,200 (100%)

---

