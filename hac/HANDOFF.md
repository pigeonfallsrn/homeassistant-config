# HAC Handoff — 2026-03-30 23:xx

## Last 3 commits
  See: git log --oneline -5

## Active tasks
  TASK: Verify at_mom_s sensors fire on next custody change (iPhone location poll pending)
  TASK: person.john_spencer UI — still needs swap from S24 → S26 tracker
  NEXT: presence audit continuation or begin backlog
  BLOCKED: None

## What was done this session (2026-03-30)
  PRESENCE FIX 1: alaina_home + ella_home - removed 30min tracker staleness check
    Both now simply is_state('person.x', 'home') — no more unavailable when phone offline
  PRESENCE FIX 2: zone.traci_s_house radius 76m → 150m (was too tight for iPhone GPS drift)
    Zone coordinates confirmed correct: 44.3625/-91.4173 = 35918 Ash St Independence WI
  ENTITY IDs CONFIRMED: at_mom_s sensors are alaina_at_mom_s / ella_at_mom_s (apostrophe=underscore)
  TOKEN NOTE: ha_api_token in secrets.yaml gets 403 on zone/template REST endpoints — use UI or ha CLI

## Known issues / next session priorities
  1. at_mom_s sensors off pending iPhone location poll — verify fires on next arrival/departure
  2. both_girls_at_mom_s + any_girl_at_mom_s — state=unavailable (restored ghost entries)
     These are orphaned registry entries, no YAML backing them — clean up or rebuild
  3. person.john_spencer still references S24 tracker in UI — swap to device_tracker.galaxy_s26_ultra

## Start next session
  cat /homeassistant/hac/HANDOFF.md
  hac status
  hac health

