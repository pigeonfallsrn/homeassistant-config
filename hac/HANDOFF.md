# HANDOFF — Session S44

## Last Session: S44 (2026-04-19)
## Last Commit: 86cacb0
## Baseline: 80 automations, 90 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S44

### 2nd Floor Bathroom Review (12 → 8 automations)
- Deleted 4: ceiling_switch_vzm30_sn (duplicate triple-fire), inovelli_vzm30_sn_controls_hue_lights (blueprint duplicate), fan_pre_trigger_hot_water_flow (Navien missing), reset_light_override_30_min (missing helper)
- Fixed 2: vanity_lights_inovelli_control entity ref (light.2nd_floor_bathroom_vanity_lights → light.2nd_floor_vanity_lights), fan_inovelli_paddle_control_v2 entity ref (fan.2nd_floor_bathroom_exhaust_fan → fan.2nd_floor_bathroom_exhaust_fan_inovelli_fan)
- Cleared stuck input_boolean.bathroom_2nd_floor_fan_manual_override

### Kitchen Tablet Automations (6 → 2)
- Research: FKB Tier 1 (native wake/sleep) vs Tier 2 (HA automations for brightness, doorbell, presence)
- Deleted 4: wake_on_kitchen_motion, sleep_after_inactivity, wake_on_presence, sleep_when_away (all broken — missing entities, wrong services)
- Rebuilt: doorbell_camera_popup → "Kitchen Tablet — Doorbell Wake + Bright" (mode:restart, resets brightness after 90s)
- Kept: brightness_schedule (working)

### Kitchen Tablet Infrastructure (NEW)
- Created storage-mode dashboard: `kitchen-tablet` (url_path)
- Installed Kiosk Mode v13 (HACS) — configured `kiosk_mode: {kiosk: true, non_admin: true}`
- Created dedicated `tablet` user (non-admin, local-only) — NordPass: "EQ14 HA — Tablet Kiosk User (tablet)"
- FKB startURL: `http://192.168.1.10:8123/kitchen-tablet/home`
- Migrated tablet off Green (192.168.1.3) → EQ14 (192.168.1.10)
- Google Calendar integration re-authenticated (pigeonfallsrn@gmail.com) — 19 calendar entities

### Kitchen Tablet Dashboard
- Sections: Weather+Clock, Family Calendar (8 curated calendars), Garage doors, Kitchen Lights (5), Climate (2 Nest), Shopping List, Who's Home
- Calendar entities on tablet: alaina_ella, master_calendar, birthdays, whitehall_14u_sb, holidays_in_united_states, phases_of_the_moon, whitehall_middle_school_volleyball_calendar, whitehall_12u_sb_black
- All native HA cards (no HACS card dependencies beyond Kiosk Mode)
- Dashboard lives in .storage/ (gitignored) — persistent but not git-tracked

### FKB Configuration
- device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Tablet IP: 192.168.21.50 (IoT VLAN "Spencer IoT")
- Remote Admin: http://192.168.21.50:2323 (password in NordPass)
- Screen Off Timer: bumped 300s → 900s (15 min)
- Motion Detection: ON (camera-based wake)
- Kiosk Lock: ON
- MAC: CA:2F:26:E8:59:B7
- Model: Samsung SM-X210 (Tab A9+), Android 16, 3.4GB RAM

---

## LEARNINGS (S44)

### Kiosk Mode + strategy dashboards (CRITICAL)
- Kiosk Mode HACS integration does NOT work on strategy dashboards (the default auto-generated HA dashboards)
- Must use a storage-mode dashboard with `kiosk_mode` config block embedded
- The `?kiosk` URL parameter is unreliable on strategy views
- Non-admin user + storage-mode dashboard + kiosk_mode config = reliable lockdown

### FKB Tier 1/Tier 2 pattern
- Tier 1 (let FKB handle natively): Screen Off Timer + camera Motion Detection for wake/sleep. Zero HA automations needed.
- Tier 2 (HA automations): Brightness scheduling, doorbell events, presence-based control, URL navigation
- FKB `switch.*.motion_detection` is a control toggle (enable/disable), NOT a motion sensor — don't trigger automations from it
- `fully_kiosk.set_config` requires device_id target, not entity_id
- `fully_kiosk.load_url` for one-time navigation, `set_config` key=startURL for persistent start page

