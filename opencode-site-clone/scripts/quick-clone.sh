#!/bin/bash
# Quick Clone Script - Downloads a site and all its assets
# Usage: ./quick-clone.sh <URL> <OUTPUT_DIR>

set -e

URL="${1:?Usage: ./quick-clone.sh <URL> <OUTPUT_DIR>}"
OUT="${2:?Usage: ./quick-clone.sh <URL> <OUTPUT_DIR>}"

# Extract domain
DOMAIN=$(echo "$URL" | sed 's|https\?://||' | cut -d'/' -f1)

echo "=== Cloning $URL ==="

# Create directory structure
mkdir -p "$OUT"/{assets/{css,js,images,fonts,cdn},pages}

# Download main page
echo "[1/6] Downloading main page..."
curl -sL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0" \
  "$URL" > "$OUT/index.html"

# Download CSS
echo "[2/6] Downloading CSS..."
grep -oP 'href="[^"]*\.css[^"]*"' "$OUT/index.html" 2>/dev/null | sed 's/href="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/css/$fname" "$url" 2>/dev/null
done

# Download JS
echo "[3/6] Downloading JS..."
grep -oP 'src="[^"]*\.js[^"]*"' "$OUT/index.html" 2>/dev/null | sed 's/src="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/js/$fname" "$url" 2>/dev/null
done

# Download images
echo "[4/6] Downloading images..."
grep -oP 'src="[^"]*\.(png|jpg|jpeg|gif|svg|webp|ico)[^"]*"' "$OUT/index.html" 2>/dev/null | \
  sed 's/src="//;s/"//' | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/images/$fname" "$url" 2>/dev/null
done

# Download fonts
echo "[5/6] Downloading fonts..."
find "$OUT/assets/css" -name "*.css" -exec grep -oP "url\(['\"]?[^)'\"]+\.(woff2?|ttf|eot)" {} + 2>/dev/null | \
  sed "s|.*url(['\"]||" | sort -u | while read -r url; do
  [[ "$url" == http* ]] || url="https://$DOMAIN$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  [ -n "$fname" ] && curl -sL -H "Referer: $URL" -o "$OUT/assets/fonts/$fname" "$url" 2>/dev/null
done

# Fix paths
echo "[6/6] Fixing paths..."
sed -i "s|https://$DOMAIN|/|g" "$OUT/index.html"
find "$OUT/assets/css" -name "*.css" -exec sed -i "s|https://$DOMAIN|/|g" {} + 2>/dev/null
find "$OUT/assets/js" -name "*.js" -exec sed -i "s|https://$DOMAIN|/|g" {} + 2>/dev/null

# Summary
echo ""
echo "=== Clone complete ==="
echo "Directory: $OUT"
echo "Files: $(find "$OUT" -type f | wc -l)"
echo "Size: $(du -sh "$OUT" | cut -f1)"
echo ""
echo "Preview: python3 -m http.server 8080 --directory $OUT"
