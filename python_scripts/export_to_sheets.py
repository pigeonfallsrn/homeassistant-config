#!/usr/bin/env python3
"""Home Assistant to Google Sheets Direct Export v3.0 - Complete System Export"""
import argparse, json, sys, yaml, requests, subprocess
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict, Counter
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

def get_ha_data():
    """Gather all HA data from API and filesystem"""
    with open('/config/secrets.yaml', 'r') as f:
        token = yaml.safe_load(f).get('ha_api_token', '')
    
    if not token:
        return init_empty_data()
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Initialize data structure
    data = init_empty_data()
    
    # Get all states
    try:
        resp = requests.get("http://localhost:8123/api/states", headers=headers, timeout=10)
        if resp.status_code == 200:
            states = resp.json()
            process_states(data, states)
        else:
            print(f"  ⚠ API returned status {resp.status_code}")
    except Exception as e:
        print(f"  ⚠ Error fetching states: {e}")
    
    # Get config info
    try:
        resp = requests.get("http://localhost:8123/api/config", headers=headers, timeout=10)
        if resp.status_code == 200:
            config = resp.json()
            data['config'] = config
    except Exception as e:
        print(f"  ⚠ Error fetching config: {e}")
    
    # Get error log
    get_error_log(data)
    
    # Get git history
    get_git_history(data)
    
    # Get sessions
    get_sessions(data)
    
    # Calculate analytics
    calculate_automation_analysis(data)
    calculate_token_efficiency(data)
    create_historical_snapshot(data)
    
    return data

def init_empty_data():
    """Initialize empty data structure"""
    return {
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'entities': [],
        'devices': [],
        'areas': [],
        'automations': [],
        'integrations': [],
        'action_items': [],
        'sessions': [],
        'errors': [],
        'git_history': [],
        'automation_analysis': [],
        'historical_snapshots': [],
        'token_efficiency': [],
        'config': {}
    }

def process_states(data, states):
    """Process entity states and build device/area lists"""
    area_stats = defaultdict(lambda: {'entities': 0, 'devices': set(), 'automations': 0, 'temp': None, 'humidity': None, 'motion': False})
    device_map = defaultdict(lambda: {'entities': [], 'area': 'UNASSIGNED', 'manufacturer': '', 'model': '', 'status': 'available'})
    
    for state in states:
        entity_id = state.get('entity_id', '')
        domain = entity_id.split('.')[0]
        attrs = state.get('attributes', {})
        current_state = state.get('state', '')
        
        # Extract area - try multiple methods
        area = 'UNASSIGNED'
        if 'area_id' in attrs:
            area = attrs['area_id']
        elif 'area' in attrs:
            area = attrs['area']
        
        # Build entities list
        entity_data = {
            'entity_id': entity_id,
            'domain': domain,
            'state': current_state,
            'friendly_name': attrs.get('friendly_name', entity_id),
            'area': area,
            'device_class': attrs.get('device_class', ''),
            'last_changed': state.get('last_changed', ''),
            'last_updated': state.get('last_updated', '')
        }
        data['entities'].append(entity_data)
        
        # Track automations
        if domain == 'automation':
            data['automations'].append({
                'entity_id': entity_id,
                'friendly_name': attrs.get('friendly_name', entity_id),
                'state': current_state,
                'last_triggered': attrs.get('last_triggered', 'never'),
                'mode': attrs.get('mode', 'single'),
                'current': attrs.get('current', 0),
                'max': attrs.get('max', 10)
            })
            area_stats[area]['automations'] += 1
        
        # Build area statistics
        area_stats[area]['entities'] += 1
        
        # Track temperature/humidity by area
        if attrs.get('device_class') == 'temperature' and attrs.get('unit_of_measurement') in ['°F', '°C']:
            try:
                temp = float(current_state)
                if area_stats[area]['temp'] is None:
                    area_stats[area]['temp'] = temp
            except:
                pass
        
        if attrs.get('device_class') == 'humidity':
            try:
                humidity = float(current_state)
                if area_stats[area]['humidity'] is None:
                    area_stats[area]['humidity'] = humidity
            except:
                pass
        
        # Track motion
        if attrs.get('device_class') == 'motion' and current_state == 'on':
            area_stats[area]['motion'] = True
        
        # Build device tracking
        device_id = attrs.get('device_id', '')
        if device_id:
            device_map[device_id]['entities'].append(entity_id)
            device_map[device_id]['area'] = area
            if current_state == 'unavailable':
                device_map[device_id]['status'] = 'unavailable'
        
        # Action items - unassigned entities
        if area == 'UNASSIGNED' and domain in ['light', 'switch', 'sensor', 'binary_sensor', 'climate']:
            data['action_items'].append({
                'priority': 'HIGH',
                'entity_id': entity_id,
                'domain': domain,
                'friendly_name': attrs.get('friendly_name', entity_id),
                'issue_type': 'NO_AREA',
                'recommendation': 'Assign to area for better organization'
            })
        
        # Action items - unavailable devices
        if current_state == 'unavailable':
            data['action_items'].append({
                'priority': 'MEDIUM',
                'entity_id': entity_id,
                'domain': domain,
                'friendly_name': attrs.get('friendly_name', entity_id),
                'issue_type': 'UNAVAILABLE',
                'recommendation': 'Check device connectivity or remove if decommissioned'
            })
    
    # Build areas list
    for area_name, stats in area_stats.items():
        data['areas'].append({
            'area_name': area_name,
            'entity_count': stats['entities'],
            'device_count': len(stats['devices']),
            'automation_count': stats['automations'],
            'temperature': f"{stats['temp']:.1f}°F" if stats['temp'] else '',
            'humidity': f"{stats['humidity']:.1f}%" if stats['humidity'] else '',
            'motion_active': 'Yes' if stats['motion'] else 'No'
        })
    
    # Build devices list (simplified - we don't have full device registry access via API)
    domain_counts = Counter(e['domain'] for e in data['entities'])
    for domain, count in domain_counts.most_common(20):
        unavailable_count = len([e for e in data['entities'] if e['domain'] == domain and e['state'] == 'unavailable'])
        data['devices'].append({
            'device_type': domain.title(),
            'count': count,
            'unavailable': unavailable_count,
            'status': 'OK' if unavailable_count == 0 else f'{unavailable_count} unavailable'
        })

