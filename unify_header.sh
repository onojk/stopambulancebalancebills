#!/bin/bash
# Unify top navigation/header on all pages that still use .site-header

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
  # Only touch files that still have the old .site-header structure
  if grep -q 'class="site-header"' "$file"; then
    echo "🔧 Patching header in $file..."
    cp "$file" "$file.bak"

    # Replace old <header class="site-header">…</header> with unified header
    NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
      s#<header class="site-header".*?</header>#$ENV{NEW_HEADER_CONTENT}#s
    ' "$file"

    # Normalize stylesheet + favicon links
    perl -pi -e '
      s#<link rel="stylesheet" href="styles\.css">#<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">#
    ' "$file"
  fi
done

echo "✅ Headers unified on all pages that used .site-header."
