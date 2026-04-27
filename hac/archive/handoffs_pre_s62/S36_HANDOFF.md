# S36 Handoff: Master Bedroom + Remaining Pools Discovery

## DISCOVERY SUMMARY

**S36 Complete Discovery Across 4 Remaining Pools:**

| Room | Lights | Switches | Sensors | Binary Sensors | Numbers | **Total** |
|------|--------|----------|---------|---|---|---------|
| Master Bedroom | 3 | 11 | 11 | 1 | 0 | **27** |
| Upstairs Hallway | 4 | 4 | 0 | 2 | 0 | **10** |
| Laundry | 0 | 0 | 0 | 0 | 0 | **0** |
| Basement | 3 | 18 | 58 | 4 | 25 | **108** |
| **S36 TOTAL** | **10** | **33** | **69** | **7** | **25** | **145** |

## GRAND TOTAL: S32→S36

**All 12 Major Areas Discovered: 1,200 Entities**

| Session | Rooms | Entities | Status |
|---------|-------|----------|--------|
| S32 | Garage + Entry Room | 308 | ✅ Labeled + Git |
| S33 | Both Bathrooms | 208 | ✅ Labeled + Git |
| S34 | Alaina's + Ella's Bedrooms | 97 | ✅ Labeled + Git |
| S35 | Kitchen + Living Room | 442 | ⏳ 131 labeled, 311 pending |
| S36 | Master Bedroom + UH + Laundry + Basement | 145 | 🆕 Discovery complete |
| **TOTAL** | **8 pools** | **1,200** | |

---

## KEY INSIGHTS: DISCOVERY PATTERNS

### 1. **Bedroom/Hallway Pattern: Adaptive Lighting Heavy**
- Master Bedroom: 4/11 switches are AL (36%) → light.master_bedroom_wall_lamp
- Upstairs Hallway: 4/4 switches are AL (100%) → light.upstairs_hallway_ceiling
- **Insight:** AL instances are now fully mapped across all areas. Pattern: 1 light = 4 AL switches (on/off toggle + color/brightness adapt + sleep mode)
- **Opportunity:** Standardize AL configuration documentation (currently in CRITICAL_RULES.md)

### 2. **Laundry: Ghost Area**
- **Status:** Area exists in HA config but contains 0 entities
- **Implication:** All laundry devices may be:
  - In basement (washer/dehumidifier plugs ARE in basement)
  - Assigned to other areas
  - Never automated
- **Recommendation:** Laundry can be marked as "cleaned" or merged into basement workflow
- **Opportunity:** Future evaluation: is laundry a distinct workflow or part of basement?

### 3. **Basement: Heavy Multi-Device Area**
- **58 sensors** = massive sensor-to-device ratio:
  - 5 smart plugs × 7 sensors each = 35 sensors (AVR, Washer, Dehumidifier, TV, Fluorescent, Milwaukee Charger, Echo Plug)
  - Echo device × 3 sensors (alarm/timer/reminder)
  - Nest Thermostat × 2 (temp/humidity)
  - Nightlight × 1
  - Smart switch × 3 (signal/auto-off/cloud)
  - **Pattern:** Smart plugs dominate basement entity count (61% of sensors)
- **Numbers:** 25 entities
  - Smart plug delays: 10 (5 plugs × 2)
  - Smart switch config: 1
  - Nightlight config: 4
  - AV Receiver config: 6
  - Zone 2 config: 3 (unavailable)
- **Insight:** Basement is equipment-heavy with monitoring/control needs far exceeding lighting

### 4. **Master Bedroom: Echo Show Dominance**
- 3 lights, but 11 switches breakdown:
  - 4 AL switches (master_bedroom_wall_lamp)
  - 1 Hue Bridge automation (tap dial)
  - 3 Echo Show controls (DND/shuffle/repeat)
  - 3 TV controls (DND/shuffle/repeat)
- **Pattern:** Media devices (Echo + TV) generate control switches separate from lighting
- **Insight:** Master Bedroom is a media-first room (not just lighting/motion)

