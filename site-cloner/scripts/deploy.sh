#!/bin/bash
# Deploy cloned site to web server
# Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT> [--no-backup]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

SRC="${1:?Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT> [--no-backup]}"
DEST="${2:?Usage: ./deploy.sh <CLONE_DIR> <WEB_ROOT> [--no-backup]}"
NO_BACKUP="${3:-}"

if [[ ! -d "$SRC" ]]; then
    log_error "Source directory not found: $SRC"
    exit 1
fi

# Check if we need sudo
USE_SUDO=""
if [[ "$DEST" == /* ]] && ! has_sudo; then
    log_warn "Destination requires root access but sudo not available"
    log_info "Try: sudo $0 $SRC $DEST"
    exit 1
fi
[[ "$DEST" == /* ]] && USE_SUDO="sudo"

log_info "Deploying $SRC to $DEST"

# Backup existing
if [[ -d "$DEST" && "$NO_BACKUP" != "--no-backup" ]]; then
    BACKUP="${DEST}.bak.$(date +%s)"
    log_info "Backing up to $BACKUP"
    $USE_SUDO cp -r "$DEST" "$BACKUP" || { log_error "Backup failed"; exit 1; }
fi

# Deploy
$USE_SUDO mkdir -p "$DEST" || { log_error "Cannot create destination"; exit 1; }
$USE_SUDO cp -rv "$SRC"/* "$DEST/" 2>/dev/null || { log_error "Copy failed"; exit 1; }

# Set permissions
$USE_SUDO find "$DEST" -type d -exec chmod 755 {} + 2>/dev/null || true
$USE_SUDO find "$DEST" -type f -exec chmod 644 {} + 2>/dev/null || true

FILE_COUNT=$(count_files "$DEST")
log_success "Deploy complete: $DEST"
echo "  Files: $FILE_COUNT"
