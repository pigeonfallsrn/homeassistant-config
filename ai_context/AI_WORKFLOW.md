# STREAMLINED AI COLLABORATION WORKFLOW

## THE PROBLEM
Current workflow is clunky:
- HAC alias doesn't persist
- Heredoc quote traps in terminal
- No standard "export for AI" command
- Each AI needs manual context feeding

## THE SOLUTION: 3-Step Pattern

### STEP 1: HAC EXPORT (Run This First)
**Purpose**: Generate complete context package for ANY AI
```bash
# New command to add to HAC
hac export
```

**What it does**:
1. Exports all critical context to single file
2. Includes: learnings, automations, entities, current status
3. Creates `/config/ai_context/AI_PACKAGE.txt`
4. Token-optimized (under 10K tokens)
5. Ready to paste to ANY AI

**Output Template**:
```
=== HOME ASSISTANT AI CONTEXT PACKAGE ===
Generated: [timestamp]
For: [AI name - Claude/Gemini/ChatGPT]

SYSTEM STATUS:
- Automations: 17 active
- Lights: 505 entities
- Person tracking: 7 entities
- Network: 3 properties (40154/40062/40003)

RECENT LEARNINGS (last 10):
[learnings here]

CURRENT PRIORITIES:
[from MASTER_PROJECT_PLAN.md Tier 1]

AVAILABLE ENTITIES (sample):
[key entities only - lights, climate, people]

CONTEXT FILES AVAILABLE:
- Read full details: /config/ai_context/MASTER_PROJECT_PLAN.md
- Family info: /config/ai_context/family_structure.md
- HVAC: /config/ai_context/heating_systems.md

AI INSTRUCTIONS:
1. Review this package
2. Ask questions about specific entities/automations
3. Generate commands for John to run
4. John will paste outputs back to you
5. You analyze and recommend next steps
6. John runs: hac learn "your recommendation"

=== END PACKAGE ===
```

### STEP 2: AI ANALYZES & RECOMMENDS
**AI receives**: The export package above (paste into chat)

**AI should**:
1. Confirm understanding of system
2. Ask for specific command outputs if needed
3. Generate commands (John executes)
4. Analyze results
5. Provide recommendation

**Example**:
```
AI: "I see you have 505 light entities. To help with garage lighting, 
run this command and paste the output:

hac entity 'garage' | grep light

Then I'll recommend the automation approach."
```

### STEP 3: COMMIT LEARNING
**After completing task**:
```bash
hac learn "[AI name] [date]: [what was accomplished] [key decision/finding]"
```

**Example**:
```bash
hac learn "Claude 2026-01-16: Analyzed garage lighting (6 Hue bulbs). 
Recommended Inovelli VZM31-SN switches for reliability. 
Avoid heredoc - use simple cat > file approach instead."
```

---

## PERSISTENT HAC FIX

**Problem**: Alias doesn't survive sessions

**Solution**: Add to ~/.zshrc permanently
```bash
echo 'alias hac="/root/hac.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## SIMPLIFIED FILE CREATION (No More Quote Traps!)

**OLD WAY** (causes issues):
```bash
cat > file.md << 'EOF'
[content with special chars]
EOF
```

**NEW WAY** (reliable):
```bash
cat > /tmp/temp_file.txt
[Paste content here]
[Ctrl+D to save]
mv /tmp/temp_file.txt /config/ai_context/target.md
```

Or even simpler - use File Editor in HA UI!

---

## ENHANCED HAC COMMANDS NEEDED

### hac export
Generates AI context package

### hac onboard
Shows AI onboarding checklist

### hac learn
Already exists - keep using it

### hac sync
Syncs context to Google Drive (future)

---

## AI COLLABORATION RULES (SIMPLIFIED)

**For ANY AI (Claude, Gemini, ChatGPT)**:

1. **John starts with**: `hac export > ai_package.txt && cat ai_package.txt`
2. **John pastes package** to AI chat
3. **AI confirms understanding** (1-2 sentence summary)
4. **AI requests specific data** (generates commands)
5. **John runs commands**, pastes outputs
6. **AI analyzes**, provides recommendation
7. **John executes recommendation** (if approved)
8. **John logs it**: `hac learn "AI-name: what happened"`

**THAT'S IT!** No complexity, no quote traps, no filesystem confusion.

---

## LEARNING COMMITMENT RULES

**What to log with `hac learn`**:
- ✅ Successful solutions to problems
- ✅ Configuration decisions and why
- ✅ "Simpler approach" discoveries
- ✅ Integration details that work
- ✅ AI collaboration insights
- ❌ NOT: Routine status checks
- ❌ NOT: Temporary debugging

**Format**:
```
[YYYY-MM-DD HH:MM] [Context]: [Action/Decision] [Outcome/Reason]
```

**Examples**:
```
[2026-01-16 17:15] Garage lighting: Chose Inovelli switches over automation-only. Reason: 4 bulbs not wired hot, reliability critical.

[2026-01-16 17:20] Shell scripting: Avoid heredoc with special chars in zsh. Use simple cat or File Editor instead. Prevents quote traps.

[2026-01-16 17:25] AI workflow: Created hac export command for standardized AI handoffs. Reduces token usage, eliminates confusion.
```

---

## WORKFLOW DIAGRAM
```
┌─────────────┐
│ John runs:  │
│ hac export  │
└──────┬──────┘
       │
       v
┌─────────────────────┐
│ Generates package   │
│ with all context    │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│ John pastes to AI   │
│ (Claude/Gemini/etc) │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│ AI analyzes &       │
│ requests data       │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│ John runs commands  │
│ & pastes outputs    │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│ AI recommends       │
│ solution            │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│ John executes &     │
│ runs: hac learn     │
└─────────────────────┘
```

---

## NEXT: IMPLEMENT THIS WORKFLOW

1. Enhance HAC with `export` command
2. Add persistent alias to ~/.zshrc
3. Create simplified file creation guide
4. Test with next AI collaboration

