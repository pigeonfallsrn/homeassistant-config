# HAC Handoff — 2026-04-04 (Community Audit + Cleanup Session)

## Last commits
  16cf433 cleanup: remove 8 stale .bak files from packages/
  a596515 security: all 7 audit items complete - SSH key auth, CF WAF, PAT rotation, recorder excludes

## MCP SESSION OPENER
Step 1: shell_command.mcp_session_init  (return_response=True)
Step 2: hassio.backup_partial(homeassistant=True, homeassistant_exclude_database=True, compressed=True, name="PreSession_YYYY-MM-DD")
Step 3: shell_command.read_critical_rules  (return_response=True)
Step 4: shell_command.read_handoff         (return_response=True)
Step 5: Work. Package changes = ha core restart.
Step 6: git add -A && git commit / then MCP git_push

## Active tasks
  NONE — all high-priority items resolved or confirmed clean this session

## Top backlog items (priority order)
  1. [x] Kitchen lighting — P1 consolidation + manual override DONE (2026-04-05)
         - binary_sensor.first_floor_main_motion: kitchen P1 + west kitchen TR + entry P1
         - binary_sensor.first_floor_hallway_motion: basement hall P1 + very front P1
         - automation.kitchen_ceiling_motion_lighting: 3-tier time-aware, 12min, mode:restart
         - input_boolean.kitchen_manual_override: 2x up-tap either chandelier/sink Inovelli
         - 4 lamp automations updated to first_floor_main_motion (was kitchen_lounge_motion only)
         - downstairs_motion: CONFIRMED template sensor in motion_aggregation.yaml, working correctly
  2. [ ] Automation categories in HA UI — 159 automations, 0 categories
         Suggested scheme: Lighting / Presence / Garage / Notifications / Security /
         Climate / Media / Maintenance / Kids / Disabled-Archive
         Method: Settings > Automations > filter by name pattern > bulk assign category (UI only)
  3. [ ] Presence tracker cleanup — 92 device_trackers, ~80 likely ghosts
         Method: Settings > Entities > filter device_tracker > sort Last Changed (oldest=ghost)
         Keep: sm_s948u1_* (S26), alaina_s_iphone*, ellas_iphone*, UniFi current devices
  4. [ ] Kasa re-auth — 2 Repairs: Basement_Hallway HS200 + Kitchen_Table_Chandelier HS220
         Method: Settings > Devices & Services > TP-Link Kasa > Re-authenticate (2 min, UI only)
  5. [ ] Aqara sensor relocation — garage_north_door + garage_south_door
  6. [ ] Recorder: run recorder.purge repack:true to compact DB (excludes now active)
         MCP: ha_call_service(recorder, purge, data={keep_days:7, repack:true})
  7. [ ] Doorbell popup: browser_mod.popup on tablet. Needs browser_mod installed first.
  8. [ ] Calendar: verify right column fills with dense_section_placement:false on tablet
  9. [ ] SSH: disable password auth — add-on Config: password:"", add authorized_keys
  10.[ ] Cloudflare Zero Trust Access policy — email-OTP for ha.myhomehub13.xyz, bypass /api/*
  11.[ ] Cloudflare WAF — rate limit /api/auth/* (5 req/min/IP)
  12.[ ] HA LLAT audit — Profile > Security tab, name all tokens, revoke unknown/unused
  13.[ ] Michelle iPhone — add MAC 6a:9a:25:dd:82:f1 to HA as person entity when ready

## CONFIRMED CLEAN — remove from future backlog
  [x] configuration.yaml dead entity refs — grep confirms zero hits in config + packages
  [x] Legacy template syntax — zero platform:template in packages, already on modern format
  [x] 8 .bak files — deleted + committed 16cf433 + pushed
  [x] South ratgdo firmware — both boards on 2026.3.1
  [x] Recorder excludes — device_tracker.*, cover.ratgdo*, sensor.ratgdo*, weather.* active
  [x] Git push method — MCP shell_command.git_push confirmed working
  [x] Security audit — SSH key-only, CF WAF, CF Zero Trust, fine-grained PAT all done

## System state (2026-04-04)
  HA 2026.4.1, OS 17.1, Supervisor 2026.03.2
  3,206 entities, 159 automations, 30 packages (0 .bak files)
  Disk: ~19GB/28GB (71%) — DB excludes now reducing growth rate
  Both ratgdo boards: 2026.3.1, North obstruction toggle OFF (hardware workaround)
  Git: clean, pushed to github.com/pigeonfallsrn/homeassistant-config (19a315e)
  2 Repairs open: Kasa HS200 + HS220 auth expiry (UI fix needed)

## shell_command registry (all confirmed working 2026-04-04)
  git_push, git_status, git_last_commit, read_critical_rules, read_handoff, mcp_session_init
  NOTE: No Jinja2 {{ }} templates in shell_command values — causes silent load failure

## Start next session
  MCP: shell_command.mcp_session_init
  MCP: shell_command.read_critical_rules
  MCP: shell_command.read_handoff
