# Site Cloner Skill - Complete Reference

## Purpose
Clone any website's assets (HTML, CSS, JS, images, fonts, videos) to a local or server directory, preserving structure and paths. This skill makes opencode a professional site cloning tool.

## When to Use
- "Clone this site", "Copy this website", "Mirror this site"
- "Download all assets from X", "Save this page offline"
- "Deploy a copy of Y to my server"
- Any request to replicate a website's frontend

## Quick Start

```bash
# 1. Recon a site
./scripts/recon.sh https://TARGET.com

# 2. Clone it
./scripts/clone.sh https://TARGET.com ./OUTPUT 2

# 3. Fix paths
./scripts/fix-paths.sh ./OUTPUT TARGET.com

# 4. Preview locally
python3 -m http.server 8080 --directory ./OUTPUT

# 5. Deploy
./scripts/deploy.sh ./OUTPUT /var/www/vhosts/DOMAIN/httpdocs
```

## Complete Cloning Workflow

### Phase 1: Reconnaissance
```bash
# 1. Fetch the main page
curl -sL "https://TARGET.com" > /tmp/recon_main.html

# 2. Extract all asset URLs
grep -oP '(?:src|href|action)="[^"]*"' /tmp/recon_main.html | sort -u > /tmp/recon_urls.txt

# 3. Identify asset types
grep -oP '\.[a-z]{2,4}(?=["\s])' /tmp/recon_main.html | sort | uniq -c | sort -rn

# 4. Check for JS frameworks
grep -c "react\|vue\|angular\|next\|nuxt" /tmp/recon_main.html

# 5. Check for API endpoints
grep -oP 'https?://[^"'\''<>\s]+api[^"'\''<>\s]*' /tmp/recon_main.html

# 6. Count sections, images, links
echo "Sections: $(grep -c '<section' /tmp/recon_main.html)"
echo "Images: $(grep -oP 'src="[^"]*\.(png|jpg|svg|webp)"' /tmp/recon_main.html | wc -l)"
echo "Links: $(grep -c 'href=' /tmp/recon_main.html)"
```

### Phase 2: Download
```bash
# Create directory structure
mkdir -p /path/to/clone/{assets/{css,js,images,fonts,videos,cdn},pages}

# Download main page
curl -sL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
  "https://TARGET.com" > /path/to/clone/index.html

# Download CSS
grep -oP 'href="[^"]*\.css[^"]*"' /path/to/clone/index.html | sed 's/href="//;s/"//' | sort -u | while read url; do
  [[ "$url" != http* ]] && url="https://TARGET.com$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  curl -o "./assets/css/$fname" "$url"
done

# Download JS
grep -oP 'src="[^"]*\.js[^"]*"' /path/to/clone/index.html | sed 's/src="//;s/"//' | sort -u | while read url; do
  [[ "$url" != http* ]] && url="https://TARGET.com$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  curl -o "./assets/js/$fname" "$url"
done

# Download images
grep -oP 'src="[^"]*\.(png|jpg|jpeg|gif|svg|webp|ico)[^"]*"' /path/to/clone/index.html | \
  sed 's/src="//;s/"//' | sort -u | while read url; do
  [[ "$url" != http* ]] && url="https://TARGET.com$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  curl -o "./assets/images/$fname" "$url"
done

# Download fonts from CSS
find ./assets/css -name "*.css" -exec grep -oP "url\(['\"]?[^)'\"]+\.(woff2?|ttf|eot)" {} + | \
  sed "s|.*url(['\"]||" | sort -u | while read url; do
  [[ "$url" != http* ]] && url="https://TARGET.com$url"
  fname=$(basename "$url" | cut -d'?' -f1)
  curl -o "./assets/fonts/$fname" "$url"
done
```

### Phase 3: Fix Paths
```bash
# Fix absolute URLs in HTML
sed -i "s|https://TARGET.com/|/|g" ./index.html
sed -i "s|https://TARGET.com|/|g" ./index.html

# Fix CSS url() references
find ./assets/css -name "*.css" -exec sed -i "s|https://TARGET.com|/|g" {} +

# Fix JS asset references
find ./assets/js -name "*.js" -exec sed -i "s|https://TARGET.com|/|g" {} +
```

