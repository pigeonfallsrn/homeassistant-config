# HANDOFF — S19 complete | 2026-04-15

## Completed this session (S19)

### Helper migration — ALL TYPES COMPLETE ✅
- input_boolean:  50/50 in UI storage
- input_select:    3/3  in UI storage (occupancy_mode, ella_sleep_timer, kitchen_lighting_scene)
- input_number:    6/6  in UI storage (entry_room_lux_threshold, grade helpers x4, garage_light_timeout)
- input_datetime: 16/16 in UI storage (9 from top-level file + 7 from packages)
- timer:           3/3  in UI storage (garage_light, guest_mode_auto_disable, manual_override_timeout)
- counter:         4/4  in UI storage (garage/doorbell/motion/alert daily counters)
- **TOTAL: 82 helpers fully migrated to UI storage ✅**

### YAML cleanup
- input_datetime.yaml, timer.yaml, counter.yaml — wiped ✅
- !include lines commented out in configuration.yaml ✅
- input_select stripped from: ella_living_room, occupancy_system, kitchen_tablet_dashboard ✅
- input_number stripped from: adaptive_lighting_entry_lamp, family_activities, garage_lighting_automation_fixed ✅
- input_text stripped from: family_activities ✅
- input_datetime stripped from: humidity_smart_alerts, kids_bedroom_automation, garage_door_alerts, family_activities ✅

### Critical learnings
- Slug matching: MCP entity_id derives from display name — use YAML key words as name, NOT the YAML friendly name
- grep no-match exits code 1, breaks && chains — run verify and restart as separate commands
- ha backups new --name works on EQ14 (replaces hac backup, which was Green-only)
- hac symlink must be re-created after power cycle: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac

### Commit
- 6d1a045: feat: S19 — all helpers migrated to UI storage (82 total)

---

## S20 — START HERE

### System state
- ALL 82 helpers in UI storage ✅
- ~84 automations still in package YAML across 19 files
- ~57 automations already in UI storage
- Packages now contain automations ONLY — no more helpers in YAML

### Step 1: Dismiss stale repairs
Settings → Repairs → dismiss:
- "Garage - Clear Arrival Dashboard"
- "Arrival - John Home"

### Step 2: Group 0 automation migration
Files: occupancy_system.yaml (6 automations) + family_activities.yaml (6 automations)
Sequence:
  A. cat both files in terminal
  B. Review: KEEP / REBUILD / DELETE
  C. MCP ha_config_set_automation for each keeper
  D. Strip automation blocks from package files
  E. ha core check → verify → commit
Group 0 is the foundation — all other groups depend on it.

### Step 3: Groups 1–11 per MASTER_PLAN sequence (one group per session)

## Tabled
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE, identity unknown
- Music Assistant — setup_error, needs add-on restart
- Person trackers: Alaina, Ella, Michelle — none assigned
- Michelle iPhone MAC: 6a:9a:25:dd:82:f1
- input_text: alaina/ella waya softball calendar IDs — low priority, recreate during Group 6 (kids)
