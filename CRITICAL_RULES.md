# CRITICAL RULES — EQ14 HA System
# Tactical knowledge that doesn't fit Project Instructions or LEARNINGS.
# Workflow rituals live in Project Instructions; session history in LEARNINGS.md.
# Last restructured: 2026-04-28 S68 (collapsed CORE + full into one file)

---

## INOVELLI — TWO ARCHITECTURES, NEVER MIX

### Tier 1 — Smart Bulb Mode (controls Hue bulbs)
- Param 52 = 1: load always-on, paddle sends ZHA events
- HA/AL controls the HUE entity, NOT the switch entity — never add the switch to AL
- Hue bridge bulbs CANNOT bind to Inovelli EP2 via ZHA (different Zigbee networks)
- Only working arch: Param 52=1 + HA automation on ZHA event + light.turn_on on Hue entity

### Tier 2 — Dumb Load (cans, pendants, under-cabinet)
- Param 52 = 0: switch cuts/restores power
- HA sends explicit brightness_pct + transition:0 to SWITCH entity — never add to AL
- transition:0 REQUIRED on motion automations: without it mode:restart re-fires brightness, LOCAL_RAMP_RATE causes visible ramp/flicker
- LOCAL_RAMP_RATE (param 1/7) = physical paddle speed; min_dim_level too low = LED flicker

### Device Inventory (confirmed S63/S64/S68)

Tier 1 SBM:
  light.entry_room_ceiling_light_inovelli_smart_dimmer_switch    d80c7fa6
  light.kitchen_lounge_inovelli_smart_dimmer                     5e2d477e
  light.kitchen_above_table_chandelier_inovelli                  17a59d3c
  light.above_kitchen_sink_inovelli_switch                       89ca030d
  light.front_driveway_inovelli_smart_bulb_mode                  (VZM30-SN, S63 rename)

Tier 2 Dumb Load:
  light.kitchen_ceiling_inovelli_vzm31_sn
  light.kitchen_bar_pendant_lights                               da86388f
  light.kitchen_under_cabinet_lights_inovelli
  light.1st_floor_bathroom_ceiling_lights_dimmer_switch_inovelli_vzm31_sn
  light.back_door_patio_light_inovelli_switch

VZM35-SN Fan:
  light.inovelli_vzm35_sn_light                                  3eed85f7  (2nd Floor Bathroom Fan)

VZM36 Fan/Light Canopy (kitchen lounge, living room):
  EP1=light, EP2=fan. Disable EP2 firmware update entity (universal — see LEARNINGS S56)
  VZM36 wire colors: blue=EP1 (light), red=EP2 (fan). Swapped controls = physically reversed wires at canopy.

### Rules
- Config button cycling: input_number + modulo, NOT input_select
- Parameters require toggle OFF→ON in ZHA UI then air gap to write
- VZM35-SN: Param 12 (auto-off) = 2700s for hardware safety backup
- Blueprint: Rohan unified (NOT fxlt — fxlt fires ALL zha_events)
- AL Kitchen Table correct lights only: chandelier, above-sink, lounge, lounge-lamp, under-cabinet
  NEVER: kitchen_ceiling_inovelli_vzm31_sn, kitchen_bar_pendant_lights (Tier 2 = AL fight)

---

## ZHA EVENT TRIGGERS

- Use device_ieee NOT device_id in event_data — ZHA events carry IEEE, not internal UUID
- VZM30-SN/VZM31-SN command field: single string 'button_2_press', NOT separate button+press_type
- Multiple ZHA events per press: use mode: single not restart
- NEVER use .get() on trigger.event.data in Jinja2 — use | default('') filter instead
- VZM30-SN button commands: button_1_press, button_2_press, button_1_held_down, button_2_held_down, button_3_press
- ZHA cluster writes: manufacturer param must be integer (4655), not hex string

---

## ADAPTIVE LIGHTING

- Create/delete via UI ONLY — no API exists
- Instances: living_spaces, entry_room_ceiling, entry_room_lamp_adaptive, kitchen_table, master_bedroom_wall_lamp, upstairs_hallway

### Hue bridge bulbs — confirmed working settings (do NOT change based on community docs)
  take_over_control: true
  detect_non_ha_changes: false      # Hue gives false positives if true
  separate_turn_on_commands: true   # required for Hue color bulbs
  Note: Community docs suggest opposite for Hue bridge. Our live system contradicts this.

### autoreset_control_seconds
  bedrooms: 0 | kitchen/living: 3600 | hallways/baths: 1800

### Tier mixing
- Tier 1 (Adaptive): Hue color bulbs — turn_on with NO brightness/color params, AL takes over
- Tier 2 (Fixed): Inovelli/LED — turn_on with explicit brightness_pct + transition:0
- NEVER mix tiers in same light.turn_on call — AL fights explicit params

