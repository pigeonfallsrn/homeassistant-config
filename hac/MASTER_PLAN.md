# HA Migration Master Project Plan
## Green → EQ14 Beelink | John Spencer | Pigeon Falls, WI
### Version 1.0 — 2026-04-13 | Session S12

See full plan in Claude Project "HA Migration — EQ14 Beelink" → Files → HA_MASTER_PROJECT_PLAN.md

## NEXT STEPS IN ORDER
1. Run Gemini bulk audit on Green (Session S13)
2. PC: Download Ubuntu 24.04 ISO + haos_generic-x86-64-17.2.img.xz
3. Flash Ubuntu to USB with Rufus
4. Flash HAOS to EQ14 via Ubuntu live USB + Gnome Disks
5. EQ14 BIOS: Disable Secure Boot, confirm UEFI, enable WOL
6. Phase 2: NAS + git clone on EQ14
7. Phase 3: ZHA migration (.storage file copy)
8. Build blueprint library
9. Group-by-group automation rebuild (Groups 0-11)

## KEY FACTS
- EQ14 fixed IP: 192.168.1.10 (set in UniFi)
- EQ14 connected via USW Flex on Main LAN
- NAS_Backups: 192.168.1.52:Backups (HA_Synology, NordPass)
- Backup 53ef3d09 on NAS (parts kit for migration)
- IoT VLAN 20: 192.168.21.x (LAN - Spencer IoT)
