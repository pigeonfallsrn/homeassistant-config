# HAC Handoff — 2026-04-09 S10-B (Pre-Migration Final + Cleanup)

## Last commit
  e80d237 docs: S10 pre-migration final — all fixes complete, migration checklist ready

## S10-B Completed (this session — storage changes only, no YAML commits)
  - living_room_lamps_activity_boost ghost × 2: removed from core.entity_registry
    (IDs: 36fe353d, 3858d1d7 — no backing YAML, pure orphans since Jan/Mar 2026)
  - Dashboards deleted (4): kitchen-tablet-wall, ella-dashboard, dashboard-6767, john-lights
    Dashboard count: 13 → 9
  - upstairs_lighting.yaml: reviewed — CLEAN, no action needed
    scene.upstairs_hallway_energize confirmed present and active

## MINI PC MIGRATION — TOMORROW 2026-04-11
  Restore backup: 7042a0e9  (Pre_Migration_Final_S9_2026-04-09, 160MB)
  Hardware: HA Green aarch64 192.168.1.3 → Mini PC x86-64

## POST-MIGRATION VERIFICATION CHECKLIST (S11 — do in order)
  1. ZHA: confirm Sonoff dongle assigned, all 49 Zigbee devices online
     grep -r "zha" /homeassistant/.storage/core.config_entries | head -5
  2. ESPHome: both Apollo R-PRO-1 need re-adopt (new arch = new binary)
     - Entry Room (apollo-r-pro-1-w-748020): re-adopt only, config is preserved
     - Kitchen Area (192.168.21.233): flash → adopt → zone config → wire occupancy
  3. Adaptive Lighting: verify all 6 instances enabled
     living_spaces, entry_room_ceiling, entry_room_lamp_adaptive,
     kitchen_table, master_bedroom_wall_lamp, upstairs_hallway
  4. person.john_spencer: swap source to device_tracker.galaxy_s26_ultra in UI
  5. hac symlink: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
  6. git push test: shell_command.git_push → confirm new machine pushes OK
  7. Disk: x86-64 should have more headroom — confirm df -h
  8. Backup automatic schedule: reset to daily/keep 3 (not 5 — fills too fast)

## S11 BACKLOG (after migration verified stable)
  - FoH switch automations: need button 1-4 spec from John
  - Upstairs hallway scenes: reviewed clean — no action needed
  - Gemini bulk audit: run audit prompt against full automation dump
  - Kitchen Apollo R-PRO-1: zone config + occupancy wiring (S8 deferred)

## Known issues / watch list
  - sensor.navien_water_flow: unavailable — Navien integration offline
  - ha core check triggers KeyError: known HA 2026.4 validator bug, ignore
  - Automatic backup schedule: still "keep 5" — will fill disk again post-migration
  - hac symlink: lost after power cycle (symlink task is step 5 of S11 checklist)

## Start next session
  hac mcp   ← paste session prompt as usual
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac

## RECENT COMMITS
e80d237 (HEAD) docs: S10 pre-migration final — all fixes complete, migration checklist ready
d4989be fix: S10 pre-migration — Apollo Entry wired, timer.cancel, kitchen_lounge dedup, hallway delay_off
