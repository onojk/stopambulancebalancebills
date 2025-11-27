#!/bin/bash
# Force a single, identical header menu on every HTML page.

set -euo pipefail

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
  echo "🔧 Replacing header in $file"
  cp "$file" "$file.bak"

  # Replace ANY existing <header>...</header> with the unified header
  NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
    s#<header[\s\S]*?</header>#$ENV{NEW_HEADER_CONTENT}#s
  ' "$file"

  # Normalize stylesheet path for consistency
  perl -pi -e '
    s#<link rel="stylesheet" href="styles\.css">#<link rel="stylesheet" href="/styles.css">#;
  ' "$file"
done

echo "✅ Single unified menu applied to all HTML pages."
