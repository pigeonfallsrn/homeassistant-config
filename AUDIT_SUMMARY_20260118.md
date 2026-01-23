# Home Assistant Comprehensive Audit Summary
**Date:** January 18, 2026
**System:** HA Green 2026.1.2
**User:** John Spencer

---

## 🎯 KEY FINDINGS

### Automations
- **Active in YAML:** 19 automations
- **Total in Registry:** 34 entities
- **Orphaned (can remove):** 15 automations
  - Bedtime timers (3): alaina, dad, ella
  - Living room TV automations (7)
  - Garage/entry lighting (3)
  - Others (2)

### Helpers (Input Booleans/Numbers)
- **Total Found:** 21 helpers
- **ALL UNUSED:** 21 (can safely remove all)
  - 13 input_boolean (test entities, manual overrides, modes)
  - 8 input_number (electricity rates, scene indexes)

### HAC System
- **Status:** ✅ WORKING PERFECTLY
- **Version:** v4.2
- **Size:** 992KB
- **Context Files:** 21 files
- **Latest:** claude_20260118_123308.md

---

## 🧹 CLEANUP PLAN

### Entities to Remove: 36 total
- 21 unused helpers
- 15 orphaned automations

### Expected Result
- Before: 4,110 entities
- After: 4,074 entities
- Reduction: 36 entities (cleaner system)

---

## ✅ BACKUPS CREATED
- Pre-audit config: /backup/pre_audit_*.tar.gz
- HAC backup: /backup/hac_backup_*.tar.gz

---

## 🚀 NEXT: Execute Cleanup
See cleanup commands in terminal.
