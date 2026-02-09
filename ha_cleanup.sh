#!/bin/bash
# Home Assistant Cleanup Helper Script
# Run from Terminal & SSH add-on

set -e

echo "================================================================================"
echo "HOME ASSISTANT CLEANUP HELPER"
echo "================================================================================"
echo ""
echo "This script helps identify cleanup tasks. Due to HA security, actual cleanup"
echo "must be done via the Web UI."
echo ""

# Check if we're in HA environment
if [ ! -d "/config" ]; then
    echo "❌ Error: Not running in Home Assistant environment"
    echo "   This script must be run from the Terminal & SSH add-on"
    exit 1
fi

echo "✅ Running in Home Assistant environment"
echo ""

# Function to create backup
create_backup() {
    echo "================================================================================"
    echo "STEP 1: CREATING BACKUP"
    echo "================================================================================"
    echo ""
    
    BACKUP_NAME="pre_cleanup_$(date +%Y%m%d_%H%M%S)"
    
    echo "Creating backup: $BACKUP_NAME"
    echo "This may take 2-5 minutes..."
    echo ""
    
    if command -v ha &> /dev/null; then
        ha backups new --name "$BACKUP_NAME"
        echo "✅ Backup created"
    else
        echo "⚠️  'ha' command not available"
        echo "   Please create backup manually via UI: Settings → System → Backups"
        read -p "Press Enter when backup is complete..."
    fi
    
    echo ""
}

# Function to analyze entities
analyze_entities() {
    echo "================================================================================"
    echo "STEP 2: ANALYZING ENTITIES"
    echo "================================================================================"
    echo ""
    
    if [ ! -f "/config/.storage/core.entity_registry" ]; then
        echo "❌ Cannot read entity registry"
        return
    fi
    
    # Count total entities
    TOTAL=$(grep -c '"entity_id"' /config/.storage/core.entity_registry || echo "unknown")
    echo "Total entities registered: $TOTAL"
    echo ""
    
    # Check for duplicates in entity IDs (rough check)
    echo "Checking for potential duplicate entity issues..."
    
    # This is a simplified check - the Python script does it better
    echo "  (Run Python script for detailed analysis)"
    echo ""
}

# Function to check areas
analyze_areas() {
    echo "================================================================================"
    echo "STEP 3: CHECKING AREA NAMES"
    echo "================================================================================"
    echo ""
    
    if [ ! -f "/config/.storage/core.area_registry" ]; then
        echo "❌ Cannot read area registry"
        return
    fi
    
    echo "Areas with potential issues:"
    echo ""
    
    # Look for malformed area names (contains ", ,")
    if grep -q '", ,"' /config/.storage/core.area_registry; then
        echo "⚠️  Found malformed area names (extra commas):"
        grep '"name":' /config/.storage/core.area_registry | grep ', ,' | head -5
        echo ""
    fi
    
    # Count total areas
    TOTAL_AREAS=$(grep -c '"area_id"' /config/.storage/core.area_registry || echo "unknown")
    echo "Total areas: $TOTAL_AREAS"
    echo ""
}

# Function to check for automation issues
check_automations() {
    echo "================================================================================"
    echo "STEP 4: CHECKING AUTOMATIONS FOR OLD AREA REFERENCES"
    echo "================================================================================"
    echo ""
    
    if [ ! -d "/config/packages" ]; then
        echo "No /config/packages directory found"
        echo "Checking /config/automations.yaml instead..."
        
        if [ -f "/config/automations.yaml" ]; then
            echo ""
            echo "Searching for problematic area references..."
            
            # Search for old area names
            if grep -i "dad's bedroom" /config/automations.yaml; then
                echo "⚠️  Found 'Dad's Bedroom' reference"
            fi
            
            if grep -i "2nd floor bathroom" /config/automations.yaml; then
                echo "⚠️  Found '2nd Floor Bathroom' reference"
            fi
        fi
        echo ""
        return
    fi
    
    echo "Searching packages/ for old area references..."
    echo ""
    
    # Search for problematic area names
    FOUND=0
    
    if grep -r "Dad's Bedroom" /config/packages/ 2>/dev/null; then
        echo "⚠️  Found 'Dad's Bedroom' references"
        FOUND=1
    fi
    
    if grep -r "2nd Floor Bathroom" /config/packages/ 2>/dev/null; then
        echo "⚠️  Found '2nd Floor Bathroom' references"
        FOUND=1
    fi
    
    if [ $FOUND -eq 0 ]; then
        echo "✅ No old area references found in automations"
    else
        echo ""
        echo "You'll need to update these after renaming areas"
    fi
    
    echo ""
}

