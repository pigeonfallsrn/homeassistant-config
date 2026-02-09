#!/usr/bin/env python3
"""Home Assistant to Google Sheets Dual Export v4.0
Exports to BOTH:
1. Master Workbook (full data, all tabs)
2. LLM Index Workbook (token-efficient summaries)
"""
import argparse, json, sys, yaml, requests, subprocess
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict, Counter
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

# Workbook IDs
MASTER_WORKBOOK_ID = "11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w"
LLM_INDEX_WORKBOOK_ID = "1zqHimElloqzVLacx_LH8NqZ9XKZ75APsE9EPiIGd3Gk"

def load_registries():
    """Load entity, device, and area registries"""
    registries = {'entities': {}, 'devices': {}, 'areas': {}}
    
    try:
        with open('/config/.storage/core.entity_registry', 'r') as f:
            entity_reg = json.load(f)
            for entity in entity_reg.get('data', {}).get('entities', []):
                registries['entities'][entity['entity_id']] = {
                    'area_id': entity.get('area_id'),
                    'device_id': entity.get('device_id'),
                    'platform': entity.get('platform'),
                    'disabled': entity.get('disabled_by') is not None
                }
    except Exception as e:
        print(f"  Note: Could not load entity registry: {e}")
    
    try:
        with open('/config/.storage/core.device_registry', 'r') as f:
            device_reg = json.load(f)
            for device in device_reg.get('data', {}).get('devices', []):
                registries['devices'][device['id']] = {
                    'area_id': device.get('area_id'),
                    'name': device.get('name_by_user') or device.get('name', 'Unknown'),
                    'manufacturer': device.get('manufacturer', ''),
                    'model': device.get('model', ''),
                    'disabled': device.get('disabled_by') is not None
                }
    except Exception as e:
        print(f"  Note: Could not load device registry: {e}")
    
    try:
        with open('/config/.storage/core.area_registry', 'r') as f:
            area_reg = json.load(f)
            for area in area_reg.get('data', {}).get('areas', []):
                registries['areas'][area['id']] = {
                    'name': area.get('name', 'Unknown'),
                    'aliases': area.get('aliases', [])
                }
    except Exception as e:
        print(f"  Note: Could not load area registry: {e}")
    
    return registries

def get_ha_data():
    """Gather all HA data"""
    with open('/config/secrets.yaml', 'r') as f:
        token = yaml.safe_load(f).get('ha_api_token', '')
    
    if not token:
        return init_empty_data()
    
    headers = {"Authorization": f"Bearer {token}"}
    registries = load_registries()
    data = init_empty_data()
    
    try:
        resp = requests.get("http://localhost:8123/api/states", headers=headers, timeout=10)
        if resp.status_code == 200:
            states = resp.json()
            process_states(data, states, registries)
    except Exception as e:
        print(f"  ⚠ Error fetching states: {e}")
    
    process_integrations_from_registry(data, registries)
    get_error_log(data)
    get_git_history(data)
    get_sessions(data)
    calculate_automation_analysis(data)
    calculate_token_efficiency(data)
    create_historical_snapshot(data)
    
    return data

def init_empty_data():
    return {
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'entities': [], 'devices': [], 'areas': [], 'automations': [],
        'integrations': [], 'action_items': [], 'sessions': [], 'errors': [],
        'git_history': [], 'automation_analysis': [], 'historical_snapshots': [],
        'token_efficiency': [], 'config': {}
    }

