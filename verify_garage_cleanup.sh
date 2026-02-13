#!/bin/bash
echo "=== Garage Automation Status ==="
echo ""
echo "Total garage automations:"
curl -s http://localhost:8123/api/states | jq '[.[] | select(.entity_id | startswith("automation.garage"))] | length'
echo ""
echo "Working (on):"
curl -s http://localhost:8123/api/states | jq '[.[] | select(.entity_id | startswith("automation.garage")) | select(.state == "on")] | length'
echo ""
echo "Unavailable:"
curl -s http://localhost:8123/api/states | jq '[.[] | select(.entity_id | startswith("automation.garage")) | select(.state == "unavailable")] | length'
echo ""
echo "All garage automations:"
curl -s http://localhost:8123/api/states | jq -r '.[] | select(.entity_id | startswith("automation.garage")) | "\(.state): \(.entity_id)"' | sort
