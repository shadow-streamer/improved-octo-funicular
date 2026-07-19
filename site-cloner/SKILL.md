---
name: site-cloner
description: Clone any website's assets (HTML, CSS, JS, images, fonts, videos) to a local or server directory, preserving structure and paths. Use when the user says "clone this site", "copy this website", "mirror this site", "download all assets", or wants to replicate a website's frontend.
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Site Cloner

Clone any website's assets to a local directory, preserving structure and paths.

## When to Use

- "Clone this site", "Copy this website", "Mirror this site"
- "Download all assets from X", "Save this page offline"
- "Deploy a copy of Y to my server"
- Any request to replicate a website's frontend

## Quick Start

```bash
# 1. Recon a site (analyze before cloning)
./scripts/recon.sh https://TARGET.com

# 2. Clone it (Python version - recommended for complex sites)
python3 ./scripts/clone.py https://TARGET.com ./OUTPUT

# Or use bash version (lightweight)
./scripts/clone.sh https://TARGET.com ./OUTPUT

# 3. Fix paths if needed (with dry-run first)
./scripts/fix-paths.sh ./OUTPUT TARGET.com --dry-run
./scripts/fix-paths.sh ./OUTPUT TARGET.com

# 4. Preview locally
python3 -m http.server 8080 --directory ./OUTPUT

# 5. Deploy
./scripts/deploy.sh ./OUTPUT /var/www/vhosts/DOMAIN/httpdocs
```

## Complete Cloning Workflow

### Phase 1: Reconnaissance

Analyze the target site before cloning:

```bash
./scripts/recon.sh https://TARGET.com
```

This generates a report with:
- Page size and asset counts
- Framework detection (React, Vue, Angular, Svelte)
- API endpoints found
- robots.txt contents
- All unique URLs

### Phase 2: Download

#### Python Version (Recommended)

```bash
python3 ./scripts/clone.py https://TARGET.com ./OUTPUT --workers 8 --timeout 60
```

Features:
- Class-based architecture (no globals)
- Parallel downloads with configurable workers
- Automatic path fixing
- Retry logic for failed downloads
- Detailed progress reporting

#### Bash Version (Lightweight)

```bash
./scripts/clone.sh https://TARGET.com ./OUTPUT
```

Uses shared library for:
- Configurable user-agent and timeouts
- Retry logic with exponential backoff
- Progress reporting

### Phase 3: Fix Paths

```bash
# Preview changes first
./scripts/fix-paths.sh ./OUTPUT TARGET.com --dry-run

# Apply fixes
./scripts/fix-paths.sh ./OUTPUT TARGET.com
```

### Phase 4: Verify

```bash
# Check all local assets resolve
echo "Images: $(grep -oP 'src="[^"]*\.(png|jpg|svg|webp)"' ./OUTPUT/index.html | grep -v "http" | wc -l)"
echo "Links: $(grep -oP 'href="[^"]*"' ./OUTPUT/index.html | grep -v "http" | wc -l)"

# Start local server and test
python3 -m http.server 8080 --directory ./OUTPUT
```

### Phase 5: Deploy

```bash
# To Plesk (with backup)
./scripts/deploy.sh ./OUTPUT /var/www/vhosts/DOMAIN/httpdocs

# To nginx (skip backup)
./scripts/deploy.sh ./OUTPUT /var/www/DOMAIN/html --no-backup

# To any web root via rsync
rsync -avz ./OUTPUT/ user@server:/var/www/site/
```

## Architecture

```
site-cloner/
├── SKILL.md              # This file
├── config/
│   └── defaults.conf     # Default configuration
├── lib/
│   └── common.sh         # Shared functions (logging, download, validation)
└── scripts/
    ├── clone.py          # Python cloner (modular, class-based)
    ├── clone.sh          # Bash cloner (uses common.sh)
    ├── recon.sh          # Site reconnaissance
    ├── fix-paths.sh      # Path fixing with dry-run
    └── deploy.sh         # Deployment with backup/rollback
```

## Configuration

Edit `config/defaults.conf` to customize behavior:

```bash
# User-Agent for requests
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"

# Request timeout (seconds)
TIMEOUT=30

# Concurrent downloads
CONCURRENT=4

# Max file size (bytes) - skip files larger than this
MAX_FILE_SIZE=52428800  # 50MB
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
for f in *; do
  python3 -c "import urllib.parse; print(urllib.parse.unquote('$f'))" | \
    xargs -I{} cp "$f" "{}"
done
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
| Deploy to Plesk | `./scripts/deploy.sh ./clone /var/www/vhosts/DOMAIN/httpdocs` |

## Tools Available

| Tool | Install | Use Case |
|------|---------|----------|
| wget | built-in | Mirror entire site |
| curl | built-in | Download specific files |
| python3 | built-in | Advanced cloning, parsing |

## Notes

- Always check `robots.txt` before cloning
- Some sites block wget/curl - use browser user-agent: `-H "User-Agent: Mozilla/5.0"`
- For JS-heavy sites, may need Playwright/Puppeteer for full rendering
- Keep original HTML as reference while creating fixed version
- Test locally before deploying to production
- For icon fonts, download the font files and add @font-face declarations
- For SPA sites, download all lazy-loaded JS chunks
- For multilingual sites, download all language versions

## See Also

- `learn-codebase` - Understand project structure before cloning
- `make-plan` - Plan complex cloning workflows
- `smart-explore` - Explore cloned sites efficiently
