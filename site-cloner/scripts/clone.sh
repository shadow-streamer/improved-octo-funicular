#!/bin/bash
# Site Cloner - Bash version with config support
# Usage: ./clone.sh <URL> <OUTPUT_DIR> [--depth N]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
load_config "$SCRIPT_DIR/../config/defaults.conf"

URL="${1:?Usage: ./clone.sh <URL> <OUTPUT_DIR> [--depth N]}"
OUT="${2:?Usage: ./clone.sh <URL> <OUTPUT_DIR> [--depth N]}"
DEPTH="${3:-2}"

validate_url "$URL" || exit 1
DOMAIN=$(extract_domain "$URL")

log_step 1 5 "Creating directory structure..."
safe_mkdir "$OUT"/{assets/{css,js,images,fonts,videos,cdn},pages}

log_step 2 5 "Downloading main page..."
download "$URL" "$OUT/index.html" || { log_error "Failed to download main page"; exit 1; }

log_step 3 5 "Extracting asset URLs..."

# CSS
grep -oP 'href="[^"]*\.css[^"]*"' "$OUT/index.html" 2>/dev/null | \
    sed 's/href="//;s/"//' | sort -u | while read -r url; do
        [[ "$url" != http* ]] && url="https://$DOMAIN$url"
        fname=$(basename "$url" | cut -d'?' -f1)
        [[ -n "$fname" ]] && download "$url" "$OUT/assets/css/$fname" || true
    done

# JS
grep -oP 'src="[^"]*\.js[^"]*"' "$OUT/index.html" 2>/dev/null | \
    sed 's/src="//;s/"//' | sort -u | while read -r url; do
        [[ "$url" != http* ]] && url="https://$DOMAIN$url"
        fname=$(basename "$url" | cut -d'?' -f1)
        [[ -n "$fname" ]] && download "$url" "$OUT/assets/js/$fname" || true
    done

# Images
grep -oP 'src="[^"]*\.(png|jpg|jpeg|gif|svg|webp|ico)[^"]*"' "$OUT/index.html" 2>/dev/null | \
    sed 's/src="//;s/"//' | sort -u | while read -r url; do
        [[ "$url" != http* ]] && url="https://$DOMAIN$url"
        fname=$(basename "$url" | cut -d'?' -f1)
        [[ -n "$fname" ]] && download "$url" "$OUT/assets/images/$fname" || true
    done

# Fonts from CSS
if ls "$OUT/assets/css/"*.css 1>/dev/null 2>&1; then
    grep -oP "url\(['\"]?[^)'\"]+\.(woff2?|ttf|eot|otf)" "$OUT/assets/css/"*.css 2>/dev/null | \
        sed "s|.*url(['\"]||" | sort -u | while read -r url; do
            [[ "$url" != http* ]] && url="https://$DOMAIN$url"
            fname=$(basename "$url" | cut -d'?' -f1)
            [[ -n "$fname" ]] && download "$url" "$OUT/assets/fonts/$fname" || true
        done
fi

log_step 4 5 "Fixing paths..."
sed -i "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" "$OUT/index.html" 2>/dev/null || true
find "$OUT/assets/css" -name "*.css" -exec sed -i "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} + 2>/dev/null || true
find "$OUT/assets/js" -name "*.js" -exec sed -i "s|https://$DOMAIN|/|g; s|http://$DOMAIN|/|g" {} + 2>/dev/null || true

log_step 5 5 "Summary..."
FILE_COUNT=$(count_files "$OUT")
TOTAL_BYTES=$(total_size "$OUT")
SIZE_STR=$(_human_size "$TOTAL_BYTES")

log_success "Clone complete: $OUT"
echo "  Files: $FILE_COUNT"
echo "  Size: $SIZE_STR"
echo "  Preview: python3 -m http.server 8080 --directory $OUT"
