#!/bin/bash
# Unify nav on ALL .html pages:
# - If a <header> exists, replace it with the unified header
# - If no <header>, insert unified header right after <body>
# - Normalize stylesheet + favicon links

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

    # Backup once per file
    backup = path.with_suffix(path.suffix + ".bak-nav2")
    if not backup.exists():
        shutil.copy2(path, backup)

    # Replace existing <header>…</header> if present
    start = text.find("<header")
    if start != -1:
        end = text.find("</header>", start)
        if end != -1:
            end += len("</header>")
            new_text = text[:start] + NEW_HEADER + text[end:]
        else:
            new_text = text
    else:
        # No header: insert right after <body> tag
        body_idx = text.find("<body")
        if body_idx == -1:
            # weird file, leave it alone
            new_text = text
        else:
            # find the closing '>' of <body ...>
            close_idx = text.find(">", body_idx)
            if close_idx == -1:
                new_text = text
            else:
                insert_pos = close_idx + 1
                new_text = text[:insert_pos] + "\n" + NEW_HEADER + "\n" + text[insert_pos:]

    # Normalize stylesheet + favicon
    new_text = new_text.replace(
        '<link rel="stylesheet" href="styles.css">',
        '<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">'
    )

    if '<link rel="stylesheet" href="/styles.css">' in new_text and 'rel="icon"' not in new_text:
        new_text = new_text.replace(
            '<link rel="stylesheet" href="/styles.css">',
            '<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">'
        )

    path.write_text(new_text)
    print(f"🔧 Nav unified in {path}")

print("✅ Uniform nav header applied to all HTML files.")
PY
