#!/bin/bash
# HAC Gist Sync v2.1 - Comprehensive context for Claude
# Syncs multiple files to single gist

GITHUB_TOKEN="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"
GIST_ID="b8a59919b8f0b71942fc21c10398f9a7"
GIST_URL="https://gist.githubusercontent.com/pigeonfallsrn/$GIST_ID/raw"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
HA_VERSION=$(cat /config/.HA_VERSION 2>/dev/null || echo "unknown")

# Create temp directory for all files
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# ═══════════════════════════════════════════════════════════
# FILE 1: README + Rules
# ═══════════════════════════════════════════════════════════
cat > "$TMPDIR/00_README.md" << EOF
# Home Assistant Context - John Spencer
**Location:** 40154 US Hwy 53, Strum, WI
**Updated:** $TIMESTAMP
**Version:** $HA_VERSION

## File Index
| File | Contents |
|------|----------|
| 01_status.md | Live status: people, modes, triggers, errors |
| 02_packages.md | All automation YAML from /config/packages/ |
| 03_knowledge.md | System architecture + learnings |
| 04_sessions.md | Recent session notes |

## LLM Rules
1. **Terminal only** - Never suggest GUI actions
2. **&& chaining** - Combine commands efficiently
3. **Propose → Approve → Execute** - Wait for 'yes' before running
4. **Never output secrets/tokens**
5. **Package files** in \`/config/packages/*.yaml\`
6. **Database** at \`/config/home-assistant_v2.db\`

## HAC Commands
| Command | Description |
|---------|-------------|
| \`hac push\` | Sync context to this gist |
| \`hac status\` | System health overview |
| \`hac errors [N]\` | Recent errors |
| \`hac auto\` | List all automations |
| \`hac triggers N\` | Recent automation triggers |
| \`hac learn "note"\` | Add session learning |
| \`hac session "title"\` | Start new session file |
EOF

# ═══════════════════════════════════════════════════════════
# FILE 2: Live Status
# ═══════════════════════════════════════════════════════════
{
  echo "# HA Status - $TIMESTAMP"
  echo "Version: $HA_VERSION"
  echo ""
  echo "## People"
  curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | \
    grep -oE '"entity_id":"person\.[^"]*","state":"[^"]*"' | \
    sed 's/"entity_id":"person\.//;s/","state":"/: /;s/"$//' || echo "API unavailable"
  echo ""
  echo "## Modes"
  for ib in entry_room_manual_override bathroom_manual_override kitchen_lounge_manual_override \
            hot_tub_mode living_room_manual_override kids_bedtime_override extended_evening \
            john_home alaina_home ella_home michelle_home someone_home girls_home both_girls_home \
            dad_bedtime_mode party_mode guest_present school_tomorrow; do
    state=$(curl -s "http://supervisor/core/api/states/input_boolean.$ib" -H "Authorization: Bearer $SUPERVISOR_TOKEN" 2>/dev/null | grep -oE '"state":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "$ib: ${state:-unavailable}"
  done
  echo ""
  echo "## Triggers (last 20)"
  sqlite3 /config/home-assistant_v2.db "
SELECT datetime(s.last_updated_ts,'unixepoch','localtime') || '|' || replace(m.entity_id,'automation.','')
FROM states s 
JOIN states_meta m ON s.metadata_id=m.metadata_id 
WHERE m.entity_id LIKE 'automation.%' AND s.state='on' 
ORDER BY s.last_updated_ts DESC LIMIT 20;" 2>/dev/null || echo "DB query failed"
  echo ""
  echo "## Errors (last 10)"
  grep -iE "error|warning" /config/home-assistant.log 2>/dev/null | grep -v "unknown_error_type" | tail -10 || echo "None"
  echo ""
  echo "## Entity Counts"
  grep '"entity_id"' /config/.storage/core.entity_registry 2>/dev/null | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | cut -d. -f1 | sort | uniq -c | sort -rn | head -15
} > "$TMPDIR/01_status.md"

# ═══════════════════════════════════════════════════════════
# FILE 3: All Package Files
# ═══════════════════════════════════════════════════════════
{
  echo "# HA Packages - $TIMESTAMP"
  echo "All automation packages from /config/packages/"
  echo ""
  for pkg in /config/packages/*.yaml; do
    [ -f "$pkg" ] || continue
    filename=$(basename "$pkg")
    echo "## $filename"
    echo '```yaml'
    cat "$pkg" | sed -E 's/(password|token|api_key|secret)["\s:=]+["\s]*[^"\s,}]+/\1: [REDACTED]/gi'
    echo '```'
    echo ""
  done
} > "$TMPDIR/02_packages.md"

