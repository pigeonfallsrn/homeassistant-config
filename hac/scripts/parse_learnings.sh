#!/bin/bash
# Parse HAC learnings and suggest prompt updates (Alpine Linux compatible)

echo "Parsing learnings for new patterns..."

# Get learnings from last 30 entries instead of date-based
echo ""
echo "📊 RECENT LEARNING FREQUENCY (Last 30 entries):"
tail -30 /homeassistant/hac_learnings.md | \
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
echo "🔍 PATTERN ANALYSIS:"
echo ""

# Extract automation patterns
echo "Automation patterns mentioned:"
grep -i "mode:\|trigger:\|automation\|motion" /homeassistant/hac_learnings.md | \
  grep -v "^#" | tail -10 | sed 's/^- [0-9:-]\+ /  /'

echo ""
echo "MCP/Privacy mentions:"
grep -i "mcp\|privacy\|exposure\|blocked" /homeassistant/hac_learnings.md | \
  tail -5 | sed 's/^- [0-9:-]\+ /  /'

echo ""
echo "Terminal/workflow issues:"
grep -i "heredoc\|terminal\|zsh\|quote" /homeassistant/hac_learnings.md | \
  tail -5 | sed 's/^- [0-9:-]\+ /  /'

echo ""
echo "💡 PROMPT IMPROVEMENT SUGGESTIONS:"
echo "  1. Review frequent terms above"
echo "  2. Check if they're in optimized_session_prompt_v2.md"
echo "  3. Add missing critical patterns"
echo "  4. Remove outdated/superseded learnings"
