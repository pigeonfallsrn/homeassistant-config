#!/usr/bin/env python3
"""
Update Dashboard AI query buttons to include tracking
"""

from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
MASTER_WORKBOOK_ID = '11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w'

creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
service = build('sheets', 'v4', credentials=creds)

# Enhanced queries with tracking instructions
queries = [
    ["Query", "Question", "Click to Ask", "After Using: Track Result"],
    ["Learning Patterns", "What patterns do you see in my automation learnings?", 
     '=AI("What patterns do you see in my automation learnings based on the Learnings tab?")',
     "hac track 'Learning Patterns' 'Pattern analysis' '[Paste AI response]'"],
    ["Focus Areas", "Based on my learnings, what should I focus on next?", 
     '=AI("Based on the patterns in my Learnings tab, what areas of my home automation should I focus on improving next?")',
     "hac track 'Focus Areas' 'Next priorities' '[Paste AI response]'"],
    ["Area Analysis", "Which areas of my home need the most attention?", 
     '=AI("Analyze the Learnings tab and tell me which physical areas (rooms/zones) have the most entries and need attention")',
     "hac track 'Area Analysis' 'Room analysis' '[Paste AI response]'"],
    ["Complexity Ranking", "What are my top 5 most complex achievements?", 
     '=AI("From the Learnings tab, identify and rank my 5 most technically complex or impressive achievements")',
     "hac track 'Complexity Ranking' 'Top achievements' '[Paste AI response]'"],
    ["Monthly Comparison", "How does this month compare to last month?", 
     '=AI("Compare the number and types of learnings from this month vs last month in the Learnings tab")',
     "hac track 'Monthly Comparison' 'Month comparison' '[Paste AI response]'"],
    ["Integration Health", "Which integrations have caused the most issues?", 
     '=AI("Analyze the Learnings tab for Integration category entries - which systems have I troubleshot most?")',
     "hac track 'Integration Health' 'Integration analysis' '[Paste AI response]'"],
    ["Automation Evolution", "How have my automations evolved over time?", 
     '=AI("Look at Automation category entries in Learnings tab chronologically - describe my automation evolution")',
     "hac track 'Automation Evolution' 'Evolution timeline' '[Paste AI response]'"],
    ["Top Tags", "What are my most worked-on topics?", 
     '=AI("Analyze the Tags column in Learnings tab and rank my top 10 most frequent topics")',
     "hac track 'Top Tags' 'Tag analysis' '[Paste AI response]'"],
    ["Lighting Insights", "Summarize my lighting control journey", 
     '=AI("Filter Learnings tab for Lighting category - summarize my lighting control improvements")',
     "hac track 'Lighting Insights' 'Lighting summary' '[Paste AI response]'"],
    ["Recent Wins", "What have I accomplished in the last 7 days?", 
     '=AI("Show learnings from the last 7 days in Learnings tab and highlight key achievements")',
     "hac track 'Recent Wins' 'Weekly achievements' '[Paste AI response]'"],
]

try:
    # Update Dashboard with tracking column
    service.spreadsheets().values().update(
        spreadsheetId=MASTER_WORKBOOK_ID,
        range='Dashboard!A22:D32',
        valueInputOption='USER_ENTERED',
        body={'values': queries}
    ).execute()
    
    print("✓ Updated Dashboard with tracking instructions")
    print("  Added 'Track Result' column with hac track commands")
    
except Exception as e:
    print(f"✗ Error: {e}")