### 5. **Upstairs Hallway: Minimal Control**
- Only 4 lights + 4 AL switches
- 2 motion sensors (standard motion + MotionAware area)
- **Pattern:** Hallway is automation-light (motion-triggered only, no media)
- **Comparison:** Entry Room has 23 switches; Upstairs Hallway has 4 → 5.75x fewer controls
- **Implication:** Hallway is intentionally minimal (motion-only design)

---

## ENTITY ASSIGNMENT STATUS (S36)

### Master Bedroom (27 entities)
**Lights:**
- `light.master_bedroom`
- `light.master_bedroom_wall_light`
- `light.master_bedroom_led_light_strip`

**Switches:**
- AL (master_bedroom_wall_lamp): 4 controls
- Hue Bridge automation: 1
- Echo Show: 3 (DND/shuffle/repeat)
- TV: 3 (DND/shuffle/repeat)

**Sensors:**
- Tap Dial battery: 1
- LED light strip power metrics: 4 (current/today/month/total consumption)
- Echo Show: 3 (next alarm/timer/reminder)
- TV: 3 (next alarm/timer/reminder)

**Binary Sensors:**
- LED light strip cloud connection: 1

### Upstairs Hallway (10 entities)
**Lights:**
- `light.upstairs_hallway`
- `light.upstairs_hallway_ceiling_[1-3]_of_3`

**Switches:**
- AL (upstairs_hallway): 4

**Binary Sensors:**
- Motion: 1
- MotionAware area: 1

### Basement (108 entities)
**Lights:**
- `light.basement`
- `light.basement_workout_area_ceiling`
- `light.basement_third_reality_nightlight_motion`

**Switches:**
- Basement hallway smart switch: 4 (on/off + auto-off + auto-update + LED)
- Echo: 3 (DND/shuffle/repeat)
- AVR: 1 (HARD POWER RESET)
- Smart plugs: 7 (washer/dehumidifier/TV/fluorescent/Milwaukee/echo plug)
- Yamaha AV Receiver: 4 (Adaptive DRC, Compressed Music, Pure Direct, Cinema DSP)

**Sensors:**
- Heating: 1
- Hallway smart switch: 3 (signal/auto-off-at/cloud)
- Nest Thermostat: 2 (temp/humidity)
- Echo: 3 (alarm/timer/reminder)
- AVR HARD POWER RESET: 7 (current/voltage/frequency/factor/demand/power/summation)
- Washer plug: 7
- Dehumidifier plug: 7
- TV plug: 7 (unavailable)
- Fluorescent plug: 7 (unavailable)
- Milwaukee Charger plug: 7
- Echo Smart Plug: 7
- Nightlight: 1 (illuminance)

**Binary Sensors:**
- Heating: 1
- Hallway switch cloud: 1
- Hallway switch overheated: 1
- Nightlight motion: 1

**Numbers:**
- Hallway switch auto-off: 1
- AVR HARD POWER RESET: 3 (turn-off/on delay)
- Smart plugs (5): 10 total (2 each: turn-off/on delay)
- Nightlight: 4 (on/off transition, on level, power-on level, start-up CT)
- Yamaha AV Receiver: 3 (max volume, volume dB, initial volume) [unavailable]
- Receiver Zone 2: 3 (max volume, volume dB, initial volume) [unavailable]

---

## LABELING STRATEGY (S37 Incoming)

### Phase 1: S36 Labeling (145 entities)
1. **Lights (10)** → `lighting` label
2. **Switches (33)** → `switches` label
3. **Sensors (69)** → `sensors` label
4. **Binary Sensors (7)** → `sensors` label (consolidated)
5. **Numbers (25)** → `sensors` label (consolidated)

**Estimated API calls:** ~15 (50 entities per batch)

