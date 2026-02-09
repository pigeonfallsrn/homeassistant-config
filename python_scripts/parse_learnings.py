#!/usr/bin/env python3
"""
Parse HAC learnings from /config/hac/learnings/ and session files
"""

import re
import os
from datetime import datetime
from pathlib import Path

def categorize_learning(text):
    """Auto-categorize learning based on keywords"""
    text_lower = text.lower()
    
    categories = {
        'Automation': ['automation', 'trigger', 'condition', 'action', 'mode:', 'restart'],
        'Lighting': ['light', 'brightness', 'hue', 'adaptive', 'bulb', 'dimmer', 'inovelli'],
        'Integration': ['sheets', 'export', 'integration', 'api', 'google', 'mcp', 'gemini'],
        'Presence': ['motion', 'presence', 'tracker', 'occupancy', 'home', 'away', 'arriving'],
        'Climate': ['climate', 'temperature', 'thermostat', 'nest', 'hvac', 'heat', 'cool'],
        'Garage': ['garage', 'ratgdo', 'door opener', 'bay'],
        'Network': ['unifi', 'wifi', 'network', 'ap', 'router'],
        'Device': ['device', 'sensor', 'switch', 'plug'],
        'System': ['hac', 'backup', 'git', 'commit', 'config', 'cleanup'],
        'Area': ['area', 'room', 'zone', 'floor', 'renamed'],
    }
    
    for category, keywords in categories.items():
        if any(keyword in text_lower for keyword in keywords):
            return category
    
    return 'General'

def extract_tags(text):
    """Extract relevant tags from learning text"""
    text_lower = text.lower()
    tags = []
    
    tag_keywords = [
        'garage', 'kitchen', 'bedroom', 'bathroom', 'living room', 'upstairs',
        'hue', 'inovelli', 'adaptive lighting', 'motion', 'presence',
        'automation', 'sheets', 'google', 'gemini', 'ratgdo',
        'nest', 'thermostat', 'unifi', 'backup', 'git', 'cleanup',
        'timeout', 'brightness', 'dimming'
    ]
    
    for keyword in tag_keywords:
        if keyword in text_lower:
            tags.append(keyword)
    
    return tags[:5]

def parse_learning_file(filepath):
    """Parse a single learning file"""
    learnings = []
    
    # Extract date from filename (YYYYMMDD format)
    filename = Path(filepath).stem
    date_match = re.search(r'(\d{8})', filename)
    
    if date_match:
        date_str = date_match.group(1)
        file_date = f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:8]}"
    else:
        file_date = datetime.now().strftime('%Y-%m-%d')
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return learnings
    
    # Parse lines with format: "- HH:MM: Learning text"
    for line in content.split('\n'):
        line = line.strip()
        
        if not line:
            continue
        
        # Match: "- 09:41: Learning text"
        match = re.search(r'^-\s*(\d{1,2}):(\d{2}):\s*(.+)$', line)
        
        if match:
            hour, minute, learning_text = match.groups()
            timestamp = f"{file_date} {hour.zfill(2)}:{minute}"
            
            category = categorize_learning(learning_text)
            tags = extract_tags(learning_text)
            
            learnings.append({
                'timestamp': timestamp,
                'date': file_date,
                'time': f"{hour.zfill(2)}:{minute}",
                'category': category,
                'learning': learning_text,
                'tags': ', '.join(tags) if tags else '',
                'source': 'Session',
                'file': Path(filepath).name
            })
    
    return learnings

def parse_all_learnings(learnings_dir='/config/hac/learnings'):
    """Parse all learning files in directory"""
    all_learnings = []
    
    if not os.path.exists(learnings_dir):
        print(f"Warning: {learnings_dir} not found")
        return all_learnings
    
    # Get all .md files
    learning_files = sorted(Path(learnings_dir).glob('*.md'))
    
    print(f"Found {len(learning_files)} learning files")
    
    for filepath in learning_files:
        learnings = parse_learning_file(filepath)
        all_learnings.extend(learnings)
    
    # Sort by timestamp
    all_learnings.sort(key=lambda x: x['timestamp'])
    
    return all_learnings

def get_learning_stats(learnings):
    """Generate statistics about learnings"""
    stats = {
        'total': len(learnings),
        'by_category': {},
        'top_tags': {},
        'by_date': {}
    }
    
    for learning in learnings:
        # Count by category
        cat = learning['category']
        stats['by_category'][cat] = stats['by_category'].get(cat, 0) + 1
        
        # Count by date
        date = learning['date']
        stats['by_date'][date] = stats['by_date'].get(date, 0) + 1
        
        # Count tags
        if learning['tags']:
            for tag in learning['tags'].split(', '):
                stats['top_tags'][tag] = stats['top_tags'].get(tag, 0) + 1
    
    return stats

if __name__ == "__main__":
    print("=" * 60)
    print("HAC LEARNINGS PARSER TEST")
    print("=" * 60)
    
    learnings = parse_all_learnings()
    print(f"\n✓ Parsed {len(learnings)} total learnings")
    
    if learnings:
        print(f"\nDate range: {learnings[0]['date']} to {learnings[-1]['date']}")
        
        print("\n--- First 5 learnings ---")
        for l in learnings[:5]:
            print(f"  {l['timestamp']} [{l['category']:12}] {l['learning'][:60]}...")
        
        print("\n--- Last 5 learnings ---")
        for l in learnings[-5:]:
            print(f"  {l['timestamp']} [{l['category']:12}] {l['learning'][:60]}...")
        
        stats = get_learning_stats(learnings)
        
        print(f"\n--- Statistics ---")
        print(f"Total learnings: {stats['total']}")
        print(f"\nBy Category:")
        for cat, count in sorted(stats['by_category'].items(), key=lambda x: x[1], reverse=True):
            print(f"  {cat:15} {count:3}")
        
        print(f"\nTop Tags:")
        for tag, count in sorted(stats['top_tags'].items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {tag:20} {count:3}")
        
        print(f"\nLearnings per date (last 7 days):")
        for date, count in sorted(stats['by_date'].items())[-7:]:
            print(f"  {date}: {count}")
