#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

echo "🔧 Generating sitemap.xml..."

python3 << 'PY'
import os
from pathlib import Path
from datetime import datetime

root = Path("/var/www/html")

urls = []
for file in root.iterdir():
    if file.suffix == ".html":
        name = file.name
        if name == "index.html":
            loc = "https://stopambulancebalancebills.org/"
        else:
            loc = f"https://stopambulancebalancebills.org/{name}"
        urls.append(loc)

sitemap = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
]

for loc in sorted(urls):
    sitemap.append("  <url>")
    sitemap.append(f"    <loc>{loc}</loc>")
    sitemap.append(f"    <lastmod>{datetime.utcnow().date()}</lastmod>")
    sitemap.append("    <changefreq>monthly</changefreq>")
    sitemap.append("  </url>")

sitemap.append("</urlset>")

Path("/var/www/html/sitemap.xml").write_text("\n".join(sitemap), encoding="utf-8")

print("🎉 sitemap.xml updated!")
PY