### Phase 2: S35 Backlog Labeling (311 entities)
- 45 Kitchen sensors → `sensors`
- 13 Living Room sensors → `sensors`
- 10 Kitchen binary_sensors → `sensors`
- 3 Living Room binary_sensors → `sensors`
- 174 Kitchen numbers → `sensors`
- 16 Living Room numbers → `sensors`

**Estimated API calls:** ~7 (50 entities per batch)

### Phase 3: Bulk Area Assignment
- All 1,200 entities across 8 discovered pools
- **Strategy:** Batch by area (not domain)
  - Garage: ~71 entities
  - Entry Room: ~185 entities
  - 1st Floor Bathroom: ~106 entities
  - 2nd Floor Bathroom: ~205 entities
  - Alaina's Bedroom: ~57 entities
  - Ella's Bedroom: ~35 entities
  - Kitchen: 386 entities
  - Living Room: 56 entities
  - Master Bedroom: 27 entities
  - Upstairs Hallway: 10 entities
  - Basement: 108 entities

**Estimated API calls:** ~50-60 (20 entities per area call)

---

## OPPORTUNITIES & LEARNINGS

### Opportunity 1: Entity Naming Inconsistencies
- **Master Bedroom:** `light.master_bedroom_*` (consistent)
- **Basement:** Mixed patterns:
  - `light.basement_*` (consistent)
  - `switch.basement_hallway_*` vs `switch.basement_yamaha_*` (device-based)
  - `number.basement_receiver_zone_*` (manual naming, not auto-generated)
- **Action:** Post-S37 standardization pass on naming

### Opportunity 2: Laundry Area Resolution
- Current state: 0 entities
- Washer/dehumidifier plugs are in basement
- **Options:**
  1. Delete laundry area (clean unused)
  2. Move washer/dehumidifier to laundry area
  3. Document as intentional (equipment managed in basement)
- **Recommendation:** Defer to post-labeling review

### Opportunity 3: AL Instance Documentation
- Master Bedroom wall lamp: 4 switches
- Upstairs Hallway: 4 switches
- Pattern is consistent across all AL instances (4 switches per light)
- **Action:** Document in CRITICAL_RULES.md under AL section for future AL deployments

### Opportunity 4: Smart Plug Standardization
- Basement has 7 smart plugs, each generating 7 sensors + 2 numbers = 9 entities
- Kitchen has at least 5 plugs (estimated)
- **Pattern:** Smart plugs are major entity generators
- **Opportunity:** Create device profile for smart plugs (like we did for Inovelli) in HAC docs

### Opportunity 5: Media Device Control Pattern
- Master Bedroom Echo + TV = 6 control switches
- Pattern: Every media device adds 3 switches (DND/shuffle/repeat)
- **Insight:** Media devices are NOT just state sensors; they're controllable entities
- **Action:** Document media device pattern for future smart speaker/TV deployments

### Opportunity 6: MotionAware vs Standard Motion
- Upstairs Hallway has BOTH:
  - `binary_sensor.upstairs_hallway_motion` (standard)
  - `binary_sensor.upstairs_hallway_upstairs_motionaware_area` (MotionAware)
- **Question:** Why 2 motion sensors? Manual + automated?
- **Recommendation:** Investigate S37 (may reveal redundancy opportunity)

---

## S37 READINESS CHECKLIST

- [ ] Backup created pre-labeling (use `ha_backup_create("S37_Pre_Label")`)
- [ ] Label IDs verified (`lighting`, `switches`, `sensors`)
- [ ] Batch strategy locked (50 entities/call, ~72 total calls)
- [ ] Git pager disabled globally (already done)
- [ ] Terminal ready for S37_HANDOFF.md + S37_LABELING_SUMMARY.md commits

---

## NEXT: S37 EXECUTION

**Immediate Actions:**
1. Label S36 (10L + 33S + 76 Sensors/BS/N)
2. Label S35 backlog (311 remaining)
3. Bulk area assign all 1,200
4. Final git commit with cumulative progress

**Target Completion:** 1,200 fully labeled + area-assigned entities
**Estimated Effort:** ~75 API calls + 2 git commits + 1 final review

---

