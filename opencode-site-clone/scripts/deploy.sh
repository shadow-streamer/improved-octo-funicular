#!/bin/bash
# Deploy cloned site to web server
# Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT>

set -e

SRC="${1:?Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT>}"
DEST="${2:?Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT>}"

echo "Deploying $SRC to $DEST"

# Backup existing
if [ -d "$DEST" ]; then
  echo "Backing up existing..."
  sudo cp -r "$DEST" "${DEST}.bak.$(date +%s)"
fi

# Deploy
sudo mkdir -p "$DEST"
sudo cp -rv "$SRC"/* "$DEST/"

# Set permissions
sudo find "$DEST" -type d -exec chmod 755 {} +
sudo find "$DEST" -type f -exec chmod 644 {} +

echo "Deploy complete: $DEST"
echo "Files: $(find "$DEST" -type f | wc -l)"
