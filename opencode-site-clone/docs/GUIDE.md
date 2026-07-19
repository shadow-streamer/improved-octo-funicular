# Site Cloner - Complete Guide

## Quick Start

```bash
# 1. Recon a site
./scripts/recon.sh https://example.com

# 2. Clone it
./scripts/clone.sh https://example.com ./my-clone 2

# 3. Fix paths
./scripts/fix-paths.sh ./my-clone example.com

# 4. Preview locally
python3 -m http.server 8080 --directory ./my-clone

# 5. Deploy
./scripts/deploy.sh ./my-clone /var/www/vhosts/DOMAIN/httpdocs
```

## Directory Structure After Clone

```
my-clone/
├── index.html          # Main page (fixed paths)
├── assets/
│   ├── css/            # Stylesheets
│   ├── js/             # JavaScript files
│   ├── images/         # Images (png, jpg, svg, webp)
│   ├── fonts/          # Web fonts (woff2, ttf, etc.)
│   ├── videos/         # Video files
│   └── cdn/            # External CDN assets
└── pages/              # Additional pages
```

## Tool Reference

### Firecrawl (Recommended)
- Best for: Full site crawling, SPA rendering, structured extraction
- Install: `pip install firecrawl-py`
- Requires API key (free tier: 1000 pages/month)

### wget (Fallback)
- Best for: Simple static sites, mirrors
- No API key needed
- `wget --mirror --convert-links --page-requisites URL`

### curl
- Best for: Selective downloads, single assets, API calls
- No API key needed
- `curl -o output.html URL`

### GitIngest
- Best for: Understanding GitHub repos before replicating
- Install: `pip install gitingest`
- `gitingest https://github.com/user/repo`

## Common Scenarios

### 1. Clone a Static Marketing Site
```bash
wget --mirror --convert-links --adjust-extension --page-requisites \
  --directory-prefix=./clone https://marketing-site.com
```

### 2. Clone a React/Next.js SPA
```bash
# Get the main bundle
curl -s https://app.example.com | grep -oP 'src="[^"]*\.js"' | sed 's/src="//;s/"//'

# Download all chunks referenced in bundle
# (inspect the JS to find chunk patterns)
```

### 3. Clone a WordPress Site
```bash
# Download wp-content directory
wget -r -np -nH --cut-dirs=3 \
  https://site.com/wp-content/

# Download theme
wget -r -np -nH --cut-dirs=3 \
  https://site.com/wp-content/themes/THEME/
```

### 4. Clone with API Preservation
```bash
# After cloning, find API endpoints in JS
grep -oP 'https?://[^"'\''<>\s]+api[^"'\''<>\s]*' assets/js/*.js | sort -u

# Create API proxy (Node.js example)
cat > api-proxy.js << 'EOF'
const http = require('http');
const https = require('https');

http.createServer((req, res) => {
  const target = `https://api.original-site.com${req.url}`;
  https.get(target, (proxy) => {
    proxy.pipe(res);
  });
}).listen(3000);
EOF
```

## Troubleshooting

### Files download as 403/404
```bash
# Try with browser user-agent
curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" URL

# Try with referer
curl -H "Referer: https://example.com/page" URL
```

### Unicode filenames break on nginx
```bash
# Create NFC/NFD copies
for f in *; do
  python3 -c "
import unicodedata, urllib.parse
decoded = urllib.parse.unquote('$f')
nfd = unicodedata.normalize('NFD', decoded)
nfc = unicodedata.normalize('NFC', decoded)
if '$f' != nfd and '$f' != nfc:
    import shutil
    shutil.copy2('$f', nfd)
" 2>/dev/null
done
```

### Missing assets after cloning
```bash
# Check for 404s in browser console
# Common patterns:
grep -oP 'url\(['"'"'"][^)'"'"'"]+' assets/css/*.css | grep -v 'data:'
grep -oP 'src=['"'"'"][^'"'"'"]+' assets/js/*.js | grep -v 'data:'
```

### SPA routes don't work
```bash
# For client-side routing, create redirect rules
# nginx: try_files $uri $uri/ /index.html
# Apache: mod_rewrite to index.html
```
