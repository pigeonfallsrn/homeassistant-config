# BREAK GLASS — EQ14 Emergency Restore Runbook
# Last updated: 2026-04-17 S26
# Keep this file short, accurate, and terminal-pasteable.

---

## FIRST 60 SECONDS — Decision Tree

1. Can you reach http://192.168.1.10:8123 from LAN?
   - YES -> Path A (UI up, something specific is broken)
   - NO  -> step 2
2. Can you SSH in? ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
   - YES -> Path B (UI down, SSH up)
   - NO  -> step 3
3. Can you ping 192.168.1.10?
   - YES -> HAOS booted but HA Core crashed. Connect monitor+keyboard, use ha core logs
   - NO  -> Box is off or NIC down. Physical access required. Check power, HDMI output.
4. Is https://ha.myhomehub13.xyz reachable?
   - YES but LAN isn't -> unlikely, but check your own network first
   - NO  -> Path C (Cloudflare tunnel down, LAN may still work)

---

## Path A — UI Up, Specific Thing Broken

### Single integration failed
Settings -> Integrations -> find the broken one -> Reload / Reconfigure.
If stuck in config_entries error: delete + re-add.

### Automations not firing
1. Check automation is enabled (Settings -> Automations)
2. Check traces (three-dot menu -> Traces)
3. ha_get_automation_traces via MCP for detailed debug
4. If automation shows unavailable: check if YAML source was deleted without UI migration

### Entity unavailable
1. Check device (Settings -> Devices -> find device -> is it online?)
2. ZHA device: Settings -> Integrations -> ZHA -> reconfigure
3. ESPHome device: check http://device-ip.local for web UI
4. If restored:true ghost: ha_remove_entity via MCP

### Dashboard broken
Restore from backup:

    cp /homeassistant/hac/backups/kitchen-wall-v2-YYYYMMDD-HHMM.json \
       /homeassistant/.storage/lovelace.kitchen_wall_v2
    ha core restart

---

## Path B — UI Down, SSH Up

### Check what's wrong

    ha core logs | tail -50
    ha core info
    ha core check

### Common fixes

Config error blocking startup:

    ha core check 2>&1 | head -30
    # Fix the YAML error, then:
    ha core start

Core in crash loop:

    ha core rebuild
    # If rebuild fails:
    ha core update --version 2026.4.2

Out of disk:

    df -h
    ha backups list
    ha backups remove SLUG_OF_OLD_BACKUP

Safe mode (skip automations/integrations):

    ha core start --safe-mode

---

## Path C — LAN Up, Cloudflare Tunnel Down

The Cloudflare tunnel is managed by the Cloudflared add-on (slug: 9074a9fa_cloudflared).

From SSH or UI terminal:

    ha addons restart 9074a9fa_cloudflared
    ha addons logs 9074a9fa_cloudflared | tail -20

If tunnel ID changed or token expired:
1. Log into https://one.dash.cloudflare.com
2. Access -> Tunnels -> find tunnel 61f4b989-...
3. Verify connector status
4. If needed: get new token, update add-on config

Fallback — LAN-only access:
- LAN UI: http://192.168.1.10:8123 (works without tunnel)
- SSH: direct on LAN, no tunnel needed
- Mobile app: works on home WiFi, fails on external URL
- Companion app: Settings -> Connection -> add http://192.168.1.10:8123 as internal URL

---

## Path D — Full Backup Restore

### When to go nuclear (stop trying surgical fixes)
- More than 2 integrations failed simultaneously
- Auth is broken (can't log in even locally)
- .storage files are inconsistent (entity counts don't match, areas missing)
- Core won't start even in safe mode

### Pre-restore

    # If SSH works, grab current state before overwriting:
    cd /homeassistant && tar czf /tmp/pre-restore-$(date +%Y%m%d-%H%M).tar.gz \
      .storage/core.entity_registry \
      .storage/core.device_registry \
      .storage/core.config_entries \
      configuration.yaml

### Restore order (.storage files — CRITICAL SEQUENCE)

    ha core stop

Extract your backup tar (from NAS at \\192.168.1.52\Backups\HomeAssistant\).
Restore files in THIS order:

1. .storage/auth — without this you can't log in
2. .storage/onboarding — marks setup as complete
3. .storage/core.config_entries — all integration configs
4. .storage/core.device_registry + core.entity_registry + core.area_registry
5. /homeassistant/ YAML files (configuration.yaml, packages/, themes/, blueprints/)
6. .storage/core.restore_state — recent entity state cache

    ha core start

7. Watch logs for 5 minutes:

    ha core logs -f | head -200

8. Verify:
   - Can log in at http://192.168.1.10:8123
   - ZHA shows 49 devices
   - Key automations show state:on
   - Integrations page has no setup_error (except Music Assistant — known, tabled)

---

## ZHA-Specific Recovery

### Sonoff Zigbee 3.0 USB Dongle Plus

Coordinator not found after reboot:

    ls /dev/serial/by-id/
    # Should show usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_*
    # If missing: unplug dongle, wait 10s, replug, then:
    ha core restart

Coordinator found but devices not responding:
- Routers (mains-powered) check in first — wait 10 minutes
- Sleepy end devices (battery sensors) may take 30+ minutes
- If >50% missing after 30 min: ZHA may need network re-form (last resort)

ZHA database recovery:
The critical file is .storage/zha.storage.json — contains network
key and device pairings. If intact, no re-pairing needed.

    wc -c /homeassistant/.storage/zha.storage.json
    # Should be >10KB for 49 devices

Full ZHA re-pair (absolute last resort):
1. Remove ZHA integration (Settings -> Integrations -> ZHA -> Delete)
2. Replug Sonoff dongle
3. Re-add ZHA, select serial port
4. ALL 49 devices must be re-paired individually
5. All automations referencing device_ieee need IEEE updates
6. Multi-hour process — exhaust all other options first

### When to abandon surgical and do full tar restore
- ZHA storage corrupted AND no recent backup has clean copy
- More than 2 core .storage files missing or zero-byte
- Auth + config_entries both broken
- 30+ minutes on surgical fixes with no progress

---

## Emergency Contacts / Links

- EQ14 LAN: http://192.168.1.10:8123
- EQ14 SSH: ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
- External: https://ha.myhomehub13.xyz
- Cloudflare dashboard: https://one.dash.cloudflare.com
- NAS DSM: http://192.168.1.52:5001
- NAS backups: \\192.168.1.52\Backups\HomeAssistant\
- HA Green cold spare: 192.168.1.3 (plug ethernet in, boots in ~60s)
- Git repo: pigeonfallsrn/homeassistant-config
