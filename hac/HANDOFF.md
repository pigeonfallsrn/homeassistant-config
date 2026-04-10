# HAC Handoff — 2026-04-09 S10-C (Pre-Migration Deep Cleanup)

## Last commit
  ba7c40b chore: S10-B — s11 ghost cleanup script (13 ghosts), remove stale dashboard bak

## S10-C Completed
  - Ghost registry cleanup script: hac/s11_ghost_registry_cleanup.py (committed)
    Run BEFORE first ha core start on Mini PC — removes 12 registry ghosts permanently
  - lovelace-kitchen-tablet.yaml.bak deleted
  - Recorder confirmed purge_keep_days: 3 — S4 backlog item CLOSED
  - All 10 unavailable automations: zero YAML backing, pure registry orphans
    Root cause: registry edits while HA live get overwritten on clean shutdown
    Fix: s11_ghost_registry_cleanup.py pre-start on Mini PC
  - HAC export duplicate status:
    OLD hac_daily_master_context_export — no unique_id, last ran 2026-04-08 08:00, still active
    NEW hac_daily_master_context_export_2 — has unique_id, NEVER triggered (S10 fix broken)
    Needs: find old YAML, delete it, verify _2 fires correctly

## MINI PC MIGRATION — TOMORROW 2026-04-11
  Restore backup: 7042a0e9  (Pre_Migration_Final_S9_2026-04-09, 160MB)
  Hardware: HA Green aarch64 192.168.1.3 → Mini PC x86-64

## POST-MIGRATION VERIFICATION CHECKLIST (S11 — do in order)
  0. PRE-START: python3 /homeassistant/hac/s11_ghost_registry_cleanup.py  ← do BEFORE ha start
  1. ZHA: confirm Sonoff dongle assigned, all 49 Zigbee devices online
     grep -r "zha" /homeassistant/.storage/core.config_entries | head -5
  2. ESPHome: both Apollo R-PRO-1 need re-adopt (new arch = new binary)
     - Entry Room (apollo-r-pro-1-w-748020): re-adopt only, config preserved
     - Kitchen Area (192.168.21.233): flash → adopt → zone config → wire occupancy
  3. Adaptive Lighting: verify all 6 instances enabled
     living_spaces, entry_room_ceiling, entry_room_lamp_adaptive,
     kitchen_table, master_bedroom_wall_lamp, upstairs_hallway
  4. person.john_spencer: swap source to device_tracker.galaxy_s26_ultra in UI
  5. hac symlink: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
  6. git push test: shell_command.git_push → confirm new machine pushes OK
  7. Disk: confirm df -h headroom on x86-64
  8. Backup schedule: set to daily/keep 3 in UI (currently keep 5)

## S11 BACKLOG (after migration verified stable)
  - HAC export duplicate: find old YAML, remove it, verify _2 fires at 08:00
  - FoH switch automations: need button 1-4 spec from John
  - Gemini bulk audit: run audit prompt against full automation dump
  - Kitchen Apollo R-PRO-1: zone config + occupancy wiring (S8 deferred)

## Known issues / watch list
  - sensor.navien_water_flow: unavailable — Navien integration offline
  - ha core check triggers KeyError: known HA 2026.4 validator bug, ignore
  - Backup schedule: still keep 5 — fix post-migration in UI
  - hac symlink: lost after power cycle — step 5 of S11 checklist
  - Ghost automations (12): live registry still has them; s11 script clears on Mini PC

## Start next session
  hac mcp   ← paste session prompt as usual
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac

## RECENT COMMITS
ba7c40b chore: S10-B — s11 ghost cleanup script (13 ghosts), remove stale dashboard bak
5e2ac59 docs: S10-B pre-migration cleanup — ghost autos removed, 4 dashboards deleted
e80d237 docs: S10 pre-migration final — all fixes complete, migration checklist ready
