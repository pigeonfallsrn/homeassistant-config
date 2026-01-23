#!/bin/bash
# Sync HA context to dpaste for Claude to read

CONTENT=$(cat << INNER
# HA Context - $(date '+%Y-%m-%d %H:%M')
Version: $(ha core info 2>/dev/null | grep 'version:' | cut -d' ' -f2)

## People
$(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | grep -oE '"entity_id":"person\.[^"]*","state":"[^"]*"' | sed 's/"entity_id":"person\.//;s/","state":"/: /;s/"$//')

## Modes  
$(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" | grep -oE '"entity_id":"input_boolean\.[^"]*","state":"[^"]*"' | grep -E 'home|mode|override' | sed 's/"entity_id":"input_boolean\.//;s/","state":"/: /;s/"$//')

## Errors
$(grep -i "error" /config/home-assistant.log 2>/dev/null | tail -5 || echo "None")
INNER
)

# Post to dpaste and get URL
RESPONSE=$(curl -s -X POST "https://dpaste.org/api/" -d "content=$CONTENT" -d "syntax=text" -d "expiry_days=30")
echo "Context URL: $RESPONSE"
echo "$RESPONSE" > /config/hac/latest_dpaste_url.txt
