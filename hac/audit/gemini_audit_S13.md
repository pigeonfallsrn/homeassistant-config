# S13 — Automation Migration Triage (Final)
## Consensus: Claude + Gemini 2.5 Pro | 2026-04-13

KEEP: ~117 | REBUILD: ~22 | DELETE: ~24 | TOTAL: 163

## Key Decisions
- 22 ghost automations: DELETE ALL
- TEMP git push: DELETE
- Kitchen + Lounge Motion Lighting: SPLIT into 3 time-tier automations
- Front Driveway Inovelli: REBUILD as Rohan blueprint
- Living Room Hue Switch: REBUILD as FOH blueprint
- 2nd Floor Bath manual Inovelli: DELETE (superseded by blueprint)
- Echo alarm sensors (Ella/Alaina): REBUILD with verified sensor names
- Hot Tub Pause/Resume: REBUILD with new UI automation IDs
- Humidity unpause fan: REBUILD (known bug fix)
- Midnight lights off: consolidate 2 overlapping automations into 1

## Entity Risks on EQ14
- person.john_spencer: swap tracker to galaxy_s26_ultra
- notify target: mobile_app_john_s_s26_ultra (verify)
- sensor.john_distance_to_home: verify Mobile App name
- media_player.basement_yamaha: verify discovery on Main LAN
- Echo alarm sensors: verify Alexa Media Player entity names
- Michelle iPhone MAC 6a:9a:25:dd:82:f1: add to presence

## Blueprint Standardization
- ALL Inovelli switches → Rohan blueprint (no manual YAML cycling)
- ALL FOH/Hue dimmers → BP-2 FOH Scene Cycling blueprint
- VZM30-SN bathroom → BP-4 when built in Group 5

## Full triage table: see Claude artifact gemini_audit_S13.md
