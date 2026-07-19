#!/bin/bash
# Recon - Analyze a website before cloning
# Usage: ./recon.sh <URL> [--json]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
load_config

URL="${1:?Usage: ./recon.sh <URL> [--json]}"
JSON_MODE="${2:-}"

validate_url "$URL" || exit 1
DOMAIN=$(extract_domain "$URL")
OUT="/tmp/recon_${DOMAIN//\./_}"

safe_mkdir "$OUT"

echo "=== Recon: $URL ==="
echo ""

# Fetch main page
log_info "Fetching main page..."
download "$URL" "$OUT/main.html" || { log_error "Failed to fetch page"; exit 1; }
SIZE=$(wc -c < "$OUT/main.html")
echo "  Page size: $SIZE bytes"

# Asset counts
log_info "Asset analysis..."
CSS_COUNT=$(grep -oP 'href="[^"]*\.css' "$OUT/main.html" 2>/dev/null | wc -l)
JS_COUNT=$(grep -oP 'src="[^"]*\.js' "$OUT/main.html" 2>/dev/null | wc -l)
IMG_COUNT=$(grep -oP 'src="[^"]*\.(png|jpg|svg|webp|ico)' "$OUT/main.html" 2>/dev/null | wc -l)
echo "  CSS: $CSS_COUNT | JS: $JS_COUNT | Images: $IMG_COUNT"

# Framework detection
log_info "Framework detection..."
FRAMEWORKS=()
grep -qi "react\|reactdom\|__NEXT_DATA__\|_next" "$OUT/main.html" 2>/dev/null && FRAMEWORKS+=("React/Next.js")
grep -qi "vue\|__vue__\|v-cloak" "$OUT/main.html" 2>/dev/null && FRAMEWORKS+=("Vue.js")
grep -qi "angular\|ng-version" "$OUT/main.html" 2>/dev/null && FRAMEWORKS+=("Angular")
grep -qi "svelte" "$OUT/main.html" 2>/dev/null && FRAMEWORKS+=("Svelte")

if [[ ${#FRAMEWORKS[@]} -gt 0 ]]; then
    echo "  Detected: ${FRAMEWORKS[*]}"
else
    echo "  No frameworks detected"
fi

# API endpoints
log_info "API endpoints..."
APIS=$(grep -oP 'https?://[^"'\''<>\s]+api[^"'\''<>\s]*' "$OUT/main.html" 2>/dev/null | sort -u || true)
if [[ -n "$APIS" ]]; then
    echo "$APIS" | head -5 | while read -r api; do
        echo "  $api"
    done
    API_COUNT=$(echo "$APIS" | wc -l)
    [[ $API_COUNT -gt 5 ]] && echo "  ... and $((API_COUNT - 5)) more"
else
    echo "  None found"
fi

# robots.txt
log_info "Checking robots.txt..."
if check_url "https://$DOMAIN/robots.txt"; then
    download "https://$DOMAIN/robots.txt" "$OUT/robots.txt" 2>/dev/null || true
    DISALLOW=$(grep -c "Disallow:" "$OUT/robots.txt" 2>/dev/null || echo "0")
    echo "  Found: $DISALLOW rules"
else
    echo "  No robots.txt"
fi

# Unique URLs
log_info "Extracting URLs..."
URLS=$(grep -oP 'https?://[^"'\''<>\s]+' "$OUT/main.html" 2>/dev/null | sort -u || true)
URL_COUNT=$(echo "$URLS" | grep -c . 2>/dev/null || echo "0")
echo "  Unique URLs: $URL_COUNT"

echo ""
log_success "Recon complete"
echo "  Report: $OUT/"
echo "  HTML: $OUT/main.html"
