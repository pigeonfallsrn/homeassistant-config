import json

# Read registries directly — no API needed
with open("/config/.storage/core.entity_registry") as f:
    ereg = json.load(f)
with open("/config/.storage/core.device_registry") as f:
    dreg = json.load(f)

entities = ereg.get("data", {}).get("entities", [])
devices = dreg.get("data", {}).get("devices", [])
dev_areas = {d["id"]: d.get("area_id") for d in devices}

# Domain counts from entity registry
domains = {}
disabled_count = 0
for ent in entities:
    eid = ent.get("entity_id", "")
    d = eid.split(".")[0]
    if ent.get("disabled_by"):
        disabled_count += 1
        continue
    domains[d] = domains.get(d, 0) + 1

# Automation count from automations storage
try:
    with open("/config/.storage/automations") as f:
        afile = json.load(f)
    auto_items = afile.get("data", {}).get("items", [])
    auto_total = len(auto_items)
except Exception:
    auto_total = domains.get("automation", 0)

helpers = sum(domains.get(d, 0) for d in ["input_boolean","input_number","input_select","input_text","input_datetime","timer","counter"])

print("=== HEALTH CHECK ===")
print(f"Automations: {auto_total}")
print(f"Helpers: {helpers}")
print(f"Lights: {domains.get('light',0)} | Switches: {domains.get('switch',0)} | Sensors: {domains.get('sensor',0)} | Binary: {domains.get('binary_sensor',0)}")
print(f"Scenes: {domains.get('scene',0)} | Scripts: {domains.get('script',0)}")
total_active = sum(domains.values())
print(f"Total: {total_active} active entities ({disabled_count} disabled) across {len(domains)} domains")
print()

# Wrong notify check
try:
    with open("/config/.storage/automations") as f:
        content = f.read()
    cnt = content.count("john_s_s26_ultra")
    if cnt > 0:
        print(f"!! WRONG NOTIFY: {cnt} refs to john_s_s26_ultra")
    else:
        print("OK Notify service correct (galaxy_s26_ultra)")
except Exception:
    print("?? Could not check notify service")

# Area-less entities
skip = {"automation","script","scene","person","zone","sun","persistent_notification",
        "conversation","tts","stt","update","button","event","calendar","todo",
        "image","backup","assist_pipeline","weather","tag","device_tracker","number","select"}
arealess = []
for ent in entities:
    eid = ent.get("entity_id", "")
    dom = eid.split(".")[0]
    if dom in skip or ent.get("disabled_by"):
        continue
    if not ent.get("area_id") and not dev_areas.get(ent.get("device_id")):
        arealess.append(eid)

if arealess:
    by_dom = {}
    for eid in arealess:
        d = eid.split(".")[0]
        by_dom.setdefault(d, []).append(eid)
    print(f"\n!! AREA-LESS ({len(arealess)} active, non-system):")
    for d in sorted(by_dom):
        print(f"  {d}: {len(by_dom[d])}")
        for eid in by_dom[d][:3]:
            print(f"    {eid}")
        if len(by_dom[d]) > 3:
            print(f"    ...+{len(by_dom[d])-3} more")
else:
    print("\nOK All active entities have area assignment")

print("\n=== END HEALTH CHECK ===")
