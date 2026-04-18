#!/bin/sh
# Full health check including entity registry area assignment
TOKEN="${SUPERVISOR_TOKEN}"
API="http://supervisor/core/api"

# Get states
STATES=$(curl -s -H "Authorization: Bearer ${TOKEN}" ${API}/states)

# Get entity registry via websocket
python3 << 'PYEOF'
import json, subprocess, sys

# Parse states from stdin-like approach
states_raw = subprocess.run(
    ["curl", "-s", "-H", f"Authorization: Bearer {__import__('os').environ['SUPERVISOR_TOKEN']}",
     "http://supervisor/core/api/states"],
    capture_output=True, text=True
).stdout
states = json.loads(states_raw)

# Domain counts
domains = {}
for e in states:
    d = e['entity_id'].split('.')[0]
    domains[d] = domains.get(d, 0) + 1

# Automation analysis
autos = [e for e in states if e['entity_id'].startswith('automation.')]
ghosts = [e for e in autos if e['attributes'].get('restored', False)]
never = [e for e in autos if not e['attributes'].get('restored', False)
         and (e['attributes'].get('last_triggered') is None
              or e['attributes'].get('last_triggered') == 'None')]

print('=== HEALTH CHECK (FULL) ===')
print(f'Automations: {len(autos)} (active:{len(autos)-len(ghosts)-len(never)} never:{len(never)} ghost:{len(ghosts)})')
print(f'Helpers: {domains.get("input_boolean",0) + domains.get("input_number",0) + domains.get("input_select",0) + domains.get("input_text",0) + domains.get("input_datetime",0) + domains.get("timer",0) + domains.get("counter",0)}')
print(f'Lights: {domains.get("light",0)} | Switches: {domains.get("switch",0)} | Sensors: {domains.get("sensor",0)}')
print(f'Scenes: {domains.get("scene",0)} | Scripts: {domains.get("script",0)}')
print(f'Total entities: {len(states)} across {len(domains)} domains')
print()

# Ghost report
if ghosts:
    print('⚠ GHOSTS:')
    for g in ghosts:
        print(f'  {g["entity_id"]}')
    print()
else:
    print('✅ No ghosts')

# Wrong notify service — grep automation configs
import subprocess as sp
grep_result = sp.run(
    ["grep", "-rl", "john_s_s26_ultra", "/homeassistant/.storage/automations"],
    capture_output=True, text=True
)
if grep_result.stdout.strip():
    print('⚠ WRONG NOTIFY SERVICE (john_s_s26_ultra) found in automation storage')
else:
    # Also check the automations file itself
    grep2 = sp.run(
        ["grep", "-c", "john_s_s26_ultra", "/homeassistant/.storage/automations"],
        capture_output=True, text=True
    )
    count = int(grep2.stdout.strip()) if grep2.stdout.strip().isdigit() else 0
    if count > 0:
        print(f'⚠ WRONG NOTIFY SERVICE: {count} references to john_s_s26_ultra in automations storage')
    else:
        print('✅ Notify service correct (galaxy_s26_ultra)')

# Area-less entities — check entity registry
try:
    with open('/homeassistant/.storage/core.entity_registry', 'r') as f:
        reg = json.load(f)
    entities = reg.get('data', {}).get('entities', [])
    # Check devices for area assignment too
    with open('/homeassistant/.storage/core.device_registry', 'r') as f:
        dev_reg = json.load(f)
    devices = dev_reg.get('data', {}).get('devices', [])
    dev_areas = {d['id']: d.get('area_id') for d in devices}

    arealess = []
    skip_domains = {'automation', 'script', 'scene', 'person', 'zone', 'sun',
                    'persistent_notification', 'conversation', 'tts', 'stt',
                    'update', 'number', 'select', 'button', 'event', 'calendar',
                    'todo', 'image', 'backup', 'assist_pipeline'}
    for ent in entities:
        eid = ent.get('entity_id', '')
        domain = eid.split('.')[0]
        if domain in skip_domains:
            continue
        if ent.get('disabled_by'):
            continue
        ent_area = ent.get('area_id')
        dev_id = ent.get('device_id')
        dev_area = dev_areas.get(dev_id) if dev_id else None
        if not ent_area and not dev_area:
            arealess.append(eid)

    if arealess:
        print(f'\n⚠ AREA-LESS ENTITIES ({len(arealess)} active, non-system):')
        # Group by domain
        by_domain = {}
        for eid in arealess:
            d = eid.split('.')[0]
            by_domain.setdefault(d, []).append(eid)
        for d in sorted(by_domain.keys()):
            print(f'  {d}: {len(by_domain[d])}')
            for eid in by_domain[d][:5]:
                print(f'    {eid}')
            if len(by_domain[d]) > 5:
                print(f'    ...and {len(by_domain[d])-5} more')
    else:
        print('\n✅ All active entities have area assignment')
except Exception as ex:
    print(f'\n⚠ Could not read entity registry: {ex}')

print('\n=== END HEALTH CHECK ===')
PYEOF
