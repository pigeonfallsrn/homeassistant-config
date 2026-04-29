# CARRYFORWARD — open items spanning multiple sessions

Items here persist across sessions until resolved. Edited (rarely) when an item resolves; not regenerated each session.
When an item resolves, log the resolution in LEARNINGS.md (the session it was resolved in) and remove it from this file.

## Devices to add
- **Navien tankless water heater** integration not yet added to EQ14. Credentials in NordPass.
- **Yamaha RX-V671** AVR at `192.168.21.171:50000` not yet added to EQ14.

## Devices/integrations needing work
- **Music Assistant** in setup_error state — investigate and repair. Currently produces 7 unavailable `media_player.*` entities in health_check.
- **Michelle's device tracker** missing. MAC: `6a:9a:25:dd:82:f1`. Likely upstream cause of `binary_sensor.adults_only_home`, `_kids_home`, `_house_occupied`, `_john_home_alone` template-chain unavailability.
- **Ratgdo north** (`192.168.21.111`): clean physical IR sensor lenses (hardware task, not software).

## Naming/cleanup tasks
- **Ella's entities**: 20 entity_ids still named `iphone_40_*` — need rename to person-naming convention (likely `iphone_ella_*` or similar).
- **NordPass backlog cleanup** — entries to rename per convention `Device/Service — Purpose (user)`. See userMemories for full list of badly-named entries.

## Larger projects
- **Google Drive audit and reorganization** — DS224+ NAS as primary fast/reliable local storage; Google Drive as offsite sync backup. Private/sensitive files NAS-only, general files synced to both.
