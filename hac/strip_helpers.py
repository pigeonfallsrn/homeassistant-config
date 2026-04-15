import re
def strip_top_level_keys(filepath, keys):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    result = []
    in_block = False
    removed = []
    for line in lines:
        matched_key = next((k for k in keys if re.match(r'^' + re.escape(k) + r':', line)), None)
        if matched_key:
            in_block = True
            removed.append(matched_key)
            continue
        if in_block:
            if line.strip() and not line.startswith(' ') and not line.startswith('\t') and not line.startswith('#'):
                in_block = False
                result.append(line)
        else:
            result.append(line)
    with open(filepath, 'w') as f:
        f.writelines(result)
    print(f"  {filepath}: stripped {removed}")
targets = [
    ("/homeassistant/packages/ella_living_room.yaml",                ["input_select"]),
    ("/homeassistant/packages/occupancy_system.yaml",                ["input_select"]),
    ("/homeassistant/packages/kitchen_tablet_dashboard.yaml",        ["input_select"]),
    ("/homeassistant/packages/adaptive_lighting_entry_lamp.yaml",    ["input_number"]),
    ("/homeassistant/packages/family_activities.yaml",               ["input_number", "input_text"]),
    ("/homeassistant/packages/garage_lighting_automation_fixed.yaml",["input_number"]),
]
for path, keys in targets:
    strip_top_level_keys(path, keys)
print("Done.")
