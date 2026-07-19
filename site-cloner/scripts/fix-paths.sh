#!/bin/bash
# Fix absolute paths in cloned site files
# Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN> [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

DIR="${1:?Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN> [--dry-run]}"
DOMAIN="${2:?Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN> [--dry-run]}"
DRY_RUN="${3:-}"

if [[ ! -d "$DIR" ]]; then
    log_error "Directory not found: $DIR"
    exit 1
fi

log_info "Fixing paths for $DOMAIN in $DIR"

# Count matches first
MATCH_COUNT=$(grep -rl "$DOMAIN" "$DIR" --include="*.html" --include="*.css" --include="*.js" 2>/dev/null | wc -l)
log_info "Found $MATCH_COUNT files to fix"

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log_warn "Dry run mode - no changes made"
    grep -rl "$DOMAIN" "$DIR" --include="*.html" --include="*.css" --include="*.js" 2>/dev/null || true
    exit 0
fi

# HTML files
find "$DIR" -name "*.html" -type f -exec sed -i \
    "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} + 2>/dev/null || true

# CSS files
find "$DIR" -name "*.css" -type f -exec sed -i \
    "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} + 2>/dev/null || true

# JS files
find "$DIR" -name "*.js" -type f -exec sed -i \
    "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} + 2>/dev/null || true

# Verify
REMAINING=$(grep -rl "$DOMAIN" "$DIR" --include="*.html" --include="*.css" --include="*.js" 2>/dev/null | wc -l)
if [[ $REMAINING -eq 0 ]]; then
    log_success "All paths fixed"
else
    log_warn "$REMAINING files still contain domain references"
fi