def get_error_log(data):
    """Extract last 50 errors from home-assistant.log"""
    try:
        log_file = Path('/config/home-assistant.log')
        if log_file.exists():
            errors = []
            with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if 'ERROR' in line or 'WARNING' in line:
                        errors.append(line.strip())
            
            # Get last 50 errors
            for error in errors[-50:]:
                parts = error.split(None, 3)  # Split on first 3 spaces
                if len(parts) >= 4:
                    timestamp = f"{parts[0]} {parts[1]}"
                    level = parts[2]
                    message = parts[3][:500]  # Truncate long messages
                    data['errors'].append({
                        'timestamp': timestamp,
                        'level': level,
                        'message': message
                    })
    except Exception as e:
        print(f"  Note: Could not read error log: {e}")

def get_git_history(data):
    """Get HAC git commit history"""
    try:
        result = subprocess.run(
            ['git', '-C', '/config/hac', 'log', '--oneline', '-20'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split(None, 1)
                    if len(parts) == 2:
                        data['git_history'].append({
                            'commit': parts[0],
                            'message': parts[1]
                        })
    except Exception as e:
        print(f"  Note: Could not read git history: {e}")

def get_sessions(data):
    """Get HAC session files"""
    try:
        # Check /config/hac/learnings/ for session files
        learnings_dir = Path('/config/hac/learnings')
        if learnings_dir.exists():
            for file in sorted(learnings_dir.glob('session_*.md'), reverse=True)[:20]:
                try:
                    content = file.read_text()
                    lines = content.split('\n')
                    
                    # Extract date from filename
                    date_str = file.stem.replace('session_', '')
                    if len(date_str) >= 8:
                        formatted_date = f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:8]}"
                    else:
                        formatted_date = date_str
                    
                    data['sessions'].append({
                        'date': formatted_date,
                        'file': file.name,
                        'lines': len(lines),
                        'preview': content[:300].replace('\n', ' ')
                    })
                except Exception as e:
                    print(f"  Note: Could not read {file}: {e}")
    except Exception as e:
        print(f"  Note: Could not read sessions: {e}")

def calculate_automation_analysis(data):
    """Analyze automation coverage and patterns"""
    # Domain coverage analysis
    domain_counts = Counter(e['domain'] for e in data['entities'])
    
    for domain, count in domain_counts.most_common(15):
        auto_count = len([a for a in data['automations'] if domain in a['entity_id']])
        
        data['automation_analysis'].append({
            'domain': domain,
            'entity_count': count,
            'automation_count': auto_count,
            'coverage': 'Yes' if auto_count > 0 else 'No',
            'recommendation': 'Good coverage' if auto_count > 0 else 'Consider adding automations'
        })

