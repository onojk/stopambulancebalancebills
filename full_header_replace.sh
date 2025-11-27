#!/bin/bash
# Force overwrite ALL <header>...</header> blocks with the unified header

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

  NEW_HEADER_CONTENT="$NEW_HEADER" perl -0pi -e '
    s#<header[\s\S]*?</header>#$ENV{NEW_HEADER_CONTENT}#g
  ' "$file"

done

echo "✅ All headers replaced with unified version."
