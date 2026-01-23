#!/bin/bash
echo "🔍 Validating configuration..."
ha core check > /tmp/config_check.txt 2>&1

# Filter out the DockerMount bug (not a real error)
grep -v "DockerMount is not JSON serializable" /tmp/config_check.txt > /tmp/config_check_filtered.txt

if grep -q "successfully" /tmp/config_check_filtered.txt || [ ! -s /tmp/config_check_filtered.txt ]; then
  CONFIG_STATUS="✅ Valid"
else
  CONFIG_STATUS="❌ ERRORS"
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_DIR="/config/ai_context/sessions/${TIMESTAMP}"
mkdir -p "${SESSION_DIR}"

# Get system info
ha core info --raw-json > "${SESSION_DIR}/system_info.json"
VERSION=$(jq -r '.data.version' "${SESSION_DIR}/system_info.json")

# Get entity counts
curl -s -X GET "http://supervisor/core/api/states" \
  -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
  -H "Content-Type: application/json" > "${SESSION_DIR}/all_states.json"

LIGHT_COUNT=$(jq '[.[] | select(.entity_id | startswith("light."))] | length' "${SESSION_DIR}/all_states.json")
AUTO_COUNT=$(jq '[.[] | select(.entity_id | startswith("automation."))] | length' "${SESSION_DIR}/all_states.json")

# Get recent errors (last 20, deduplicated)
ha core log | grep -i "error" | tail -20 | sort -u > "${SESSION_DIR}/recent_errors.txt"
ERROR_COUNT=$(wc -l < "${SESSION_DIR}/recent_errors.txt")

# Save config check
cp /tmp/config_check_filtered.txt "${SESSION_DIR}/config_check.txt"

# Update symlink
rm -f /config/ai_context/latest_session
ln -s "${SESSION_DIR}" /config/ai_context/latest_session

# TOKEN-EFFICIENT OUTPUT
cat << AIEOF
════════════════════════════════════════════════════════════
HOME ASSISTANT CONTEXT - $(date '+%Y-%m-%d %H:%M')
Session: ${TIMESTAMP}
════════════════════════════════════════════════════════════

SYSTEM: HA ${VERSION} | Config: ${CONFIG_STATUS}
ENTITIES: ${LIGHT_COUNT} lights | ${AUTO_COUNT} automations
ERRORS: ${ERROR_COUNT} recent

$(if [ ${ERROR_COUNT} -gt 0 ]; then
  echo "⚠️ RECENT ERRORS:"
  head -5 "${SESSION_DIR}/recent_errors.txt" | sed 's/^/  /'
  if [ ${ERROR_COUNT} -gt 5 ]; then
    echo "  ... ($(($ERROR_COUNT - 5)) more, run: haclogs)"
  fi
else
  echo "✅ No recent errors"
fi)

$(if [ "$CONFIG_STATUS" = "❌ ERRORS" ] && [ -s /tmp/config_check_filtered.txt ]; then
  echo "⚠️ CONFIG ERRORS:"
  cat /tmp/config_check_filtered.txt | sed 's/^/  /'
fi)

────────────────────────────────────────────────────────────
📁 Session: ${SESSION_DIR}
💬 hac | haclogs | hacerrors | haclearn "note"
────────────────────────────────────────────────────────────
AIEOF
