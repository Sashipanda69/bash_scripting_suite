#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.cfg"

timestamp() { date +%F_%H%M%S; }

mkdir -p "$BACKUP_DEST"

avail_mb=$(df --output=avail -m "$BACKUP_DEST" 2>/dev/null | tail -1 | tr -d ' ' || echo 9999)
if (( avail_mb < MIN_FREE_MB )); then
  echo "ERROR: Not enough free space on $BACKUP_DEST. Available: ${avail_mb}MB. Required: ${MIN_FREE_MB}MB."
  exit 2
fi

ARCHIVE="$BACKUP_DEST/backup_$(timestamp).tar.gz"
echo "Creating backup $ARCHIVE from: $BACKUP_SRC"
tar -czf "$ARCHIVE" -C / $(realpath --relative-to=/ "$BACKUP_SRC") 2>/dev/null || tar -czf "$ARCHIVE" "$BACKUP_SRC"

# Rotation
mapfile -t files < <(ls -1t "$BACKUP_DEST"/backup_*.tar.gz 2>/dev/null || true)
if (( ${#files[@]} > BACKUP_KEEP )); then
  to_delete=( "${files[@]:$BACKUP_KEEP}" )
  for f in "${to_delete[@]}"; do
    rm -f -- "$f"
    echo "Deleted $f"
  done
fi

echo "Backup completed: $ARCHIVE"
exit 0
