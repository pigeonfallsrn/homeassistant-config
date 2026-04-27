# HANDOFF — Session S61

## Last Session: S61 (2026-04-27)
## Last Commit: (set after this session's commit)
## Baseline: 79 automations, 51 input_booleans, 15 input_numbers, 6 timers, 0 IP bans

---

## WHAT HAPPENED IN S61

### Goal
Top of HANDOFF queue. read_handoff returned S58-headed content; diagnostic flipped the goal.

### Diagnostic chain (3rd consecutive session where starter premise was stale)

1. `git log` showed S59 (`2e0033a`) and S60 (`d63716d`) had completed without bumping HANDOFF's `## Last Session:` header. Body partially updated, header stale, BENCHMARK column added — Frankenstein file. That is the regen-template bug S60 commit identified; fix landed this session.

2. **S58 priority queue is fully retired:**
   - #1 auth-retry hunt — closed S59. Storm ended 2026-04-14 at EQ14 cutover stabilization. Mobile App Temp LLAT revoked. Stale `auth:` block stripped from configuration.yaml.
   - #2 automations.yaml drift — closed S60. Diagnosed as non-drift. configuration.yaml line 52 sets `automation ui: !include automations.yaml` → that YAML IS the canonical UI storage layer on this system.
   - #3 Google Calendar re-auth — closed by John pre-S61. Verified live: `calendar.pigeonfallsrn_gmail_com` state `on` ("Hokens birthday"), last_updated 17:55 UTC.

3. **HANDOFF.md rebuilt cleanly** (full overwrite, not surgical edit). Header bumped, body S61-only, BENCHMARK extended.

### Workflow lessons (S61)

- `grep -c PATTERN file` returns exit 1 when zero matches → broke `&&` chain at `IP_BANS TOTAL: 0`. Same root cause as S59 `diff`-on-difference. Two-occurrence candidate: **exit-code-aware chaining** — `;` not `&&` between sections in diagnostic dumps; close optional/may-be-empty commands with `|| true`; trailing `; true` at end of complex one-liner.
- Defensive `; true` at end of dump #2 successfully prevented break. Pattern confirmed.
- `hac/HANDOFF.md` and `hac/LEARNINGS.md` exist as legacy files in `/homeassistant/hac/` from pre-EQ14 tooling era. **The active files are top-level**, not in hac/.

### Files touched (S61)
- `/homeassistant/HANDOFF.md` — full rebuild
- `/homeassistant/LEARNINGS.md` — S61 section appended

---

## NEXT SESSION (S62) — RECOMMENDED PRIORITY

S58 queue empty. S57 deferred batch is now top.

1. **Front Driveway + Very Front Door unification.** Apply S57 Hue CLIP v2 split pattern. Resolve typo entity `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode`.
2. **Stale ref scan post-S57.** `light.front_hallway_ceiling_*` → `light.front_entryway_ceiling` or `light.stairway_ceiling_*_of_2`. Use batch `ha_get_state` (entity-ref hygiene PROMOTED RULE).
3. **Hue Bridge duplicate zone cleanup.** All Exterior x2, Garage Ceiling x2.
4. **Curated outdoor scene library.** Back Patio: Galaxy / Northern Lights / Disco — Hue app work first.
5. **mcp_session_init enrichment (optional).** Add `head -3 HANDOFF.md` + `git log --oneline -5` to the init dump so header/commit drift is unmissable in the first 10 lines of session start.

---

## CARRIED FORWARD (long-running)

- Ella companion app rename (sensor.iphone_40_* → sensor.ella_s_*)
- Garage opener Hue bulbs unreachable (power circuit, not software)
- Very Front Door Hallway: disconnected pending rewire + 2 new A19s
- Kitchen tablet enhancements (Calendar Card Pro, doorbell camera, screensaver, battery mgmt)
- Govee lamp area reassignment when moved to master bedroom
- Discovered integrations to review: 2nd Floor Roomba, DS224plus NAS, Roku 4620X, Tuya, Vizio SmartCast
- Navien + Yamaha RX-V671 not yet on EQ14
- NordPass: "Mobile App Temp Long-lived Token - HA" entry is DEAD (revoked S59) — delete from vault
- NordPass backlog renames (hassio adv ssh, 192.168.1.3 entries, ha_synology entries)

## BLOCKED

- binary_sensor.house_occupied (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

---

## BENCHMARK

| Metric | S58 | S59 | S60 | S61 |
|---|---|---|---|---|
| Automations | 79 | 79 | 79 | 79 |
| Input booleans | 51 | 51 | 51 | 51 |
| IP bans (total) | 70 | 0 | 0 | 0 |
| Local API auth | working | working | working | working |
| HA version | 2026.4.4 | 2026.4.4 | 2026.4.4 | 2026.4.4 |
| Active repairs | 1 (Cal OAuth) | 0 | 0 | 0 |
| HANDOFF state | S55–S57 catchup | unbumped header | partial regen | clean rebuild |
| automations.yaml architecture | "drifted" (wrong) | "drifted" (wrong) | confirmed canonical | confirmed canonical |
| S58 priority queue | created | #1 done | #2 done | #3 done, retired |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Tokens in NordPass: "HA EQ14 — LLAT for export_to_sheets (john)" + "Claude Desktop MCP" both active. "Mobile App Temp" revoked, delete entry.
