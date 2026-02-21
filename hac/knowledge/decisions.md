# Architectural Decisions
*Last updated: 2026-02-21*

## Inovelli Blueprints
- **Current:** fxlt VZM31-only (outdated, double-fires by design)
- **Target:** MasterDevwi unified (VZM30/31/35/36, Dec 2024) or Ratoka Hue-specific
- **Rationale:** Per-device triggers eliminate cross-automation firing

## Automation Organization
- Packages in `/homeassistant/packages/` for domain grouping
- Inovelli controls in `automations/` dir (legacy, migrate to packages)
- UI-created automations in `automations.yaml` (avoid, prefer YAML)

## Local vs Cloud
- Local control preferred over cloud dependencies
- Hue via local bridge, not cloud
- UniFi for presence (local API)

## HAC Workflow
- Propose → approve → execute pattern
- MCP for live state, terminal for file edits
- `hac backup` before ANY edit
- `hac learn` for session insights, `hac promote` for permanent KB
