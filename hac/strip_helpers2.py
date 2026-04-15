import re

# 1. Wipe top-level helper files (entire file = the helper block)
for f in ["/homeassistant/input_datetime.yaml",
          "/homeassistant/timer.yaml",
          "/homeassistant/counter.yaml"]:
    open(f, 'w').close()
    print(f"  Wiped: {f}")

# 2. Comment out !include lines in configuration.yaml
with open("/homeassistant/configuration.yaml", "r") as f:
    lines = f.readlines()
result = []
for line in lines:
    if re.match(r'^(input_datetime|timer|counter):\s*!include', line):
        result.append("# " + line)
        print(f"  Commented: {line.strip()}")
    else:
        result.append(line)
with open("/homeassistant/configuration.yaml", "w") as f:
    f.writelines(result)

# 3. Strip input_datetime: blocks from 4 package files
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

for pkg in ["humidity_smart_alerts.yaml", "kids_bedroom_automation.yaml",
            "garage_door_alerts.yaml", "family_activities.yaml"]:
    strip_top_level_keys(f"/homeassistant/packages/{pkg}", ["input_datetime"])

print("Done.")
