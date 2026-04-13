# HAC Handoff — S13 FINAL CLOSE 2026-04-13

## Last commit (this session)
  audit: S13 — full system pre-migration audit complete

## S13 Summary
  - Automation triage: 163 audited (117 KEEP / 22 REBUILD / 24 DELETE)
  - Helper triage: 62 audited (56 REBUILD / 6 DROP for mode consolidation)
  - Script triage: 18 audited (14 REBUILD / 4 DELETE → native Scenes)
  - Entity naming: 55 of 492 need renaming (Google Sheets saved)
  - Configuration.yaml: minimal 60-line template ready for EQ14
  - HACS: 9 REINSTALL, 1 DROP (localtuya), 1 SKIP (yamaha_ynca), 1 TBD (nodered)
  - Learnings: cheat sheet distilled (4 CRITICAL, 4 USEFUL, 1 STALE)
  - All dumps in hac/audit/ (9 files)

## CURRENT STATE
  - Green: healthy, running, NAS backup active
  - EQ14: 192.168.1.10, Windows installed, awaiting HAOS flash
  - Ubuntu 24.04 ISO: downloaded on PC (6.5GB)
  - HAOS img: downloaded on PC (haos_generic-x86-64-17.2.img.xz, 580MB)
  - Full audit: COMPLETE

## NEXT SESSION (S14) — EQ14 Hardware Flash
  Prerequisites on PC:
    1. Download Rufus from rufus.ie
    2. Flash Ubuntu ISO to USB drive with Rufus
    3. Copy haos_generic-x86-64-17.2.img.xz to NAS (\\192.168.1.52\Backups\)

  At the EQ14 (need: keyboard, monitor, ethernet):
    1. Boot from Ubuntu USB (F7 or Del for boot menu)
    2. "Try Ubuntu" (do NOT install)
    3. Gnome Disks → select 1TB NVMe → Restore Disk Image → HAOS img
    4. Wait ~10 min → remove USB → reboot
    5. BIOS: disable Secure Boot, confirm UEFI, enable WOL
    6. Navigate to homeassistant.local:8123 → complete onboarding
    7. DHCP reservation: MAC → 192.168.1.10 in UniFi
    8. Confirm SSH: hassio@192.168.1.10 -p 2222
    9. Begin Phase 2: NAS + git clone

## BACKLOG
  1. Vanity slow fade: LOCAL_RAMP_RATE VZM30-SN → Group 5
  2. humidity_smart_alerts unpause bug → Group 7
  3. FoH button 1-4 spec needed → Group 1-3
  4. Kitchen Apollo zone config + occupancy wiring → Group 2
  5. Decide: nodered DROP or REINSTALL?
  6. Decide: yamaha_ynca SKIP or REINSTALL?

## Start next session
  Open Claude Project: "HA Migration — EQ14 Beelink"
  Reference: hac/MASTER_PLAN.md + hac/audit/gemini_audit_S13.md
