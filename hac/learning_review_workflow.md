# HAC Learning Review Workflow

## Weekly Learning Review (Every Sunday)

### Step 1: Parse Recent Learnings
```bash
/homeassistant/hac/scripts/parse_learnings.sh
```

### Step 2: Identify New Patterns
Look for themes appearing 3+ times in recent learnings:
- New automation patterns
- Repeated errors/issues
- Terminal workflow improvements
- Device-specific quirks
- MCP/privacy adjustments

### Step 3: Update Session Prompt
```bash
# Add new critical patterns to v2 prompt
echo "New pattern: ..." >> /homeassistant/hac/prompt_updates_queue.txt
```

### Step 4: Clean Superseded Learnings
When a learning is incorporated into the prompt or resolved:
```bash
# Mark as incorporated
hac learn "RESOLVED: [old issue] - now documented in optimized_session_prompt_v2.md"
```

## Monthly Deep Review (1st of Month)

### Compare Against:
1. HA community forums (new best practices)
2. Adaptive Lighting updates
3. ZHA coordinator improvements
4. New device integrations

### Update:
- best_practices_alignment.md
- optimized_session_prompt_v2.md
- HAC command aliases (if needed)

## Continuous Learning Rules

### Always Log:
- Repeated errors (3+ occurrences = add to prompt)
- New device quirks (Inovelli, Hue, ZHA behaviors)
- Terminal command patterns (what works efficiently)
- Automation mode/trigger discoveries

### Never Log:
- One-off issues
- User-specific temporary states
- Debugging steps (only log solutions)

## Integration with Git

After prompt updates:
```bash
cd /homeassistant && \
git add hac/optimized_session_prompt_v2.md hac/best_practices_alignment.md && \
git commit -m "HAC: Updated prompts based on learning review $(date +%Y-%m-%d)" && \
git push
```
