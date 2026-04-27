# HANDOFF — Session S58

## Last Session: S58 (2026-04-27)
## Last Commit: (set after this session's commit)
## Baseline: 79 automations, 51 input_booleans, 15 input_numbers, 6 timers, ~70 IP bans (down from 73)

---

## NOTE ON HANDOFF.MD DRIFT (S55–S57)

HANDOFF.md was last updated S54 and skipped three closures (S55, S56, S57). S58 found this drift on session start. Going forward, HANDOFF.md must be regenerated every session-end via heredoc paste — no exceptions. S55–S57 work is preserved in git commit log and Project starter prompts; this file resumes accurate state from S58.

Reference for the missing sessions (from S57 starter prompt):
- S55: (specifics not captured here — see git log between commits 006332b and 7794748)
- S56: (specifics not captured here — see git log)
- S57 (commit 7794748): Back Patio Iconic + Quiet Travel toggle + Hot Tub deprecation; Front Hallway split via Hue CLIP v2 (Stairway zone + Front Entryway zone with 2 FOH switches bound to scenes)

---

## WHAT HAPPENED IN S58

### Goal
Rotate HA long-lived access token (per S57→S58 starter, claimed REVOKED with silent script failures).

### What we actually found (diagnosis chain rewrote the story)

1. **Token rotation completed cleanly** — new LLAT issued (`export_to_sheets` named token), secrets.yaml line 12 updated via env-var-passed Python heredoc (token never echoed to shell history or chat). 184-byte file, 183-char extracted token, 2 dots, valid JWT structure.

2. **The "confirmed REVOKED" claim from the starter was a misdiagnosis.** Earlier 403s observed on the old token were actually IP-ban responses, NOT token-revocation responses. We may have rotated a working token. Verifying ground truth before urgent action is now a Two-Occurrence-Rule candidate (S45 entity-ref discipline applied here too).

3. **Real broken state: `::1` (IPv6 localhost) was on the IP ban list since 2026-03-31.** Every `curl localhost:8123` from the EQ14 host resolved to `::1` first and got blocked at the aiohttp ban-middleware layer BEFORE hitting HA's auth subsystem. Pre-auth blocks return plain-text `403: Forbidden` (14 bytes) instead of HA's JSON error format — that distinction was the smoking gun.

4. **`ip_bans.yaml` cleaned of all local/private IPs** — removed `::1`, `192.168.1.3` (decommissioned Green), `192.168.1.95`. Preserved 70 external bans. `127.0.0.1` and `192.168.1.10` were not in the list to begin with. HA core restart reloaded the cleaned list.

5. **End-to-end auth path verified post-cleanup** — IPv4 (127.0.0.1), IPv6 (::1), default localhost, 192.168.1.10 LAN IP all return HTTP 200 with new token. `export_to_sheets.py` auth pattern (yaml.safe_load → bearer header → /api/) verified independently via urllib stdlib (HAOS Python lacks `requests` module).

### Discovered (not pursued, flagged for S59+)

- **Persistent auth-retry loop is generating bans at ~14/week.** 70 external IPs banned over 5 weeks, mostly T-Mobile/Verizon IPv6 ranges (2600:1008:*, 2603:b078:*). Pattern suggests a mobile companion app or cloud integration with a stale token, repeatedly retrying. Source unknown. **High-priority S59 investigation.**
- **Google Calendar OAuth expired** for pigeonfallsrn@gmail.com. HA repair surfaced 2 minutes after restart. Re-auth required via UI — single click in Settings → Repairs. May or may not be the ban-loop source.
- **`automations.yaml` architectural drift confirmed (S58 starter Option 5).** File showed S57 Back Patio rewrite content (UP=current scene + claim override 2hr...) but was never committed in S57 closure. Either HA dual-writes to YAML AND `.storage`, OR a direct YAML edit happened. UI-first architecture says all automations in `.storage` only. Content is correct, committed in S58, but the WRITE PATH needs investigation in S59.
- **HA self-updated 2026.4.3 → 2026.4.4** between S57 and S58. Auto-update enabled somewhere; benign noise but worth noting.