def process_states(data, states, registries):
    """Process states and build data structures"""
    area_stats = defaultdict(lambda: {'entities': 0, 'devices': set(), 'automations': 0, 'temp': None, 'humidity': None, 'motion': False})
    
    for state in states:
        entity_id = state.get('entity_id', '')
        domain = entity_id.split('.')[0]
        attrs = state.get('attributes', {})
        current_state = state.get('state', '')
        
        entity_reg = registries['entities'].get(entity_id, {})
        area_id = entity_reg.get('area_id')
        device_id = entity_reg.get('device_id')
        
        if not area_id and device_id:
            device_reg = registries['devices'].get(device_id, {})
            area_id = device_reg.get('area_id')
        
        area_name = 'UNASSIGNED'
        if area_id:
            area_info = registries['areas'].get(area_id, {})
            area_name = area_info.get('name', area_id)
        
        entity_data = {
            'entity_id': entity_id, 'domain': domain, 'state': current_state,
            'friendly_name': attrs.get('friendly_name', entity_id), 'area': area_name,
            'device_class': attrs.get('device_class', ''), 'last_changed': state.get('last_changed', ''),
            'platform': entity_reg.get('platform', ''), 'disabled': entity_reg.get('disabled', False)
        }
        data['entities'].append(entity_data)
        
        if domain == 'automation':
            data['automations'].append({
                'entity_id': entity_id, 'friendly_name': attrs.get('friendly_name', entity_id),
                'state': current_state, 'last_triggered': attrs.get('last_triggered', 'never'),
                'mode': attrs.get('mode', 'single'), 'current': attrs.get('current', 0),
                'max': attrs.get('max', 10)
            })
            area_stats[area_name]['automations'] += 1
        
        area_stats[area_name]['entities'] += 1
        if device_id:
            area_stats[area_name]['devices'].add(device_id)
        
        if attrs.get('device_class') == 'temperature' and attrs.get('unit_of_measurement') in ['°F', '°C']:
            try:
                temp = float(current_state)
                if area_stats[area_name]['temp'] is None:
                    area_stats[area_name]['temp'] = temp
            except: pass
        
        if attrs.get('device_class') == 'humidity':
            try:
                humidity = float(current_state)
                if area_stats[area_name]['humidity'] is None:
                    area_stats[area_name]['humidity'] = humidity
            except: pass
        
        if attrs.get('device_class') == 'motion' and current_state == 'on':
            area_stats[area_name]['motion'] = True
        
        if area_name == 'UNASSIGNED' and domain in ['light', 'switch', 'sensor', 'binary_sensor', 'climate']:
            data['action_items'].append({
                'priority': 'HIGH', 'entity_id': entity_id, 'domain': domain,
                'friendly_name': attrs.get('friendly_name', entity_id),
                'issue_type': 'NO_AREA', 'recommendation': 'Assign to area'
            })
        
        if current_state == 'unavailable':
            data['action_items'].append({
                'priority': 'MEDIUM', 'entity_id': entity_id, 'domain': domain,
                'friendly_name': attrs.get('friendly_name', entity_id),
                'issue_type': 'UNAVAILABLE', 'recommendation': 'Check connectivity'
            })
    
    for area_name, stats in area_stats.items():
        data['areas'].append({
            'area_name': area_name, 'entity_count': stats['entities'],
            'device_count': len(stats['devices']), 'automation_count': stats['automations'],
            'temperature': f"{stats['temp']:.1f}°F" if stats['temp'] else '',
            'humidity': f"{stats['humidity']:.1f}%" if stats['humidity'] else '',
            'motion_active': 'Yes' if stats['motion'] else 'No'
        })
    
    device_area_map = defaultdict(list)
    for entity_id, entity_reg in registries['entities'].items():
        device_id = entity_reg.get('device_id')
        if device_id:
            device_area_map[device_id].append(entity_id)
    
    for device_id, device_info in registries['devices'].items():
        entity_count = len(device_area_map.get(device_id, []))
        if entity_count > 0:
            area_id = device_info.get('area_id')
            area_name = 'UNASSIGNED'
            if area_id:
                area_info = registries['areas'].get(area_id, {})
                area_name = area_info.get('name', area_id)
            
            data['devices'].append({
                'device_name': device_info['name'], 'manufacturer': device_info['manufacturer'],
                'model': device_info['model'], 'area': area_name,
                'entity_count': entity_count, 'disabled': device_info['disabled']
            })

def process_integrations_from_registry(data, registries):
    platform_counts = Counter()
    for entity_reg in registries['entities'].values():
        platform = entity_reg.get('platform')
        if platform:
            platform_counts[platform] += 1
    
    for platform, count in platform_counts.most_common(30):
        data['integrations'].append({
            'integration': platform, 'entity_count': count, 'status': 'active'
        })

