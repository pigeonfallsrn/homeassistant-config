import json

with open('.storage/core.entity_registry', 'r') as f:
    registry = json.load(f)

# Enable car-related sensors
car_sensors = [
    'sensor.john_s_phone_car_name',
    'sensor.john_s_phone_car_battery',
    'sensor.john_s_phone_car_charging_status'
]

for entity in registry['data']['entities']:
    if entity['entity_id'] in car_sensors:
        entity['disabled_by'] = None
        print(f"Enabled: {entity['entity_id']}")

with open('.storage/core.entity_registry', 'w') as f:
    json.dump(registry, f, indent=2)
