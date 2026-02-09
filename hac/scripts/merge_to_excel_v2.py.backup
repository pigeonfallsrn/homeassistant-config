#!/usr/bin/env python3
"""Merge CSV exports into formatted Excel workbook v2.0"""

import sys
import os
import re
import csv
import json
from pathlib import Path

try:
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill, Alignment
    from openpyxl.utils import get_column_letter
except ImportError:
    print("ERROR: openpyxl not installed. Installing...", file=sys.stderr)
    os.system("pip3 install openpyxl --break-system-packages")
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill, Alignment
    from openpyxl.utils import get_column_letter

def apply_header_style(ws, row=1):
    """Apply Office 365 style to header row"""
    header_fill = PatternFill(start_color="0078D4", end_color="0078D4", fill_type="solid")
    header_font = Font(bold=True, color="FFFFFF", size=11)
    
    for cell in ws[row]:
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="left", vertical="center")

def auto_size_columns(ws, max_width=50):
    """Auto-size columns based on content"""
    for column in ws.columns:
        max_length = 0
        column_letter = get_column_letter(column[0].column)
        
        for cell in column:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(str(cell.value))
            except:
                pass
        
        adjusted_width = min(max_length + 2, max_width)
        ws.column_dimensions[column_letter].width = adjusted_width

def csv_to_sheet(wb, csv_path, sheet_name):
    """Import CSV into worksheet with formatting"""
    if not os.path.exists(csv_path):
        print(f"WARNING: {csv_path} not found, skipping...", file=sys.stderr)
        return None
    
    ws = wb.create_sheet(sheet_name)
    
    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        for row_idx, row in enumerate(reader, start=1):
            for col_idx, value in enumerate(row, start=1):
                ws.cell(row=row_idx, column=col_idx, value=value)
    
    apply_header_style(ws)
    auto_size_columns(ws)
    ws.freeze_panes = 'A2'
    
    return ws