def calculate_token_efficiency(data):
    """Calculate estimated token usage"""
    # Rough token estimation: 1 token ≈ 4 characters
    entities_size = sum(len(str(e)) for e in data['entities']) // 4
    automations_size = sum(len(str(a)) for a in data['automations']) // 4
    sessions_size = sum(len(s['preview']) for s in data['sessions']) // 4
    
    data['token_efficiency'].append({
        'tab_name': 'Entities',
        'row_count': len(data['entities']),
        'estimated_tokens': entities_size,
        'optimization': 'Use LLM Index for queries'
    })
    
    data['token_efficiency'].append({
        'tab_name': 'Automations',
        'row_count': len(data['automations']),
        'estimated_tokens': automations_size,
        'optimization': 'Filter by domain when querying'
    })
    
    data['token_efficiency'].append({
        'tab_name': 'Sessions',
        'row_count': len(data['sessions']),
        'estimated_tokens': sessions_size,
        'optimization': 'Query by date range'
    })
    
    total_tokens = entities_size + automations_size + sessions_size
    data['token_efficiency'].append({
        'tab_name': 'TOTAL (Full Workbook)',
        'row_count': len(data['entities']) + len(data['automations']) + len(data['sessions']),
        'estimated_tokens': total_tokens,
        'optimization': f'Use LLM Index (~700 tokens) for {int(100 * (1 - 700/max(total_tokens, 1)))}% reduction'
    })

def create_historical_snapshot(data):
    """Create daily snapshot entry"""
    data['historical_snapshots'].append({
        'date': data['timestamp'],
        'total_entities': len(data['entities']),
        'total_automations': len(data['automations']),
        'total_action_items': len(data['action_items']),
        'unavailable_count': len([e for e in data['entities'] if e['state'] == 'unavailable']),
        'areas': len(data['areas']),
        'integrations': len(data['integrations'])
    })

def write_sheets(svc, sid, data):
    """Write all data to Google Sheets"""
    # Map display names to actual sheet names (replace underscores with spaces for display)
    sheet_mapping = {
        'Dashboard': 'Dashboard',
        'Historical Snapshots': 'Historical_Snapshots - Daily entity/automation cou',
        'Error Log': 'Error_Log - Last 50 errors with timestamps',
        'Git History': 'Git_History - HAC commit log',
        'Token Efficiency': 'Token_Efficiency - Track context size over t',
        'Entities': 'Entities',
        'Devices': 'Devices',
        'Areas': 'Areas',
        'Automations': 'Automations',
        'Integrations': 'Integrations',
        'Action Items': 'Action Items',
        'Automation Analysis': 'Automation Analysis',
        'Sessions': 'Sessions'
    }
    
    sheets_data = {
        'Dashboard': format_dashboard(data),
        'Historical Snapshots': format_historical_snapshots(data),
        'Error Log': format_error_log(data),
        'Git History': format_git_history(data),
        'Token Efficiency': format_token_efficiency(data),
        'Entities': format_entities(data),
        'Devices': format_devices(data),
        'Areas': format_areas(data),
        'Automations': format_automations(data),
        'Integrations': format_integrations(data),
        'Action Items': format_action_items(data),
        'Automation Analysis': format_automation_analysis(data),
        'Sessions': format_sessions(data)
    }
    
    for display_name, rows in sheets_data.items():
        sheet_name = sheet_mapping.get(display_name, display_name)
        try:
            # Clear existing data
            svc.spreadsheets().values().clear(
                spreadsheetId=sid,
                range=f"'{sheet_name}'!A:Z"
            ).execute()
            
            # Write new data
            svc.spreadsheets().values().update(
                spreadsheetId=sid,
                range=f"'{sheet_name}'!A1",
                valueInputOption='RAW',
                body={'values': rows}
            ).execute()
            
            print(f"  ✓ {display_name}: {len(rows)} rows")
        except Exception as e:
            print(f"  ⚠ {display_name}: {e}")

def format_dashboard(data):
    return [
        ['HA MASTER CONTEXT v3.0'],
        [''],
        ['Generated:', data['timestamp']],
        [''],
        ['=== SUMMARY ==='],
        ['Total Entities', len(data['entities'])],
        ['Total Automations', len(data['automations'])],
        ['Total Areas', len(data['areas'])],
        ['Total Integrations', len(data['integrations'])],
        ['Action Items', len(data['action_items'])],
        ['Sessions Logged', len(data['sessions'])],
        [''],
        ['=== HEALTH ==='],
        ['Unavailable Entities', len([e for e in data['entities'] if e['state'] == 'unavailable'])],
        ['Recent Errors', len(data['errors'])],
        ['Git Commits', len(data['git_history'])],
    ]

