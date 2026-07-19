#!/bin/bash
# Site Cloner - Quick clone script
# Usage: ./clone.sh <URL> <OUTPUT_DIR> [DEPTH]
# Example: ./clone.sh https://example.com ./clone 2

set -e

URL="${1:?Usage: ./clone.sh <URL> <OUTPUT_DIR> [DEPTH]}"
OUT="${2:?Usage: ./clone.sh <URL> <OUTPUT_DIR> [DEPTH]}"
DEPTH="${3:-2}"

# Extract domain for referer
DOMAIN=$(echo "$URL" | sed 's|https\?://||' | cut -d'/' -f1)

echo "[1/5] Creating directory structure..."
mkdir -p "$OUT"/{assets/{css,js,images,fonts,videos,cdn},pages}

echo "[2/5] Downloading main page..."
curl -sL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0" \
  "$URL" > "$OUT/index.html"

echo "[3/5] Extracting asset URLs..."
# CSS
grep -oP 'href="[^"]*\.css[^"]*"' "$OUT/index.html" 2>/dev/null | sed 's/href="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" != http* ]] && url="$url"  # relative URL
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/css/$fname" "$url" 2>/dev/null
done

# JS
grep -oP 'src="[^"]*\.js[^"]*"' "$OUT/index.html" 2>/dev/null | sed 's/src="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/js/$fname" "$url" 2>/dev/null
done

# Images
grep -oP 'src="[^"]*\.(png|jpg|jpeg|gif|svg|webp|ico)[^"]*"' "$OUT/index.html" 2>/dev/null | \
  sed 's/src="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/images/$fname" "$url" 2>/dev/null
done

# Fonts
grep -oP "url\(['\"]?[^)'\"]+\.(woff2?|ttf|eot|otf)" "$OUT/assets/css/"*.css 2>/dev/null | \
  sed "s|.*url(['\"]||" | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/fonts/$fname" "$url" 2>/dev/null
done

echo "[4/5] Fixing paths..."
# Fix absolute URLs in HTML
sed -i "s|https://$DOMAIN|/|g" "$OUT/index.html"
# Fix CSS url() references
find "$OUT/assets/css" -name "*.css" -exec sed -i "s|https://$DOMAIN|/|g" {} + 2>/dev/null

echo "[5/5] Summary..."
echo "Clone complete: $OUT"
echo "Files: $(find "$OUT" -type f | wc -l)"
echo "Size: $(du -sh "$OUT" | cut -f1)"
echo "Run: python3 -m http.server 8080 --directory $OUT"
