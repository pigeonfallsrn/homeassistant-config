# HANDOFF — Session S44

## Last Session: S44 (2026-04-19)
## Last Commit: see git log
## Baseline: 80 automations, 90 helpers, 0 ghosts, 0 YAML auto files

---

## WHAT HAPPENED IN S44

### 2nd Floor Bathroom Review (12 → 8 automations)
- **Deleted 4 automations:**
  - `ceiling_switch_vzm30_sn` — duplicate, triple-firing with keeper
  - `inovelli_vzm30_sn_controls_hue_lights` — blueprint duplicate, triple-firing
  - `fan_pre_trigger_hot_water_flow` — dead (Navien entity missing, wrong fan entity)
  - `reset_light_override_30_min` — dead (helper `input_boolean.2nd_floor_bathroom_manual_override` never existed)
- **Fixed 2 automations:**
  - Keeper (`vanity_lights_inovelli_control`): `light.2nd_floor_bathroom_vanity_lights` → `light.2nd_floor_vanity_lights` (OFF, brightness up/down now work on vanity)
  - Fan paddle (`fan_inovelli_paddle_control_v2`): `fan.2nd_floor_bathroom_exhaust_fan` → `fan.2nd_floor_bathroom_exhaust_fan_inovelli_fan`
- **Cleared stuck state:** `input_boolean.bathroom_2nd_floor_fan_manual_override` (was stuck ON)

### Kitchen Tablet Review (6 → 2 automations)
- **Research:** Community consensus — let FKB handle screen wake/sleep natively (Screen Off Timer + camera motion detection). HA automations only for things FKB can't know about (brightness schedule, doorbell, presence).
- **Deleted 4 automations:**
  - `wake_on_kitchen_motion` — FKB handles natively; all 3 trigger entities missing
  - `sleep_after_inactivity` — FKB Screen Off Timer handles natively; trigger entity missing
  - `wake_on_presence` — wrong service (notify.mobile_app), gate closed, duplicate of FKB
  - `sleep_when_away` — wrong service (notify.mobile_app), silently failing
- **Rebuilt 1 automation:**
  - `doorbell_camera_popup` → `Kitchen Tablet — Doorbell Wake + Bright` — removed broken `house_occupied` condition, removed orphaned `input_boolean` refs, mode:restart, resets brightness to schedule-appropriate level after 90s. Future: add `fully_kiosk.load_url` to navigate to doorbell camera view.
- **Fixed tablet URL:** `fully_kiosk.set_config` startURL changed from Green (192.168.1.3) → EQ14 (192.168.1.10). Tablet needs one-time physical auth tap.
- **Kept 1 automation:** `brightness_schedule` — working correctly

### Session Totals
- Started: 84 automations (post-S43 + additions between sessions)
- Deleted: 8 automations (4 bathroom + 4 kitchen tablet)
- Net: **80 automations**

---

## LEARNINGS (S44)

### Fully Kiosk Browser — Tier 1/Tier 2 pattern (NEW)
- **Tier 1 (let FKB handle natively):** Screen Off Timer + camera Motion Detection for basic wake/sleep. Runs locally, zero network dependency. Do NOT duplicate with HA automations.
- **Tier 2 (HA automations):** Brightness scheduling, doorbell events, away/home presence, URL navigation. Use `switch.*.screen` for wake, `number.*.screen_brightness` for brightness, `fully_kiosk.load_url` for navigation, `fully_kiosk.set_config` for persistent settings.
- FKB `switch.*.motion_detection` is a control toggle (enable/disable), NOT a motion sensor. Don't trigger automations from it.

### Entity ref bugs are pervasive
- Second occurrence of broken entity refs surviving across sessions (first was Entry Room in S42). Multiple automations referencing entities that don't exist or have slightly different names. Always verify entity existence before trusting automation configs.
- **Promoted to rule:** Before any review session, run entity existence check on all entities referenced in the automation group.

### Triple-fire pattern
- Multiple automations listening to the same ZHA device_ieee will ALL fire on every button press. The "keeper" pattern from consolidation must include deleting the legacy automations, not just disabling.

---

## TABLED ITEMS

