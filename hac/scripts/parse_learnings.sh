#!/bin/bash
# Parse HAC learnings and suggest prompt updates

echo "Parsing learnings for new patterns..."

# Extract recent learnings (last 30 days)
THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y-%m-%d)

# Analyze frequency of topics
echo ""
echo "📊 LEARNING FREQUENCY (Last 30 days):"
grep "^- $(date +%Y-%m)" /homeassistant/hac_learnings.md | \
  sed 's/^- [0-9:-]\+ //' | \
  awk '{
    for(i=1; i<=NF; i++) {
      word=tolower($i)
      gsub(/[^a-z0-9]/, "", word)
      if(length(word) > 4) freq[word]++
    }
  }
  END {
    for(w in freq) if(freq[w] > 2) print freq[w], w
  }' | sort -rn | head -20

echo ""
echo "💡 SUGGESTED PROMPT ADDITIONS:"
echo "Review frequent terms above and consider adding to optimized_session_prompt_v2.md"
