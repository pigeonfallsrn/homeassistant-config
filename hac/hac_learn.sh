#!/bin/bash
# hac learn "note" - Add learning to current session
SESSION_FILE="/config/hac/contexts/session_$(date +%Y%m%d).md"
TIMESTAMP=$(date '+%H:%M')

if [[ -z "$1" ]]; then
  echo "Usage: hac learn \"your learning note\""
  exit 1
fi

# Create session file if doesn't exist
if [[ ! -f "$SESSION_FILE" ]]; then
  echo "# Session $(date '+%Y-%m-%d')" > "$SESSION_FILE"
  echo "" >> "$SESSION_FILE"
fi

echo "- [$TIMESTAMP] $*" >> "$SESSION_FILE"
echo "✓ Added to $(basename $SESSION_FILE)"
