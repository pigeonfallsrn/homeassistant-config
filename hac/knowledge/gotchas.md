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