---

## MOTION AUTOMATIONS

- Always mode: restart for motion-triggered lights
- Use combined binary_sensor (template OR-logic), NOT OR-ing individual sensors (race condition)
- BINARY_SENSOR GROUP delay_off NOT SUPPORTED — use template:sensor with debounce on automation
- Open concept zones (kitchen+lounge, no door): single combined sensor + single automation pair
- Timeout by room: hallways 5-10min, active 8-20min, relaxation 15-45min
- Lux gate over sunset condition — use Third Reality nightlight illuminance sensor (12 live, threshold ~200 lux)

---

## GARAGE / RATGDO

### Diagnostic fast-path (run FIRST in any garage session)
  binary_sensor.ratgdo32disco_fd8d8c_obstruction   North (chronic)
  binary_sensor.ratgdo32disco_5735e8_obstruction   South (healthy)
  lock.ratgdo32disco_fd8d8c_lock_remotes
  lock.ratgdo32disco_5735e8_lock_remotes
  cover.ratgdo32disco_fd8d8c_door
  cover.ratgdo32disco_5735e8_door

### Hard rules
- lock_remotes is a RED HERRING — obstruction is the cause every time. Stop chasing lock_remotes.
- NEVER auto-cycle door from obstruction sensor state — ever
- Door-actuating automation MUST have ALL: home condition + time 07:00-22:00 + boolean flag + mode:single + cooldown
- NEVER include ratgdo light.* entities in HA automations — Chamberlain handles its own light, HA commands cause obstruction sensor interference

### North board fd8d8c permanent workaround
  Toggle Status obstruction OFF at http://ratgdo32disco-fd8d8c.local
  After ANY restart/OTA: verify Status obstruction still OFF
  DO NOT use binary_sensor.ratgdo32disco_fd8d8c_obstruction in automations
  For v2.5 boards: add obst_sleep_low: true to ratgdo ESPHome component config

### Both boards on firmware 2026.3.1 confirmed
### Ratgdo IPs: North 192.168.21.111 (fd8d8c), South 192.168.21.21 (5735e8)

### Notification tag ownership — NEVER duplicate
  arrival_john             notifications_system.yaml + arrival overwrite
  garage_arrival_dashboard garage_smart_arrival_dashboard_popup only
  garage_auto_close        garage_auto_close_north_on_departure only
  garage_door_north/south  native alert system only with skip_first: true
  garage_quick_open        garage_walk_in_door_quick_open only

---

## YAML PACKAGE RULES