### Immediate next (S45 priority order):
1. **Kids bedrooms** — blueprint standardization (Alaina + Ella dimmer switches)
2. **Verify Alaina companion app** — confirm device_tracker entity, link to person.alaina_spencer
3. **Kitchen Govee lamp → Master Bedroom** — reassign light.kitchen_floor_lamp (MAC 98:88:e0:f2:32:48, IP 192.168.10.201)
4. **Scenes/scripts/dashboard audit** — future pass

### Blocked / dependency items:
- `binary_sensor.house_occupied` — unavailable (template package issue). Blocks doorbell popup condition + future away/home tablet control. Investigate which template package defines it.
- `sensor.2nd_floor_bathroom_humidity_derivative` — unavailable. Check if template package or integration issue.
- Kitchen tablet: build dedicated doorbell camera dashboard view, then add `fully_kiosk.load_url` to doorbell automation
- Kitchen tablet: rebuild away/home screen control using `switch.kitchen_wall_a9_tablet_screen` (not mobile_app notify) once house_occupied is fixed

### Orphaned helpers to review:
- `input_boolean.kitchen_tablet_doorbell_popup` — no longer referenced by any automation
- `input_boolean.kitchen_tablet_screen_control` — no longer referenced by any automation

### Ongoing from prior sessions:
- Michelle's person tracker (MAC: 6a:9a:25:dd:82:f1)
- Music Assistant setup_error
- Security hardening session (~30 min: SSH password auth, Cloudflare Zero Trust, plaintext PAT, recorder PII)
- AndroidTV at 192.168.1.17 — real ADB device, do not delete
- NordPass cleanup backlog

---

## BENCHMARK

| Metric | S43 | S44 |
|--------|-----|-----|
| Automations | 77 | 80 (84 after S43 adds, -8 S44 cleanup, +4 between sessions) |
| Helpers | 90 | 90 |
| Ghosts | 0 | 0 |
| YAML auto files | 0 | 0 |
| Template packages | 14 | 14 |

---

## QUICK REFERENCE

- HA: http://192.168.1.10:8123
- SSH: `ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"`
- Git push: MCP `shell_command.git_push` only
- Notify: `notify.mobile_app_galaxy_s26_ultra`
- Kitchen tablet device_id: `86870b5d8b01f345f5d5dd9c2ac06d2b`
- Kitchen tablet FKB start URL: `http://192.168.1.10:8123/lovelace-kitchen-tablet/0`

## ADDENDUM — Kitchen Tablet Dashboard (S44 continued)

### Built:
- New storage-mode dashboard at `kitchen-tablet` (url_path)
- Kiosk Mode v13 installed (HACS) + configured (`non_admin: true`)
- Dedicated `tablet` user (non-admin, local-only) — NordPass: "EQ14 HA — Tablet Kiosk User (tablet)"
- FKB startURL: `http://192.168.1.10:8123/kitchen-tablet/home`
- FKB device_id: `86870b5d8b01f345f5d5dd9c2ac06d2b`
- Tablet IP: `192.168.21.50` (IoT VLAN), FKB Remote Admin: `192.168.21.50:2323`
- Dashboard sections: Weather+Clock, Calendar (placeholder), Garage, Kitchen Lights, Climate, Shopping List, Who's Home

### Learnings:
- Kiosk Mode does NOT work on strategy dashboards (default auto-generated). Must use storage-mode dashboard.
- FKB `fully_kiosk.set_config` requires device_id target, not entity_id
- FKB Remote Admin commands: Clear Web Cache + Load Start URL for cache refresh
- `tablet` user shared across all future tablets; per-tablet dashboard via FKB startURL

### Blocked:
- Google Calendar integration needs re-auth (OAuth expired from Green migration)
- Once calendar entities exist, swap markdown placeholder for native `calendar` card with `initial_view: listWeek`
- Calendar Card Pro (HACS custom card) is the community favorite for family calendars — consider for future enhancement

### Orphaned helpers to clean up:
- `input_boolean.kitchen_tablet_doorbell_popup` — no longer referenced
- `input_boolean.kitchen_tablet_screen_control` — no longer referenced
