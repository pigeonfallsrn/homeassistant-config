# S9 HANDOFF — from S8 2026-04-08

## LAST COMMIT: 3e79160
## MINI PC ARRIVES: 2026-04-11 (Friday)

## S8 COMPLETED
- P1: Hue motion gap audit — no gap, design correct
- P2: kitchen_tier2_motion_on default (22+): OFF + scene.kitchen_nightlight
- P3: timer.kitchen_override_timer (30min) + SET/CLEAR automations
- P4: CRITICAL_RULES_CORE — LD2450 zone fix + VZM31-SN P27 added
- Kitchen Apollo R-PRO-1 adopted in ESPHome Device Builder (new add-on installed)

## S9 PRIORITY QUEUE (do in order)

### 1. KITCHEN APOLLO — POST-FLASH WIRING (first task)
After ESPHome compile+flash completes:
- Confirm device online in ESPHome Device Builder
- Add to HA: Settings → Devices & Services → ESPHome → Add Device
  IP: 192.168.21.233, encryption key: HBDFcZsyn0zMmOlfkEic/kG8EJDq2dykr7oclXUw7UU=
- Set LD2450 zones: X1=-4000, X2=4000, Y1=500, Y2=6000, timeout=60s
- Find occupancy entity: ha_search_entities "kitchen_area_r_pro_1"
- Add to first_floor_main_motion template (lighting_motion_firstfloor.yaml)
- Verify illuminance entity for lux gating

### 2. ENTRY ROOM APOLLO — WIRE OCCUPANCY
- Confirm occupancy entity (likely binary_sensor.entry_room_occupied)
- Add to first_floor_main_motion alongside existing Aqara P1
- Consider "Take Control" in Device Builder to get YAML editable

### 3. OVERRIDE TIMER — AUTO-CLEAR FIX
- Edit kitchen_manual_override_auto_clear (package YAML, ~line 44)
- Add timer.cancel to action block so no-motion clear also kills timer

### 4. UPSTAIRS HALLWAY — scenes instead of brightness/color_temp
- File: /homeassistant/packages/upstairs_lighting.yaml lines 45-80

### 5. FOH SWITCH AUTOMATIONS (3 switches — see S5 HANDOFF)

### 6. VZM36 LIVING ROOM _3+_4 DUPLICATES — investigate

## PRE-MIGRATION CHECKLIST (before Mini PC Friday)
- All Apollo sensors wired and tested
- Config check clean
- Final backup named Pre_MiniPC_Migration_Final

## ARCHITECTURE NOTE (S9 cleanup candidate)
kitchen_tier2_motion_on (package YAML) + kitchen_lounge_motion_lighting (UI)
both target ceiling/pendants on same trigger — last-write-wins conflict.
Plan: consolidate into single package YAML automation, delete UI version.
