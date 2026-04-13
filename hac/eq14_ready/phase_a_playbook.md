# Phase A: Foundation — EQ14 Deployment Playbook
## S13B | Floors, Areas, Labels, Categories

> Run after EQ14 HAOS boots. BEFORE copying entity/device registries.

## A1. FLOORS (4)
ha_config_set_floor(name="Outdoors", icon="mdi:tree", level=0)
ha_config_set_floor(name="1st Floor", icon="mdi:home-floor-1", level=1)
ha_config_set_floor(name="2nd Floor", icon="mdi:home-floor-2", level=2)
ha_config_set_floor(name="Basement", icon="mdi:home-floor-negative-1", level=-1)

NOTE: Green has separate Attic floor — do NOT recreate. Attic is area under 2nd Floor.
Green floor_ids: 1st_floor_home, 2nd_floor_home. EQ14 will be: 1st_floor, 2nd_floor.
Entity registries reference area_ids not floor_ids, so this is fine.

## A2. AREAS (25) — RECOMMENDED: Copy core.area_registry from backup
Green has mismatched area_ids (upstairs for "Upstairs Hallway", 2nd_floor_bathroom
for "Upstairs Bathroom"). Copy core.area_registry from backup 53ef3d09 to preserve IDs.

### Step 1: Copy area registry
scp -P 2222 core.area_registry hassio@192.168.1.10:/homeassistant/.storage/

### Step 2: Create floors (MCP, A1 above)

### Step 3: Fix floor assignments
ha_config_set_area(area_id="basement_hallway", floor_id="basement")
ha_config_set_area(area_id="pigeon_falls_properties", floor_id="outdoors")
ha_config_set_area(area_id="attic", floor_id="2nd_floor")
Smart Home AV: already on Basement — no fix needed (confirmed S13B, AVR shelf under living room)

### Step 4: Reassign devices from areas being deleted
ha_update_device(device_id="b91ed78e5f6bb6e5fe81174541ea114c", area_id="front_driveway")  # G4 Doorbell
ha_update_device(device_id="b8924dbf13d6d832c14564b264c4ac37", area_id="very_front_door")  # Hue light
ha_update_device(device_id="901e88f32f15b375319ac1b695d6c073", area_id="very_front_door")  # Aqara motion
ha_update_device(device_id="8a7d9d41f4549be1168a85f7077bcfa8", area_id="")  # spare Shelly

### Step 5: Delete 9 unwanted areas
ha_config_remove_area: yard_sheds, bedroom, entry_way, cloud, cloud_wifi_sync_module,
  basement_stairs, front_door, very_front_door_hallway, other

### Step 6: ha core restart

## A3. LABELS (12)
ha_config_set_label: Lighting(yellow), Presence(blue), Security(red), Climate(orange),
  Kids(pink), Garage(grey), AV(purple), Notifications(cyan), Override(deep-orange),
  Utilities(brown), HA System(light-blue), Adaptive(amber)

## A4. CATEGORIES
Automations: Active, Review Needed, Disabled, Template Instance
Helpers: Modes, Scene Indexes, Timers, Presence, Kids, Overrides, System
Scripts: Room Reset, System, Notifications

## FINAL COUNTS: 4 floors, 25 areas, 12 labels, 14 categories
