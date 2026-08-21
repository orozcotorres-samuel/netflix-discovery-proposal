#!/usr/bin/env bash
# Files loose screenshots into the repo's screenshot folders using the slots
# assigned in 01-research/screenshots/README.md, then rewrites that index so
# its links match the extensions that actually landed.
#
#   ./tools/place-screenshots.sh ~/Desktop/staging          # dry run
#   ./tools/place-screenshots.sh ~/Desktop/staging --apply  # file them
#
# Accepts png / jpg / jpeg / webp and preserves each file's real extension —
# a .webp renamed to .png is a broken file, and GitHub renders webp natively.
# Sources map to slots in natural sort order, so image1..image18 and 01..18
# both order correctly. Verify the printed mapping before applying.

set -euo pipefail

SRC="${1:-}"
APPLY="${2:-}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO/01-research/screenshots"
INDEX="$DEST/README.md"

if [[ -z "$SRC" || ! -d "$SRC" ]]; then
  echo "usage: $0 <staging-dir> [--apply]" >&2
  exit 1
fi

TARGETS=(
  "keyword-planner/01-saved-keywords-list|Keyword Planner - 10 saved keywords w/ volumes, +900% YoY row"
  "keyword-planner/02-what-to-watch|Keyword Planner - what to watch (100K-1M bucket)"
  "google-trends/03-good-movies-to-watch|Trends - good movies to watch, related queries (4 Netflix-branded)"
  "google-trends/04-feel-good-movies|Trends - feel good movies, 8 reformulations"
  "google-trends/05-good-drama-movies-to-watch|Trends - good drama movies, +500% / breakout"
  "google-trends/06-good-shows-to-watch|Trends - good shows to watch, tv shows chain"
  "semrush/07-what-to-watch|Semrush - what to watch (1.2M, KD 66, 70.4K variations)"
  "semrush/08-action-movies-to-watch|Semrush - action movies to watch (6.6K, KD 74)"
  "semrush/09-feel-good-movies|Semrush - feel good movies (22.2K, KD 47)"
  "semrush/10-good-drama-movies|Semrush - good drama movies (6.6K, KD 47)"
  "semrush/11-good-shows-to-watch|Semrush - good shows to watch (33.1K, KD 47)"
  "semrush/12-movies-to-watch-when-bored|Semrush - movies to watch when bored (1.9K, KD 26)"
  "semrush/13-new-movies-to-watch|Semrush - new movies to watch (33.1K, KD 81, where-to-watch Qs)"
  "semrush/14-bulk-keyword-analysis|Semrush - bulk analysis, 15 keywords (demand table source)"
  "clicks-so/15-popular-movie-keywords|Clicks.so - popular movie keywords, DARK page (3.35M, KD 95)"
  "ubersuggest/16-good-movies-to-watch|Ubersuggest - good movies to watch (246K, 17K backlinks)"
  "semrush-serp/17-serp-positions-1-10|Semrush SERP - what to watch, positions 1-10 (Netflix #2)"
  "semrush-serp/18-serp-positions-11-20|Semrush SERP - positions 11-20 (RT movies_at_home 369.1K)"
)

FILES=()
while IFS= read -r f; do
  FILES+=("$f")
done < <(find "$SRC" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort -V)

echo "Found ${#FILES[@]} image(s) in $SRC"
echo "Expecting ${#TARGETS[@]} screenshots"
[[ ${#FILES[@]} -ne ${#TARGETS[@]} ]] && echo "!! count mismatch - check the mapping carefully"
echo

[[ ${#FILES[@]} -eq 0 ]] && { echo "Nothing to file." >&2; exit 1; }

for i in "${!TARGETS[@]}"; do
  IFS='|' read -r stem desc <<< "${TARGETS[$i]}"
  if [[ $i -ge ${#FILES[@]} ]]; then
    printf '%2d. %-48s <- (MISSING)\n' "$((i+1))" "$stem.*"
    continue
  fi
  src="${FILES[$i]}"
  ext="${src##*.}"
  ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
  [[ "$ext" == "jpeg" ]] && ext="jpg"
  target="$stem.$ext"

  printf '%2d. %-48s <- %s\n' "$((i+1))" "$target" "$(basename "$src")"
  printf '    %s\n' "$desc"

  if [[ "$APPLY" == "--apply" ]]; then
    mkdir -p "$DEST/$(dirname "$target")"
    # drop any previously filed copy with a different extension
    rm -f "$DEST/$stem".png "$DEST/$stem".jpg "$DEST/$stem".webp
    cp "$src" "$DEST/$target"
    # point the index at the extension that actually landed
    if [[ "$ext" != "png" ]]; then
      /usr/bin/sed -i '' "s|$(basename "$stem")\.png|$(basename "$target")|g" "$INDEX"
    fi
  fi
done

echo
if [[ "$APPLY" == "--apply" ]]; then
  echo "Filed into $DEST"
  echo "Index links updated for non-png files."
  echo
  echo "Next:"
  echo "  git add -A && git commit -m 'Add research screenshots' && git push"
else
  echo "DRY RUN - nothing moved. Verify the mapping above, then re-run with --apply"
fi
