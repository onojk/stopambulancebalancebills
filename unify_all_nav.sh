#!/bin/bash
# Force a single, uniform header + navigation onto EVERY .html page.

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
      <a href="/">Home</a>
      <a href="/learn.html">Learn</a>
      <a href="/stories.html">Stories</a>
      <a href="/policy.html">Policy</a>
      <a href="/take-action.html">Take Action</a>
      <a href="/resources.html">Resources</a>
      <a href="/media.html">Media</a>
      <a href="/letter-generator.html">Letter Generator</a>
      <a href="/about.html">About</a>
    </nav>
  </div>
</header>"""

root = Path(".")

for path in root.rglob("*.html"):
    text = path.read_text()

    # Find the first <header ... </header> block
    start = text.find("<header")
    if start == -1:
        # no header in this file, skip
        continue
    end = text.find("</header>", start)
    if end == -1:
        continue
    end += len("</header>")

    print(f"🔧 Patching header in {path}")

    # backup once per file
    backup = path.with_suffix(path.suffix + ".bak-nav")
    if not backup.exists():
        shutil.copy2(path, backup)

    # splice in new header
    new_text = text[:start] + NEW_HEADER + text[end:]

    # Normalize stylesheet and favicon
    # 1) handle relative styles.css
    new_text = new_text.replace(
        '<link rel="stylesheet" href="styles.css">',
        '<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">'
    )
    # 2) if it already had /styles.css but no favicon, we can inject favicon once
    if '<link rel="stylesheet" href="/styles.css">' in new_text and 'rel="icon"' not in new_text:
        new_text = new_text.replace(
            '<link rel="stylesheet" href="/styles.css">',
            '<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">'
        )

    path.write_text(new_text)

print("✅ Uniform nav header applied to all HTML files with an existing <header>.")
PY
