#!/bin/bash
# Force-unify the header/menu in take-action.html

set -euo pipefail

python3 << 'PY'
from pathlib import Path
import shutil

FILE = Path("take-action.html")

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

text = FILE.read_text()

# Backup once
backup = FILE.with_suffix(FILE.suffix + ".bak-takeaction")
if not backup.exists():
    shutil.copy2(FILE, backup)

start = text.find("<header")
if start != -1:
    end = text.find("</header>", start)
    if end != -1:
        end += len("</header>")
        new_text = text[:start] + NEW_HEADER + text[end:]
    else:
        new_text = text
else:
    # no header, insert right after <body>
    body_idx = text.find("<body")
    if body_idx == -1:
        new_text = text
    else:
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

FILE.write_text(new_text)
print("✅ take-action.html header unified.")
PY
