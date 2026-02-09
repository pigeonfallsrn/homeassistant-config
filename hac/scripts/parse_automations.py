#!/usr/bin/env python3
"""Parse automations.yaml into CSV format"""

import yaml
import csv
import sys
from datetime import datetime

def count_entities(obj, entity_list=None):
    """Recursively count entity references"""
    if entity_list is None:
        entity_list = set()
    
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key == 'entity_id':
                if isinstance(value, str):
                    entity_list.add(value)
                elif isinstance(value, list):
                    entity_list.update(value)
            count_entities(value, entity_list)
    elif isinstance(obj, list):
        for item in obj:
            count_entities(item, entity_list)
    
    return entity_list

def parse_triggers(automation):
    """Extract trigger types"""
    triggers = automation.get('triggers', automation.get('trigger', []))
    if not isinstance(triggers, list):
        triggers = [triggers]
    
    trigger_types = []
    for t in triggers:
        if isinstance(t, dict):
            trigger_types.append(t.get('platform', t.get('trigger', 'unknown')))
    
    return ';'.join(trigger_types) if trigger_types else 'none'

def main():
    writer = csv.writer(sys.stdout)
    writer.writerow([
        'id', 'alias', 'description', 'trigger_types', 
        'entity_count', 'file_location', 'mode'
    ])
    
    try:
        with open('/homeassistant/automations.yaml', 'r') as f:
            automations = yaml.safe_load(f) or []
        
        for auto in automations:
            entities = count_entities(auto)
            writer.writerow([
                auto.get('id', 'NO_ID'),
                auto.get('alias', 'UNNAMED'),
                auto.get('description', '')[:100],  # Truncate long descriptions
                parse_triggers(auto),
                len(entities),
                'automations.yaml',
                auto.get('mode', 'single')
            ])
    
    except Exception as e:
        print(f"Error parsing automations: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