### Files touched
- `secrets.yaml` line 12: ha_api_token rotated to new LLAT
- `ip_bans.yaml`: 3 local IPs removed (::1, 192.168.1.3, 192.168.1.95)
- `automations.yaml`: S57 Back Patio Inovelli content committed (drift catchup)
- `.HA_VERSION`: 2026.4.3 → 2026.4.4 (HA auto-update)
- `.ha_run.lock`, `www/doorbell/snapshot_driveway.jpg`: removed from git index (still in .gitignore — were tracked from before .gitignore added them)

---

## NEXT SESSION (S59) — RECOMMENDED PRIORITY ORDER

### 1. AUTH-RETRY LOOP HUNT (high-value, security-relevant)
- Goal: identify what's repeatedly authenticating with bad credentials and getting IPs banned
- Approach: enable HA debug logging on `homeassistant.components.http.ban` for 24h, correlate ban entries with HA log for IP+timestamp+method+path+user-agent
- Likely suspects: stale companion app token, decommissioned Green still trying to talk, Google Calendar OAuth retry, AdGuard/UniFi internal scripts
- Side effect of fix: stop polluting ip_bans.yaml indefinitely

### 2. AUTOMATIONS.YAML DRIFT DIAGNOSIS (architectural)
- Goal: determine if HA is dual-writing or if a direct YAML edit happened
- Approach: 
  - `grep -rn 'automations.yaml' /homeassistant/configuration.yaml` (is it referenced?)
  - Check `.storage/core.config_entries` for automation domain config
  - `inotifywait` on `automations.yaml` to catch the writer in the act
- If dual-write: stop YAML inclusion, .storage is canonical
- If direct edit: trace who/what edited (likely an MCP tool or shell script)

### 3. GOOGLE CALENDAR RE-AUTH (1-click)
- Settings → Repairs → "Authentication expired for pigeonfallsrn@gmail.com" → Submit
- Verify 19 calendar entities come back online after

### 4. DEFERRED FROM S57 (still on the menu)
- Front Driveway + Very Front Door unification (apply S57 Hue split pattern; resolve `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode` typo entity)
- Stale ref scan post-S57 (`light.front_hallway_ceiling_*` → `light.front_entryway_ceiling` or `light.stairway_ceiling_*_of_2`)
- Hue Bridge duplicate zone cleanup (All Exterior x2, Garage Ceiling x2)
- Curated outdoor scene library (Back Patio: Galaxy/Northern Lights/Disco — needs Hue app work first)

---

## CARRIED FORWARD (long-running)

- Ella companion app rename (sensor.iphone_40_* → sensor.ella_s_*)
- Garage opener Hue bulbs unreachable (power circuit, not software)
- Very Front Door Hallway: disconnected pending rewire + 2 new A19s
- Kitchen tablet enhancements (Calendar Card Pro, doorbell camera, screensaver, battery mgmt)
- Govee lamp area reassignment when physically moved to master bedroom
- 2nd Floor Roomba, DS224plus NAS, Roku 4620X, Tuya, Vizio SmartCast — discovered integrations to review

## BLOCKED

- binary_sensor.house_occupied (template package issue)
- sensor.2nd_floor_bathroom_humidity_derivative (unavailable)
- Music Assistant (setup_error)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

---

## BENCHMARK

| Metric | S57 | S58 |
|---|---|---|
| Automations | 79 | 79 |
| Input booleans | 51 | 51 |
| IP bans (total) | 73 | 70 |
| IP bans (local IPs) | 3 | 0 |
| Local API auth | broken (::1 banned) | working (4/4 endpoints 200) |
| LLAT for export_to_sheets | revoked? unclear | rotated, verified |
| HA version | 2026.4.3 | 2026.4.4 |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Token in NordPass: "HA EQ14 — LLAT for export_to_sheets (john)"
