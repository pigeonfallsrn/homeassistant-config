# HAC v4.2 - Complete Documentation

**Version:** 4.2
**Date:** January 17, 2026
**Status:** ✅ Production Ready

## Commands

### AI-Specific Contexts
- `hac claude` - Comprehensive markdown for Claude
- `hac gemini` - Structured quick format for Gemini  
- `hac gpt` - Conversational format for ChatGPT

### Specialized
- `hac tablet` - Kitchen tablet entities
- `hac search <term>` - Search entities
- `hac check` - System health
- `hac list` - List contexts

## Kitchen Tablet Status

✅ 4 Automations Active:
1. Wake on Activity
2. Sleep After Inactivity (5 min)
3. Power Off When Everyone Away
4. Wake When Someone Arrives

## Files
- Script: /config/hac/hac.sh
- Contexts: /config/hac/contexts/
- Automations: /config/automations/kitchen_tablet_wake.yaml
- Automations: /config/automations/tablet_power.yaml

## Usage
1. Run `hac claude` (or gemini/gpt)
2. Copy output between lines
3. Paste into AI chat with your question

✅ Ready to use!
