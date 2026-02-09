#!/usr/bin/env python3
"""Generate summary statistics for dashboard"""

import sys
import json
import csv
from pathlib import Path

def count_csv_rows(filepath):
    """Count rows in CSV (excluding header)"""
    try:
        with open(filepath, 'r') as f:
            return sum(1 for _ in f) - 1
    except:
        return 0

def analyze_entities(temp_dir):
    """Analyze entity breakdown"""
    entities_file = Path(temp_dir) / 'entities.csv'
    
    stats = {
        'total': 0,
        'unassigned': 0,
        'by_domain': {},
        'physical_unassigned': 0
    }
    
    physical_domains = {'light', 'switch', 'sensor', 'binary_sensor', 'climate', 'cover', 'fan'}
    
    with open(entities_file, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 8:
                continue
            
            entity_id = row[0]
            area_id = row[2]
            domain = row[7]
            
            stats['total'] += 1
            
            if area_id == 'UNASSIGNED':
                stats['unassigned'] += 1
                if domain in physical_domains:
                    stats['physical_unassigned'] += 1
            
            stats['by_domain'][domain] = stats['by_domain'].get(domain, 0) + 1
    
    return stats

def main():
    if len(sys.argv) < 2:
        print("Usage: generate_stats.py <temp_dir>", file=sys.stderr)
        sys.exit(1)
    
    temp_dir = sys.argv[1]
    
    stats = {
        'entity_count': count_csv_rows(Path(temp_dir) / 'entities.csv'),
        'device_count': count_csv_rows(Path(temp_dir) / 'devices.csv'),
        'area_count': count_csv_rows(Path(temp_dir) / 'areas.csv'),
        'automation_count': count_csv_rows(Path(temp_dir) / 'automations.csv'),
        'action_items': count_csv_rows(Path(temp_dir) / 'action_items.csv'),
        'entity_analysis': analyze_entities(temp_dir)
    }
    
    print(json.dumps(stats, indent=2))

if __name__ == '__main__':
    main()
