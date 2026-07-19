#!/usr/bin/env python3
"""
Site Cloner - Modular Python version with parallel downloads.
Usage: python3 clone.py <URL> <OUTPUT_DIR> [--depth N] [--workers N]
"""

import sys
import re
import argparse
import urllib.parse
import urllib.request
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class CloneConfig:
    """Configuration for site cloning."""
    base_url: str
    output_dir: Path
    max_workers: int = 4
    timeout: int = 30
    user_agent: str = (
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    )

    @property
    def domain(self) -> str:
        return urllib.parse.urlparse(self.base_url).netloc

    @property
    def headers(self) -> dict:
        return {"User-Agent": self.user_agent}


@dataclass
class AssetCollection:
    """Container for extracted assets."""
    css: list = field(default_factory=list)
    js: list = field(default_factory=list)
    images: list = field(default_factory=list)
    fonts: list = field(default_factory=list)
    other: list = field(default_factory=list)

    def total(self) -> int:
        return len(self.css) + len(self.js) + len(self.images) + len(self.fonts) + len(self.other)

    def summary(self) -> str:
        parts = []
        for name, items in [("css", self.css), ("js", self.js), ("images", self.images), ("fonts", self.fonts)]:
            if items:
                parts.append(f"{name}:{len(items)}")
        return ", ".join(parts) if parts else "none"


