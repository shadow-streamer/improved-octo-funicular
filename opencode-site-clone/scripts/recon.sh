#!/bin/bash
# Recon script - analyze a website before cloning
# Usage: ./recon.sh <URL>

set -e

URL="${1:?Usage: ./recon.sh <URL>}"
DOMAIN=$(echo "$URL" | sed 's|https\?://||' | cut -d'/' -f1)
OUT="/tmp/recon_${DOMAIN//\./_}"

mkdir -p "$OUT"
echo "=== Recon: $URL ===" | tee "$OUT/report.txt"

# Fetch main page
echo "[1] Fetching main page..." | tee -a "$OUT/report.txt"
curl -sL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
  "$URL" > "$OUT/main.html" 2>/dev/null

# Page size
SIZE=$(wc -c < "$OUT/main.html")
echo "  Page size: $SIZE bytes" | tee -a "$OUT/report.txt"

# Asset counts
echo "[2] Asset analysis..." | tee -a "$OUT/report.txt"
echo "  CSS files: $(grep -oP 'href="[^"]*\.css' "$OUT/main.html" | wc -l)" | tee -a "$OUT/report.txt"
echo "  JS files: $(grep -oP 'src="[^"]*\.js' "$OUT/main.html" | wc -l)" | tee -a "$OUT/report.txt"
echo "  Images: $(grep -oP 'src="[^"]*\.(png|jpg|svg|webp)' "$OUT/main.html" | wc -l)" | tee -a "$OUT/report.txt"

# Framework detection
echo "[3] Framework detection..." | tee -a "$OUT/report.txt"
grep -qi "react\|reactdom\|__NEXT_DATA__\|_next" "$OUT/main.html" && echo "  React/Next.js detected" | tee -a "$OUT/report.txt"
grep -qi "vue\|__vue__\|v-cloak" "$OUT/main.html" && echo "  Vue.js detected" | tee -a "$OUT/report.txt"
grep -qi "angular\|ng-version" "$OUT/main.html" && echo "  Angular detected" | tee -a "$OUT/report.txt"
grep -qi "svelte" "$OUT/main.html" && echo "  Svelte detected" | tee -a "$OUT/report.txt"

# API endpoints
echo "[4] API endpoints found..." | tee -a "$OUT/report.txt"
grep -oP 'https?://[^"'\''<>\s]+api[^"'\''<>\s]*' "$OUT/main.html" 2>/dev/null | sort -u | tee -a "$OUT/report.txt"

# robots.txt
echo "[5] Checking robots.txt..." | tee -a "$OUT/report.txt"
curl -sL "https://$DOMAIN/robots.txt" > "$OUT/robots.txt" 2>/dev/null
cat "$OUT/robots.txt" | tee -a "$OUT/report.txt"

# Extract all unique URLs
echo "[6] All unique URLs..." | tee -a "$OUT/report.txt"
grep -oP 'https?://[^"'\''<>\s]+' "$OUT/main.html" | sort -u > "$OUT/all_urls.txt"
wc -l < "$OUT/all_urls.txt" | xargs -I{} echo "  {} unique URLs found" | tee -a "$OUT/report.txt"

echo ""
echo "=== Recon complete ===" | tee -a "$OUT/report.txt"
echo "Report: $OUT/report.txt"
echo "Main HTML: $OUT/main.html"
