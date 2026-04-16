# CRITICAL RULES CORE — EQ14 HA System
# Rules only. No history. No session notes.
# Full history: CRITICAL_RULES_HISTORY.md
# Last restructured: 2026-04-16 S24

---

## SESSION RITUALS

### Start (every session)
1. shell_command.read_handoff via MCP
2. shell_command.mcp_session_init via MCP
3. Confirm goal before touching anything

### End (every session — non-negotiable)
1. grep -rEl 'unique_id: auto_' /homeassistant/packages/
2. Update HANDOFF.md
3. git add -A && git commit
4. shell_command.git_push via MCP (NEVER terminal)
5. Verify: git log --oneline -3 shows origin/main at HEAD

---

## TERMINAL

- Paths: /homeassistant/ from terminal. NEVER /config/ in terminal.
- shell_commands use /config/ internally — never mix
- git -C /homeassistant works from any directory — use when unsure
- Always && chain commands
- NEVER chain after python3 -c or python3 << HEREDOC
- Escape ! or use single quotes: echo 'Hello!' not echo "Hello!"
- Alpine Linux BusyBox: NO --include grep, NO long sed options
  grep: use -rEl only. sed: use python3 for multi-line edits.
- ~/.zshrc does NOT persist across SSH add-on updates
  Persistent init: bash /config/hac/addon_init.sh in add-on init_commands (done S24)
