#!/bin/bash
# Recursively unify the header/menu on EVERY .html file under this directory.

set -euo pipefail

# This is the ONE TRUE MENU used on all pages
read -r -d '' NEW_HEADER <<'EOF'
<header>
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
</header>
EOF

# Find ALL .html files under this tree
find . -name '*.html' -print0 | while IFS= read -r -d '' file; do
  echo "🔧 Patching $file"
  cp "$file" "$file.bak"

  NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
    s#<header[\s\S]*?</header>#$ENV{NEW_HEADER_CONTENT}#s
  ' "$file"
done

echo "✅ Unified header applied to every .html file under $(pwd)"
