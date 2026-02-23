# Gotchas (Learned Hard Way)
*Last updated: 2026-02-21*

## Inovelli
- fxlt blueprint triggers ALL zha_events, filters by device_id in condition
  → All automations using blueprint fire on every button press
  → Fix: Migrate to per-device-id trigger or MasterDevwi unified blueprint
- Scene events (button_X_press) work even when smart_bulb_mode broken - independent features
- Params must be toggled OFF/ON in ZHA UI to force write to device, then air gap

## Entity Management  
- Entity purge requires UI - REST API returns 400
- Orphaned entities: Settings → Entities → filter unavailable → bulk delete
- No CLI method for entity registry cleanup

## Notifications
- Phone re-registration breaks notify service names
- notify.mobile_app_john_s_phone → notify.mobile_app_sm_s928u
- Future-proof: Use notify groups to abstract device names

## HA Green Recovery
- Hung (ping works, SSH refused): Power cycle via UniFi switch port, not physical

## ZSH Terminal
- Always escape `!` or use single quotes
- Never chain after `python3 -c` on same line

## DANGER ZONE - NEVER EDIT DIRECTLY
These files will crash HA Core if malformed:
- `.storage/core.config_entries` - Integration registry
- `.storage/core.entity_registry` - Entity definitions  
- `.storage/core.device_registry` - Device definitions
- Any `.storage/*.json` - Internal HA databases

**If you need to modify these, the answer is: YOU DONT.**
Use UI or accept it cant be done programmatically.

## UI-ONLY OPERATIONS (No API/CLI exists)
- **Adaptive Lighting**: Create/delete entries (use UI config flow)
- **ZHA**: Device pairing, network settings
- **Hue**: Bridge linking, entertainment areas
- **Matter**: Device commissioning
- **Any integration config flow**: Must use UI wizard

## SAFE OPERATIONS (API/CLI supported)
- Automations: ha_config_set_automation or YAML
- Scripts: ha_config_set_script or YAML
- Helpers: ha_config_set_helper (most types)
- Services: ha_call_service
- Entity settings: ha_set_entity
- Dashboards: ha_config_set_dashboard
