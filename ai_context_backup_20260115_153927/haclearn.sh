#!/bin/bash
# Capture session learnings

if [ -z "$1" ]; then
  echo "Usage: haclearn \"what we learned this session\""
  exit 1
fi

LEARNING="[$(date +"%Y-%m-%d %H:%M")] $1"

echo "${LEARNING}" >> /config/ai_context/session_learnings.txt

echo "✅ Learning recorded:"
echo "${LEARNING}"
echo ""
echo "📚 Recent learnings:"
tail -5 /config/ai_context/session_learnings.txt
