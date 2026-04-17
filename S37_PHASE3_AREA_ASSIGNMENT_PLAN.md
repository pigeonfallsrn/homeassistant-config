# S37 Phase 3: BULK AREA ASSIGNMENT EXECUTION PLAN

## Overview
**Total Entities to Assign:** 1,200  
**Total Areas:** 11  
**Assignment Method:** Bulk batching (20-30 entities per API call)  
**Estimated API Calls:** 50-60  

## AREA ASSIGNMENT TARGETS

### 1. Garage (~71 entities)
**Entity Search Query:** "garage"  
**Target Area ID:** garage  
**Status:** 211 entities found (includes scenes, automations, helpers)  
**Estimated to Assign:** ~71 core entities (lights/switches/sensors)

### 2. Entry Room (~185 entities)
**Entity Search Query:** "entry room" OR "entry_room"  
**Target Area ID:** entry_room  
**Status:** Core lights/switches/sensors (~185)

### 3. 1st Floor Bathroom (~106 entities)
**Entity Search Query:** "1st floor bathroom" OR "1st_floor_bathroom"  
**Target Area ID:** 1st_floor_bathroom  
**Status:** Core entities (~106)

### 4. 2nd Floor Bathroom (~205 entities)
**Entity Search Query:** "2nd floor bathroom" OR "2nd_floor_bathroom"  
**Target Area ID:** 2nd_floor_bathroom  
**Status:** Core entities (~205)

### 5. Alaina's Bedroom (~57 entities)
**Entity Search Query:** "alaina" OR "alaina_s"  
**Target Area ID:** alaina_s_bedroom  
**Status:** Many pre-assigned; remaining ~57

### 6. Ella's Bedroom (~35 entities)
**Entity Search Query:** "ella" OR "ella_s"  
**Target Area ID:** ella_s_bedroom  
**Status:** Many pre-assigned; remaining ~35

### 7. Kitchen (386 entities)
**Entity Search Query:** "kitchen"  
**Target Area ID:** kitchen  
**Status:** All 386 labeled, awaiting area assignment

### 8. Living Room (56 entities)
**Entity Search Query:** "living room" OR "living_room"  
**Target Area ID:** living_room  
**Status:** All 56 labeled, awaiting area assignment

### 9. Master Bedroom (27 entities)
**Entity Search Query:** "master bedroom" OR "master_bedroom"  
**Target Area ID:** master_bedroom  
**Status:** All 27 labeled, awaiting area assignment

### 10. Upstairs Hallway (10 entities)
**Entity Search Query:** "upstairs hallway" OR "upstairs_hallway"  
**Target Area ID:** upstairs_hallway  
**Status:** All 10 labeled, awaiting area assignment

### 11. Basement (108 entities)
**Entity Search Query:** "basement"  
**Target Area ID:** basement  
**Status:** All 108 labeled, awaiting area assignment

---

## EXECUTION STRATEGY

### Phase 3A: Entity Discovery by Area (Verify counts)
Run searches for each area to confirm entity discovery:
```bash
# Kitchen (largest pool)
curl -s http://localhost:8123/api/entities \
  -H "Authorization: Bearer $HA_TOKEN" | \
  jq '.[] | select(.entity_id | startswith("light.kitchen") or startswith("sensor.kitchen") or startswith("switch.kitchen") or startswith("number.kitchen") or startswith("binary_sensor.kitchen")) | .entity_id' | wc -l

# Repeat for each area
```

### Phase 3B: Bulk Area Assignment (API-based)
For each area, batch assign entities in groups of 20-30:

**Pattern:**
```python
# Pseudo-code
for area in areas:
    entity_ids = search_entities_by_area(area.query)
    for batch in chunks(entity_ids, 20):
        ha_set_entity(entity_id=batch, area_id=area.area_id)
```

### Phase 3C: Verification
Sample check across 5 areas to confirm assignments:
```bash
# Verify Kitchen
curl -s http://localhost:8123/api/entity_registry/list \
  -H "Authorization: Bearer $HA_TOKEN" | \
  jq '.[] | select(.entity_id | startswith("light.kitchen")) | {entity_id, area_id}' | head -10

# Repeat for other areas
```

---

## IMPLEMENTATION TIMELINE

**Total Estimated Time:** 10-15 minutes  
**API Call Overhead:** ~60 calls × 50ms = ~3 seconds total  
**Human Review Time:** 5 minutes verification + 5 minutes commit

---

## SUCCESS CRITERIA

✅ **Phase 3 Complete When:**
- All 1,200 entities have area_id assigned
- Verified spot checks across 5 areas show correct assignments
- No entities left with area_id=null (except helpers/automations that legitimately don't need areas)
- Final commit captures completion stats

---

## DEFERRED ITEMS

1. **Laundry Area (0 entities):** Remains empty; document post-S37
2. **Stale Entity Cleanup:** 2 orphaned entities identified, logged for post-S37 audit
3. **Entity Naming Standardization:** Post-S37 project

---

## NEXT STEPS

1. Execute Phase 3A discovery verifications
2. Execute Phase 3B bulk area assignments (via Claude MCP or terminal API)
3. Execute Phase 3C verification spot checks
4. Create S37_PHASE3_COMPLETION_SUMMARY.md with stats
5. Final git commit

---

