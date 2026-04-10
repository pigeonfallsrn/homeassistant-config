#!/usr/bin/env python3
"""
S11 Post-Migration Ghost Registry Cleanup
Run BEFORE first HA start on Mini PC after backup restore.
Usage: python3 /homeassistant/hac/s11_ghost_registry_cleanup.py
"""
import json, pathlib

reg = pathlib.Path('/homeassistant/.storage/core.entity_registry')
rs  = pathlib.Path('/homeassistant/.storage/core.restore_state')

# All confirmed ghost entity_ids (no YAML backing, verified 2026-04-09)
GHOST_ENTITY_IDS = {
    'automation.living_room_lamps_activity_boost',
    'automation.living_room_lamps_activity_boost_2',
    'automation.garage_arrival_action_handler',
    'automation.arrival_driveway_garage_lights_when_approaching',
    'automation.kitchen_lounge_lamp_hard_off_at_evening_end',
    'automation.global_all_adaptive_lamps_off_when_everyone_leaves',
    'automation.garage_quick_open_action_handler',
    'automation.garage_clear_quick_open_when_door_opens_2',
    'automation.google_sheets_daily_export',
    'automation.google_sheets_manual_export',
    'automation.departure_clear_alert_on_return',
    'automation.upstairs_bathroom_night_lighting',
    # Script ghosts — kitchen_tablet_dashboard.yaml package was removed; scripts orphaned
    # NOTE: lovelace-kitchen-tablet.yaml lines 237+259 still reference these — fix dashboard after cleanup
    'script.kitchen_scene_all_on',       # registry id: 4334405d8585c8b187d563ffa3d0ed4b
    'script.kitchen_scene_movie_night',  # registry id: 726a3a8aab12a8a2dafd6978e16f1e94
    # hac_daily_master_context_export: NOT a ghost — was config.yaml inline block (deleted S10-C)
    # _2 registry entry deleted below by registry id so automation re-registers clean
}

# entity_registry
data = json.loads(reg.read_text())
before = len(data['data']['entities'])
data['data']['entities'] = [
    e for e in data['data']['entities']
    if e.get('entity_id') not in GHOST_ENTITY_IDS
]
after = len(data['data']['entities'])
# Also delete _2 registry entry for hac_daily_master_context_export
# so it re-registers as automation.hac_daily_master_context_export after config.yaml fix
hac_dup_id = 'f76b7bce645f0dd3bcc5f9ccff6a5410'
before2 = len(data['data']['entities'])
data['data']['entities'] = [e for e in data['data']['entities'] if e.get('id') != hac_dup_id]
after2 = len(data['data']['entities'])
reg.write_text(json.dumps(data, indent=2))
print(f"entity_registry: removed {before - after2} ghosts ({after2} remain)")

# restore_state
if rs.exists():
    rs_data = json.loads(rs.read_text())
    before_rs = len(rs_data['data'])
    rs_data['data'] = [
        e for e in rs_data['data']
        if e.get('state', {}).get('entity_id') not in GHOST_ENTITY_IDS
    ]
    after_rs = len(rs_data['data'])
    rs.write_text(json.dumps(rs_data, indent=2))
    print(f"restore_state:   removed {before_rs - after_rs} ghosts ({after_rs} remain)")

print("Done. Start HA now.")
