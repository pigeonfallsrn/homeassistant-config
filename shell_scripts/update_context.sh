#!/bin/bash
BACKUP_ROOT="/config/context_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

mkdir -p "$BACKUP_DIR"
echo "Starting context backup at $(date)"

cp /config/automations.yaml "$BACKUP_DIR/automations.yaml"
cp /config/scripts.yaml     "$BACKUP_DIR/scripts.yaml"
cp /config/configuration.yaml "$BACKUP_DIR/configuration.yaml"
cp /config/secrets.yaml     "$BACKUP_DIR/secrets.yaml"
cp /config/customize.yaml   "$BACKUP_DIR/customize.yaml"

CONTEXT_DOC="/config/context/HA-Master-Context-Updated.md"
if [ -f "$CONTEXT_DOC" ]; then
    cp "$CONTEXT_DOC" "$BACKUP_DIR/HA-Master-Context-Updated_$TIMESTAMP.md"
fi

tar -czf "$BACKUP_DIR/homeassistant_config_$TIMESTAMP.tar.gz" \
    -C /config configuration.yaml automations.yaml scripts.yaml secrets.yaml customize.yaml

echo "$(date): Backup created at $BACKUP_DIR" >> /config/context/update_log.txt
exit 0
