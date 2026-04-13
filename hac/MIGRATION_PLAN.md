# Migration Plan — HA Green → Beelink EQ14
## Created S12 2026-04-13

## Hardware
- **From**: HA Green aarch64, 192.168.1.3, HAOS 17.2, Core 2026.4.2
- **To**: Beelink EQ14 Mini PC, Intel N150, 16GB DDR4, 1TB SSD, amd64
- **Method**: Bare metal HAOS (not Proxmox — DS224+ covers secondary services)

## Safety backup
- Backup ID: 53ef3d09 (S12_Pre_Fresh_Build_Audit_2026-04-13, 159MB)
- Download to PC and copy to NAS before touching EQ14

## System inventory (S12 audit)
- 3,258 entities, 44 domains, 34 areas
- 64 integrations (63 loaded, 1 setup_retry)
- 163 automations, 156 scenes, 33 scripts, 9 dashboards
- 6 Adaptive Lighting instances
- 49 Zigbee devices (ZHA / Sonoff USB)
- 39 HACS repos

## What's in git (auto-restores)
- All YAML package files, configuration.yaml, scenes, scripts, themes
- Blueprints, ESPHome configs, hac/ tooling

## What requires manual attention post-restore
- ZHA USB path reassignment (Sonoff dongle — new port on EQ14)
- AL instances: verify all 6 enabled (living_spaces, entry_room_ceiling,
  entry_room_lamp_adaptive, kitchen_table, master_bedroom_wall_lamp, upstairs_hallway)
- ESPHome re-adopt: both Apollo R-PRO-1s (new arch = new binary)
- person.john_spencer: swap tracker to galaxy_s26_ultra in UI
- hac symlink: ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
- git push test via MCP shell_command.git_push
- NAS backup target: re-add network storage on EQ14

## HAOS install procedure (EQ14)
1. PC: download Ubuntu 24.04 LTS ISO + haos_generic-x86-64-17.2.img.xz
2. Flash Ubuntu to USB stick (Balena Etcher)
3. EQ14 BIOS (Delete key): Disable Secure Boot, confirm UEFI mode, enable WOL
4. Boot Ubuntu from USB → Try Ubuntu (NOT install)
5. Gnome Disks → select 1TB SSD → Restore Disk Image → haos_generic-x86-64-17.2.img.xz
6. Remove USB → boot EQ14 → reach homeassistant.local:8123 → STOP at onboarding
7. Restore from backup → upload 53ef3d09 → wait 45-60 min (amd64 addon pull)
8. SSH in, run: ha core stop → python3 /homeassistant/hac/s11_ghost_registry_cleanup.py → ha core start

## NAS setup (DS224+)
### Backup target (Phase 1 — immediate)
- DSM: Create share homeassistant_backups, user ha_backup, Read/Write
- HA: Settings → System → Storage → Add network storage → Samba
- Schedule: daily, keep 7, destination NAS

### MariaDB (Phase 5 — after 1 week stable)
- DSM Package Center: install MariaDB
- Create DB: homeassistant, user: ha_db, grant all
- configuration.yaml: recorder: db_url: mysql://ha_db:PASS@NAS_IP/homeassistant?charset=utf8mb4
- purge_keep_days: 30

## ZHA cross-arch migration note
- Backup restore carries .storage/zha.storage.json intact
- All 49 device pairings survive the aarch64 → amd64 transition
- Only the USB serial path changes — reassign in ZHA integration settings
- Devices check back in within 5-10 minutes of ZHA restart

## Post-migration backlog (unchanged from S12)
- S12/1: Vanity slow fade — LOCAL_RAMP_RATE on VZM30-SN IEEE 18:0d:f9:ff:fe:34:58:66
- S12/2: humidity_smart_alerts unpause bug
- S12/3: FoH switch automations (need button 1-4 spec)
- S12/4: Gemini bulk audit
- S12/5: Kitchen Apollo R-PRO-1 zone config + occupancy wiring
