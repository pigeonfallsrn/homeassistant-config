# HANDOFF — Session S59

## Last Session: S59 (2026-04-27)
## Last Commit: (set after this session's commit)
## Baseline: 79 automations, 51 input_booleans, 11 refresh_tokens (was 12), 70 ip_bans (unchanged; 0 new since 2026-04-14)

---

## WHAT HAPPENED IN S59

### Goal
Auth-retry loop hunt — identify what was generating ~14 IP bans/week from T-Mobile/Verizon IPv6 ranges.

### Diagnosis (the loop already ended 13 days ago)

1. **ip_bans.yaml last entry timestamped 2026-04-14T21:05:55** — 71 bans across 2026-03-22 → 2026-04-14, then quiet. S58's "ongoing 14/week" framing was a snapshot of the 5-week storm window, not current behavior. No new bans since.

2. **Two strong timing correlations on the last day of bans (2026-04-14):**
   - Ban `216.183.105.23` at 04:07:02 → `Mobile App Temp` LLAT issued at 04:10:57 (Δ +3m55s)
   - Ban `216.26.125.164` at 21:05:55 → `Claude Desktop MCP` LLAT issued at 21:10:02 (Δ +4m07s)
   Pattern fits: stale Green-era token retries → 5 fails → ban → human re-issues LLAT → device pairs against EQ14 → vector ends.

3. **Story end-to-end:** Green decommissioned S51. Cloudflare tunnel re-pointed ha.myhomehub13.xyz to EQ14. Mobile clients holding Green-era tokens kept retrying through cellular CGNAT (T-Mobile 2600:1008:*, Verizon 2603:b078:*, T-Mobile IPv4 174.x), each retry rotating to a fresh mobile IP. By 2026-04-14 every active client had been re-paired and the storm ended on its own.

4. **No rogue tokens.** All 12 (now 11) refresh_tokens belong to known household members or system services. Token review revealed John's android last_used_ip = 181.215.195.101 (AS262287 Latitude.sh Chicago, hosting/VPN). Confirmed as NordVPN egress. Benign.

### Cleanups completed
- LLAT revoked: `Mobile App Temp` (bae7d574b3..) via /profile/security UI. Refresh_token store dropped 12 → 11.
- `configuration.yaml` lines 88-91 removed: stale `auth: { auth_providers: [{type: homeassistant}] }` block (was logging ERROR on every restart). `ha core check` passed clean.
- Runtime logger: `homeassistant.components.http.ban` set to DEBUG. Insurance for S60 — captures path + user-agent if any new ban fires before next restart.

### Pre-revoke MCP probe (workflow safeguard)
Before revoking the second LLAT (`Claude Desktop MCP`), I ran ha_get_state on sun.sun to verify MCP authentication after the first revoke. Result confirmed MCP still authed → MCP is using a different token path than `Claude Desktop MCP`. Skipped the second revoke. Decision deferred to S60.

### Discovered, not pursued
- **Music Assistant** setup_error InvalidToken — internal HA retry, no external bans. Carryforward.
- **AndroidTV 192.168.1.17** setup_retry — LAN device, no external bans. Carryforward.
- **Google Calendar OAuth** still expired (1-click fix at /config/repairs). Top of S60 quick-wins.
- **UniFi UBB websocket spam** — 860 `aiounifi.models.event` "Unsupported event" warnings in <1h (EVT_BB_ChannelChanged / EVT_BB_LinkRadioChanged from P.F.P. - UBB). Pure noise. S60 logger suppression.
- **Adaptive_lighting stale refs** — `switch.adaptive_lighting_sleep_mode_*`, `light.kitchen_lounge_ceiling_2of2`, `light.living_room_tv_smart_light_strip` warned as missing/unavailable. Carryforward from S57.

### Files touched
- `configuration.yaml` (lines 88-91 deleted, validated)
- `HANDOFF.md` (this file, regenerated)
- `LEARNINGS.md` (S59 entry appended)

---

## NEXT SESSION (S60) — RECOMMENDED PRIORITY ORDER

### 1. Quick-wins block (chain in one short pass)
- Google Calendar OAuth re-auth via /config/repairs → verify 19 calendar entities online
- Suppress aiounifi spam: add `aiounifi.models.event: error` to logger block in configuration.yaml
- `Claude Desktop MCP` LLAT decision: probe whether it's actually in use (test revoke in a maintenance window? compare /api/states response with vs without it). Last_used_at stuck at 2026-04-14 but MCP probes work — token may be JWT-validated without store updates.
- Drop `http.ban` DEBUG logger if no new bans observed (terminal grep "Login attempt|Banned IP" in home-assistant.log)

### 2. automations.yaml drift diagnosis (S58 carryforward, architectural)
- `grep -rn 'automations.yaml' /homeassistant/configuration.yaml` — referenced for include?
- `.storage/core.config_entries` automation domain check
- `inotifywait` on automations.yaml to catch the writer
- If dual-write: drop YAML inclusion; .storage is canonical
- If direct edit: identify the MCP tool or shell script writing it

### 3. Deferred from S57
- Front Driveway + Very Front Door unification (S57 Hue split pattern; resolve `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode` typo entity)
- Stale ref scan post-S57 (`light.front_hallway_ceiling_*` → `light.front_entryway_ceiling` or `light.stairway_ceiling_*_of_2`)
- Adaptive_lighting stale refs cleanup (S59 finding)
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
- Music Assistant (setup_error — InvalidToken)
- AndroidTV 192.168.1.17 (setup_retry)
- Michelle person tracker (MAC 6a:9a:25:dd:82:f1)

## NORDPASS BACKLOG (manual)

- DELETE: `Mobile App Temp Long-lived Token - HA` (token revoked S59)
- Existing rename queue unchanged (8 entries: hassio adv ssh; http://192.168.1.3:8123 x2; ha_synology; DS finder ha_synology; http://192.168.1.52:5000 x3; http://192.168.1.52:32400\)

---

## BENCHMARK

| Metric                          | S57    | S58    | S59    |
|---------------------------------|--------|--------|--------|
| Automations                     | 79     | 79     | 79     |
| Input booleans                  | 51     | 51     | 51     |
| IP bans (total)                 | 73     | 70     | 70     |
| Refresh tokens                  | ?      | 12     | 11     |
| Active LLATs                    | ?      | 3      | 2      |
| New bans since prior session    | n/a    | n/a    | 0      |
| configuration.yaml parse ERRORs | 1      | 1      | 0      |
| Local API auth                  | broken | working| working|
| HA version                      | 2026.4.3 | 2026.4.4 | 2026.4.4 |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- LLATs in NordPass: "HA EQ14 — LLAT for export_to_sheets (john)" (active), "HA EQ14 — LLAT for Claude Desktop MCP (john)" (decision pending S60)
