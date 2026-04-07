import os
pkg = "/homeassistant/packages"
files = [
"adaptive_lighting_entry_lamp.yaml","lighting_motion_firstfloor.yaml",
"garage_arrival_optimized.yaml","upstairs_lighting.yaml",
"garage_door_alerts.yaml","family_activities.yaml",
"entry_room_ceiling_motion.yaml","humidity_smart_alerts.yaml",
"ella_living_room.yaml","occupancy_system.yaml",
"notifications_system.yaml","kitchen_tablet_dashboard.yaml",
"garage_quick_open.yaml","lights_auto_off_safety.yaml",
"garage_notifications_consolidated.yaml","garage_lighting_automation_fixed.yaml",
"kids_bedroom_automation.yaml"]
total = 0
for fn in files:
    path = os.path.join(pkg, fn)
    with open(path) as f:
        lines = f.readlines()
    filtered = [l for l in lines if not l.lstrip().startswith("unique_id: auto_")]
    removed = len(lines) - len(filtered)
    if removed:
        with open(path, "w") as f:
            f.writelines(filtered)
        print(f"{fn}: removed {removed}")
    total += removed
print(f"Total removed: {total}")
