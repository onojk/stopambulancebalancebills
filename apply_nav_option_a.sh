#!/bin/bash
# Apply "Option A" single-line nav to styles.css

set -euo pipefail

CSS="/var/www/html/styles.css"

echo "📦 Backing up styles.css..."
cp "$CSS" "${CSS}.bak-nav-$(date +%F-%H%M%S)"

echo "✏️ Appending single-line nav CSS to styles.css..."

cat << 'EOF' >> "$CSS"

/* ===============================
   Single-line nav (Option A)
   Forces nav links onto one row.
   =============================== */

.nav-links {
  display: flex;
  flex-wrap: nowrap;      /* prevent wrapping to second line */
  white-space: nowrap;    /* keep labels on one line */
  gap: 1.25rem;
  overflow-x: auto;       /* allow gentle horizontal scroll on very small screens */
  scrollbar-width: none;  /* hide scrollbar (Firefox) */
}

.nav-links::-webkit-scrollbar {
  display: none;          /* hide scrollbar (Chrome/Safari) */
}
EOF

echo "✅ Option A CSS applied to $CSS"
echo "💡 Hard-refresh your browser (Ctrl+Shift+R) to see the updated nav."
