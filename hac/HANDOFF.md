# HAC Handoff — 2026-04-09 S10 FINAL (Pre-Migration Complete)

## Last commit
  50133c8 fix: S10-C — kitchen_scene scripts recreated via MCP, removed from ghost list; .storage baks purged

## S10 Full Session Summary (S10-A through S10-C)
  - Ghost automations x12: s11_ghost_registry_cleanup.py ready (pre-start on Mini PC)
  - Ghost scripts x2 (kitchen_scene_all_on, kitchen_scene_movie_night): FIXED — recreated via MCP
    lovelace-kitchen-tablet.yaml now has live backing scripts again
  - HAC Daily Export duplicate: FIXED — deleted config.yaml inline block, automations.yaml is sole def
    On Green: still shows _2 (race condition); s11 script clears registry entry on Mini PC
  - 4 dashboards deleted: kitchen-tablet-wall, ella-dashboard, dashboard-6767, john-lights (13→9)
  - 60 MB .storage bak files purged (16 stale baks deleted, 3 remain)
  - lovelace-kitchen-tablet.yaml.bak deleted
  - Recorder confirmed purge_keep_days: 3 — backlog item CLOSED
  - upstairs_lighting.yaml reviewed: CLEAN
  - CRITICAL_RULES updated: registry race condition, grep --include warning, inline automation pitfall
  - Disk freed to 5.3 GB (80% used) — ready for migration

## MINI PC MIGRATION — TOMORROW 2026-04-11
  Restore backup: 7042a0e9  (Pre_Migration_Final_S9_2026-04-09, 160MB)
  Hardware: HA Green aarch64 192.168.1.3 → Mini PC x86-64

## POST-MIGRATION VERIFICATION CHECKLIST (S11 — do in order)
  0. PRE-START: python3 /homeassistant/hac/s11_ghost_registry_cleanup.py  ← do BEFORE ha core start
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
  9. Verify hac_daily_master_context_export shows no _2 suffix, fires at 03:00

## S11 BACKLOG (after migration verified stable)
  - FoH switch automations: need button 1-4 spec from John
  - Gemini bulk audit: run audit prompt against full automation dump
  - Kitchen Apollo R-PRO-1: zone config + occupancy wiring (S8 deferred)

## Known issues / watch list
  - sensor.navien_water_flow: unavailable — Navien integration offline
  - ha core check triggers KeyError: known HA 2026.4 validator bug, ignore
  - Backup schedule: still keep 5 — fix post-migration in UI
  - hac symlink: lost after power cycle — step 5 of S11 checklist
  - Ghost automations (11 + HAC _2): still live on Green (race condition); s11 script fixes on Mini PC

## Start next session
  hac mcp   ← paste session prompt as usual
  ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac

## RECENT COMMITS
50133c8 fix: S10-C — kitchen_scene scripts recreated, .storage baks purged
4d5bf14 fix: s11 cleanup — add kitchen_scene script ghosts
ff727c9 docs: CRITICAL_RULES — registry race, grep --include, inline automation pitfall
4032d21 docs: S10-C — recorder clean, HAC export dupe flagged
c1ae816 fix: S10-C — remove duplicate HAC export from config.yaml
ba7c40b chore: S10-B — s11 ghost cleanup script, stale bak removed
5e2ac59 docs: S10-B — 4 dashboards deleted, ghost autos removed