# ═══════════════════════════════════════════════════════════
# FILE 4: System Knowledge + Learnings
# ═══════════════════════════════════════════════════════════
{
  echo "# System Knowledge - $TIMESTAMP"
  echo ""
  cat /config/hac/SYSTEM_KNOWLEDGE.md 2>/dev/null || echo "No SYSTEM_KNOWLEDGE.md found"
  echo ""
  echo "---"
  echo ""
  echo "## LLM Rules Reference"
  cat /config/hac/HAC_LLM_RULES.md 2>/dev/null || echo "No HAC_LLM_RULES.md found"
  echo ""
  echo "---"
  echo ""
  echo "## Learnings Archive"
  cat /config/hac/learnings/*.md 2>/dev/null | tail -100 || echo "No learnings yet"
} > "$TMPDIR/03_knowledge.md"

# ═══════════════════════════════════════════════════════════
# FILE 5: Recent Sessions
# ═══════════════════════════════════════════════════════════
{
  echo "# Recent Sessions - $TIMESTAMP"
  echo ""
  for f in $(ls -t /config/hac/contexts/session_*.md 2>/dev/null | head -5); do
    echo "---"
    echo "## $(basename "$f")"
    cat "$f"
    echo ""
  done
  for f in $(ls -t /config/hac/SESSION_*.md 2>/dev/null | head -3); do
    echo "---"
    echo "## $(basename "$f")"
    head -100 "$f"
    echo ""
  done
} > "$TMPDIR/04_sessions.md"

# ═══════════════════════════════════════════════════════════
# SYNC TO GIST - Using Python to build JSON from files
# ═══════════════════════════════════════════════════════════
python3 - "$TMPDIR" << 'PYEOF' > "$TMPDIR/payload.json"
import json
import sys
import os

tmpdir = sys.argv[1]
files = {}
for fname in ["00_README.md", "01_status.md", "02_packages.md", "03_knowledge.md", "04_sessions.md"]:
    fpath = os.path.join(tmpdir, fname)
    if os.path.exists(fpath):
        with open(fpath, 'r') as f:
            files[fname] = {"content": f.read()}

print(json.dumps({"files": files}))
PYEOF

RESPONSE=$(curl -s -X PATCH "https://api.github.com/gists/$GIST_ID" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d @"$TMPDIR/payload.json")

# Check for errors
if echo "$RESPONSE" | grep -q '"html_url"'; then
  echo "✓ Gist synced successfully"
else
  echo "✗ Gist sync failed:"
  echo "$RESPONSE" | head -5
fi

# Also sync to Google Drive if mounted
if mountpoint -q /mnt/gdrive 2>/dev/null; then
  cp "$TMPDIR/00_README.md" /mnt/gdrive/
  cp "$TMPDIR/01_status.md" /mnt/gdrive/
  cp "$TMPDIR/02_packages.md" /mnt/gdrive/
  cp "$TMPDIR/03_knowledge.md" /mnt/gdrive/
  cp "$TMPDIR/04_sessions.md" /mnt/gdrive/
  echo "✓ Google Drive synced"
fi

# OUTPUT FOR LLM
cat << LLMOUT
═══════════════════════════════════════════════════════════
CLAUDE: Fetch these URLs:
  $GIST_URL/00_README.md   (start here)
  $GIST_URL/01_status.md   (live status)
  $GIST_URL/02_packages.md (all automations)
  $GIST_URL/03_knowledge.md (system docs)
═══════════════════════════════════════════════════════════
Rules: Terminal only | && chaining | Propose→approve→execute
Commands: hac push | hac status | hac learn "note"
═══════════════════════════════════════════════════════════
LLMOUT