### Entity ref bugs — PROMOTED TO RULE (2nd occurrence)
- First: Entry Room S42. Second: bathroom + kitchen tablet S44
- Multiple automations referencing entities that don't exist or have wrong names
- RULE: Before any review session, verify entity existence for all entities referenced in the automation group

### Triple-fire pattern
- Multiple automations listening to same ZHA device_ieee ALL fire on every button press
- Consolidation keeper must include DELETING legacy automations, not just disabling

### Dashboard storage vs git
- Dashboard configs live in `.storage/lovelace.*` (gitignored by design)
- Automation configs also in `.storage/` but committed via shell_command.git_push (HA writes automations.json)
- Dashboard changes are persistent in HA but not version-controlled — accept this or add .storage/lovelace exceptions to .gitignore

### Google Calendar OAuth
- Tokens from Green don't transfer to EQ14 — need fresh OAuth flow
- Device code flow: HA gives code → go to google.com/device → enter code → authorize
- "Google hasn't verified this app" warning is normal for self-hosted — click Continue

---

## TABLED / REMAINING WORK

### S45 Priority:
1. Kids bedrooms — blueprint standardization (Alaina + Ella dimmer switches)
2. Verify Alaina companion app — confirm device_tracker entity, link to person.alaina_spencer
3. Kitchen Govee lamp → Master Bedroom — reassign light.kitchen_floor_lamp (MAC 98:88:e0:f2:32:48)

### Kitchen Tablet Enhancements (future):
- Calendar Card Pro (HACS) — community favorite, supports per-calendar colors/emojis (e.g. basketball emoji for Alaina's team)
- Master Calendar parsing — filter to grade-specific events only (days off, inservice, kid-specific)
- Doorbell camera view — dedicated dashboard view + fully_kiosk.load_url in doorbell automation
- Away/home screen control — use switch.kitchen_wall_a9_tablet_screen + presence (blocked by house_occupied template fix)
- FKB screensaver — consider family photos or ambient clock display
- Battery management — automation to toggle charge between 20-80% via smart plug (extends battery life)
- Motion detection tuning — verify camera angle catches people walking up; if unreliable consider external motion sensor trigger

### Blocked / Dependency Items:
- binary_sensor.house_occupied — unavailable (template package issue). Blocks doorbell condition + away/home tablet control
- sensor.2nd_floor_bathroom_humidity_derivative — unavailable
- Music Assistant — setup_error state
- Michelle's person tracker (MAC: 6a:9a:25:dd:82:f1)

### Orphaned Helpers to Clean Up:
- input_boolean.kitchen_tablet_doorbell_popup — no longer referenced
- input_boolean.kitchen_tablet_screen_control — no longer referenced

### Ongoing:
- Security hardening session (~30 min: SSH password auth, Cloudflare Zero Trust, plaintext PAT, recorder PII)
- AndroidTV at 192.168.1.17 — real ADB device, do not delete (Android Debug Bridge integration showing "failed setup, will retry")
- NordPass cleanup backlog
- Discovered integrations to review: 2nd Floor Roomba, DS224plus NAS, Bluetooth hci0, Roku 4620X, Tuya, Vizio SmartCast

---

## BENCHMARK

| Metric | S43 | S44 |
|--------|-----|-----|
| Automations | 77 | 80 |
| Helpers | 90 | 90 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |
| HACS cards | 0 | 1 (Kiosk Mode) |
| Calendars | 0 | 19 |
| Tablet dashboards | 0 | 1 (kitchen-tablet) |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Kitchen tablet device_id: `86870b5d8b01f345f5d5dd9c2ac06d2b`
- Kitchen tablet FKB startURL: `http://192.168.1.10:8123/kitchen-tablet/home`
- Kitchen tablet FKB Remote Admin: `http://192.168.21.50:2323`
- Kitchen tablet HA user: `tablet` (non-admin, local-only)
- Tablet dashboard url_path: `kitchen-tablet` (storage-mode, kiosk_mode enabled)
