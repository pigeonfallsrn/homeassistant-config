# HANDOFF — Session S16A
Date: 2026-04-13
Status: IN PROGRESS — S16B continues next session

## Completed This Session
- hac symlink recreated on EQ14
- Cloudflared 7.0.5 installed on EQ14 via custom repo (brenner-tobias/ha-addons)
- cert.pem obtained via Cloudflare browser auth (Authorize Tunnel flow)
- New tunnel: 61f4b989-377f-4966-8111-c077d33f6248 (4 connections, ord06/11/12/16)
- ha.myhomehub13.xyz CNAME updated → EQ14 tunnel — CONFIRMED WORKING
- Cloudflared stopped on Green (was slug 9074a9fa_cloudflared)

## S16B — Start Here Next Session
VERIFY FIRST: System health shows amd64 + 192.168.1.10 (not aarch64/Green)

1. Fix NAS_Backups CIFS mount on EQ14
   Settings → System → Storage → NAS_Backups → reconfigure
   Host: 192.168.1.52 | Share: Backups | User: HA_Synology | Pass: NordPass

2. Configure daily backup: keep 7, destination NAS_Backups

3. Phase 6 Integrations (priority order):
   - Hue Bridge (3-sec button press)
   - ESPHome: ratgdo North (fd8d8c), ratgdo South (5735e8), Apollo Entry (748020)
   - Google Calendar + Nest (pigeonfallsrn@gmail.com)
   - UniFi + UniFi Protect
   - Spotify, Plex, Roku x2, Yamaha, TP-Link Kasa, Sonos, Alexa

## Hardware State
- EQ14 (192.168.1.10): PRIMARY — Cloudflared running, tunnel active
- Green (192.168.1.3): COLD SPARE — Cloudflared stopped, ZHA offline
- NAS (192.168.1.52): NAS_Backups mount still failing on EQ14 (fix in S16B)
