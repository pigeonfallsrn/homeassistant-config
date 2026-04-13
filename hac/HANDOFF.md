# HAC Handoff — S13 CLOSE 2026-04-13

## Last commit (this session)
  audit: S13 — complete automation triage (Claude + Gemini)

## S13 Summary
  - Gemini bulk audit: all 163 automations triaged
  - Claude filled gaps (Gemini only covered ~40 on first pass)
  - Final consensus: 117 KEEP / 22 REBUILD / 24 DELETE
  - 22 ghost automations confirmed DELETE (YAML package leftovers)
  - 10 must-rebuild automations identified with specific actions
  - Entity risks documented (person tracker, distance sensor, Yamaha)
  - Blueprint standardization plan: all Inovelli → Rohan, all FOH → BP-2
  - automation_dump.yaml (80KB) committed to hac/audit/
  - gemini_audit_S13.md committed to hac/audit/
  - Full triage table in Claude Project artifact

## CURRENT STATE
  - Green: healthy, running, NAS backup active
  - EQ14: 192.168.1.10, Windows installed, awaiting HAOS flash
  - Ubuntu 24.04 ISO: downloaded on PC
  - HAOS img: downloaded on PC (haos_generic-x86-64-17.2.img.xz)
  - Audit: COMPLETE — triage list ready for all 12 migration groups

## NEXT SESSION (S14) — EQ14 Hardware
  1. Flash Ubuntu 24.04 to USB with Rufus
  2. Boot EQ14 from USB → "Try Ubuntu"
  3. Gnome Disks → write HAOS img to 1TB NVMe
  4. Reboot → HAOS onboarding at homeassistant.local:8123
  5. BIOS: disable Secure Boot, confirm UEFI, enable WOL
  6. DHCP reservation: MAC → 192.168.1.10 in UniFi
  7. Confirm SSH: hassio@192.168.1.10 -p 2222
  8. Begin Phase 2: NAS + git clone

## BACKLOG
  1. Vanity slow fade: LOCAL_RAMP_RATE VZM30-SN → Group 5
  2. humidity_smart_alerts unpause bug → Group 7
  3. FoH button 1-4 spec needed → Group 1-3
  4. Kitchen Apollo zone config + occupancy wiring → Group 2

## Start next session
  Open Claude Project: "HA Migration — EQ14 Beelink"
  Reference: hac/MASTER_PLAN.md + hac/audit/gemini_audit_S13.md
