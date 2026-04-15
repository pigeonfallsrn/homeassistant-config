# HANDOFF S17 — 2026-04-14

## Done this session
- MCP confirmed on EQ14 (192.168.1.10, amd64, HAOS 17.2)
- Fixed /config/ → /homeassistant/ in shell_commands (4 lines)
- Fixed external_url → ha.myhomehub13.xyz
- Roku Kitchen Lounge — was offline, now loaded
- Full config audit: 27 packages, 55 helpers in YAML, 141 automations in storage
- First EQ14 git commit pushed

## Tabled
- AndroidTV 192.168.1.17 — real device, unknown which, DO NOT DELETE
- Music Assistant setup_error
- Person trackers: Alaina, Ella, Michelle have none assigned

## S18 priorities
1. Recreate ~55 helpers in UI via MCP (see EQ14_MIGRATION_INVENTORY.md)
2. Remove YAML helper includes from configuration.yaml
3. Group 0 — floors, areas, labels

## SSH
ssh hassio@192.168.1.10 -p 2222 -o "MACs=hmac-sha2-256-etm@openssh.com"
Password: NordPass EQ14 Beelink — SSH Terminal (hassio)
