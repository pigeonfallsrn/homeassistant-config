#!/bin/bash
echo "🔍 Creating comprehensive baseline..."

# Fetch all entity states from HA API
curl -s -X GET "http://supervisor/core/api/states" \
  -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
  -H "Content-Type: application/json" > /tmp/all_states.json

# Count entities by domain
jq -r '.[].entity_id' /tmp/all_states.json | cut -d. -f1 | sort | uniq -c > /tmp/entity_counts.txt

# Extract all entity IDs
jq -r '.[].entity_id' /tmp/all_states.json > /tmp/all_entities.txt

# Get system info
TIMESTAMP=$(date +"%Y%m%d")
HA_VERSION=$(ha core info --raw-json | jq -r '.data.version')

# Create JSON baseline
cat > /config/ai_context/BASELINE_${TIMESTAMP}.json << JSONEOF
{
  "generated_at": "$(date -Iseconds)",
  "ha_version": "${HA_VERSION}",
  "system": {
    "url": "http://homeassistant.local:8123",
    "network": "192.168.1.3/24"
  },
  "user_preferences": {
    "shell": "zsh",
    "zigbee": "ZHA (not Zigbee2MQTT)",
    "command_style": "one at a time, && chains acceptable",
    "verification": "ha core check before restart"
  },
  "entity_counts": $(cat /tmp/entity_counts.txt | awk '{print "\"" $2 "\": " $1}' | paste -sd ',' | sed 's/^/{/' | sed 's/$/}/'),
  "all_entities": $(jq -R . /tmp/all_entities.txt | jq -s .),
  "full_state": $(cat /tmp/all_states.json)
}
JSONEOF

# Create human-readable summary
cat > /config/ai_context/BASELINE_SUMMARY.txt << SUMEOF
HA BASELINE SNAPSHOT
Generated: $(date)
HA Version: ${HA_VERSION}

ENTITY COUNTS BY DOMAIN:
$(cat /tmp/entity_counts.txt)

TOTAL ENTITIES: $(wc -l < /tmp/all_entities.txt)

USER PREFERENCES:
- Shell: ZSH terminal
- Zigbee: ZHA (not Zigbee2MQTT)
- Commands: One at a time, && chains acceptable
- Always: ha core check before ha core restart

SYSTEM INFO:
- URL: http://homeassistant.local:8123
- Network: 192.168.1.3/24

FILES:
- Full JSON: /config/ai_context/BASELINE_${TIMESTAMP}.json
- This summary: /config/ai_context/BASELINE_SUMMARY.txt
SUMEOF

echo "✅ Baseline created!"
echo "📁 Summary: /config/ai_context/BASELINE_SUMMARY.txt"
echo "📁 Full data: /config/ai_context/BASELINE_${TIMESTAMP}.json"
