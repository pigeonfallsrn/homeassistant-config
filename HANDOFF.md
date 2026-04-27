# HANDOFF — Session S60

## Last Session: S60 (2026-04-27)
## Last Commit: (set after this session's commit)
## Baseline: 79 automations, 51 input_booleans, 15 input_numbers, 6 timers, IP bans post-storm

---

## NOTE ON HANDOFF DRIFT (now resolved twice)

Two prior drift events: S55–S57 (3-session skip), S59 (1-session skip — content rewritten but session header not bumped). S60 found S59 drift on session start.

Going forward:
- HANDOFF.md regenerates every session-end via heredoc paste — NO EXCEPTIONS
- Regeneration MUST bump the session header (Last Session, WHAT HAPPENED IN S<NN>, benchmark column), not just rewrite content. S59 rewrote 197 lines but kept "Session S58" header — that masked the drift.

---

## WHAT HAPPENED IN S60

### Goal
S58 queue items #2 (automations.yaml drift diagnosis) and #3 (Google Calendar re-auth).

### Findings

**#3 Google Calendar — already resolved.** 0 active repairs, 0 persistent notifications, all 19 calendar entities returning normal on/off states. Presumed fixed during S59.

**#2 automations.yaml — NO DRIFT, working as designed.** The "drift" was based on a faulty mental model in Project Instructions and prior HANDOFFs. Evidence:

1. configuration.yaml:52 contains `automation ui: !include automations.yaml` — this directive makes automations.yaml the canonical store for UI automations.
2. .storage/ contains no automation files.
3. automations.yaml has 79 alias entries — matches HA automation count exactly.
4. Mixed ID styles in the file (snake_case manual + numeric Unix-timestamp UI-generated) confirm both write paths land in the same file. Normal.

**Conclusion:** When `automation: !include X.yaml` is in configuration.yaml, that YAML file IS canonical UI storage. There is no parallel .storage/automations to be in conflict with. UI editor and ha_config_set_automation writes both go to the YAML.

The `automation ui:` label (vs default `automation:`) is non-standard but functional. Likely legacy from an abandoned manual+UI split. Not worth changing.

### Bonus discoveries

- S59 commit 2e0033a rewrote 197 lines of HANDOFF.md but kept "Session S58" header — masked S59 drift until S60 git log surfaced the mismatch.
- hac/MASTER_PLAN.md.stub_backup_s58: untracked S58 archive stub — deleted in S60 close.

### Files touched in S60
- hac/MASTER_PLAN.md.stub_backup_s58: deleted
- HANDOFF.md: regenerated for S60
- LEARNINGS.md: appended S60 entry

---

## NEXT SESSION (S61) — RECOMMENDED PRIORITY ORDER

### 1. DEFERRED FROM S57 (longest in queue)
- Front Driveway + Very Front Door unification (apply S57 Hue split pattern)
- Resolve `light.front_drivay_inovelli_switch_for_front_driveway_hue_lights_smart_bulb_mode` typo entity
- Stale ref scan post-S57 (`light.front_hallway_ceiling_*` → `light.front_entryway_ceiling` or `light.stairway_ceiling_*_of_2`)
- Hue Bridge duplicate zone cleanup (All Exterior x2, Garage Ceiling x2)
- Curated outdoor scene library (Back Patio: Galaxy/Northern Lights/Disco — needs Hue app work first)

### 2. PROJECT INSTRUCTIONS UPDATE (governance)
Apply S60 corrections to Project Instructions:
- Remove ".storage/ is canonical for automations" assumption from UI-first description
- Add: "When `automation: !include X.yaml` is in configuration.yaml, that YAML is canonical UI storage. .storage/ is NOT used for automations on this system."
- Add HANDOFF regen rule: "session header bump is mandatory, not just content rewrite"
- Promote DIAGNOSTIC DISCIPLINE to PROMOTED RULES (S58 + S60 = 2 occurrences confirmed)

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

| Metric | S58 | S59 | S60 |
|---|---|---|---|
| Automations | 79 | 79 | 79 |
| Input booleans | 51 | 51 | 51 |
| Local API auth | working | working | working |
| HA version | 2026.4.4 | 2026.4.4 | 2026.4.4 |
| Active repairs | 1 (Cal OAuth) | 0 | 0 |
| Active notifications | unknown | 0 | 0 |
| HANDOFF state | S55-S57 catchup | unbumped header | resolved + protocol fix |
| automations.yaml architecture | "drifted" (wrong) | "drifted" (wrong) | confirmed canonical |

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- Hue Bridge: 192.168.1.68 (API key in /homeassistant/hac/backup/)
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP shell_command.git_push only
- Notify: notify.mobile_app_galaxy_s26_ultra
- Token in NordPass: "HA EQ14 — LLAT for export_to_sheets (john)"
- NordPass entry "Mobile App Temp Long-lived Token - HA" is now DEAD (revoked S59) — delete from vault