- automations.yaml: id at column 0 (^- id:)
- packages/*.yaml: id at 2-space indent (^  - id:)
- ALWAYS search BOTH paths when hunting automation source
- MCP ha_config_set_automation injects unique_id: auto_* into package YAML — HA 2026.4.1 schema rejects this
  Detection: grep -rEl 'unique_id: auto_' /homeassistant/packages/
  Fix: python3 /homeassistant/hac/fix_pkg_unique_id.py
- input_boolean sub-fields in YAML KILL the entire file if helper also registered in UI store
  Fix: strip to bare helper_id: with no children
- Empty automation stub (- id: only, no alias/trigger/action) = config error
- ha core check returns non-zero for "Successful config (partial)" — never use as && gate; read bottom of output instead

---

## MCP BLIND SPOTS

| Symptom in MCP | Why MCP misses it | Fix |
|---|---|---|
| template binary_sensor unavailable | sees state not source | cat defining YAML |
| ha_config_get_automation RESOURCE_NOT_FOUND | YAML-only auto | cat packages/file.yaml |
| ha_deep_search returns wrong IDs | stale cache | terminal grep authoritative |
| notify target looks valid | dead mobile_app persists | grep mobile_app_X .storage/ |
| _2 suffix on new automation | ghost holds clean ID | ha_remove_entity then ha_set_entity |

RULE: unavailable on YAML-owned sensor = cat the file FIRST, never diagnose from MCP state alone.
RULE: After MCP edits any package automation, remove from YAML before next restart.

---

## DASHBOARD

- Storage-Mode kitchen-wall-v2 backup before ANY edit:
  cp .storage/lovelace.kitchen_wall_v2 hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
- ALWAYS force_reload:True before transform — captures current hash
- ONE comprehensive transform — never piecemeal index-based edits (indices shift silently)
- Reload tablet + verify after EVERY transform before next edit
- python_transform list comprehension on root cards[] can silently wipe sections — use direct index ops

### Sections View Gutter — CONFIRMED FIX (kitchen_wall theme, 2026-03-19)
/homeassistant/themes/kitchen_wall.yaml MUST contain exactly:
  ha-view-sections-column-max-width: 2000px
  ha-view-sections-column-min-width: 300px
  ha-view-sections-column-gap: 8px
  card-mod-view-yaml: |
    hui-sections-view:
      $: |
        :host {
          --ha-view-sections-column-max-width: 2000px !important;
        }

card-mod-view-yaml runs after component init, sets CSS var at shadow DOM host before HA defaults apply.
card-mod-root-yaml runs too early. CSS resource files lose specificity. FKB customCSS cannot pierce shadow DOM.
After theme change: frontend.reload_themes + clear cache + reload tablet. DO NOT change.

### atomic-calendar-revive (wall tablet) — locked settings
- compactMode: false (NEVER true — collapses card height)
- maxDaysToShow: 3-5, maxEventCount: 12-15
- dateSize: 200+, titleSize: 190+, timeSize: 160+
- column_span:1 on BOTH sections + max_columns:2 = correct 50/50 split
- dense_section_placement: false (true fights column_span)

### Kiosk Mode requirements
- Storage-mode dashboard required (NOT strategy)
- kiosk_mode config block + non-admin user = reliable lockdown

---

## FKB (Fully Kiosk Browser)

- Tab A9+, IoT VLAN 192.168.21.50, MAC CA:2F:26:E8:59:B7
- device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b (set_config requires device_id, NOT entity_id)
- startURL: http://192.168.1.10:8123/kitchen-tablet/home
- Screen Off Timer: 900s
- Auto-Update Fully Kiosk Browser: OFF (causes random restarts/stuck-on-logo)
- FKB port 2323 blocked LAN→IoT — use fully_kiosk.set_config cross-VLAN service instead
- Tier 1: native wake/sleep (Screen Off Timer + camera motion, no HA automations)
- Tier 2: HA automations for brightness/doorbell/presence/URL

---

## FAMILY CONTEXT — NEVER MIX

- Traci = Alaina and Ella's mother. Lives Independence WI. zone.traci_s_house = at_mom_s for girls.
- Michelle = John's girlfriend. Lives 40062 US Hwy 53. zone.michelles_house. Mother of Jarrett and Owen.
- at_mom_s sensors MUST use zone.traci_s_house — NEVER zone.michelles_house
- BSSID 60:22:32 and 62:22:32 = Michelle's WiFi. NEVER use for girls' mom detection.

---

## MATTER / AQARA

- Recommission fix: remove stale fabric from BOTH HA Matter AND Aqara app
- Use BOTH Matter + HomeKit integrations (different devices exposed)
- M3 IR blaster does NOT expose to HA
- Locks: Matter only. Some sensors: HomeKit only.
- Aqara P1 lux: exposed in Aqara app but NOT to HA via HomeKit/Matter bridge
  Fix: re-pair P1s directly to Sonoff ZBT-1 ZHA (loses Aqara app integration)

---

## NEVER RULES — INFRASTRUCTURE SAFETY

- UniFi network topology (VLANs, port profiles, firewall, port power) is UniFi-UI manual ONLY. HA may READ UniFi state, NEVER write. Lockout risk.
- NEVER create a UI helper without both a label AND a meaningful entity_id in the same session. Auto-IDs like input_boolean.new_input_boolean_2 become untrackable dark matter in gitignored .storage.
- NEVER edit .storage/* while HA is running — HA flushes in-memory registry to disk on shutdown, overwriting changes.
- NEVER auto-cycle garage door from any automation without home + time + boolean flag + mode:single + cooldown.
- NEVER include ratgdo light.* in HA automations.

---

## SHELL COMMANDS (MCP-callable, S67+)

  git_push            bundles add+commit+push (pass message via {{ message }} param) — ALWAYS via MCP, never terminal
  git_status          dirty working tree (--short) + unpushed commits
  git_last_commit     HEAD hash + message
  read_handoff        cat /config/HANDOFF.md
  read_learnings      cat /config/LEARNINGS.md
  read_critical_rules cat /config/CRITICAL_RULES.md
  mcp_session_init    git_status + git_last_commit + HANDOFF in one call
  health_check        REST API system audit (unavailable entities, double-fires, integration status)

---

## TERMINAL

- Paths: /homeassistant/ from terminal. NEVER /config/ from terminal. shell_commands use /config/ internally.
- git -C /homeassistant works from any directory — use when unsure
- Chain rules: see Project Instructions OPERATIONAL DEFENSES → EXIT-CODE CHAINING
- Escape ! or single-quote: echo 'Hello!' not echo "Hello!"
- BusyBox grep on EQ14: grep -rEl (no --include); pipe filter for extension narrowing
- BusyBox sed: NO multi-line scripts — use python3 heredoc for non-trivial edits
- ZSH bracket paste: sometimes injects [200~ prefix — retype manually
- ALWAYS use EQ14 (192.168.1.10). Green (192.168.1.3) decommissioned S51.
- shell_command edits in configuration.yaml require ha_restart (NOT reload_core) to take effect
