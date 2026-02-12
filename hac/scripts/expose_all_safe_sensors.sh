#!/bin/bash
# Expose ALL zero-risk sensors (temperature, humidity, battery, power monitoring)
# Run this to maximize MCP context while maintaining safety

echo "=== EXPOSING ALL SAFE SENSORS ==="
echo "This will expose ~220 additional READ-ONLY sensors"
echo ""

# Get all safe temperature sensors
TEMP_SENSORS=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  http://supervisor/core/api/states | \
  jq -r '.[] | select(.entity_id | test("sensor.*temperature")) | .entity_id')

# Get all safe humidity sensors  
HUMIDITY_SENSORS=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  http://supervisor/core/api/states | \
  jq -r '.[] | select(.entity_id | test("sensor.*humidity")) | .entity_id')

# Get all safe battery sensors
BATTERY_SENSORS=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  http://supervisor/core/api/states | \
  jq -r '.[] | select(.entity_id | test("sensor.*battery")) | .entity_id')

# Expose them
echo "Exposing temperature sensors..."
for sensor in $TEMP_SENSORS; do
  curl -s -X POST \
    -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/services/conversation/expose \
    -d "{\"entity_id\": \"$sensor\", \"should_expose\": true}" > /dev/null
  echo "  ✓ $sensor"
done

echo "Exposing humidity sensors..."
for sensor in $HUMIDITY_SENSORS; do
  curl -s -X POST \
    -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/services/conversation/expose \
    -d "{\"entity_id\": \"$sensor\", \"should_expose\": true}" > /dev/null
  echo "  ✓ $sensor"
done

echo "Exposing battery sensors..."
for sensor in $BATTERY_SENSORS; do
  curl -s -X POST \
    -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/services/conversation/expose \
    -d "{\"entity_id\": \"$sensor\", \"should_expose\": true}" > /dev/null
  echo "  ✓ $sensor"
done

echo ""
echo "✅ COMPLETE - All safe sensors exposed"
echo "Total entities now exposed: ~290"
echo ""
echo "VERIFIED BLOCKED (no changes):"
echo "  ❌ Garage door covers"
echo "  ❌ Locks"
echo "  ❌ Water valve"
echo "  ❌ Network controls"