def get_error_log(data):
    try:
        log_file = Path('/config/home-assistant.log')
        if log_file.exists():
            errors = []
            with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if 'ERROR' in line:
                        errors.append(line.strip())
            
            for error in errors[-50:]:
                parts = error.split(None, 3)
                if len(parts) >= 4:
                    data['errors'].append({
                        'timestamp': f"{parts[0]} {parts[1]}",
                        'level': parts[2],
                        'message': parts[3][:500]
                    })
    except: pass

def get_git_history(data):
    try:
        result = subprocess.run(['git', '-C', '/config/hac', 'log', '--oneline', '-20'],
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split(None, 1)
                    if len(parts) == 2:
                        data['git_history'].append({'commit': parts[0], 'message': parts[1]})
    except: pass

def get_sessions(data):
    try:
        learnings_dir = Path('/config/hac/learnings')
        if learnings_dir.exists():
            for file in sorted(learnings_dir.glob('session_*.md'), reverse=True)[:20]:
                try:
                    content = file.read_text()
                    lines = content.split('\n')
                    date_str = file.stem.replace('session_', '')
                    formatted_date = f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:8]}" if len(date_str) >= 8 else date_str
                    data['sessions'].append({
                        'date': formatted_date, 'file': file.name,
                        'lines': len(lines), 'preview': content[:300].replace('\n', ' ')
                    })
                except: pass
    except: pass

def calculate_automation_analysis(data):
    domain_counts = Counter(e['domain'] for e in data['entities'])
    for domain, count in domain_counts.most_common(15):
        auto_count = len([a for a in data['automations'] if domain in a['entity_id']])
        data['automation_analysis'].append({
            'domain': domain, 'entity_count': count, 'automation_count': auto_count,
            'coverage': 'Yes' if auto_count > 0 else 'No',
            'recommendation': 'Good' if auto_count > 0 else 'Consider automations'
        })

def calculate_token_efficiency(data):
    entities_size = sum(len(str(e)) for e in data['entities']) // 4
    automations_size = sum(len(str(a)) for a in data['automations']) // 4
    sessions_size = sum(len(s['preview']) for s in data['sessions']) // 4
    total = entities_size + automations_size + sessions_size
    
    data['token_efficiency'] = [
        {'tab_name': 'Entities', 'row_count': len(data['entities']), 'estimated_tokens': entities_size, 'optimization': 'Use LLM Index'},
        {'tab_name': 'Automations', 'row_count': len(data['automations']), 'estimated_tokens': automations_size, 'optimization': 'Filter by domain'},
        {'tab_name': 'Sessions', 'row_count': len(data['sessions']), 'estimated_tokens': sessions_size, 'optimization': 'Query by date'},
        {'tab_name': 'TOTAL', 'row_count': len(data['entities'])+len(data['automations'])+len(data['sessions']),
         'estimated_tokens': total, 'optimization': f'LLM Index: {int(100*(1-700/max(total,1)))}% reduction'}
    ]

def create_historical_snapshot(data):
    data['historical_snapshots'].append({
        'date': data['timestamp'], 'total_entities': len(data['entities']),
        'total_automations': len(data['automations']), 'total_action_items': len(data['action_items']),
        'unavailable_count': len([e for e in data['entities'] if e['state'] == 'unavailable']),
        'areas': len(data['areas']), 'integrations': len(data['integrations'])
    })

