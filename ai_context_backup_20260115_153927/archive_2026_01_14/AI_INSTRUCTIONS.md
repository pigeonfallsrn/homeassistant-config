# HOME ASSISTANT CONTEXT SYSTEM - AI GUIDE

## For ChatGPT, Gemini, and Claude

This document teaches you how to work effectively with John's Home Assistant setup.

---

## 🎯 THE HAC SYSTEM

John runs `hac` in his Home Assistant terminal, which generates a diagnostic summary. When he pastes that output to you, here's what you're seeing:

### Architecture
1. **Baseline** (1.5MB JSON) - All 2,912 entities, created quarterly
   - Location: `/config/ai_context/BASELINE_20260106.json`
   - Summary: `/config/ai_context/BASELINE_SUMMARY.txt`
   
2. **Session Export** (~40 lines) - Current status, generated in 2 seconds
   - Location: `/config/ai_context/sessions/TIMESTAMP/`
   - Contains: system info, entity counts, recent errors, automations
   
3. **Learning Log** - Persistent lessons across all AI sessions
   - Location: `/config/ai_context/session_learnings.txt`
   - Updated with: `haclearn "lesson learned"`

---

## 📋 CRITICAL: JOHN'S PREFERENCES

**ALWAYS follow these rules:**

### Terminal & Commands
- ✅ Terminal: ZSH on Home Assistant OS (not bash prompts)
- ✅ Commands: **ONE at a time** - wait for output before next
- ✅ Chaining: `&&` chains are acceptable (e.g., `cmd1 && cmd2`)
- ✅ Validation: **ALWAYS** run `ha core check` before `ha core restart`
- ❌ Never: Multi-line scripts without testing each step first

### Technology Choices
- ✅ Zigbee: **ZHA** (never suggest Zigbee2MQTT)
- ✅ Network: UniFi ecosystem
- ✅ NAS: Synology DS224+ with Google Drive sync
- ✅ Security: Conscious, uses Cloudflare tunnels
- ❌ Never: Suggest replacing his working infrastructure

### Communication Style
- ✅ Direct, technical, assume competence
- ✅ Explain *why* behind recommendations
- ✅ Show commands, don't just describe
- ❌ No: Hand-holding, over-explaining basics, "let's walk through"

---

## 🔧 HOW TO TROUBLESHOOT WITH JOHN

### Step 1: Understand the Context
When John pastes `hac` output, you see:
- System version and config status
- Entity counts (lights, switches, sensors, automations)
- Recent errors from logs
- Sample automations
- Inovelli switch inventory

### Step 2: Reference the Baseline (When Needed)
If you need detailed entity information:
```
"Check the baseline at /config/ai_context/BASELINE_SUMMARY.txt 
for full entity details on [specific device]"
```

### Step 3: Provide Commands ONE at a Time
**GOOD:**
```bash
# First, let's check the current state
ha core check
```
*[Wait for John's output]*

**BAD:**
```bash
# Let's do all these steps
ha core check
ha core restart
curl -X GET http://supervisor/core/api/states
# etc...
```

### Step 4: Test Before Restart
```bash
# After making changes
ha core check

# ONLY if valid:
ha core restart
```

---

## 📚 KEY LEARNINGS (From Claude Sessions)

### Home Assistant OS Environment
1. **HA API format**: Returns flat JSON array, not nested by domain
2. **No yq**: Only `jq` is available for JSON parsing
3. **Tools available**: bash, curl, jq, ha CLI, Python 3
4. **Paths**: Use `/config/` for persistent files

### Common Patterns
1. **Entity state query**: 
```bash
   curl -s -X GET "http://supervisor/core/api/states" \
     -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
     -H "Content-Type: application/json"
```

2. **Config validation**:
```bash
   ha core check
```

3. **View logs**:
```bash
   ha core log | tail -20
```

### Inovelli Switch Configuration
- 13 total switches (10 VZM31-SN dimmers, 3 VZM36 fan/light combos)
- Blueprint available: `/config/blueprints/fxlt/zha-inovelli-vzm31-sn-blue-series-2-1-switch.yaml`
- Supports: button press, hold, release, 2x-5x taps
- ZHA events trigger automations

---

## 🔄 WORKFLOW WITH JOHN

### Standard Troubleshooting Session
1. John runs: `hac`
2. John pastes output to you
3. You read the summary + reference baseline if needed
4. You provide **one command** to diagnose/fix
5. John executes and shares output
6. Repeat steps 4-5 until resolved
7. John runs: `haclearn "solution we found"`

### When You Don't Know Something
**DON'T:** Make assumptions or guess
**DO:** Ask John directly:
```
"Can you run this to check: [specific command]"
```

### Referencing Past Sessions
The learning log contains previous solutions. Reference it:
```
"Based on our previous learning about [topic], try..."
```

---

## 🚨 CRITICAL REMINDERS

### Never Do This
- ❌ Run `ha core restart` without `ha core check` first
- ❌ Suggest Zigbee2MQTT as an alternative to ZHA
- ❌ Provide multiple commands without waiting for output
- ❌ Make assumptions about John's infrastructure
- ❌ Suggest cloud services when local solutions exist

### Always Do This
- ✅ Provide commands John can copy/paste directly
- ✅ Explain why you're suggesting each step
- ✅ Wait for John's output before next command
- ✅ Check logs when errors occur: `ha core log | tail -20`
- ✅ Respect John's time - be efficient and direct

---

## 💾 CAPTURING LEARNINGS

At the end of your session with John, **recommend** he capture the learning:
```bash
haclearn "concise description of what was solved"
```

This makes the solution available to future AI sessions (including you next time, ChatGPT, and Gemini).

---

## 🤝 CROSS-AI COLLABORATION

All of John's AI context syncs to Google Drive:
- **Path**: `\\DS224plus\GoogleDrive\AI_Context\`
- **Gemini**: Auto-indexes this folder for insights
- **ChatGPT/Claude**: References via John's pastes
- **Sync delay**: ~30 seconds from HA to Google Drive

When you learn something valuable, it becomes available to all AI tools John uses.

---

## 📖 QUICK REFERENCE

### John's Setup
- **HA Version**: 2025.12.5
- **Total Entities**: 2,912
- **Network**: 192.168.1.3/24 (UniFi)
- **Access**: http://homeassistant.local:8123
- **Zigbee**: ZHA coordinator

### Useful Commands
```bash
hac                          # Generate diagnostic context
haclearn "lesson"            # Record learning
ha core check                # Validate config
ha core restart              # Restart (after validation)
ha core log | tail -20       # View recent logs
cat /config/ai_context/BASELINE_SUMMARY.txt  # View full baseline
```

### When in Doubt
1. Ask John to run `hac` for fresh context
2. Reference the baseline for entity details
3. Check the learning log for past solutions
4. Provide ONE command at a time
5. Always validate before restarting

---

**Remember**: You're part of a collaborative AI team helping John maintain a complex smart home. Be precise, be efficient, and learn from each session to improve future interactions.

---

*Last updated: 2026-01-06*
*System version: 2025.12.5*
*Total entities: 2,912*
