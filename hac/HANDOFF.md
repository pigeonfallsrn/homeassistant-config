# HAC Handoff — 2026-03-28

## Last 3 commits
  (see: git log --oneline -5)

## Active tasks
  TASK: notify migration — COMPLETE ✅
  RESULT: grep found zero sm_s928u refs in packages/. MCP deep_search returned 5 false positives
          (fuzzy name match only, match_in_config:false). Doorbell automation already correct.
          Migration fully done — sm_s928u retired.

## Top backlog items
  - [ ] Calendar: verify fills full right column with dense_section_placement:false — check on tablet
  - [ ] Doorbell popup: browser_mod popup on tablet showing camera feed. Needs browser_mod installed first.
  - [ ] Room audit remaining: Alaina, Ella, Basement, Master Bedroom
  - [ ] Inovelli blueprint consolidation (8 automations → single blueprint)

## Start next session
  cat /homeassistant/hac/HANDOFF.md   ← read this first
  hac status                           ← who is home, last triggers
  hac health                           ← check for errors
