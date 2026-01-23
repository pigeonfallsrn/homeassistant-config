#!/bin/bash
OUTPUT_DIR="/config/ai_context"
CONTEXT_FILE="$OUTPUT_DIR/ha_context_latest.txt"
mkdir -p "$OUTPUT_DIR"

cat > "$CONTEXT_FILE" << 'CONTEXT_START'
================================================================================
HOME ASSISTANT SYSTEM CONTEXT
Generated: $(date '+%Y-%m-%d %H:%M:%S')
System: HA Green 2025.12.4
User: John Spencer | Strum, WI
================================================================================

## SYSTEM STATUS
CONTEXT_START

ha core info >> "$CONTEXT_FILE"
echo -e "\n## RECENT ERRORS (Last 30, deduplicated)" >> "$CONTEXT_FILE"
ha core logs -n 1000 | grep -iE "(error|critical)" | awk '{$1=$2=$3=""; print $0}' | sort -u | tail -30 >> "$CONTEXT_FILE"
echo -e "\n## RECENT WARNINGS (Last 10)" >> "$CONTEXT_FILE"
ha core logs -n 500 | grep -i "warning" | awk '{$1=$2=$3=""; print $0}' | sort -u | tail -10 >> "$CONTEXT_FILE"
echo -e "\n## CONFIGURATION VALIDATION" >> "$CONTEXT_FILE"
ha core check >> "$CONTEXT_FILE" 2>&1

cat >> "$CONTEXT_FILE" << 'CONTEXT_END'

================================================================================
AI INSTRUCTIONS
================================================================================

System: HA Green 2025.12.4 @ ha.myhomehub13.xyz
User: John Spencer | Strum, WI

Response format:
- Chain commands with &&
- Run 'ha core check' before 'ha core restart'
- Token-efficient, no verbose explanations
- Terminal commands only

Key entities:
- device_tracker.john_s_phone
- device_tracker.alaina_s_iphone_17
- device_tracker.ellas_iphone
- light.ratgdo32disco_fd8d8c_light (North garage)
- light.ratgdo32disco_5735e8_light (South garage)

================================================================================
CONTEXT_END

echo "Context exported: $(date)" > "$OUTPUT_DIR/last_export.txt"
echo "Context exported to: $CONTEXT_FILE"
