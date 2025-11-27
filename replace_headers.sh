#!/bin/bash
# Automatically replace headers on all *.html files in the current directory
# Standardizes on the "nav-inner" header from index.html and adds .active per page.

set -euo pipefail

# Base header pieces, without the nav links themselves
read -r -d '' BASE_HEADER_TOP <<'EOF'
<header>
  <div class="nav-inner">
    <div class="nav-left">
      <a href="/" class="logo">Stop Ambulance Balance Bills</a>
      <div class="nav-tagline">Because when you call 911, you shouldn&rsquo;t get a $5,000 bill.</div>
    </div>
    <nav class="nav-links">
EOF

read -r -d '' BASE_HEADER_BOTTOM <<'EOF'
    </nav>
  </div>
</header>
EOF

# Which nav item should be active for each page
# (index.html has no "Home" link in this header, so we leave everything inactive there)
declare -A active_map
active_map["index.html"]=""
active_map["learn.html"]="learn"
active_map["stories.html"]="stories"
active_map["policy.html"]="policy"
active_map["take-action.html"]="take-action"
active_map["about.html"]="about"

for file in *.html; do
  echo "🔧 Patching $file..."

  # Backup original file
  cp "$file" "${file}.bak"

  # Determine which link should be active for this file (if any)
  active="${active_map[$file]:-}"

  # Build nav links with correct .active class
  nav_links=''

  nav_links+='      <a href="/learn.html"'
  [[ "$active" == "learn" ]] && nav_links+=' class="active"'
  nav_links+='>Learn</a>
'

  nav_links+='      <a href="/stories.html"'
  [[ "$active" == "stories" ]] && nav_links+=' class="active"'
  nav_links+='>Stories</a>
'

  nav_links+='      <a href="/policy.html"'
  [[ "$active" == "policy" ]] && nav_links+=' class="active"'
  nav_links+='>Policy</a>
'

  nav_links+='      <a href="/take-action.html"'
  [[ "$active" == "take-action" ]] && nav_links+=' class="active"'
  nav_links+='>Take Action</a>
'

  nav_links+='      <a href="/about.html"'
  [[ "$active" == "about" ]] && nav_links+=' class="active"'
  nav_links+='>About</a>
'

  # Assemble full header content
  header_content="${BASE_HEADER_TOP}
${nav_links}${BASE_HEADER_BOTTOM}"

  # Use Perl with an env var to safely do a multiline replacement
  NEW_HEADER="$header_content" perl -0pi -e '
    s#<header.*?</header>#$ENV{NEW_HEADER}#s
  ' "$file"

done

echo "✅ All headers replaced."