def redact_sensitive_data(value):
    """Redact sensitive information for AI_SAFE version"""
    if not isinstance(value, str):
        return value
    
    # Redact IP addresses
    value = re.sub(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', '[IP_REDACTED]', value)
    
    # Redact MAC addresses
    value = re.sub(r'([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})', '[MAC_REDACTED]', value)
    
    # Redact GPS coordinates
    value = re.sub(r'-?\d+\.\d{6,}, ?-?\d+\.\d{6,}', '[GPS_REDACTED]', value)
    
    # Redact personal names
    personal_patterns = [
        r'[Jj]ohn[s]?[_\s]',
        r'[Mm]ichelle[s]?[_\s]',
        r'[Aa]laina[s]?[_\s]',
        r'[Ee]lla[s]?[_\s]',
        r'[Jj]arrett[s]?[_\s]',
        r'[Oo]wen[s]?[_\s]'
    ]
    
    for pattern in personal_patterns:
        value = re.sub(pattern, 'User_', value)
    
    return value

def create_dashboard_sheet(wb, temp_dir):
    """Create enhanced summary dashboard tab"""
    ws = wb.create_sheet("Dashboard", 0)
    
    # Title
    ws['A1'] = "Home Assistant Master Context v2.0"
    ws['A1'].font = Font(size=16, bold=True, color="0078D4")
    
    # Load stats if available
    stats_file = os.path.join(temp_dir, 'stats.json')
    stats = {}
    if os.path.exists(stats_file):
        with open(stats_file, 'r') as f:
            stats = json.load(f)
    
    # Metadata
    row = 3
    ws[f'A{row}'] = "Generated:"
    ws[f'B{row}'] = os.path.basename(temp_dir).replace('temp_', '')
    ws[f'A{row}'].font = Font(bold=True)
    
    row += 2
    ws[f'A{row}'] = "SUMMARY STATISTICS"
    ws[f'A{row}'].font = Font(size=14, bold=True, color="0078D4")
    
    row += 1
    ws[f'A{row}'] = "Total Entities:"
    ws[f'B{row}'] = stats.get('entity_count', 0)
    
    row += 1
    ws[f'A{row}'] = "Total Devices:"
    ws[f'B{row}'] = stats.get('device_count', 0)
    
    row += 1
    ws[f'A{row}'] = "Total Areas:"
    ws[f'B{row}'] = stats.get('area_count', 0)
    
    row += 1
    ws[f'A{row}'] = "Total Automations:"
    ws[f'B{row}'] = stats.get('automation_count', 0)
    
    row += 2
    ws[f'A{row}'] = "ACTION ITEMS"
    ws[f'A{row}'].font = Font(size=14, bold=True, color="C43900")
    
    row += 1
    ws[f'A{row}'] = "Items Needing Attention:"
    ws[f'B{row}'] = stats.get('action_items', 0)
    ws[f'B{row}'].font = Font(bold=True, color="C43900")
    
    # Entity analysis
    entity_stats = stats.get('entity_analysis', {})
    if entity_stats:
        row += 1
        ws[f'A{row}'] = "Physical Devices Unassigned:"
        ws[f'B{row}'] = entity_stats.get('physical_unassigned', 0)
        
        if entity_stats.get('physical_unassigned', 0) > 0:
            ws[f'B{row}'].font = Font(color="C43900")
    
    ws.column_dimensions['A'].width = 30
    ws.column_dimensions['B'].width = 30

def create_safe_version(wb_full, temp_dir):
    """Create redacted AI_SAFE version"""
    wb_safe = Workbook()
    wb_safe.remove(wb_safe.active)
    
    for sheet_name in wb_full.sheetnames:
        ws_full = wb_full[sheet_name]
        ws_safe = wb_safe.create_sheet(sheet_name)
        
        for row in ws_full.iter_rows():
            safe_row = []
            for cell in row:
                safe_value = redact_sensitive_data(cell.value)
                safe_row.append(safe_value)
            
            ws_safe.append(safe_row)
        
        # Copy formatting
        apply_header_style(ws_safe)
        auto_size_columns(ws_safe)
        ws_safe.freeze_panes = 'A2'
    
    return wb_safe

def main():
    if len(sys.argv) < 4:
        print("Usage: merge_to_excel.py <temp_dir> <output_dir> <timestamp>", file=sys.stderr)
        sys.exit(1)
    
    temp_dir = sys.argv[1]
    output_dir = sys.argv[2]
    timestamp = sys.argv[3]
    
    # Create FULL version
    wb_full = Workbook()
    wb_full.remove(wb_full.active)
    
    # Create dashboard first
    create_dashboard_sheet(wb_full, temp_dir)
    
    # Import CSV sheets in logical order
    csv_sheets = [
        ('action_items.csv', 'Action Items'),  # NEW - First for visibility!
        ('entities.csv', 'Entities'),
        ('devices.csv', 'Devices'),
        ('areas.csv', 'Areas'),
        ('automations.csv', 'Automations'),
        ('integrations.csv', 'Integrations'),
        ('learnings.csv', 'HAC Learnings'),
        ('privacy_audit.csv', 'Privacy Audit')
    ]
    
    for csv_file, sheet_name in csv_sheets:
        csv_path = os.path.join(temp_dir, csv_file)
        csv_to_sheet(wb_full, csv_path, sheet_name)
    
    # Save FULL version
    full_path = os.path.join(output_dir, f"HA_Master_Context_{timestamp}_FULL.xlsx")
    wb_full.save(full_path)
    print(f"✅ Created: {full_path}")
    
    # Create and save AI_SAFE version
    wb_safe = create_safe_version(wb_full, temp_dir)
    safe_path = os.path.join(output_dir, f"HA_Master_Context_{timestamp}_AI_SAFE.xlsx")
    wb_safe.save(safe_path)
    print(f"✅ Created: {safe_path}")

if __name__ == '__main__':
    main()
