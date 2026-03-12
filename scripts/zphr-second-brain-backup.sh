#!/bin/bash
set -euo pipefail

SOURCE="$HOME/zphr-second-brain"
BACKUP_DIR="$HOME/zphr-second-brain-backup"
KEEP=24

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/zphr-second-brain-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

notify-send "Second Brain Backup" "Starting backup..."
echo "Starting backup: $BACKUP_FILE"
tar czf "$BACKUP_FILE" -C "$HOME" zphr-second-brain
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup complete: $SIZE"
notify-send "Second Brain Backup" "Backup complete ($SIZE)"

# Remove old backups, keeping the newest $KEEP
OLD_BACKUPS=$(ls -t "$BACKUP_DIR"/zphr-second-brain-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)))
if [ -n "$OLD_BACKUPS" ]; then
    echo "$OLD_BACKUPS" | xargs rm -v
    echo "Cleaned up old backups"
else
    echo "No old backups to clean up"
fi
