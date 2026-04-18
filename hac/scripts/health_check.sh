#!/bin/sh
curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/core/api/states | python3 -c "
import sys, json

states = json.load(sys.stdin)

# Domain counts
domains = {}
for e in states:
    d = e['entity_id'].split('.')[0]
    domains[d] = domains.get(d, 0) + 1

# Automation analysis
autos = [e for e in states if e['entity_id'].startswith('automation.')]
ghosts = [e for e in autos if e['attributes'].get('restored', False)]
never = [e for e in autos if not e['attributes'].get('restored', False) and (e['attributes'].get('last_triggered') is None or e['attributes'].get('last_triggered') == 'None')]
active = len(autos) - len(ghosts) - len(never)

print('=== HEALTH CHECK ===')
print(f'Automations: {len(autos)} (active:{active} never:{len(never)} ghost:{len(ghosts)})')
print(f'Helpers: {domains.get(\"input_boolean\",0) + domains.get(\"input_number\",0) + domains.get(\"input_select\",0) + domains.get(\"input_text\",0) + domains.get(\"input_datetime\",0) + domains.get(\"timer\",0) + domains.get(\"counter\",0)}')
print(f'Lights: {domains.get(\"light\",0)} | Switches: {domains.get(\"switch\",0)} | Sensors: {domains.get(\"sensor\",0)} | Binary: {domains.get(\"binary_sensor\",0)}')
print(f'Scenes: {domains.get(\"scene\",0)} | Scripts: {domains.get(\"script\",0)}')
print()

# Wrong notify service check
wrong_notify = []
for a in autos:
    friendly = a['attributes'].get('friendly_name', '')
    eid = a['entity_id']
    # We can only check state-level attributes; full config needs REST /api/config/automation/config/
    # This is a heuristic — full check needs terminal grep

# Ghost check
if ghosts:
    print('⚠ GHOSTS FOUND:')
    for g in ghosts:
        print(f'  {g[\"entity_id\"]}')
    print()

# Entities with no area (via entity registry — need separate call)
print('(Area-less entity check requires entity registry dump — run separately)')
print()

# Summary
if not ghosts:
    print('✅ No ghosts')
print(f'📊 Total entities: {len(states)}')
print(f'📊 Total domains: {len(domains)}')
"
