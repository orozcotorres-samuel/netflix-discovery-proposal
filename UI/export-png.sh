#!/usr/bin/env bash
# Renders how-it-works.svg to a 3x PNG for Google Docs / Word / Slides.
#   ./export-png.sh          -> 3x  (3480x1680)
#   ./export-png.sh 4        -> 4x  (4640x2240)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
SCALE="${1:-3}"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "Google Chrome not found" >&2; exit 1; }

{ printf '<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;padding:0;background:#fff}svg{display:block}</style></head><body>'
  cat how-it-works.svg
  printf '</body></html>'; } > _wrap.html

"$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
  --force-device-scale-factor="$SCALE" --window-size=1160,560 \
  --screenshot="$PWD/how-it-works.png" "file://$PWD/_wrap.html" 2>/dev/null || true
rm -f _wrap.html
file how-it-works.png
