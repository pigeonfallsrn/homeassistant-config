# HAC Handoff — 2026-03-30 22:15

## Last 3 commits
  See: git log --oneline -5

## Active tasks
  TASK: Verify 6 rebuilt presence sensors fire correctly on next custody change (girls arrive home or go to Traci's)
  TASK: Fix binary_sensor.alaina_home upstream — simplify to just is_state('person.alaina_spencer', 'home'), remove 30min tracker age check that causes unavailable when phone offline
  TASK: Verify zone.traci_s_house radius covers Independence address — if ella_at_mom_s doesn't fire when girls are there, adjust radius
  NEXT: presence audit continuation or begin backlog
  BLOCKED: None

## What was done this session (2026-03-30)
  GARAGE ARRIVAL: 3 bugs fixed — HFL BT connect as direct trigger, mode restart,
    120s GPS recency template on door-opened notification. Package YAML cleaned.
  PRESENCE AUDIT: 6 orphaned sensors rebuilt in presence_system.yaml
    alaina/ella: in_bed (BSSID upstairs), at_moms (zone.traci_s_house), at_school (zone.whitehall_school)
    Fixed availability AND->OR. Cleared ghost registry entries. All 6 now live as 'off'.
  CRITICAL_RULES: MCP BLIND SPOTS section added + GARAGE/ARRIVAL + TEMPLATE SENSOR AVAILABILITY + FAMILY CONTEXT
  TABLET NOTIFY: mobile_app_kitchen_samsung_tablet_wall_mount confirmed active in traces.

## Known issues / next session priorities
  1. binary_sensor.alaina_home goes unavailable when Alaina's phone offline >30min
     Fix: simplify template in presence_system.yaml line 81-83 to just person state
  2. ella_person shows Michelle's House zone when girls at Traci's — GPS zone overlap?
     Check zone.michelles_house radius vs Independence distance
  3. MCP HANDOFF note: package YAML automations return RESOURCE_NOT_FOUND from MCP —
     always use terminal cat for package file contents

## Start next session
  cat /homeassistant/hac/HANDOFF.md   ← read this first
  hac status                           ← who is home, last triggers
  hac health                           ← check for errors
