# HANDOFF — S26 complete | 2026-04-17

## Completed this session (S26)

### v1.1 Governance — docs only, no migration files touched
- Appended 2 NEVER rules to CRITICAL_RULES_CORE.md:
  1. UniFi network topology is manual UniFi-UI only — HA may READ, never WRITE
  2. UI helpers require both label AND meaningful entity_id in same session
- Created ops/PLAYBOOKS/BREAK_GLASS.md (201 lines):
  Decision tree (60-second triage) → Path A (UI up) → Path B (SSH up) →
  Path C (tunnel down) → Path D (full restore with .storage order) →
  ZHA-specific recovery → emergency links
- Backup taken before edits (slug: 2457fb86)

### Green audit completed
- packages/ empty, no unique content to preserve
- 3 unpushed commits (S25-S26 docs) superseded by EQ14 S27-S37 history — abandoned
- custom_components all HACS-managed, blueprints verified on EQ14
- Green is safe to wipe after one final blueprint ls confirmation on EQ14

## S27 — RESUME MIGRATION HERE

### Priority 1: Group 5 — upstairs_lighting.yaml
grep -n "^  - id:\|^    alias:" /homeassistant/packages/upstairs_lighting.yaml

## Package files remaining (6)
Group 5: upstairs_lighting.yaml
Group 6: kids_bedroom_automation.yaml, ella_living_room.yaml
Group 7: humidity_smart_alerts.yaml
Group 10: notifications_system.yaml
Template-only stubs (not pending): kitchen_tablet_dashboard.yaml, lighting_motion_firstfloor.yaml

## Tabled (carried forward)
- Person trackers: Alaina, Ella, Michelle — none assigned. Michelle MAC: 6a:9a:25:dd:82:f1
- AndroidTV 192.168.1.17 — real device, DO NOT DELETE
- Music Assistant — setup_error, tabled
- North ratgdo: toggle obstruction OFF after any OTA flash
- Apollo Kitchen 192.168.21.233: OTA flash pending
- Vanity slow fade: VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66 -> Group 5
- humidity_smart_alerts unpause bug -> Group 7
- input_text alaina/ella WAYA softball calendar IDs -> Group 6
- Aqara sensor gap: 6 door + 4 P1 motion sensors need EQ14 entity ID hunt
- first_floor_hallway_motion delay_off bug in lighting_motion_firstfloor.yaml
- 6 Ella bedroom scenes missing -> Group 6
- HA Green full config audit before wipe (audit done S26, wipe pending)
- Security session: SSH key + Cloudflare ZT + PAT rotation (~30 min dedicated)
- CRITICAL_RULES_CORE.md has duplicate sections (GHOST MIGRATION x3, TOKEN EFFICIENCY x2, etc) — dedup after migration
- v1.1 remaining: verify helper labels before session close (add to ritual)
