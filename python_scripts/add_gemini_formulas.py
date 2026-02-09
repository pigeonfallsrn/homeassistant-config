#!/usr/bin/env python3
"""Add Gemini AI formulas to Master Workbook for intelligent insights"""
from google.oauth2 import service_account
from googleapiclient.discovery import build

SERVICE_ACCOUNT_FILE = '/config/ha-service-account.json'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
MASTER_WORKBOOK_ID = "11quLdO56rqI8GAPq-KnKtJoBs7cH6QAVgHs8W6UC_8w"

def add_gemini_insights(svc):
    """Add Gemini-powered insights to Dashboard"""
    
    # Create AI Insights section on Dashboard
    insights_data = [
        [''],
        ['=== GEMINI AI INSIGHTS ==='],
        ['Ask Gemini about your system:'],
        [''],
        ['Question:', 'Answer'],
        ['What are my biggest automation gaps?', '=AI("Based on the Automation Analysis tab, identify the top 3 domains with the most entities but no automations, and suggest specific automation ideas for each")'],
        ['Which areas need the most attention?', '=AI("Analyze the Action Items tab and Areas tab to identify which physical areas have the most issues and what should be prioritized")'],
        ['What devices are most unreliable?', '=AI("Review the Devices and Action Items tabs to identify devices with the most unavailable entities and suggest troubleshooting steps")'],
        ['How can I improve energy efficiency?', '=AI("Based on the entities and automations, suggest 3 specific automations that could reduce energy usage")'],
        ['What should I automate next?', '=AI("Analyze my current automations and suggest the next most valuable automation based on my entity coverage gaps")']
    ]
    
    # Write to Dashboard starting at row 20
    try:
        svc.spreadsheets().values().update(
            spreadsheetId=MASTER_WORKBOOK_ID,
            range="Dashboard!A20",
            valueInputOption='USER_ENTERED',  # This allows formulas to work
            body={'values': insights_data}
        ).execute()
        print("✓ Added Gemini AI Insights to Dashboard")
    except Exception as e:
        print(f"⚠ Error adding insights: {e}")

def add_automation_suggestions(svc):
    """Add AI-powered automation suggestions tab"""
    
    # Create a new sheet for AI suggestions
    try:
        # Check if sheet exists, if not create it
        spreadsheet = svc.spreadsheets().get(spreadsheetId=MASTER_WORKBOOK_ID).execute()
        sheets = [s['properties']['title'] for s in spreadsheet.get('sheets', [])]
        
        if 'AI Suggestions' not in sheets:
            request = {
                'addSheet': {
                    'properties': {
                        'title': 'AI Suggestions'
                    }
                }
            }
            svc.spreadsheets().batchUpdate(
                spreadsheetId=MASTER_WORKBOOK_ID,
                body={'requests': [request]}
            ).execute()
            print("✓ Created AI Suggestions tab")
        
        # Add AI formulas for suggestions
        suggestions_data = [
            ['AI-POWERED AUTOMATION SUGGESTIONS'],
            ['Generated from your entities, areas, and current automations'],
            [''],
            ['Category', 'Suggestion', 'Priority', 'Entities Involved'],
            ['Energy Savings', '=AI("Suggest an automation to turn off lights in unoccupied areas based on motion sensors. Reference specific entities from the Entities tab")', 'HIGH', ''],
            ['Security', '=AI("Suggest door/window monitoring automations based on available sensors in the Entities tab")', 'HIGH', ''],
            ['Comfort', '=AI("Suggest climate automations based on temperature sensors and thermostats in the Entities tab")', 'MEDIUM', ''],
            ['Convenience', '=AI("Suggest arrival/departure automations based on person entities and available devices")', 'MEDIUM', ''],
            ['Maintenance', '=AI("Suggest monitoring automations for device health based on unavailable entities in Action Items tab")', 'LOW', '']
        ]
        
        svc.spreadsheets().values().update(
            spreadsheetId=MASTER_WORKBOOK_ID,
            range="'AI Suggestions'!A1",
            valueInputOption='USER_ENTERED',
            body={'values': suggestions_data}
        ).execute()
        print("✓ Added AI formulas to AI Suggestions tab")
        
    except Exception as e:
        print(f"⚠ Error adding suggestions: {e}")

def add_smart_charts(svc):
    """Add AI-generated chart suggestions"""
    
    chart_formulas = [
        [''],
        ['=== RECOMMENDED CHARTS ==='],
        ['Ask Gemini to create charts:'],
        [''],
        ['Chart Type', 'Description', 'Data Source'],
        ['Entity Growth', 'Line chart showing entity count over time', 'Historical_Snapshots'],
        ['Automation Coverage', 'Pie chart of domains with/without automations', 'Automation Analysis'],
        ['Area Distribution', 'Bar chart of entities per area', 'Areas'],
        ['Device Health', 'Gauge showing % of available devices', 'Devices + Action Items'],
        ['Action Items Trend', 'Line chart of action items over time', 'Historical_Snapshots']
    ]
    
    try:
        svc.spreadsheets().values().update(
            spreadsheetId=MASTER_WORKBOOK_ID,
            range="Dashboard!A35",
            valueInputOption='USER_ENTERED',
            body={'values': chart_formulas}
        ).execute()
        print("✓ Added chart recommendations to Dashboard")
    except Exception as e:
        print(f"⚠ Error adding charts: {e}")

def main():
    print("=" * 70)
    print("Adding Gemini AI Integration to Master Workbook")
    print("=" * 70)
    
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, 
        scopes=SCOPES
    )
    svc = build('sheets', 'v4', credentials=creds)
    print("✓ Auth successful")
    
    add_gemini_insights(svc)
    add_automation_suggestions(svc)
    add_smart_charts(svc)
    
    print("\n✓ COMPLETE - Gemini AI features added!")
    print(f"  View: https://docs.google.com/spreadsheets/d/{MASTER_WORKBOOK_ID}")
    print("\nNote: Gemini formulas require Google Workspace and may need manual")
    print("      activation in Google Sheets. Click on cells to enable AI features.")
    print("=" * 70)

if __name__ == '__main__':
    main()
