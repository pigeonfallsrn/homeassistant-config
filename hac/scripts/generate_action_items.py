#!/usr/bin/env python3
"""Generate action items for entities needing attention"""

import json
import csv
import sys

# Physical entity domains that SHOULD have areas
PHYSICAL_DOMAINS = {
    'light', 'switch', 'cover', 'fan', 'climate', 'lock',
    'binary_sensor', 'sensor', 'camera', 'media_player',
    'vacuum', 'humidifier', 'water_heater'
}

# Domains that don't need areas (virtual/service entities)
VIRTUAL_DOMAINS = {
    'person', 'calendar', 'tts', 'todo', 'weather', 'sun',
    'zone', 'automation', 'script', 'scene', 'input_boolean',
    'input_number', 'input_text', 'input_select', 'input_datetime',
    'timer', 'counter', 'group', 'alert', 'persistent_notification'
}

def main():
    writer = csv.writer(sys.stdout)
    writer.writerow([
        'entity_id', 'domain', 'friendly_name', 'platform',
        'issue_type', 'priority', 'recommendation'
    ])
    
    try:
        with open('/homeassistant/.storage/core.entity_registry', 'r') as f:
            registry = json.load(f)
        
        for entity in registry['data']['entities']:
            entity_id = entity.get('entity_id', '')
            domain = entity_id.split('.')[0] if '.' in entity_id else 'unknown'
            area_id = entity.get('area_id')
            device_id = entity.get('device_id')
            disabled = entity.get('disabled_by')
            platform = entity.get('platform', 'unknown')
            name = entity.get('original_name', entity_id)
            
            # Skip disabled entities
            if disabled:
                continue
            
            # Skip virtual entities
            if domain in VIRTUAL_DOMAINS:
                continue
            
            # Physical entity without area
            if domain in PHYSICAL_DOMAINS and not area_id:
                priority = 'HIGH' if domain in ['light', 'switch', 'climate'] else 'MEDIUM'
                writer.writerow([
                    entity_id,
                    domain,
                    name,
                    platform,
                    'NO_AREA_ASSIGNED',
                    priority,
                    'Assign to appropriate area for organization'
                ])
            
            # Entity without device (orphaned)
            elif not device_id and domain in PHYSICAL_DOMAINS:
                writer.writerow([
                    entity_id,
                    domain,
                    name,
                    platform,
                    'NO_DEVICE',
                    'LOW',
                    'Review if this entity is still needed'
                ])
    
    except Exception as e:
        print(f"Error generating action items: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
