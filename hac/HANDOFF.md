# HANDOFF — S13B
## Date: 2026-04-13
## Last session: S13B — Pre-Migration Build Session

### What was built:
- Phase A: 4 floors, 25 areas, 12 labels, 14 categories playbook
- Phase B: 91 helpers triaged by migration group (6 DROP, 11 → templates)
- Phase C/D/E: Entity rename process, 4 kitchen scenes, full dependency map
- Phase F: BP-2 FOH Scene Cycling + BP-4 VZM30 Bathroom blueprint drafts
- Phase G: Git cleanup plan + EQ14 first-boot clone workflow
- All playbook files on PC as s13b_files.tar.gz (pending git commit)

### Key decisions (S13B):
- Smart Home AV: Basement floor (physically under living room)
- front_door area: G4 Doorbell → merge into front_driveway, delete area
- very_front_door_hallway: Hue light + Aqara motion → merge into very_front_door
- 6 house_mode booleans → DROP, consolidated into input_select.house_mode
- 11 presence booleans (all unavailable) → convert to template binary_sensors
- Recommended: copy core.area_registry from backup (preserves mismatched area_ids)

### Area cleanup on EQ14:
- DELETE 9 areas: yard_sheds, bedroom, entry_way, cloud, cloud_wifi_sync_module, basement_stairs, front_door, very_front_door_hallway, other
- FIX floors: basement_hallway → Basement, pigeon_falls_properties → Outdoors, attic → 2nd Floor

### Open items for John:
- FOH switch button 1-4 mapping (which button does what?)
- Kitchen scene exact brightness/color values
- Update master plan Section 5: Smart Home AV → Basement

### Next session (S14):
1. Enable SFTP on SSH addon, SCP + commit S13B playbook files
2. Get USB drive, flash Ubuntu ISO + HAOS image
3. Flash HAOS to EQ14 NVMe via Ubuntu live USB
4. Execute Phase 2 (NAS + git clone on EQ14)
5. Begin executing Phase A playbook on EQ14
