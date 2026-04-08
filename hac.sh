#!/usr/bin/env zsh
# HAC v9.1 — Home Automation Context system
# Rebuilt 2026-04-08 after container wipe

KNOWLEDGE_FILE="/config/HAC_PROJECT_KNOWLEDGE_1.md"
HANDOFF_FILE="/config/HANDOFF.md"
CRITICAL_FILE="/config/CRITICAL_RULES.md"

case "$1" in
  learn)
    CATEGORY="$2"
    INSIGHT="$3"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
    echo "" >> "$KNOWLEDGE_FILE"
    echo "### [$TIMESTAMP] $CATEGORY" >> "$KNOWLEDGE_FILE"
    echo "- $INSIGHT" >> "$KNOWLEDGE_FILE"
    echo "✅ Learned [$CATEGORY]: $INSIGHT"
    ;;
  wrap)
    SUMMARY="$2"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
    echo "" >> "$HANDOFF_FILE"
    echo "## Session Wrap — $TIMESTAMP" >> "$HANDOFF_FILE"
    echo "$SUMMARY" >> "$HANDOFF_FILE"
    cd /config && git add -A && git commit -m "hac wrap: $SUMMARY" && GIT_TERMINAL_PROMPT=0 git push origin main
    echo "✅ Session wrapped and pushed"
    ;;
  backup)
    LABEL="${2:-manual}"
    echo "⚠️  Use MCP ha_backup_create for backups — hac backup is informational only"
    echo "Last backup should be named with Pre_ prefix via MCP"
    ;;
  mcp)
    echo "📋 HAC MCP Session Start"
    echo "Knowledge file: $KNOWLEDGE_FILE"
    echo "Critical rules: $CRITICAL_FILE"
    echo "Handoff: $HANDOFF_FILE"
    tail -50 "$KNOWLEDGE_FILE" 2>/dev/null
    ;;
  --version|-v)
    echo "HAC v9.1 — rebuilt 2026-04-08"
    ;;
  *)
    echo "HAC v9.1 commands: learn <CATEGORY> <insight> | wrap <summary> | mcp | backup"
    ;;
esac
