#!/usr/bin/env python3
"""
HAC Automation Counter - Accurate count across all sources
"""
import os
import json
import yaml

def count_automations():
    sources = {
        'packages/': {'count': 0, 'files': []},
        'automations/': {'count': 0, 'files': []},
        'automations.yaml': {'count': 0, 'files': []},
        'configuration.yaml': {'count': 0, 'files': []},
    }
    
    total = 0
    
    # Count packages/
    if os.path.exists('/homeassistant/packages'):
        for file in os.listdir('/homeassistant/packages'):
            if file.endswith('.yaml') and not file.endswith('.bak'):
                try:
                    with open(f'/homeassistant/packages/{file}') as f:
                        count = f.read().count('alias:')
                        if count > 0:
                            sources['packages/']['count'] += count
                            sources['packages/']['files'].append(f"{file}: {count}")
                            total += count
                except:
                    pass
    
    # Count automations/
    if os.path.exists('/homeassistant/automations'):
        for file in os.listdir('/homeassistant/automations'):
            if file.endswith('.yaml'):
                try:
                    with open(f'/homeassistant/automations/{file}') as f:
                        count = f.read().count('alias:')
                        if count > 0:
                            sources['automations/']['count'] += count
                            sources['automations/']['files'].append(f"{file}: {count}")
                            total += count
                except:
                    pass
    
    # Count automations.yaml
    try:
        with open('/homeassistant/automations.yaml') as f:
            count = f.read().count('alias:')
            sources['automations.yaml']['count'] = count
            total += count
    except:
        pass
    
    # Count configuration.yaml inline
    try:
        with open('/homeassistant/configuration.yaml') as f:
            content = f.read()
            # Count only in automation: section
            if 'automation:' in content:
                count = content.split('automation:')[1].split('\n\n')[0].count('alias:')
                sources['configuration.yaml']['count'] = count
                total += count
    except:
        pass
    
    # Print results
    print(f"╔{'═'*60}╗")
    print(f"║  HAC Automation Counter - Accurate Analysis{' '*17}║")
    print(f"╚{'═'*60}╝\n")
    
    for source, data in sources.items():
        if data['count'] > 0:
            pct = (data['count'] / total * 100) if total > 0 else 0
            print(f"{source:20s} {data['count']:3d} automations ({pct:5.1f}%)")
            if data['files'] and len(data['files']) <= 5:
                for f in data['files']:
                    print(f"  • {f}")
            elif data['files']:
                print(f"  • {len(data['files'])} files")
    
    print(f"\n{'Total:':20s} {total:3d} automations")
    
    # Compare with entity registry
    try:
        with open('/homeassistant/.storage/core.entity_registry') as f:
            registry = json.load(f)
        entity_count = len([e for e in registry['data']['entities'] 
                           if e['entity_id'].startswith('automation.')])
        
        diff = entity_count - total
        print(f"{'Entity registry:':20s} {entity_count:3d} entities")
        if diff > 0:
            print(f"\nNote: {diff} additional entities may be disabled/orphaned/deleted")
    except:
        pass

if __name__ == '__main__':
    count_automations()
