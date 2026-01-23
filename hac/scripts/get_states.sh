#!/bin/bash
# Get all entity states via API
curl -s -X GET \
  -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
  -H "Content-Type: application/json" \
  http://supervisor/core/api/states | \
  jq -r '.[].entity_id' | sort
