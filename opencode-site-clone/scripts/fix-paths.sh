#!/bin/bash
# Fix absolute paths in cloned site files
# Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN>

set -e

DIR="${1:?Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN>}"
DOMAIN="${2:?Usage: ./fix-paths.sh <CLONE_DIR> <DOMAIN>}"

echo "Fixing paths for $DOMAIN in $DIR"

# HTML files
find "$DIR" -name "*.html" -exec sed -i \
  "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} +

# CSS files
find "$DIR" -name "*.css" -exec sed -i \
  "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} +

# JS files
find "$DIR" -name "*.js" -exec sed -i \
  "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} +

echo "Done. Check with:"
echo "  grep -r '$DOMAIN' $DIR"
