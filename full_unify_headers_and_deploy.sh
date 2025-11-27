#!/bin/bash
# Full automation:
# 1) Replace ALL <header>...</header> blocks with the unified header
# 2) Mark the correct nav item as .active per page
# 3) (Optional) Deploy to /var/www/html using rsync

set -euo pipefail

############################
# 1. BASE HEADER TEMPLATE
############################

# Top + bottom of the header; links get injected in between.
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

############################
# 2. ACTIVE LINK MAP
############################
# Key = filename, value = which link should get class="active"
# (index has no active link; logo acts as "home".)

declare -A active_map
active_map["index.html"]=""
active_map["learn.html"]="learn"
active_map["stories.html"]="stories"
active_map["policy.html"]="policy"
active_map["take-action.html"]="take-action"
active_map["about.html"]="about"

############################
# 3. PATCH EACH HTML FILE
############################

for file in *.html; do
  echo "🔧 Updating header in $file..."
  cp "$file" "$file.bak"

  active="${active_map[$file]:-}"

  # Build nav links for this file with the right .active
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

  # Replace ANY existing <header>...</header> with this one
  NEW_HEADER="$header_content" perl -0pi -e '
    s#<header[\s\S]*?</header>#$ENV{NEW_HEADER}#s
  ' "$file"
done

echo "✅ All HTML headers unified and active links set."

############################
# 4. OPTIONAL DEPLOY STEP
############################

read -r -p "👉 Deploy to /var/www/html with rsync? [y/N] " ans
ans=${ans:-N}

if [[ "$ans" =~ ^[Yy]$ ]]; then
  echo "📦 Backing up current /var/www/html ..."
  sudo cp -r /var/www/html "/var/www/html-backup-$(date +%F-%H%M%S)"

  echo "🚀 Deploying from $(pwd) to /var/www/html ..."
  sudo rsync -av --delete ./ /var/www/html/

  echo "✅ Deploy complete. Remember to hard-refresh your browser (Ctrl+Shift+R)."
else
  echo "ℹ️ Skipping deploy. Files are updated locally in $(pwd) only."
fi
