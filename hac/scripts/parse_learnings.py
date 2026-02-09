#!/usr/bin/env python3
"""Extract HAC learnings metadata"""

import os
import csv
import sys
import re
from datetime import datetime

def main():
    writer = csv.writer(sys.stdout)
    writer.writerow(['date', 'filename', 'project', 'file_path', 'size_kb'])
    
    learnings_dir = '/homeassistant/hac/learnings'
    
    if not os.path.exists(learnings_dir):
        return
    
    for filename in sorted(os.listdir(learnings_dir)):
        if not filename.endswith('.md'):
            continue
        
        filepath = os.path.join(learnings_dir, filename)
        
        # Extract date from filename (YYYYMMDD.md)
        date_match = re.match(r'(\d{8})\.md', filename)
        date_str = date_match.group(1) if date_match else 'UNKNOWN'
        
        # Get first line as project title
        try:
            with open(filepath, 'r') as f:
                first_line = f.readline().strip().replace('#', '').strip()
                project = first_line[:100] if first_line else 'Untitled'
        except:
            project = 'Error reading file'
        
        size_kb = os.path.getsize(filepath) / 1024
        
        writer.writerow([
            date_str,
            filename,
            project,
            filepath,
            f"{size_kb:.2f}"
        ])

if __name__ == '__main__':
    main()