class SiteCloner:
    """Main site cloner class."""

    def __init__(self, config: CloneConfig):
        self.config = config
        self.out = config.output_dir
        self.failed_urls: list = []

    def fetch(self, url: str, out_path: Path) -> tuple:
        """Download a single file. Returns (success, url, size_or_error)."""
        try:
            req = urllib.request.Request(url, headers=self.config.headers)
            with urllib.request.urlopen(req, timeout=self.config.timeout) as resp:
                data = resp.read()
                out_path.parent.mkdir(parents=True, exist_ok=True)
                out_path.write_bytes(data)
                return True, url, len(data)
        except Exception as e:
            return False, url, str(e)

    def resolve_url(self, url: str, base_url: str) -> Optional[str]:
        """Resolve relative URLs to absolute. Returns None for non-downloadable URLs."""
        if url.startswith("//"):
            return "https:" + url
        if any(url.startswith(p) for p in ("data:", "javascript:", "#", "mailto:", "tel:")):
            return None
        if not url.startswith("http"):
            return urllib.parse.urljoin(base_url, url)
        return url

    def extract_assets(self, html: str, page_url: str) -> AssetCollection:
        """Extract all asset URLs from HTML."""
        assets = AssetCollection()

        patterns = {
            "css": r'href=["\']([^"\']*\.css[^"\']*)',
            "js": r'src=["\']([^"\']*\.js[^"\']*)',
            "images": r'(?:src|href)=["\']([^"\']*\.(?:png|jpg|jpeg|gif|svg|webp|ico)[^"\']*)',
            "fonts": r'url\(["\']?([^"\')]+\.(?:woff2?|ttf|eot|otf))',
        }

        for attr, pattern in patterns.items():
            for match in re.finditer(pattern, html):
                resolved = self.resolve_url(match.group(1), page_url)
                if resolved:
                    getattr(assets, attr).append(resolved)

        return assets

    def extract_css_assets(self, css_content: str, css_url: str) -> list:
        """Extract assets referenced in CSS (fonts, images)."""
        assets = []
        for match in re.finditer(r'url\(["\']?([^"\')]+)["\']?\)', css_content):
            resolved = self.resolve_url(match.group(1), css_url)
            if resolved and not resolved.startswith("data:"):
                assets.append(resolved)
        return assets

    def download_assets(self, assets: AssetCollection) -> None:
        """Download all extracted assets in parallel."""
        downloads = []
        category_map = {
            "css": "css", "js": "js", "images": "images",
            "fonts": "fonts", "other": "cdn"
        }

        for category_name in ["css", "js", "images", "fonts", "other"]:
            urls = getattr(assets, category_name)
            subdir = category_map[category_name]
            for url in urls:
                fname = urllib.parse.urlparse(url).path.split("/")[-1].split("?")[0]
                if fname:
                    out_path = self.out / "assets" / subdir / fname
                    downloads.append((url, out_path))

        if not downloads:
            return

        completed = 0
        with ThreadPoolExecutor(max_workers=self.config.max_workers) as pool:
            futures = {pool.submit(self.fetch, url, path): url for url, path in downloads}

            for future in as_completed(futures):
                completed += 1
                ok, url, info = future.result()
                if not ok:
                    self.failed_urls.append(url)
                    print(f"  WARN: Failed {url}: {info}")
                elif completed % 10 == 0 or completed == len(futures):
                    print(f"  Progress: {completed}/{len(futures)}")

    def download_css_assets(self) -> None:
        """Download fonts and images referenced in CSS files."""
        css_dir = self.out / "assets" / "css"
        if not css_dir.exists():
            return

        for css_file in css_dir.glob("*.css"):
            try:
                css_content = css_file.read_text(errors="ignore")
                css_url = str(self.config.base_url)
                for url in self.extract_css_assets(css_content, css_url):
                    fname = urllib.parse.urlparse(url).path.split("/")[-1].split("?")[0]
                    if fname:
                        is_font = any(url.endswith(ext) for ext in (".woff2", ".woff", ".ttf", ".eot", ".otf"))
                        subdir = "fonts" if is_font else "images"
                        out_path = self.out / "assets" / subdir / fname
                        self.fetch(url, out_path)
            except Exception:
                pass

    def fix_paths(self) -> None:
        """Replace absolute domain URLs with relative paths."""
        domain = self.config.domain
        replacements = [f"https://{domain}", f"http://{domain}"]

        for pattern in ["*.html", "assets/css/*.css", "assets/js/*.js"]:
            for filepath in self.out.glob(pattern):
                try:
                    content = filepath.read_text(errors="ignore")
                    for replacement in replacements:
                        content = content.replace(replacement, "")
                    filepath.write_text(content)
                except Exception:
                    pass

    def create_structure(self) -> None:
        """Create output directory structure."""
        for subdir in ["assets/css", "assets/js", "assets/images", "assets/fonts", "assets/cdn", "pages"]:
            (self.out / subdir).mkdir(parents=True, exist_ok=True)

    def print_summary(self) -> None:
        """Print clone summary."""
        file_count = sum(1 for _ in self.out.rglob("*") if _.is_file())
        total_bytes = sum(f.stat().st_size for f in self.out.rglob("*") if f.is_file())
        size_str = self._human_size(total_bytes)

        print(f"\n{'='*50}")
        print(f"Clone complete: {self.out}")
        print(f"Files: {file_count}")
        print(f"Size: {size_str}")
        if self.failed_urls:
            print(f"Failed: {len(self.failed_urls)} URLs")
        print(f"Preview: python3 -m http.server 8080 --directory {self.out}")

    @staticmethod
    def _human_size(size_bytes: int) -> str:
        for unit in ["B", "KB", "MB", "GB"]:
            if size_bytes < 1024:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024
        return f"{size_bytes:.1f} TB"

    def run(self) -> None:
        """Execute the full clone workflow."""
        print(f"=== Cloning {self.config.base_url} ===")

        self.create_structure()

        print("[1/4] Fetching main page...")
        ok, _, size = self.fetch(self.config.base_url, self.out / "index.html")
        if not ok:
            print(f"Failed to fetch {self.config.base_url}")
            sys.exit(1)

        html = (self.out / "index.html").read_text(errors="ignore")
        print(f"  Page: {self._human_size(size)}")

        print("[2/4] Extracting assets...")
        assets = self.extract_assets(html, self.config.base_url)
        print(f"  Found: {assets.summary()}")

        print("[3/4] Downloading assets...")
        self.download_assets(assets)

        print("[3b/4] Downloading CSS-referenced assets...")
        self.download_css_assets()

        print("[4/4] Fixing paths...")
        self.fix_paths()

        self.print_summary()


def main():
    parser = argparse.ArgumentParser(description="Clone a website's assets")
    parser.add_argument("url", help="Target URL to clone")
    parser.add_argument("output", help="Output directory")
    parser.add_argument("--workers", type=int, default=4, help="Parallel download workers")
    parser.add_argument("--timeout", type=int, default=30, help="Request timeout in seconds")

    args = parser.parse_args()

    if not args.url.startswith(("http://", "https://")):
        parser.error("URL must start with http:// or https://")

    config = CloneConfig(
        base_url=args.url,
        output_dir=Path(args.output),
        max_workers=args.workers,
        timeout=args.timeout,
    )

    cloner = SiteCloner(config)
    cloner.run()


if __name__ == "__main__":
    main()
