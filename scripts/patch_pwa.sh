#!/bin/bash
# Patch Godot-exported index.html to add PWA support
# Run this after `godot --export-release` succeeds

set -e

WEB_DIR="/home/kirk/.picoclaw/workspace/Swordjin_Godot/builds/web"
INDEX="$WEB_DIR/index.html"

if [ ! -f "$INDEX" ]; then
    echo "ERROR: $INDEX not found. Export first."
    exit 1
fi

echo "Patching $INDEX for PWA support..."

# Add manifest link in <head> (before </head>)
if ! grep -q '<link rel="manifest"' "$INDEX"; then
    sed -i 's|</head>|  <link rel="manifest" href="manifest.json">\n  <meta name="theme-color" content="#1a1a2e">\n</head>|' "$INDEX"
fi

# Add service worker registration before </body>
if ! grep -q 'serviceWorker' "$INDEX"; then
    sed -i 's|</body>|  <script>\n    if (\x27serviceWorker\x27 in navigator) {\n      navigator.serviceWorker.register(\x27sw.js\x27).catch(err => console.error(\x27SW failed:\x27, err));\n    }\n  </script>\n</body>|' "$INDEX"
fi

# Copy manifest and sw if not present
cp "$WEB_DIR/../manifest.json" "$WEB_DIR/" 2>/dev/null || true
cp "$WEB_DIR/../sw.js" "$WEB_DIR/" 2>/dev/null || true

echo "PWA patch complete: $INDEX"
