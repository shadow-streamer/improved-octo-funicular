# Quick Reference for Site Cloning

## 3-Step Clone

```bash
# Step 1: Recon
/home/xwbnug6vcib1/site-cloner/scripts/recon.sh https://TARGET.com

# Step 2: Clone
/home/xwbnug6vcib1/site-cloner/scripts/clone.sh https://TARGET.com ./OUTPUT 2

# Step 3: Fix paths
/home/xwbnug6vcib1/site-cloner/scripts/fix-paths.sh ./OUTPUT TARGET.com
```

## Python Clone (better for complex sites)

```bash
python3 /home/xwbnug6vcib1/site-cloner/scripts/clone.py https://TARGET.com ./OUTPUT
```

## Deploy

```bash
/home/xwbnug6vcib1/site-cloner/scripts/deploy.sh ./OUTPUT /var/www/vhosts/DOMAIN/httpdocs
```

## Manual Approach

```bash
# Download page
curl -sL https://TARGET.com > page.html

# Download all CSS
grep -oP 'href="[^"]*\.css' page.html | sed 's/href="//' | while read u; do
  [[ "$u" != http* ]] && u="https://TARGET.com$u"
  curl -o "assets/css/$(basename "$u")" "$u"
done

# Download all JS
grep -oP 'src="[^"]*\.js' page.html | sed 's/src="//' | while read u; do
  [[ "$u" != http* ]] && u="https://TARGET.com$u"
  curl -o "assets/js/$(basename "$u")" "$u"
done

# Download all images
grep -oP 'src="[^"]*\.(png|jpg|svg|webp)' page.html | sed 's/src="//' | sort -u | while read u; do
  [[ "$u" != http* ]] && u="https://TARGET.com$u"
  curl -o "assets/images/$(basename "$u")" "$u"
done

# Fix paths
sed -i 's|https://TARGET.com|/|g' page.html assets/css/*.css assets/js/*.js
```

## Tools Available

| Tool | Install | Use Case |
|------|---------|----------|
| wget | built-in | Mirror entire site |
| curl | built-in | Download specific files |
| python3 | built-in | Advanced cloning, parsing |
| firecrawl | pip install | SPA rendering, crawl API |
| gitingest | pip install | Analyze GitHub repos |
| same.new | web SaaS | AI-powered cloning |
