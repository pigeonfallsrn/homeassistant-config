#!/bin/bash
# Minimal context for LLM - token efficient
echo "# HA Context $(date '+%Y-%m-%d %H:%M')"
echo "## Stats"
echo "Entities: $(curl -s "http://supervisor/core/api/states" -H "Authorization: Bearer $SUPERVISOR_TOKEN"|grep -o '"entity_id"'|wc -l)"
echo "## Packages"
ls /config/packages/*.yaml 2>/dev/null|xargs -n1 basename
echo "## Recent Errors"
grep -i "error" /config/home-assistant.log 2>/dev/null|tail -3||echo "None"
echo "## Read: /config/hac/HAC_LLM_RULES.md"
