#!/bin/bash

TOKEN=$(printenv SUPERVISOR_TOKEN)
API="http://supervisor/core/api"

echo "=== HA CONTEXT: $(date '+%m/%d %H:%M') ==="
echo ""

# Helper function
get_state() {
    curl -s -H "Authorization: Bearer $TOKEN" "$API/states/$1" 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4
}

# STATUS
echo "STATUS:"
ha core info --no-progress 2>&1 | grep "version:" | head -1
ha supervisor info --no-progress 2>&1 | grep "healthy:" | head -1
echo ""

# PRESENCE
echo "PRESENCE:"
echo "  John: $(get_state device_tracker.john_s_phone)"
echo "  Alaina: $(get_state device_tracker.alaina_s_iphone_17)"
echo "  Ella: $(get_state device_tracker.ellas_iphone)"
echo "  Time: $(date '+%A %H:%M')"
echo ""

# GARAGE
echo "GARAGE:"
echo "  North: $(get_state cover.ratgdo32disco_fd8d8c_door)"
echo "  South: $(get_state cover.ratgdo32disco_5735e8_door)"
echo ""

# Get all states once
all_states=$(curl -s -H "Authorization: Bearer $TOKEN" "$API/states" 2>/dev/null)

# LIGHTS (fixed to exclude update entities)
echo "LIGHTS:"
lights_total=$(echo "$all_states" | grep -o '"entity_id":"light\.[^"]*"' | wc -l)
lights_on=$(echo "$all_states" | grep '"entity_id":"light\.[^"]*"' | grep '"state":"on"' | wc -l)
lights_unavail=$(echo "$all_states" | grep '"entity_id":"light\.[^"]*"' | grep '"state":"unavailable"' | wc -l)
echo "  Total: $lights_total | On: $lights_on | Unavailable: $lights_unavail"
if [ "$lights_unavail" -gt 0 ]; then
    echo "  Problem lights:"
    # More precise: get entity_id AND state, then lookup friendly name
    echo "$all_states" | grep '"entity_id":"light\.[^"]*".*"state":"unavailable"' | grep -o '"entity_id":"light\.[^"]*"' | cut -d'"' -f4 | head -3 | sed 's/light\./    /'
fi
echo ""

# AUTOMATIONS
echo "AUTOMATIONS:"
auto_total=$(echo "$all_states" | grep -o '"entity_id":"automation\.[^"]*"' | wc -l)
auto_on=$(echo "$all_states" | grep '"entity_id":"automation\.[^"]*"' | grep '"state":"on"' | wc -l)
auto_off=$(echo "$all_states" | grep '"entity_id":"automation\.[^"]*"' | grep '"state":"off"' | wc -l)
auto_unavail=$(echo "$all_states" | grep '"entity_id":"automation\.[^"]*"' | grep '"state":"unavailable"' | wc -l)
echo "  Total: $auto_total | On: $auto_on | Off: $auto_off"
if [ "$auto_unavail" -gt 0 ]; then
    echo "  ⚠ Unavailable: $auto_unavail"
fi
if [ "$auto_off" -gt 5 ]; then
    echo "  Recently disabled:"
    echo "$all_states" | grep '"entity_id":"automation\.[^"]*"' | grep '"state":"off"' | grep -o '"entity_id":"automation\.[^"]*"' | cut -d'"' -f4 | head -3 | sed 's/automation\./    /'
fi
echo ""

# SYSTEM
echo "SYSTEM:"
echo "  $(uptime -p | sed 's/up /Up: /')"
echo "  Load: $(uptime | awk -F'average:' '{print $2}')"
echo "  Disk: $(df -h /data | tail -1 | awk '{print $5 " used"}')"
echo ""

# RECENT ERRORS
echo "RECENT ERRORS (last 10):"
journalctl -u homeassistant@homeassistant.service --since "2 hours ago" 2>/dev/null | \
  grep -i "ERROR" | \
  grep -v "Retrying" | \
  tail -10 | \
  cut -c 60- | \
  awk '!seen[$0]++' | \
  sed 's/^/  /'
echo ""

# PROBLEM ENTITIES (excluding lights, updates)
echo "OTHER UNAVAILABLE:"
problem_count=$(echo "$all_states" | grep '"state":"unavailable"' | grep -v '"entity_id":"update\.' | grep -v '"entity_id":"light\.' | wc -l)
if [ "$problem_count" -gt 0 ]; then
    echo "  Count: $problem_count"
    echo "$all_states" | grep '"state":"unavailable"' | grep -v '"entity_id":"update\.' | grep -v '"entity_id":"light\.' | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | head -5 | sed 's/^/    /'
else
    echo "  ✓ None"
fi
echo ""

# AI INSTRUCTIONS
cat << 'EOF'
=== AI INSTRUCTIONS ===
System: HA Green 2025.12.5 @ ha.myhomehub13.xyz
User: John Spencer | Strum, WI

Key Entity IDs:
- device_tracker.john_s_phone
- device_tracker.alaina_s_iphone_17
- device_tracker.ellas_iphone
- light.ratgdo32disco_fd8d8c_light (North garage)
- light.ratgdo32disco_5735e8_light (South garage)

Response Requirements:
✓ Chain commands with &&
✓ Run 'ha core check' before 'ha core restart'
✓ Copy/paste ready terminal commands
✓ Natural prose, not bullets (unless requested)
✓ Token-efficient, no verbose explanations

=== Paste above + describe your issue ===
EOF
