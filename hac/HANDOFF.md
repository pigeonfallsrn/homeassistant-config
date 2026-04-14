# HANDOFF — Session S15
## ZHA Migration — Green → EQ14
Date: 2026-04-13

## STATUS: COMPLETE ✅

## What was accomplished
- Git repo cloned to EQ14 /homeassistant, main branch, push confirmed working
- zigbee.db + zigbee.db-shm + zigbee.db-wal copied from Green via Python HTTP server
- core.config_entries, core.device_registry, core.entity_registry copied from Green
- Sonoff Zigbee USB dongle physically moved Green → EQ14
- ZHA loaded on EQ14: 52 devices, 1193 entities — all devices present, no re-pairing needed
- HA Core 2026.4.2 running on HAOS 17.2

## Known issues (do not fix now)
- NAS_Backups not mounted on EQ14 (CIFS auth not configured) — fix in next session
- Alexa Media Player needs reauth — Phase 6
- Google Calendar, Nest, Spotify, Roku, TP-Link, Wyoming — all need reauth — Phase 6
- MCP still pointing to Green (ha.myhomehub13.xyz) — update Cloudflare tunnel next session

## Next session: S16
1. Fix NAS_Backups CIFS mount on EQ14 (get correct password from NordPass)
2. Update Cloudflare tunnel to point to EQ14 (192.168.1.10)
3. Verify MCP connects to EQ14
4. Configure daily backup to NAS
5. Begin Phase 6 — integrations reauth (Hue Bridge first)

## Green status
- ZHA offline (dongle removed) — Green is now cold spare only
- Keep Green powered but do NOT re-enable ZHA on Green