# Function to show manual cleanup steps
show_cleanup_steps() {
    echo "================================================================================"
    echo "MANUAL CLEANUP STEPS (Web UI Required)"
    echo "================================================================================"
    echo ""
    
    cat << 'EOF'
Home Assistant doesn't allow entity/area deletion via terminal for safety.
Complete these steps in the Web UI:

📍 STEP 1: FIX AREA NAMES (15 min)
   Settings → Areas & Labels → Areas
   
   1. Click: 'Master Bedroom, , Dad's Bedroom'
      → Rename to: 'Master Bedroom'
      → Save
   
   2. Click: '2nd Floor Bathroom, Upstairs Bathroom'
      → Rename to: 'Upstairs Bathroom'
      → Save

🗑️  STEP 2: DELETE UNAVAILABLE ENTITIES (10 min)
   Settings → Devices & Services → Entities tab
   
   1. Click the "UNAVAILABLE" badge at top
   2. Review each entity (31 total)
   3. Select entities to delete
   4. Click trash icon
   5. Confirm deletion

🔄 STEP 3: FIX DUPLICATES (5 min)
   Settings → Devices & Services → Entities tab
   
   1. Search: "Anyone Home" → delete one
   2. Search: "Kitchen" media_player → delete unavailable one
   3. Search: "2nd_Floor_Bathroom_Dual_Smart_Plug" → rename to Outlet 1 & 2

✅ STEP 4: VERIFY (5 min)
   Developer Tools → States
   
   1. Check for unexpected unavailable entities
   2. Test automations in renamed areas
   3. Verify motion sensors work

📝 STEP 5: DOCUMENT (Terminal - run these commands)
   cd /config
   hac sheets
   git add -A
   git commit -m "Cleanup: fixed area names, removed unavailable entities"
   hac learn "Cleanup complete 2026-02-09: renamed areas, removed unavailable"

EOF
}

# Function to generate detailed report
generate_report() {
    echo "================================================================================"
    echo "GENERATING CLEANUP REPORT"
    echo "================================================================================"
    echo ""
    
    REPORT_FILE="/config/cleanup_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Home Assistant Cleanup Report"
        echo "Generated: $(date)"
        echo ""
        echo "SYSTEM INFO:"
        echo "  Config directory: /config"
        echo "  Entity registry: /config/.storage/core.entity_registry"
        echo "  Area registry: /config/.storage/core.area_registry"
        echo ""
        echo "FINDINGS:"
        echo ""
        
        if [ -f "/config/.storage/core.entity_registry" ]; then
            TOTAL=$(grep -c '"entity_id"' /config/.storage/core.entity_registry || echo "0")
            echo "  Total entities: $TOTAL"
        fi
        
        if [ -f "/config/.storage/core.area_registry" ]; then
            TOTAL_AREAS=$(grep -c '"area_id"' /config/.storage/core.area_registry || echo "0")
            echo "  Total areas: $TOTAL_AREAS"
        fi
        
        echo ""
        echo "See CLEANUP_PLAN.md for detailed step-by-step instructions"
        
    } > "$REPORT_FILE"
    
    echo "✅ Report saved to: $REPORT_FILE"
    echo ""
}

# Main execution
main() {
    # Step 1: Backup
    read -p "Create backup before continuing? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_backup
    else
        echo "⚠️  Skipping backup - NOT RECOMMENDED"
        echo ""
    fi
    
    # Step 2-4: Analysis
    analyze_entities
    analyze_areas
    check_automations
    
    # Show manual steps
    show_cleanup_steps
    
    # Generate report
    generate_report
    
    echo "================================================================================"
    echo "NEXT: Open Home Assistant Web UI to complete cleanup"
    echo "      Reference the manual steps above"
    echo "================================================================================"
    echo ""
}

# Run main function
main
