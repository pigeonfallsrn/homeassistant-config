# Automation System Recommendations
**Generated:** 2026-01-17  
**Status:** Action items prioritized and ready to execute

---

## 🚨 IMMEDIATE ACTIONS (Do Today)

### 1. Delete Deprecated Garage Automation
**Priority:** HIGH - Prevents conflicts with new system  
**Automation:** Garage All Lights OFF (ID: 1767207374114)  
**Reason:** Superseded by 5-automation intelligent garage system  

**Action Commands:**
```bash
# Backup first
cp /config/automations.yaml /config/automations.yaml.backup_delete_old_garage_$(date +%Y%m%d_%H%M%S)

# Remove the old automation
sed -i '/- id: .1767207374114/,/mode: restart/d' /config/automations.yaml

# Validate configuration
ha core check

# If validation passes, restart
ha core restart
```

**Verification:**
```bash
# Confirm it's gone (should return 0)
grep -c "1767207374114" /config/automations.yaml
```

---

### 2. Update "Everyone Away" Automation
**Priority:** HIGH - Missing person entity  
**Automation:** Everyone Away → All Lights Off  
**Issue:** Missing `person.michelle` from condition checks  
**Impact:** Lights may turn off even when Michelle is home

**Fix via UI:**
1. Settings → Automations & Scenes
2. Find "Everyone Away → All Lights Off"
3. Edit conditions
4. Add: State condition for person.michelle = not_home

**Or edit YAML directly - add to conditions:**
```yaml
  - condition: state
    entity_id: person.michelle
    state: not_home
```

---

## ⚙️ NEAR-TERM ACTIONS (This Week)

### 3. Test Garage System Real-World Usage
**Priority:** MEDIUM - Validate new automations  
**Duration:** 2-3 days of normal use

**What to watch:**
- ✅ Lights turn on when arriving home (door opens)
- ✅ Lights turn on when exiting house to garage (walk-in door)
- ✅ Lights stay on during garage work (motion keep-alive)
- ✅ Lights turn off 20sec after departure (door closes)
- ✅ False alarm cleanup works (open door briefly, no entry)

**Monitor logs:**
```bash
# Watch garage automation activity
grep -i garage /config/home-assistant.log | tail -50
```

---

### 4. Review Garage Hue Dimmer Switch Interaction
**Priority:** MEDIUM - May need coordination  
**Entity:** `switch.automation_garage_hue_dimmer_switch`  
**Question:** Does manual dimmer override conflict with automated system?

**Test:**
1. Use Hue dimmer to manually change garage lights
2. Verify automations don't immediately override
3. Test if dimmer can "hold" manual state

---

## 📈 MEDIUM-TERM (Next 2-4 Weeks)

### 5. Enhance "First Person Home" Automation
**Current:** Simple person.state = home trigger  
**Enhancement:** Multi-signal arrival confirmation using your documented pattern

**Your arrival pattern (2026-01-15):**
1. Presence changed to home (Wi-Fi)
2. Interior motion detected
3. Entry door opened
4. Vehicle detected

**Proposed improvement:**
- Stage 1: Presence changes to home
- Stage 2: Wait for motion OR door within 3 min
- Stage 3: If confirmed, turn on lights

---

## 📋 CHECKLIST

### This Week
- [ ] Delete old garage automation (ID: 1767207374114)
- [ ] Update "Everyone Away" to include Michelle
- [ ] Test new garage system (2-3 days)
- [ ] Review Hue dimmer interaction

### This Month  
- [ ] Enhance "First Person Home" automation
- [ ] Document garage system learnings
- [ ] Consider seasonal adjustments

### Backlog
- [ ] Garage-to-house lighting sequence
- [ ] Vehicle detection integration
- [ ] Adaptive brightness system
- [ ] Room presence tracking

---

## 🎯 SUCCESS METRICS

### Week 1 Goals
- ✅ Zero conflicts between old and new garage automations
- ✅ All person entities properly tracked
- ✅ Garage system tested in real-world

### Month 1 Goals
- ✅ Arrival detection upgraded to multi-signal
- ✅ All automations documented in HAC context
- ✅ No false triggers or missed events

---

## 📝 DOCUMENTATION COMMANDS
```bash
# Document audit completion
hac context add "automation_audit_2026-01-17" "Completed comprehensive automation review. 22 total: 17 keep, 3 update, 1 delete, 5 new garage system."

# Log specific changes
hac context add "everyone_away_automation" "Updated to include person.michelle in conditions."

# Track testing period
hac context add "garage_system_validation" "2026-01-17 to 2026-01-20: Testing 5-automation garage system."
```

---

## ⚠️ CRITICAL REMINDERS

1. **Always backup before edits**
2. **Always validate:** `ha core check` before restarting
3. **Test one change at a time**
4. **Document as you go**
5. **Monitor logs after changes**

**Next scheduled audit:** 2026-04-17