def write_master_workbook(svc, data):
    """Write full data to master workbook"""
    print("\n=== MASTER WORKBOOK ===")
    
    sheet_mapping = {
        'Dashboard': 'Dashboard',
        'Historical Snapshots': 'Historical_Snapshots - Daily entity/automation cou',
        'Error Log': 'Error_Log - Last 50 errors with timestamps',
        'Git History': 'Git_History - HAC commit log',
        'Token Efficiency': 'Token_Efficiency - Track context size over time',
        'Entities': 'Entities', 'Devices': 'Devices', 'Areas': 'Areas',
        'Automations': 'Automations', 'Integrations': 'Integrations',
        'Action Items': 'Action Items', 'Automation Analysis': 'Automation Analysis',
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
            svc.spreadsheets().values().clear(spreadsheetId=MASTER_WORKBOOK_ID, range=f"'{sheet_name}'!A:Z").execute()
            svc.spreadsheets().values().update(spreadsheetId=MASTER_WORKBOOK_ID, range=f"'{sheet_name}'!A1",
                                              valueInputOption='RAW', body={'values': rows}).execute()
            print(f"  ✓ {display_name}: {len(rows)} rows")
        except Exception as e:
            print(f"  ⚠ {display_name}: {e}")

def write_llm_index_workbook(svc, data):
    """Write token-efficient summaries to LLM Index"""
    print("\n=== LLM INDEX WORKBOOK ===")
    
    llm_sheets = {
        'Status Summary': format_llm_status_summary(data),
        'Recent Changes': format_llm_recent_changes(data),
        'Active Issues': format_llm_active_issues(data),
        'Quick Reference': format_llm_quick_reference(data),
        'HAC Session Latest': format_llm_session_latest(data)
    }
    
    for sheet_name, rows in llm_sheets.items():
        try:
            svc.spreadsheets().values().clear(spreadsheetId=LLM_INDEX_WORKBOOK_ID, range=f"'{sheet_name}'!A:Z").execute()
            svc.spreadsheets().values().update(spreadsheetId=LLM_INDEX_WORKBOOK_ID, range=f"'{sheet_name}'!A1",
                                              valueInputOption='RAW', body={'values': rows}).execute()
            print(f"  ✓ {sheet_name}: {len(rows)} rows")
        except Exception as e:
            print(f"  ⚠ {sheet_name}: {e}")

# LLM Index Formatters (Token-Efficient Summaries)
def format_llm_status_summary(data):
    unavailable = len([e for e in data['entities'] if e['state'] == 'unavailable'])
    top_areas = sorted(data['areas'], key=lambda x: x['entity_count'], reverse=True)[:5]
    
    return [
        ['HA LLM INDEX - Status Summary'],
        ['Generated:', data['timestamp']],
        [''],
        ['System', f"HA 2026.2.1 | HAC v7.3"],
        ['Entities', len(data['entities'])],
        ['Automations', len(data['automations'])],
        ['Areas', len(data['areas'])],
        ['Devices', len(data['devices'])],
        ['Integrations', len(data['integrations'])],
        [''],
        ['Health'],
        ['Unavailable', unavailable],
        ['Action Items', len(data['action_items'])],
        ['Recent Errors', len(data['errors'])],
        [''],
        ['Top 5 Areas by Entity Count'],
        ['Area', 'Entities']
    ] + [[a['area_name'], a['entity_count']] for a in top_areas[:5]]

def format_llm_recent_changes(data):
    recent_sessions = data['sessions'][:7]
    return [
        ['Recent Changes (Last 7 Days)'],
        ['Date', 'Activity']
    ] + [[s['date'], s['preview'][:100]] for s in recent_sessions]

def format_llm_active_issues(data):
    high_priority = [i for i in data['action_items'] if i['priority'] == 'HIGH'][:10]
    return [
        ['Active Issues'],
        ['Priority', 'Entity', 'Issue']
    ] + [[i['priority'], i['entity_id'], i['issue_type']] for i in high_priority]

def format_llm_quick_reference(data):
    top_integrations = sorted(data['integrations'], key=lambda x: x['entity_count'], reverse=True)[:10]
    return [
        ['Quick Reference'],
        [''],
        ['Master Workbook', f'https://docs.google.com/spreadsheets/d/{MASTER_WORKBOOK_ID}'],
        [''],
        ['Top 10 Integrations'],
        ['Integration', 'Entities']
    ] + [[i['integration'], i['entity_count']] for i in top_integrations]

def format_llm_session_latest(data):
    latest = data['sessions'][0] if data['sessions'] else {'date': 'None', 'preview': 'No sessions'}
    return [
        ['Latest HAC Session'],
        ['Date', latest['date']],
        [''],
        ['Summary'],
        [latest['preview']]
    ]

# Master Workbook Formatters (Full Data)
def format_dashboard(data):
    return [
        ['HA MASTER CONTEXT v4.0'],
        [''], ['Generated:', data['timestamp']], [''],
        ['=== SUMMARY ==='],
        ['Total Entities', len(data['entities'])],
        ['Total Automations', len(data['automations'])],
        ['Total Areas', len(data['areas'])],
        ['Total Integrations', len(data['integrations'])],
        ['Total Devices', len(data['devices'])],
        ['Action Items', len(data['action_items'])],
        ['Sessions Logged', len(data['sessions'])],
        [''], ['=== HEALTH ==='],
        ['Unavailable Entities', len([e for e in data['entities'] if e['state'] == 'unavailable'])],
        ['Recent Errors', len(data['errors'])],
        ['Git Commits', len(data['git_history'])],
        [''], [''], 
        ['AI INSIGHTS - CLICK TO ASK', '', '', ''],
        [''], 
        ['Query', 'Question', 'Click to Ask', 'After Using: Track Result'],
        ['Learning Patterns', 'What patterns in my automation learnings?', 
         '=AI("What patterns do you see in my automation learnings based on the Learnings tab?")',
         "hac track 'Learning Patterns' 'Pattern analysis' '[Paste AI response]'"],
        ['Focus Areas', 'What should I focus on next?', 
         '=AI("Based on Learnings tab patterns, what areas should I improve next?")',
         "hac track 'Focus Areas' 'Next priorities' '[Paste AI response]'"],
        ['Area Analysis', 'Which areas need most attention?', 
         '=AI("Which physical areas (rooms/zones) have most Learnings entries?")',
         "hac track 'Area Analysis' 'Room analysis' '[Paste AI response]'"],
        ['Complexity Ranking', 'Top 5 complex achievements?', 
         '=AI("From Learnings tab, rank my 5 most technically complex achievements")',
         "hac track 'Complexity Ranking' 'Top achievements' '[Paste AI response]'"],
        ['Monthly Comparison', 'This month vs last month?', 
         '=AI("Compare learnings: this month vs last month")',
         "hac track 'Monthly Comparison' 'Month comparison' '[Paste AI response]'"],
        ['Integration Health', 'Which integrations cause most issues?', 
         '=AI("Analyze Integration category - which systems troubleshot most?")',
         "hac track 'Integration Health' 'Integration analysis' '[Paste AI response]'"],
        ['Automation Evolution', 'How have automations evolved?', 
         '=AI("Describe automation evolution chronologically from Learnings")',
         "hac track 'Automation Evolution' 'Evolution timeline' '[Paste AI response]'"],
        ['Top Tags', 'Most worked-on topics?', 
         '=AI("Analyze Tags column - rank top 10 most frequent topics")',
         "hac track 'Top Tags' 'Tag analysis' '[Paste AI response]'"],
        ['Lighting Insights', 'Lighting control journey?', 
         '=AI("Filter Learnings for Lighting category - summarize improvements")',
         "hac track 'Lighting Insights' 'Lighting summary' '[Paste AI response]'"],
        ['Recent Wins', 'Last 7 days achievements?', 
         '=AI("Show last 7 days learnings and highlight key achievements")',
         "hac track 'Recent Wins' 'Weekly achievements' '[Paste AI response]'"],

    ]

def format_historical_snapshots(data):
    return [['Date', 'Entities', 'Automations', 'Action Items', 'Unavailable', 'Areas', 'Integrations']] + \
           [[s['date'], s['total_entities'], s['total_automations'], s['total_action_items'],
             s['unavailable_count'], s['areas'], s['integrations']] for s in data['historical_snapshots']]

def format_error_log(data):
    return [['Timestamp', 'Level', 'Message']] + [[e['timestamp'], e['level'], e['message']] for e in data['errors']]

def format_git_history(data):
    return [['Commit', 'Message']] + [[g['commit'], g['message']] for g in data['git_history']]

def format_token_efficiency(data):
    return [['Tab Name', 'Row Count', 'Estimated Tokens', 'Optimization']] + \
           [[t['tab_name'], t['row_count'], t['estimated_tokens'], t['optimization']] for t in data['token_efficiency']]

def format_entities(data):
    return [['entity_id', 'domain', 'state', 'friendly_name', 'area', 'device_class', 'platform', 'last_changed']] + \
           [[e['entity_id'], e['domain'], e['state'], e['friendly_name'], e['area'],
             e['device_class'], e['platform'], e['last_changed']] for e in sorted(data['entities'], key=lambda x: (x['area'], x['domain']))]

def format_devices(data):
    return [['Device Name', 'Manufacturer', 'Model', 'Area', 'Entity Count', 'Disabled']] + \
           [[d['device_name'], d['manufacturer'], d['model'], d['area'], d['entity_count'], d['disabled']]
            for d in sorted(data['devices'], key=lambda x: x['area'])]

def format_areas(data):
    return [['Area Name', 'Entity Count', 'Device Count', 'Automation Count', 'Temperature', 'Humidity', 'Motion Active']] + \
           [[a['area_name'], a['entity_count'], a['device_count'], a['automation_count'],
             a['temperature'], a['humidity'], a['motion_active']] for a in sorted(data['areas'], key=lambda x: x['area_name'])]

def format_automations(data):
    return [['entity_id', 'friendly_name', 'state', 'last_triggered', 'mode', 'current', 'max']] + \
           [[a['entity_id'], a['friendly_name'], a['state'], a['last_triggered'],
             a['mode'], a['current'], a['max']] for a in data['automations']]

def format_integrations(data):
    return [['Integration', 'Entity Count', 'Status']] + [[i['integration'], i['entity_count'], i['status']] for i in data['integrations']]

def format_action_items(data):
    return [['Priority', 'Entity', 'Domain', 'Name', 'Issue', 'Recommendation']] + \
           [[i['priority'], i['entity_id'], i['domain'], i['friendly_name'],
             i['issue_type'], i['recommendation']] for i in data['action_items']]

def format_automation_analysis(data):
    return [['Domain', 'Entity Count', 'Automation Count', 'Coverage', 'Recommendation']] + \
           [[a['domain'], a['entity_count'], a['automation_count'], a['coverage'], a['recommendation']]
            for a in data['automation_analysis']]

def format_sessions(data):
    return [['Date', 'File', 'Lines', 'Preview']] + [[s['date'], s['file'], s['lines'], s['preview']] for s in data['sessions']]


# ============================================================================
# LEARNINGS EXPORT INTEGRATION
# ============================================================================

def export_learnings_to_sheets(service, spreadsheet_id):
    """Export HAC learnings to Google Sheets"""
    print("\n=== LEARNINGS TAB ===")
    
    # Import the parser
    import sys
    sys.path.append('/config/python_scripts')
    from parse_learnings import parse_all_learnings
    
    # Parse all learnings
    learnings = parse_all_learnings()
    
    if not learnings:
        print("  ⚠ No learnings found")
        return
    
    # Prepare data for sheets
    headers = ['Timestamp', 'Date', 'Time', 'Category', 'Learning', 'Tags', 'Source']
    rows = [headers]
    
    for learning in learnings:
        rows.append([
            learning['timestamp'],
            learning['date'],
            learning['time'],
            learning['category'],
            learning['learning'],
            learning['tags'],
            learning['source']
        ])
    
    # Write to sheet
    try:
        body = {'values': rows}
        service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range='Learnings!A1',
            valueInputOption='RAW',
            body=body
        ).execute()
        
        print(f"  ✓ Learnings: {len(rows)-1} rows")
        
    except Exception as e:
        print(f"  ✗ Learnings export failed: {e}")


def main():
    print("=" * 70)
    print("HA Dual Export v4.0")
    print("=" * 70)
    
    creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
    svc = build('sheets', 'v4', credentials=creds)
    print("✓ Auth successful")
    
    data = get_ha_data()
    print(f"✓ Gathered: {len(data['entities'])} entities, {len(data['automations'])} automations, "
          f"{len(data['areas'])} areas, {len(data['integrations'])} integrations, {len(data['devices'])} devices")
    
    write_master_workbook(svc, data)
    export_learnings_to_sheets(svc, MASTER_WORKBOOK_ID)
    write_llm_index_workbook(svc, data)
    
    print(f"\n✓ COMPLETE")
    print(f"  Master: https://docs.google.com/spreadsheets/d/{MASTER_WORKBOOK_ID}")
    print(f"  LLM Index: https://docs.google.com/spreadsheets/d/{LLM_INDEX_WORKBOOK_ID}")
    print("=" * 70)

if __name__ == '__main__':
    main()