def format_historical_snapshots(data):
    return [
        ['Date', 'Entities', 'Automations', 'Action Items', 'Unavailable', 'Areas', 'Integrations']
    ] + [
        [s['date'], s['total_entities'], s['total_automations'], s['total_action_items'], 
         s['unavailable_count'], s['areas'], s['integrations']]
        for s in data['historical_snapshots']
    ]

def format_error_log(data):
    return [
        ['Timestamp', 'Level', 'Message']
    ] + [
        [e['timestamp'], e['level'], e['message']]
        for e in data['errors']
    ]

def format_git_history(data):
    return [
        ['Commit', 'Message']
    ] + [
        [g['commit'], g['message']]
        for g in data['git_history']
    ]

def format_token_efficiency(data):
    return [
        ['Tab Name', 'Row Count', 'Estimated Tokens', 'Optimization']
    ] + [
        [t['tab_name'], t['row_count'], t['estimated_tokens'], t['optimization']]
        for t in data['token_efficiency']
    ]

def format_entities(data):
    return [
        ['entity_id', 'domain', 'state', 'friendly_name', 'area', 'device_class', 'last_changed']
    ] + [
        [e['entity_id'], e['domain'], e['state'], e['friendly_name'], e['area'], 
         e['device_class'], e['last_changed']]
        for e in sorted(data['entities'], key=lambda x: (x['area'], x['domain']))
    ]

def format_devices(data):
    return [
        ['Device Type', 'Count', 'Unavailable', 'Status']
    ] + [
        [d['device_type'], d['count'], d['unavailable'], d['status']]
        for d in data['devices']
    ]

def format_areas(data):
    return [
        ['Area Name', 'Entity Count', 'Device Count', 'Automation Count', 'Temperature', 'Humidity', 'Motion Active']
    ] + [
        [a['area_name'], a['entity_count'], a['device_count'], a['automation_count'],
         a['temperature'], a['humidity'], a['motion_active']]
        for a in sorted(data['areas'], key=lambda x: x['area_name'])
    ]

def format_automations(data):
    return [
        ['entity_id', 'friendly_name', 'state', 'last_triggered', 'mode', 'current', 'max']
    ] + [
        [a['entity_id'], a['friendly_name'], a['state'], a['last_triggered'], 
         a['mode'], a['current'], a['max']]
        for a in data['automations']
    ]

def format_integrations(data):
    return [
        ['Domain', 'Entity Count', 'Service Count', 'Status']
    ] + [
        [i['domain'], i['entity_count'], i['service_count'], i['status']]
        for i in sorted(data['integrations'], key=lambda x: -x['entity_count'])
    ]

def format_action_items(data):
    return [
        ['Priority', 'Entity', 'Domain', 'Name', 'Issue', 'Recommendation']
    ] + [
        [i['priority'], i['entity_id'], i['domain'], i['friendly_name'], 
         i['issue_type'], i['recommendation']]
        for i in data['action_items']
    ]

def format_automation_analysis(data):
    return [
        ['Domain', 'Entity Count', 'Automation Count', 'Coverage', 'Recommendation']
    ] + [
        [a['domain'], a['entity_count'], a['automation_count'], a['coverage'], a['recommendation']]
        for a in data['automation_analysis']
    ]

def format_sessions(data):
    return [
        ['Date', 'File', 'Lines', 'Preview']
    ] + [
        [s['date'], s['file'], s['lines'], s['preview']]
        for s in data['sessions']
    ]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--spreadsheet-id', required=True)
    args = parser.parse_args()
    
    print("=" * 70)
    print("HA Master Context Export v3.0")
    print("=" * 70)
    
    # Authenticate
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, 
        scopes=SCOPES
    )
    svc = build('sheets', 'v4', credentials=creds)
    print("✓ Auth successful")
    
    # Gather data
    data = get_ha_data()
    print(f"✓ Gathered: {len(data['entities'])} entities, {len(data['automations'])} automations, "
          f"{len(data['areas'])} areas, {len(data['integrations'])} integrations")
    
    # Write to sheets
    write_sheets(svc, args.spreadsheet_id, data)
    
    print(f"✓ Complete: https://docs.google.com/spreadsheets/d/{args.spreadsheet_id}")
    print("=" * 70)

if __name__ == '__main__':
    main()
