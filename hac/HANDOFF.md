# HAC Handoff — 2026-04-09 S9

## Last commit
  008ca78 docs: S9 handoff + learnings — bathroom switches fixed, VZM36 cleaned, pre-migration backup 7042a0e9

## S9 Completed
  - VZM36 living room _3/_4 orphan entities: hidden + labelled (not referenced anywhere, Hue group is active path)
  - #3 kitchen override timer.cancel: already existed in clear automation — queue entry was stale
  - 2nd floor bathroom switches: rebuilt combined automation (both vanity + ceiling switch → both Hue light groups, scene cycling via input_number.bathroom_scene_index, 0=Energize/1=Relax/2=Dimmed/3=Nightlight)
  - Old fxlt ceiling blueprint automation: disabled (double-fire prevention)
  - Fan humidity v3: unstuck via restart — state: on, all triggers active
  - ghost automation.2nd_floor_bathroom_ceiling_lights_inovelli_control: confirmed ghost (not in storage, not in packages) — no action needed
  - Disk cleared: 89% → 79% (5.6 GB free) by deleting 7 auto + 26 manual backups
  - Final pre-migration backup: 7042a0e9 Pre_Migration_Final_S9_2026-04-09 (160 MB)
  - Backup IDs on disk: b29e3f3b (pre-S9), 7042a0e9 (post-S9 = USE THIS for Mini PC migration)

## MINI PC MIGRATION — FRIDAY 2026-04-11
  Hardware: HA Green (aarch64, 192.168.1.3) → Mini PC (x86-64)
  USE BACKUP: 7042a0e9 Pre_Migration_Final_S9_2026-04-09
  ZHA: Sonoff USB dongle will need reassignment post-migration
  ESPHome: both Apollo R-PRO-1 units need re-adopt after migration

## S10 Priority Queue
  1. APOLLO KITCHEN FLASH — ESPHome Device Builder → Kitchen Area R-PRO-1 → Install Wirelessly → 192.168.21.233
     Key: HBDFcZsyn0zMmOlfkEic/kG8EJDq2dykr7oclXUw7UU=
     After online: LD2450 zones X1=-4000,X2=4000,Y1=500,Y2=6000
     Wire binary_sensor.kitchen_area_r_pro_1_occupancy into first_floor_main_motion template
  2. APOLLO ENTRY ROOM — wire occupancy into first_floor_main_motion (already online, just needs template edit)
  3. PACKAGE YAML FIXES (terminal + ha core restart):
     a. lighting_motion_firstfloor.yaml line 44: add timer.cancel before input_boolean.turn_off in kitchen_manual_override_auto_clear
     b. lighting_motion_firstfloor.yaml lines 81-82: remove duplicate light.kitchen_lounge entry in Tier 1 turn_on
     c. lighting_motion_firstfloor.yaml lines 106-107: remove duplicate light.kitchen_lounge entry in Tier 1 turn_off
     d. lighting_motion_firstfloor.yaml line 26: confirm if delay_off: {minutes: 5} needed on first_floor_hallway_motion
  4. UPSTAIRS HALLWAY SCENES — replace brightness/color_temp with scenes in upstairs_lighting.yaml lines 45-80
     (need: cat -n /homeassistant/packages/upstairs_lighting.yaml)
  5. FOH SWITCH AUTOMATIONS — Friends of Hue switch, Living Room Lounge
     Entities: event.works_with_hue_switch_1_button_1 through _4
     Currently: zero HA automations (Hue-native only)
     Need: button spec from John before building
  6. POST-MIGRATION: person.john_spencer → swap source to device_tracker.galaxy_s26_ultra in UI

## Known issues / watch list
  - sensor.navien_water_flow: unavailable — Navien integration offline, hot water flow trigger in fan automation dead until fixed
  - first_floor_hallway_motion: missing delay_off (comment says 5min but not in YAML)
  - Disk: 79% post-cleanup. Automatic backup schedule still set to "keep 5" — will fill back up. Consider reducing retention or offloading to NAS.

## Start next session
  hac mcp   ← paste session prompt as usual
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac   ← after any power cycle
