#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

echo "🔧 Removing ALL old headers and inserting clean mobile header…"

python3 << 'PYTHONCODE'
import re
from pathlib import Path

PAGES = [
    "index.html",
    "learn.html",
    "stories.html",
    "policy.html",
    "take-action.html",
    "about.html",
]

# Stronger pattern: remove ANY <header>…</header> regardless of formatting or attributes
HEADER_ANY = re.compile(r"<header\b[\s\S]*?</header>", re.IGNORECASE)

# The unified header + JS
BLOCK = """<header class="site-header">
  <div class="container nav-container">
    <a href="/" class="logo">
      <span class="logo-mark">🚑</span>
      <div class="logo-text-wrap">
        <span class="logo-text">Stop Ambulance Balance Bills</span>
        <span class="logo-tagline">Because when you call 911, you shouldn’t get a $5,000 bill.</span>
      </div>
    </a>

    <button class="nav-toggle" aria-label="Toggle navigation" aria-expanded="false">
      <span></span>
      <span></span>
      <span></span>
    </button>

    <nav class="main-nav">
      <a href="/">Home</a>
      <a href="/learn.html">Learn</a>
      <a href="/stories.html">Stories</a>
      <a href="/policy.html">Policy</a>
      <a href="/take-action.html">Take Action</a>
      <a href="/about.html">About</a>
    </nav>
  </div>
</header>

<script>
  (function () {
    var toggle = document.querySelector('.nav-toggle');
    var nav = document.querySelector('.main-nav');
    if (!toggle || !nav) return;
    toggle.addEventListener('click', function () {
      var isOpen = nav.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });
    nav.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') {
        nav.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  })();
</script>
"""

BODY_RE = re.compile(r"<body[^>]*>", re.IGNORECASE)

for file in PAGES:
    p = Path(file)
    if not p.exists():
        print(f"⚠️  Missing {file}")
        continue

    html = p.read_text()

    # 1. Remove ALL existing header blocks
    html, removed = HEADER_ANY.subn("", html)
    print(f"🧹 {file}: removed {removed} old headers")

    # 2. Insert ONE clean unified header after <body>
    m = BODY_RE.search(html)
    if m:
        pos = m.end()
        html = html[:pos] + "\n" + BLOCK + "\n" + html[pos:]
        print(f"✅ {file}: inserted unified header")
    else:
        print(f"❌ {file}: no <body> found")

    # 3. Save
    p.write_text(html)

PYTHONCODE

echo "🎉 All pages cleaned and unified!"
