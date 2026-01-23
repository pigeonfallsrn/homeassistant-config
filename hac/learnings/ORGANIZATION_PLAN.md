# Home Assistant Organization Plan
Date: January 17, 2026

## Issues Found

### 1. **1,079 Disabled Entities** ⚠️ CRITICAL
This is excessive. Most are likely from:
- Old integrations that were removed/re-added
- Devices that no longer exist
- Duplicate entities from integration updates

**Action Required:**
- Review in UI: Settings > Devices & Services > Entities
- Filter by "Disabled"
- Delete entities that don't belong to current devices

### 2. **No Areas Configured** ⚠️
Areas help organize devices and are used in voice commands.

**Recommended Areas:**
- Kitchen
- Living Room
- Master Bedroom
- Upstairs Hallway
- Garage
- Basement
- Alaina's Bedroom
- Ella's Bedroom
- Entry Room
- Upstairs Bathroom
- 1st Floor Bathroom

**Action:** Settings > Areas > Add each area

### 3. **No Zones Configured** ⚠️
Zones enable location-based automations.

**Recommended Zones:**
- Home (main residence)
- Work (TCHCC hospital)
- School (for kids' devices)
- Pigeon Falls Village Hall (if needed)

**Action:** Settings > Zones > Add each zone

### 4. **Duplicate Entities (_2, _3 suffixes)**
These are from device re-adds or integration updates:
- UniFi devices
- Device trackers
- Calendars
- Scenes

**These can likely be deleted:**
- `calendar.minnesota_vikings_2`
- `device_tracker.*_2` and `*_3` entries
- `scene.new_scene_2`, `scene.new_scene_3`

### 5. **Dashboard Backups (34 files)** ✓ LOW PRIORITY
Not critical but could clean up:
```bash
find /config -name "*.yaml.backup*" -type f | grep -v automations
```

## Cleanup Commands

### Safe Cleanup (Run These)
```bash
# 1. Clean old dashboard backups (>60 days)
find /config -name "*.backup*" -mtime +60 -delete

# 2. Clean old HAC contexts (>14 days)  
find /config/hac/contexts -name "*.md" -mtime +14 -delete
find /config/hac/contexts -name "*.txt" -mtime +14 -delete

# 3. List disabled entities to review
grep '"disabled_by"' /config/.storage/core.entity_registry | \
  grep -v '"disabled_by":null' | \
  grep -o '"entity_id":"[^"]*"' | \
  cut -d'"' -f4 > /config/hac/learnings/disabled_entities.txt

echo "Disabled entities list: /config/hac/learnings/disabled_entities.txt"
```

### Manual UI Cleanup (DO IN HOME ASSISTANT)

**Step 1: Clean Disabled Entities**
1. Settings > Devices & Services > Entities
2. Click Filter icon
3. Select "Disabled" status
4. Review list - delete entities from non-existent devices
5. Target: Reduce from 1,079 to ~100-200

**Step 2: Setup Areas**
1. Settings > Areas
2. Create area for each room
3. Assign devices to areas
4. Benefit: Better organization, voice control

**Step 3: Setup Zones**
1. Settings > Zones > Add Zone
2. Create "Home" zone around your house
3. Create "Work" zone around TCHCC
4. Used for presence detection automations

**Step 4: Clean Duplicate Entities**
1. Settings > Devices & Services > Entities
2. Search for "_2" or "_3"
3. Delete duplicates (keep the one without suffix)

## HAC Updates Needed

Update HAC to include Areas and Zones in context:
```bash
# Add to generate_claude_context():
echo "## Areas"
grep '"name"' /config/.storage/core.area_registry | cut -d'"' -f4 | sort

echo "## Zones"  
grep '"name"' /config/.storage/core.zone_storage | cut -d'"' -f4 | sort
```

## Priority Order

1. **HIGH**: Setup Areas (improves organization immediately)
2. **HIGH**: Clean disabled entities (reduces clutter)
3. **MEDIUM**: Setup Zones (enables better automations)
4. **LOW**: Clean duplicate entities (_2, _3)
5. **LOW**: Clean old backups

## Expected Results After Cleanup

- Disabled entities: 1,079 → ~150
- Backup files: 39 → ~10
- Areas configured: 0 → 11+
- Zones configured: 0 → 2+
- HAC context includes areas/zones
- Cleaner entity list
- Better voice assistant integration

## Next Steps

1. Run safe cleanup commands above
2. Review disabled_entities.txt
3. Setup areas in UI
4. Setup zones in UI
5. Re-run system audit: `hac check`
6. Update HAC with area/zone context

---
**Status:** Plan created, ready to execute
