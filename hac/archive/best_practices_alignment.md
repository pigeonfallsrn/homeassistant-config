# HAC Workflow vs HA Community Best Practices

## ✅ ALIGNED WITH BEST PRACTICES

### Automation Patterns
**Community:** Use mode: restart for motion automations to prevent overlap
**HAC:** ✅ Documented and following

**Community:** Separate turn_on_commands for Adaptive Lighting with Hue
**HAC:** ✅ Implemented in AL config

**Community:** Avoid wait_for_trigger, use dual-trigger pattern
**HAC:** ✅ Documented preference

### Device Management
**Community:** Smart bulb mode ON for Inovelli switches with smart bulbs
**HAC:** ✅ Confirmed enabled for key switches

**Community:** Regular automation cleanup (check for duplicates)
**HAC:** ✅ Uses grep pattern for duplicate detection

### Security
**Community:** Never expose garage doors, locks, valves via voice/MCP
**HAC:** ✅ MCP privacy model enforces this

**Community:** Use binary_sensor for door status (not cover entity)
**HAC:** ✅ Correctly exposes sensors, blocks covers

## ⚠️ GAPS IDENTIFIED

### Missing Automations
**Community:** Motion automations should have timeout conditions
**HAC Gap:** Need to add "no motion for X minutes" to turn-off triggers

**Community:** Use input_boolean helpers for manual override
**HAC Gap:** No documented override pattern for automations

### Monitoring
**Community:** Monitor for orphaned/unavailable entities
**HAC Gap:** Found 3 unavailable automations (upstairs_hallway_*)
**Action needed:** Regular entity health check

### Backup Strategy
**Community:** Automated nightly backups to external location
**HAC:** Manual git commits only
**Recommendation:** Add automated backup script

## 🆕 BEST PRACTICES TO ADOPT

### 1. Automation Documentation
**Community standard:**
```yaml
- alias: "Descriptive Name"
  description: "What it does and WHY"
  # Include mode, conditions explained
```
**HAC improvement:** Add description field to all automations

### 2. Testing Mode
**Community:** Use test automations in separate file
**HAC improvement:** Create `automations_test.yaml` for new logic

### 3. Entity Naming Convention
**Community:** `domain.location_device_function`
**HAC status:** Mostly following, some inconsistencies
**Example fix:** `light.alaina_s_led_light_strip_1` → consistent

### 4. Adaptive Lighting Best Practices
**Community recommendations:**
- Max brightness limits (prevent 100% at night)
- Sleep mode automation (manual override)
- Per-room instances (not house-wide)

**HAC current:** 2 instances (Living Spaces, Entry Room)
**HAC improvement:** Consider per-bedroom AL instances when Apollo Pro installed

### 5. Presence Detection Hierarchy
**Community best practice:**
```
1. Device tracker (UniFi AP) - coarse presence
2. Room sensors (mmWave) - fine presence  
3. Binary sensors (motion) - activity detection
4. Combo logic for "truly away"
```

**HAC current:** Has 1 & 3, planning 2 (Apollo Pro)
**HAC improvement:** Implement combo logic after Apollo Pro

## 📋 ACTIONABLE IMPROVEMENTS

### High Priority
1. **Clean up unavailable automations** (upstairs_hallway ghosts)
2. **Add automation descriptions** to existing automations
3. **Create automated backup script** (nightly git push)
4. **Implement entity health monitoring** (weekly report)

### Medium Priority
5. **Add manual override helpers** for key automations
6. **Create test automation file** for new logic
7. **Document AL sleep mode workflow** (when to use)

### Low Priority (Future)
8. **Refine entity naming** for consistency
9. **Per-room AL instances** (after Apollo Pro)
10. **Advanced presence combo logic** (after Apollo Pro)

