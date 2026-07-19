#!/usr/bin/env python3
"""
Advanced Site Cloner - Python version with better HTML parsing
Usage: python3 clone.py <URL> <OUTPUT_DIR>

Features:
- Parses HTML to extract all asset URLs
- Downloads CSS, JS, images, fonts in parallel
- Fixes paths automatically
- Handles relative URLs correctly
- Creates proper directory structure
"""

import sys, os, re, urllib.parse, urllib.request
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

DOMAIN = ""
BASE_URL = ""
HEADERS = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"}

def fetch(url, out_path):
    """Download a single file."""
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_bytes(data)
            return True, url, len(data)
    except Exception as e:
        return False, url, str(e)

def fix_url(url, page_url):
    """Resolve relative URLs to absolute."""
    if url.startswith("//"):
        return "https:" + url
    if url.startswith("data:") or url.startswith("javascript:") or url.startswith("#"):
        return None
    if not url.startswith("http"):
        return urllib.parse.urljoin(page_url, url)
    return url

def extract_assets(html, page_url):
    """Extract all asset URLs from HTML."""
    assets = {"css": [], "js": [], "images": [], "fonts": [], "other": []}
    
    # CSS
    for m in re.finditer(r'href=["\']([^"\']*\.css[^"\']*)', html):
        u = fix_url(m.group(1), page_url)
        if u: assets["css"].append(u)
    
    # JS
    for m in re.finditer(r'src=["\']([^"\']*\.js[^"\']*)', html):
        u = fix_url(m.group(1), page_url)
        if u: assets["js"].append(u)
    
    # Images
    for m in re.finditer(r'(?:src|href)=["\']([^"\']*\.(?:png|jpg|jpeg|gif|svg|webp|ico)[^"\']*)', html):
        u = fix_url(m.group(1), page_url)
        if u: assets["images"].append(u)
    
    # Fonts from inline styles
    for m in re.finditer(r'url\(["\']?([^"\')]+\.(?:woff2?|ttf|eot|otf))', html):
        u = fix_url(m.group(1), page_url)
        if u: assets["fonts"].append(u)
    
    return assets

def extract_css_assets(css_content, css_url):
    """Extract assets referenced in CSS."""
    assets = []
    for m in re.finditer(r'url\(["\']?([^"\')]+)["\']?\)', css_content):
        u = fix_url(m.group(1), css_url)
        if u and not u.startswith("data:"):
            assets.append(u)
    return assets

def main():
    global DOMAIN, BASE_URL
    
    if len(sys.argv) < 3:
        print("Usage: python3 clone.py <URL> <OUTPUT_DIR>")
        sys.exit(1)
    
    BASE_URL = sys.argv[1]
    OUT = Path(sys.argv[2])
    DOMAIN = urllib.parse.urlparse(BASE_URL).netloc
    
    print(f"=== Cloning {BASE_URL} to {OUT} ===")
    
    # Fetch main page
    print("[1/4] Fetching main page...")
    ok, _, size = fetch(BASE_URL, OUT / "index.html")
    if not ok:
        print(f"Failed to fetch {BASE_URL}")
        sys.exit(1)
    
    html = (OUT / "index.html").read_text(errors="ignore")
    print(f"  Page: {size} bytes")
    
    # Extract assets
    print("[2/4] Extracting assets...")
    assets = extract_assets(html, BASE_URL)
    total = sum(len(v) for v in assets.values())
    print(f"  Found {total} assets: {', '.join(f'{k}:{len(v)}' for k, v in assets.items() if v)}")
    
    # Download assets
    print("[3/4] Downloading assets...")
    downloads = []
    with ThreadPoolExecutor(max_workers=4) as pool:
        futures = {}
        for category, urls in assets.items():
            subdir = "cdn" if category == "other" else category
            for url in urls:
                fname = urllib.parse.urlparse(url).path.split("/")[-1].split("?")[0]
                if fname:
                    out_path = OUT / "assets" / subdir / fname
                    f = pool.submit(fetch, url, out_path)
                    futures[f] = (url, out_path)
        
        done = 0
        for f in as_completed(futures):
            done += 1
            ok, url, info = f.result()
            if not ok:
                print(f"  WARN: Failed {url}: {info}")
            elif done % 10 == 0 or done == len(futures):
                print(f"  Progress: {done}/{len(futures)}")
    
    # Download CSS assets (fonts, images referenced in CSS)
    print("[3b/4] Downloading CSS-referenced assets...")
    for css_file in (OUT / "assets" / "css").glob("*.css"):
        try:
            css_content = css_file.read_text(errors="ignore")
            css_assets = extract_css_assets(css_content, str(BASE_URL))
            for url in css_assets:
                fname = urllib.parse.urlparse(url).path.split("/")[-1].split("?")[0]
                if fname:
                    subdir = "fonts" if any(url.endswith(ext) for ext in [".woff2", ".woff", ".ttf", ".eot", ".otf"]) else "images"
                    out_path = OUT / "assets" / subdir / fname
                    fetch(url, out_path)
        except Exception:
            pass
    
    # Fix paths
    print("[4/4] Fixing paths...")
    # HTML
    content = (OUT / "index.html").read_text(errors="ignore")
    content = content.replace(f"https://{DOMAIN}", "")
    content = content.replace(f"http://{DOMAIN}", "")
    (OUT / "index.html").write_text(content)
    
    # CSS
    for css_file in (OUT / "assets" / "css").glob("*.css"):
        try:
            c = css_file.read_text(errors="ignore")
            c = c.replace(f"https://{DOMAIN}", "")
            css_file.write_text(c)
        except Exception:
            pass
    
    # JS
    for js_file in (OUT / "assets" / "js").glob("*.js"):
        try:
            c = js_file.read_text(errors="ignore")
            c = c.replace(f"https://{DOMAIN}", "")
            js_file.write_text(c)
        except Exception:
            pass
    
    # Summary
    file_count = sum(1 for _ in OUT.rglob("*") if _.is_file())
    total_size = sum(f.stat().st_size for f in OUT.rglob("*") if f.is_file())
    print(f"\n=== Clone complete ===")
    print(f"Files: {file_count}")
    print(f"Size: {total_size / 1024:.1f} KB")
    print(f"Preview: python3 -m http.server 8080 --directory {OUT}")

if __name__ == "__main__":
    main()
