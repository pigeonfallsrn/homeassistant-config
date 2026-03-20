# HAC Architecture Decisions
*Why the system is built the way it is*
*Consult before proposing architectural changes*

## Config Architecture
**Decision:** Package-based YAML under `/homeassistant/packages/` with git version control
**Why:** Local control, auditable history, AI-friendly structure, easy rollback
**Implication:** Never use UI editor for package-managed automations — git is source of truth

## Presence System
**Decision:** Template `binary_sensor` (Phase 9.1) — replaced 10 `input_boolean` + 11 automations
**Why:** Fewer moving parts, no race conditions, no automation dependency chain
**Entities:** `binary_sensor.john_home`, `alaina_home`, `ella_home`, `michelle_home`,
`someone_home`, `girls_home`, `both_girls_home`, `john_and_girls`, `john_and_michelle`, `full_house`
**Caveat:** Ella unreliable (tracks iPad not iPhone 17) — tabled until she returns

## Govee Integration
**Decision:** Matter on IoT VLAN only — govee2mqtt abandoned
**Why:** govee2mqtt cross-VLAN LAN discovery confirmed dead end (do not retry)
**Entity:** `light.kitchen_govee_floor_lamp` (Matter, static IP 192.168.21.64)

## FKB Control
**Decision:** `fully_kiosk.set_config` HA service — not port 2323
**Why:** Tablet on IoT VLAN 192.168.21.x, port 2323 blocked cross-VLAN
**Device ID:** `86870b5d8b01f345f5d5dd9c2ac06d2b`

## Dashboard Architecture
**Decision:** `kitchen-wall-v2` storage-mode sections layout
**Why:** Sections layout only available in storage-mode, not YAML-mode dashboards
**Implication:** `ha_config_set_dashboard` only — no file editing for this dashboard

## Network Segmentation
**Decision:** IoT devices on VLAN 192.168.21.x, HA has cross-VLAN access
**Why:** Security isolation — IoT devices cannot initiate connections to main LAN
**Implication:** Some integrations need HA-side polling rather than device-push

## Adaptive Lighting
**Decision:** Separate AL instances per room/bulb-type
**Why:** Same make/model requirement — mixing bulb types in one instance causes conflicts
**Instances:** living_spaces, entry_room_ceiling, kitchen_table, kids_rooms, upstairs_hallway
