#!/bin/bash
# Python-based header unifier: removes old .site-header blocks and replaces
# them with the unified header used on index.html.

set -euo pipefail

python3 << 'PY'
from pathlib import Path
import shutil

NEW_HEADER = """<header>
  <div class="nav-inner">
    <div class="nav-left">
      <a href="/" class="logo">Stop Ambulance Balance Bills</a>
      <div class="nav-tagline">Because when you call 911, you shouldn&rsquo;t get a $5,000 bill.</div>
    </div>
    <nav class="nav-links">
      <a href="/learn.html">Learn</a>
      <a href="/stories.html">Stories</a>
      <a href="/policy.html">Policy</a>
      <a href="/take-action.html">Take Action</a>
      <a href="/about.html">About</a>
    </nav>
  </div>
</header>"""

root = Path(".")
for path in root.rglob("*.html"):
    text = path.read_text()
    if 'class="site-header"' not in text:
        continue

    print(f"🔧 Patching {path}")

    # backup once
    backup = path.with_suffix(path.suffix + ".bak-siteheader")
    if not backup.exists():
        shutil.copy2(path, backup)

    start = text.find('<header class="site-header">')
    if start == -1:
        # nothing to do
        continue
    end = text.find('</header>', start)
    if end == -1:
        continue
    end += len('</header>')

    # splice in the new header
    new_text = text[:start] + NEW_HEADER + text[end:]

    # normalize stylesheet + favicon like index.html
    new_text = new_text.replace(
        '<link rel="stylesheet" href="styles.css">',
        '<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">'
    )

    path.write_text(new_text)

print("✅ Done running Python header unifier.")
PY
