# LEARNINGS LOG

## S40 — 2026-04-18
- MCP context blindness: terminal dumps >> MCP one-at-a-time for audit work
- Websocket bulk delete: REST cant delete entity registry. WS config/entity_registry/remove works. pip3 install websockets. Use max_size=2**22
- Hybrid REST+WS: REST for reads (no size limit), WS for writes (registry ops)
- 42 ghosts accumulated from earlier migrations — periodic sweeps needed
- notify service naming: phone name in mobile app registration = service name. After re-registration all old refs silently break
- Never-triggered != broken: timer resets, button handlers, condition-dependent automations show Never until conditions are met
- calendar.get_events is correct name but action doesnt register without calendar entities. Disable dont fix
- Garage notification anti-pattern: 7-automation chain is over-engineered. Use one automation with inline wait_for_trigger + choose
