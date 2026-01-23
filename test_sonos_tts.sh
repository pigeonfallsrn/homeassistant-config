#!/bin/bash
curl -X POST http://localhost:8123/api/services/tts/speak \
  -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "entity_id": "media_player.kitchen_2",
    "media_player_entity_id": "media_player.kitchen_2",
    "message": "Test doorbell announcement"
  }'