- ZSH bracket paste: sometimes injects [200~ prefix — retype manually
- git push: ALWAYS via MCP shell_command.git_push. GIT_TERMINAL_PROMPT=0 required.
- ALWAYS use EQ14 terminal (192.168.1.10). NEVER HA Green (192.168.1.3).

---

## GHOST ENTITY REGISTRY

### Detection
state: unavailable + restored: true = ghost (no active source)

### Cleanup — UI first (2026)
Settings -> Devices & Services -> Entities -> filter Restored -> bulk delete

### Cleanup — MCP method (confirmed S23/S24)
create automation (gets _2) -> ha_remove_entity ghost -> ha_set_entity rename _2 to clean ID

### Cleanup — .storage surgery (last resort only)
STOP HA FIRST: ha core stop
Edit BOTH in same python3 pass:
  /homeassistant/.storage/core.entity_registry  remove from data.entities
  /homeassistant/.storage/core.restore_state    remove from data by state.entity_id
Filter by entity_id NOT unique_id
Then: ha core start
NEVER ha core restart during surgery — flushes in-memory state, overwrites edits
NEVER edit .storage files while HA is running

### YAML migration order (non-negotiable)
CORRECT: strip YAML -> restart -> create in UI -> clean IDs (no _2)
WRONG:   create in UI -> strip YAML -> always gets _2

### Ghost types
- unavailable + restored:true = YAML id: entry, source gone -> ha_remove_entity
- RESOURCE_NOT_FOUND from ha_config_get_automation = YAML-only, never in UI store
- Duplicate alias YAML + UI = BOTH load concurrently, BOTH run — strip YAML after MCP create

---

## YAML PACKAGE RULES

- MCP ha_config_set_automation injects unique_id: auto_* into package YAML (breaking 2026.4)
  Detection: grep -rEl 'unique_id: auto_' /homeassistant/packages/
  Fix: python3 /homeassistant/hac/fix_pkg_unique_id.py
- input_boolean sub-fields in YAML kills entire file if helper registered in UI store
  Fix: strip to bare helper_id: with no children
- Empty automation stub (- id: only, no alias/trigger/action) = config error
- automations.yaml: id at column 0 (^- id:)
- packages/*.yaml: id at 2-space indent (^  - id:)
- Search BOTH paths when hunting automation source
- ha core check returns non-zero for Successful config partial — never use as && gate

---

## ZHA EVENT TRIGGERS

- Use device_ieee NOT device_id in event_data
- VZM30-SN and VZM31-SN command field: single string e.g. button_2_press
- Multiple ZHA events per press: use mode: single not restart
- NEVER use .get() on trigger.event.data in Jinja2 — use | default filter
- VZM30-SN commands: button_1_press, button_2_press, button_1_held_down,
  button_2_held_down, button_3_press

---

## MOTION AUTOMATIONS

- Always mode: restart for motion-triggered lights
- Use combined binary_sensor not OR-ing individual sensors (race condition)
- Inovelli dumb-load switches: always include transition: 0 in light.turn_on
- BINARY_SENSOR GROUP: delay_off NOT SUPPORTED — use template: sensor instead
- Open concept zones kitchen+lounge: single combined sensor, single automation pair
- Timeout by room: hallways 5-10min, active 8-20min, relaxation 15-45min

---

## INOVELLI SWITCHES

### Two architectures — NEVER mix
Tier 1 Smart Bulb Mode (Hue bulbs):
  Param 52=1, load always-on, paddle sends ZHA events
  HA/AL controls HUE entity NOT switch entity — never add switch to AL

Tier 2 Dumb Load (cans, pendants, under-cabinet):
  Param 52=0, switch cuts power
  HA sends brightness_pct + transition:0 to SWITCH entity — never add to AL

### Rules
- Config button cycling: input_number + modulo, not input_select
- Parameters require toggle OFF->ON in ZHA UI then air gap
- VZM35-SN fans: Param 12 auto-off = 2700s
- Blueprint: Rohan unified (NOT fxlt — fxlt fires ALL zha_events)
- HUE BRIDGE BULBS cannot bind to Inovelli EP2 via ZHA — different Zigbee network
  Only working arch: Param 52=1 + HA automation on ZHA event + light.turn_on on Hue entity

### Device Inventory (confirmed EQ14)
Tier 1: light.entry_room_ceiling_light_inovelli_smart_dimmer_switch  d80c7fa6
        light.kitchen_lounge_inovelli_smart_dimmer                   5e2d477e
        light.kitchen_above_table_chandelier_inovelli                17a59d3c
        light.above_kitchen_sink_inovelli_switch                     89ca030d
Tier 2: light.kitchen_ceiling_inovelli_vzm31_sn
        light.kitchen_bar_pendant_lights                             da86388f
        light.kitchen_under_cabinet_lights_inovelli
        light.1st_floor_bathroom_ceiling_lights_dimmer_switch_inovelli_vzm31_sn
        light.back_door_patio_light_inovelli_switch
        light.front_driveway_inovelli

---

## ADAPTIVE LIGHTING

- Create/delete via UI ONLY — no API exists
- Instances: living_spaces, entry_room_ceiling, entry_room_lamp_adaptive,
  kitchen_table, master_bedroom_wall_lamp, upstairs_hallway

### Hue bridge bulbs — confirmed working settings (do not change based on community docs)
  take_over_control: true
  detect_non_ha_changes: false    Hue bulbs give false positives if true
  separate_turn_on_commands: true required for Hue color bulbs
  NOTE: Community suggests opposite for Hue bridge. Our live system contradicts this.
  Keep until explicitly tested otherwise.

### autoreset_control_seconds
  bedrooms: 0 | kitchen/living: 3600 | hallways/baths: 1800

### Kitchen Table AL correct lights only
  chandelier, above-sink, lounge, lounge-lamp, under-cabinet
  NEVER: kitchen_ceiling_inovelli, kitchen_bar_pendant_lights (Tier 2 — AL fight)

---

## GARAGE / RATGDO

### Diagnostic fast-path (run first in any garage session)
  binary_sensor.ratgdo32disco_fd8d8c_obstruction  North
  binary_sensor.ratgdo32disco_5735e8_obstruction  South
  lock.ratgdo32disco_fd8d8c_lock_remotes
  lock.ratgdo32disco_5735e8_lock_remotes
  cover.ratgdo32disco_fd8d8c_door
  cover.ratgdo32disco_5735e8_door

### Hard rules
- lock_remotes = RED HERRING. Obstruction is almost always the real cause.
- NEVER auto-cycle door from obstruction sensor state — ever
- Door-actuating automation MUST have ALL:
  home condition + time 07:00-22:00 + boolean flag + mode:single + cooldown

### North board fd8d8c permanent workaround
  Toggle Status obstruction OFF at http://ratgdo32disco-fd8d8c.local
  After ANY restart/OTA: verify Status obstruction still OFF
  DO NOT use binary_sensor.ratgdo32disco_fd8d8c_obstruction in automations
  For v2.5 boards: add obst_sleep_low: true to ratgdo ESPHome component config

### Both boards on firmware 2026.3.1 confirmed

### Notification tag ownership — never duplicate
  arrival_john             notifications_system.yaml + arrival overwrite
  garage_arrival_dashboard garage_smart_arrival_dashboard_popup only
  garage_auto_close        garage_auto_close_north_on_departure only
  garage_door_north/south  native alert system only with skip_first: true
  garage_quick_open        garage_walk_in_door_quick_open only

---

## MCP BLIND SPOTS

Symptom                               Why                        Fix
template sensor unavailable           sees state not source      cat defining YAML
ha_config_get_automation NOT_FOUND    YAML-only auto             cat packages/file.yaml
ha_deep_search wrong IDs              stale cache                terminal grep
notify target looks valid             dead mobile_app persists   grep mobile_app_X .storage/
_2 suffix on new automation           ghost holds clean ID       ha_remove_entity then ha_set_entity

RULE: unavailable on YAML-owned sensor = cat the file FIRST
RULE: after MCP creates UI automation, always strip from YAML before next restart

---

## SHELL COMMANDS (MCP callable)

  git_push            push origin main — always via MCP never terminal
  git_status          pending vs origin/main
  git_last_commit     HEAD hash + message
  read_critical_rules cat CRITICAL_RULES_CORE.md
  read_handoff        cat HANDOFF.md
  mcp_session_init    git_status + git_last_commit combined

---

## DASHBOARD

- Before ANY kitchen-wall-v2 edit: cp .storage/lovelace.kitchen_wall_v2 hac/backups/kitchen-wall-v2-$(date +%Y%m%d-%H%M).json
- Always force_reload:True before transform to get current hash
- One comprehensive transform — never piecemeal index-based edits
- After transform: reload tablet + verify before proceeding
- FKB auto-update DISABLE: FKB Settings > Auto-Update = OFF
- FKB config via fully_kiosk.set_config cross-VLAN device_id: 86870b5d8b01f345f5d5dd9c2ac06d2b
- Sections gutter fix in kitchen_wall theme card-mod-view-yaml — DO NOT CHANGE

---

## FAMILY CONTEXT

- Traci = Alaina and Ella mother. zone.traci_s_house = at_mom_s
- Michelle = John girlfriend. zone.michelles_house. Mother of Jarrett and Owen
- at_mom_s MUST use zone.traci_s_house — NEVER zone.michelles_house
- BSSID 60:22:32 and 62:22:32 = Michelle WiFi — never use for girls mom detection

---

## SECURITY BACKLOG

- SSH password auth still enabled — set password empty string in add-on config + add ed25519 key
- Cloudflare Zero Trust not configured — HA login exposed to internet
- Git PAT in plaintext at /config/.git/config — rotate to fine-grained PAT
- 92 device_tracker entities logging GPS — recorder exclude already in config

---

## MATTER / AQARA

- Recommission: remove stale fabric from BOTH HA Matter AND Aqara app
- Use BOTH Matter + HomeKit integrations — different devices exposed
- M3 IR blaster does NOT expose to HA
- Locks Matter only. Some sensors HomeKit only.
