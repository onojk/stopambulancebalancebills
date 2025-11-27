#!/bin/bash
# Force-unify the header/menu in stories.html to match index.html

set -euo pipefail

FILE="stories.html"

# Backup first
cp "$FILE" "${FILE}.bak-fix-$(date +%F-%H%M%S)"

# Unified header (same as index.html)
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

# Replace the OLD header block
NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
  s#<header class="site-header">[\s\S]*?</header>#$ENV{NEW_HEADER_CONTENT}#s
' "$FILE"

# Normalize stylesheet href + add favicon to match index.html
perl -pi -e '
  s#<link rel="stylesheet" href="styles\.css">#<link rel="stylesheet" href="/styles.css">\n  <link rel="icon" type="image/png" href="/favicon.png">#;
' "$FILE"

echo "✅ stories.html header unified."
