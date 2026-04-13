# Phase G: Git Repo Cleanup + EQ14 Clone Workflow
## S13B

## G1. Files That Transfer to EQ14
KEEP: configuration.yaml (replace with eq14_ready/ version), themes/, blueprints/, hac/
IGNORE: automations.yaml, scripts.yaml, scenes.yaml (EQ14 builds fresh in UI)

## G2. .gitignore Must Include
.storage/, .cloud/, home-assistant_v2.db*, secrets.yaml, deps/, tts/,
__pycache__/, *.log, custom_components/, www/community/, zigbee.db,
.DS_Store, *.swp, backups/, *.tar, node-red/

## G3. EQ14 First Boot Workflow
1. ssh hassio@192.168.1.10 -p 2222
2. cd /homeassistant
3. GIT_TERMINAL_PROMPT=0 git clone https://\[PAT\]@github.com/pigeonfallsrn/homeassistant-config.git .
4. cp hac/eq14_ready/configuration.yaml configuration.yaml
5. ln -sf /homeassistant/hac/hac.sh /usr/local/bin/hac
6. ha core restart

If git clone fails (dir not empty):
  git init && git remote add origin https://\[PAT\]@github.com/...
  GIT_TERMINAL_PROMPT=0 git fetch origin && git checkout -f main
  cp hac/eq14_ready/configuration.yaml configuration.yaml

## Post-Clone: Copy Registry Files from Backup 53ef3d09
ha core stop
scp core.area_registry → /homeassistant/.storage/
scp zha.storage.json → /homeassistant/.storage/ (after moving dongle)
scp core.entity_registry → /homeassistant/.storage/
scp core.device_registry → /homeassistant/.storage/
scp core.config_entries → /homeassistant/.storage/
ha core start

## NEVER in Git
.storage/, secrets.yaml, home-assistant_v2.db, custom_components/, zigbee.db
