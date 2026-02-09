#!/usr/bin/env python3
"""
Track AI insights to history tab
Usage: python3 track_ai_insight.py "Query Type" "Question" "AI Response"
"""

import sys
from datetime import datetime
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
MASTER_WORKBOOK_ID = '11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w'

def add_insight_to_history(query_type, question, response):
    """Add an AI insight to the history tab"""
    
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, 
        scopes=SCOPES
    )
    service = build('sheets', 'v4', credentials=creds)
    
    # Create timestamp
    now = datetime.now()
    timestamp = now.strftime('%Y-%m-%d %H:%M:%S')
    date = now.strftime('%Y-%m-%d')
    time = now.strftime('%H:%M:%S')
    
    # Truncate response for summary (first 100 chars)
    summary = response[:100] + "..." if len(response) > 100 else response
    
    # Extract tags from query type
    tags = query_type.lower().replace(" ", ",")
    
    # Create row
    row = [[
        timestamp,
        date,
        time,
        query_type,
        question,
        summary,
        response,
        '📋 Planned',  # Default status
        '',  # Empty notes
        tags
    ]]
    
    try:
        # Append to sheet
        service.spreadsheets().values().append(
            spreadsheetId=MASTER_WORKBOOK_ID,
            range='AI Insights History!A2',  # Start after header
            valueInputOption='RAW',
            insertDataOption='INSERT_ROWS',
            body={'values': row}
        ).execute()
        
        print(f"✓ Tracked insight: {query_type}")
        return True
        
    except Exception as e:
        print(f"✗ Error tracking insight: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 track_ai_insight.py 'Query Type' 'Question' 'AI Response'")
        sys.exit(1)
    
    query_type = sys.argv[1]
    question = sys.argv[2]
    response = sys.argv[3]
    
    add_insight_to_history(query_type, question, response)
