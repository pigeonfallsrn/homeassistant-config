# HANDOFF — S71 → S72

**Last commit:** (S71 close, this session)
**Live counts:** 72 automations, 98 helpers, 14 template packages, 0 ghosts
**HA path:** EQ14 sole instance, ha.myhomehub13.xyz via Cloudflare

---

## S71 — health_check.py v2 + MCP path fix

**Goal:** Patch chk_unavail to filter design-noise + repair MCP shell_command path.

**Done:**
- v2 filter: added `event` and `scene` to EXCLUDE_DOMS; extended EXCLUDE_RE to drop `button.*_(identify|restart|power_cycle|reset_*)` and `update.*_firmware`
- Result: 653 → 393 unavail (terminal AND MCP agree)
- Discovered MCP path was broken (HTTP 401 — SUPERVISOR_TOKEN scope insufficient for Core API)
- Created LLAT `health_check` in HA, stored at `/config/.health_check_token` (chmod 600, gitignored)
- Patched `fetch()` for dual-token fallback: env SUPERVISOR_TOKEN first (terminal/addon path), file LLAT second via localhost:8123 (HA Core subprocess path)
- Wrapper `health_check_full.sh` reverted to clean 2-line form
- NordPass entry: "Home Assistant — Long-Lived Access Token (health_check)"

**Files touched:**
- `/config/hac/scripts/health_check.py` (filter + dual-token fetch)
- `/config/hac/scripts/health_check_full.sh` (no functional change vs S70 — bounced through debug forms)
- `/config/.gitignore` (added `.health_check_token`)
- `/config/.health_check_token` (untracked, 600)

---

## S72 priority queue

**Top of queue: Triage the 393 unavail down to actionable list.**
Post-v2 domain breakdown:
- sensor 172, number 77, switch 55, button 32, select 16, binary_sensor 16, light 10, media_player 6, tts 2, notify 2, conversation 2, stt 1, input_button 1, image 1

Likely real-signal clusters to attack first:
- Template chain `binary_sensor._house_occupied` / `_kids_home` / `_home_alone` / `_john_home_alone` — probably cascading from one broken upstream (Michelle's missing device_tracker per carryforward?)
- Apollo MSR-1 entry_room presence sensor (`entry_room_r_pro_1_ld2412_*`) — multi-entity unavail suggests the device itself is offline or just-flashed
- First-floor motion (`first_floor_hallway_motion`, `first_floor_main_motion`) — investigate
- Music Assistant 7 entries (known carryforward — setup_error)
- Inovelli `number.*` 77 + `select.*` 16 — likely diagnostic noise but worth one-pass scan; some may be promotion-to-EXCLUDE_RE candidates if clearly stateless config endpoints

**Suggested approach:** terminal dump grouped by suspected root, then options A/B/C per cluster.

---

## Carryforward (unchanged from S70)

- AndroidTV at 192.168.1.17 — DO NOT DELETE
- Music Assistant in setup_error state
- Michelle's device tracker missing (MAC `6a:9a:25:dd:82:f1`)
- Ella: 20 entity_ids still named `iphone_40_*` — need rename
- Ratgdo north: clean physical IR sensor lenses
- Navien integration not yet added to EQ14
- Yamaha RX-V671 not yet added to EQ14
- NordPass backlog cleanup
- Google Drive audit and reorganization

## Blocked
None.

## Benchmark
- shell_command.health_check via MCP: 0.51s, returncode 0, [1] reports 393 unavail
- Terminal direct: 0.64s, [1] reports 393 unavail
- Both paths return identical CRIT count