### Phase 4: Verify
```bash
# Check all local assets resolve
echo "Images: $(grep -oP 'src="[^"]*\.(png|jpg|svg|webp)"' ./index.html | grep -v "http" | wc -l)"
echo "Links: $(grep -oP 'href="[^"]*"' ./index.html | grep -v "http" | wc -l)"

# Start local server and test
python3 -m http.server 8080 --directory /path/to/clone
```

### Phase 5: Deploy
```bash
# To Plesk
sudo cp -r /path/to/clone/* /var/www/vhosts/DOMAIN/httpdocs/

# To nginx
sudo cp -r /path/to/clone/* /var/www/DOMAIN/html/

# To any web root
rsync -avz /path/to/clone/ user@server:/var/www/site/
```

## Handling Common Patterns

### React/SPA Sites
```bash
# SPAs load assets dynamically - need to capture the JS bundle
curl -s "https://app.example.com" | grep -oP 'src="[^"]*\.js"' | sed 's/src="//;s/"//'

# Check for chunk files referenced in the main JS
grep -oP '[a-zA-Z0-9_-]+\.chunk\.js' main.js

# Download all chunks
grep -oP '"[^"]*\.js"' bundle.js | tr -d '"' | sort -u | while read f; do
  curl -o "./assets/js/$f" "https://app.example.com/$f"
done
```

### CDN Assets
```bash
# Many sites use CDNs - download those too
grep -oP 'https?://[^"'\''<>\s]+\.(css|js|png|jpg|svg|woff2)' /tmp/recon_main.html | sort -u | \
  while read url; do
    filename=$(basename "$url" | cut -d'?' -f1)
    curl -o "./assets/cdn/$filename" "$url"
  done
```

### Font Files
```bash
# Extract font URLs from CSS
grep -oP "url\(['\"]?[^)'\"]+\.(woff2?|ttf|eot|otf)[^)'\"]*\)['\"]?" style.css | \
  sed "s/url(['\"]//;s/['\"]?.*//" | sort -u
```

### Unicode/Filename Issues
```bash
# When files have unicode chars that nginx can't resolve
# Create decoded copies
for f in *; do
  python3 -c "import urllib.parse; print(urllib.parse.unquote('$f'))" | \
    xargs -I{} cp "$f" "{}"
done
```

### Icon Fonts
```bash
# Find icon font declarations in CSS
grep -oP '@font-face\{[^}]*\}' styles.css | head -5

# Download font files
curl -o ./fonts/icomoon.woff "https://TARGET.com/themes/custom/fonts/icomoon.woff"

# Add @font-face declaration to your CSS
```

## Quick Reference Commands

| Task | Command |
|------|---------|
| Download single page | `curl -o page.html URL` |
| Download page + assets (depth 1) | `wget -r -l1 -np URL` |
| Mirror entire site | `wget --mirror --convert-links URL` |
| Extract all images from page | `grep -oP 'src="[^"]*\.(png\|jpg\|svg\|webp)"' page.html` |
| Find all CSS files | `grep -oP 'href="[^"]*\.css"' page.html` |
| Fix absolute paths in HTML | `sed -i 's\|https://domain.com\|/path\|g' index.html` |
| Start local server | `python3 -m http.server 8080 --directory ./clone` |
| Deploy to Plesk | `sudo cp -r ./clone/* /var/www/vhosts/DOMAIN/httpdocs/` |

## Notes
- Always check `robots.txt` before cloning
- Some sites block wget/curl - use browser user-agent: `-H "User-Agent: Mozilla/5.0"`
- For JS-heavy sites, may need Playwright/Puppeteer for full rendering
- Keep original HTML as reference while creating fixed version
- Test locally before deploying to production
- For icon fonts, download the font files and add @font-face declarations
- For SPA sites, download all lazy-loaded JS chunks
- For multilingual sites, download all language versions
