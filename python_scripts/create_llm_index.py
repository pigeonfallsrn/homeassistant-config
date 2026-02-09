#!/usr/bin/env python3
"""Create HA LLM Index - Token-Efficient Companion Workbook"""
import json
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive'\]

def main():
    # Authenticate
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, 
        scopes=SCOPES
    )
    
    sheets_service = build('sheets', 'v4', credentials=creds)
    drive_service = build('drive', 'v3', credentials=creds)
    
    # Create new spreadsheet
    spreadsheet = {
        'properties': {
            'title': 'HA LLM Index - Token Efficient Context'
        },
        'sheets': [
            {'properties': {'title': 'Status Summary'}},
            {'properties': {'title': 'Recent Changes'}},
            {'properties': {'title': 'Active Issues'}},
            {'properties': {'title': 'Quick Reference'}},
            {'properties': {'title': 'HAC Session Latest'}}
        ]
    }
    
    result = sheets_service.spreadsheets().create(body=spreadsheet).execute()
    spreadsheet_id = result['spreadsheetId']
    spreadsheet_url = f"https://docs.google.com/spreadsheets/d/{spreadsheet_id}"
    
    print(f"✓ Created LLM Index workbook")
    print(f"  Spreadsheet ID: {spreadsheet_id}")
    print(f"  URL: {spreadsheet_url}")
    
    # Write spreadsheet ID to file for future use
    with open('/config/.llm_index_id', 'w') as f:
        f.write(spreadsheet_id)
    
    print(f"\n✓ Saved spreadsheet ID to /config/.llm_index_id")
    print(f"\nNext steps:")
    print(f"1. Add this ID to your export automation")
    print(f"2. Run the LLM export to populate it")

if __name__ == '__main__':
    main()
