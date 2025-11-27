#!/bin/bash
# Unify top header/nav across all HTML files to match index.html

set -euo pipefail

# Canonical header from index.html
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

for file in *.html; do
  echo "🔧 Patching header in $file..."
  cp "$file" "$file.bak"

  # Replace any <header ... </header> block with the unified header
  NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
    s#<header.*?</header>#$ENV{NEW_HEADER_CONTENT}#s
  ' "$file"
done

echo "✅ All top menus/headers unified to the index.html style."
