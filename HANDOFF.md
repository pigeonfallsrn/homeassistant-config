# HANDOFF — Session S51

## Last Session: S51 (2026-04-21)
## Last Commit: b69f978
## Baseline: 77 automations, 91 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S51

### Green Deprecation (COMPLETE)
- Audited 59 integrations on Green — all conflicting with EQ14 (AL x4, Hue, UniFi, tplink x8, Nest, Kumo, Sonos, Roku, FKB, Matter, etc)
- Harvested: Navien water heater creds (saved to NordPass), Yamaha RX-V671 config (192.168.21.171:50000), derivative helper config, Michelle WiFi template config
- Verified derivative + Michelle template already exist on EQ14
- Reviewed HAC workflow system (hac.sh v9.1) — learn/promote/health/table patterns. Most superseded by Claude Project memory. Health check pattern worth building on EQ14.
- Shut down Green via `ha host shutdown` — all 59 conflicting integrations stopped
- Green available for future garage repurpose (fresh HAOS install)

### Dashboard Cleanup
- Removed 3 broken YAML dashboards from configuration.yaml (kitchen-tablet YAML, mobile, climate)
- Archived all dashboard YAML files to hac/archive/dashboards_yaml_s51/
- configuration.yaml now has clean `lovelace: mode: storage` only

### HACS Cards Installed (4 new)
- Mushroom Cards — modern card components
- auto-entities — dynamic entity filtering for dashboards
- card-mod — CSS styling on any card
- mini-graph-card — sensor history sparklines
- Total HACS: 5 (+ existing Kiosk Mode)

### Arriving Home Dashboard Rebuilt
- Dynamic "Lights On Now" section using auto-entities + Mushroom light cards
- Auto-excludes: AL switches, Inovelli SBM, EP2, identify entities
- Mushroom climate cards for 1st/2nd Floor Nest thermostats
- Quick Toggles: garage, back patio, front driveway
- Garage door covers with open/close controls

### Governance Review (S51)
- Updated 3 stale Claude memory entries (state, tabled items, dashboard stack)
- Added Green deprecation learning to memory
- Reviewed Green HAC workflow — identified health_check as worth porting
- HANDOFF.md brought current (was stale at S44)

---

## TABLED / REMAINING WORK

### Next Priority:
1. Ella companion app — rename device (sensor.iphone_40_* → sensor.ella_s_*)
2. Michelle person tracker (MAC 6a:9a:25:dd:82:f1)
3. Full system audit — all automations/scenes/entities vs best practice
4. Navien integration setup on EQ14 (creds in NordPass)
5. Yamaha RX-V671 integration on EQ14 (192.168.21.171:50000)

### Dashboard Iteration:
- Arriving Home: names truncated in Mushroom cards — consider 2-col or name overrides
- Kitchen tablet: Calendar Card Pro, doorbell camera view, away/home screen control
- Future: per-room dashboards with mini-graph-card for climate/humidity

### Blocked:
- binary_sensor.house_occupied — unavailable (template package issue)
- Music Assistant — setup_error state
- Michelle person tracker

### Ongoing:
- Security hardening session (~30 min)
- AndroidTV at 192.168.1.17 — real ADB device, DO NOT DELETE
- NordPass cleanup backlog
- Ratgdo north physical IR sensor — clean lenses
- Build shell_command.health_check (inspired by Green HAC hac.sh health pattern)

---

## BENCHMARK

| Metric | S50 | S51 |
|--------|-----|-----|
| Automations | 77 | 77 |
| Helpers | 90 | 91 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 1 | 5 |
| Calendars | 19 | 19 |
| Storage dashboards | 3 | 3 |
| YAML dashboards | 3 | 0 |
| Green status | running | shut down |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- Kitchen tablet device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Kitchen tablet FKB Remote Admin: http://192.168.21.50:2323
- Green: SHUT DOWN (192.168.1.3) — repurpose for garage later
