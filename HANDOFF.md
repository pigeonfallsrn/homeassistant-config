# HANDOFF — Session S50

## Last Session: S50 (2026-04-21)
## Last Commit: (pending)
## Baseline: 77 automations, 90 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S50

### Garage Door Obstruction Fix (ROOT CAUSE FOUND)
- Diagnosed north ratgdo obstruction sensor stuck ON — door wouldn't close reliably
- Found TWO stacking root causes:
  1. EQ14 garage motion automations included `light.garage_north_garage_door_ratgdo32disco_light` — sent Security+ 2.0 light commands during door operations, confusing obstruction detection
  2. HA Green (192.168.1.3) was still actively connected to both ratgdo ESPHome devices, causing dual-API conflicts
- Fixed: Removed ratgdo light entity from Garage — Motion Lights ON and OFF automations
- Fixed: Deleted ESPHome integration from Green (disconnected from ratgdo + Apollo)
- Confirmed: Door opens and closes successfully after both fixes
- Physical obstruction sensor still reads ON (hardware — dirty/misaligned IR beam, clean when convenient)
- Status obstruction toggle OFF is still needed after OTA — but root cause of rapid snap-back was the automation + Green conflict

### Green Discovery — NOT Fully Deprecated
- Green (192.168.1.3) is still running HAOS 17.2, Core 2026.4.3
- ESPHome integration was actively connecting to ratgdo north (192.168.21.111), ratgdo south (192.168.21.21), Apollo (192.168.21.234)
- ZHA showing "Failed setup, will retry" — Zigbee dongle physically moved to EQ14
- 52 ZHA devices, Navien, Music Assistant, Yamaha YNCA all still configured
- LEARNINGS.md on Green is EMPTY — knowledge from early sessions only in git commit messages
- Green has valuable reference configs but NO active automations (storage returned 0 garage automations)
- Formal deprecation audit needed: harvest configs, remove conflicting integrations, decide cold-spare fate

### Dashboard Work
- Created "Arriving Home" dashboard (storage-mode, sections view, sidebar enabled)
  - Garage doors with open/close controls
  - Obstruction sensor status
  - Area-based light tiles for all floors
  - URL: /arriving-home/home
- Deleted VZM36 Test dashboard (served its purpose)
- Identified broken YAML dashboards: Climate Command, Mobile, Kitchen Tablet (YAML mode) — all stale from git, full of entity-not-found errors
- These need removal from configuration.yaml

### Research: Community Dashboard Best Practices
- Mushroom Cards (HACS) — community standard for modern card design
- auto-entities (HACS) — dynamic "show only what's on" filtering, exactly what John wants
- card-mod (HACS) — CSS styling for polish
- Mushroom Media Card — works with Music Assistant for album art + playback controls
- Sections view + Mushroom + auto-entities = the community-recommended stack

---

## TABLED / REMAINING WORK

### S51 Priority — Green Deprecation + Dashboard Cleanup:
1. GREEN AUDIT: Systematic review of Green configs — harvest useful learnings from git history, integration configs (Navien, Yamaha, etc.), remove all conflicting integrations (ZHA, any remaining ESPHome), decide cold-spare vs power-off
2. YAML DASHBOARD CLEANUP: Remove Climate Command, Mobile, Kitchen Tablet (YAML) refs from configuration.yaml — these were pulled from git and are broken
3. DASHBOARD REBUILD: Install Mushroom Cards + auto-entities via HACS, rebuild Arriving Home dashboard with dynamic "lights on" view, Mushroom tiles, media controls
4. GOVERNANCE REVIEW: Due since S50 (deferred) — promote mature LEARNINGS into project instructions

### Full System Audit (multi-session):
- Review ALL automations against HA best practice: still wanted? needed? reliable? clean entity refs?
- Review ALL scenes: still used? current entity refs?
- Review ALL helpers: orphaned? still referenced?
- Review ALL entities: naming convention compliance, area assignments, labels
- Consider Gemini bulk audit approach (paste full dumps for triage)

### Blocked / Dependency Items:
- binary_sensor.house_occupied — unavailable (template package issue)
- Music Assistant — setup_error state
- Michelle's person tracker (MAC: 6a:9a:25:dd:82:f1)
- North ratgdo physical obstruction sensor — clean IR beam sensors when convenient

### Kitchen Tablet Enhancements (future):
- Calendar Card Pro (HACS)
- Doorbell camera view + fully_kiosk.load_url
- Away/home screen control (blocked by house_occupied)
- FKB screensaver, battery management

### Ongoing:
- Security hardening session (~30 min)
- AndroidTV at 192.168.1.17 — real ADB device, do not delete
- NordPass cleanup backlog
- Ella companion app entity rename (20 entity_ids still iphone_40_*)
- Govee lamp area reassign when physically moved

---

## BENCHMARK

| Metric | S49 | S50 |
|--------|-----|-----|
| Automations | 77 | 77 |
| Helpers | 90 | 90 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 1 | 1 (Kiosk Mode) |
| Calendars | 19 | 19 |
| Storage dashboards | 3 | 3 (map, kitchen-tablet, arriving-home) |
| YAML dashboards | 3 | 3 (climate, mobile, kitchen-tablet — all broken) |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- North ratgdo: 192.168.21.111 (v32disco_secplus2, fd8d8c)
- South ratgdo: 192.168.21.21 (v32board_secplus2, 5735e8)
- Apollo: 192.168.21.234 (748020)
- Green: 192.168.1.3 (NOT deprecated — ESPHome removed, ZHA failed, still running)
- Arriving Home dashboard: /arriving-home/home
- Kitchen tablet dashboard: /kitchen-tablet/home
