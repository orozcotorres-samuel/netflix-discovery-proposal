#!/usr/bin/env bash
# Files loose screenshots into the repo's screenshot folders using the
# filenames pre-assigned in 01-research/screenshots/README.md.
#
#   ./tools/place-screenshots.sh ~/Desktop/staging          # dry run
#   ./tools/place-screenshots.sh ~/Desktop/staging --apply  # actually move
#
# Source files are matched to the 18 targets below in natural sort order, so
# image1..image18 and 01..18 both order correctly. Verify the printed mapping
# before applying.

set -euo pipefail

SRC="${1:-}"
APPLY="${2:-}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO/01-research/screenshots"

if [[ -z "$SRC" || ! -d "$SRC" ]]; then
  echo "usage: $0 <staging-dir> [--apply]" >&2
  exit 1
fi

TARGETS=(
  "keyword-planner/01-saved-keywords-list.png|Keyword Planner - 10 saved keywords w/ volumes"
  "keyword-planner/02-what-to-watch.png|Keyword Planner - what to watch (100K-1M)"
  "google-trends/03-good-movies-to-watch.png|Trends - good movies to watch, related queries"
  "google-trends/04-feel-good-movies.png|Trends - feel good movies, related queries"
  "google-trends/05-good-drama-movies-to-watch.png|Trends - good drama movies to watch"
  "google-trends/06-good-shows-to-watch.png|Trends - good shows to watch"
  "semrush/07-what-to-watch.png|Semrush - what to watch (1.2M, KD 66)"
  "semrush/08-action-movies-to-watch.png|Semrush - action movies to watch (6.6K, KD 74)"
  "semrush/09-feel-good-movies.png|Semrush - feel good movies (22.2K, KD 47)"
  "semrush/10-good-drama-movies.png|Semrush - good drama movies (6.6K, KD 47)"
  "semrush/11-good-shows-to-watch.png|Semrush - good shows to watch (33.1K, KD 47)"
  "semrush/12-movies-to-watch-when-bored.png|Semrush - movies to watch when bored (1.9K, KD 26)"
  "semrush/13-new-movies-to-watch.png|Semrush - new movies to watch (33.1K, KD 81)"
  "semrush/14-bulk-keyword-analysis.png|Semrush - bulk analysis, 15 keywords"
  "semrush-serp/15-serp-positions-1-10.png|Semrush SERP - what to watch, positions 1-10"
  "semrush-serp/16-serp-positions-11-20.png|Semrush SERP - what to watch, positions 11-20"
  "ubersuggest/17-good-movies-to-watch.png|Ubersuggest - good movies to watch (246K)"
  "clicks-so/18-popular-movie-keywords.png|Clicks.so - popular movie keywords (3.35M, KD 95)"
)

# bash 3.2 (macOS default) has no mapfile, so read into an array the portable way
FILES=()
while IFS= read -r f; do
  FILES+=("$f")
done < <(find "$SRC" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort -V)

echo "Found ${#FILES[@]} image(s) in $SRC"
echo "Expecting ${#TARGETS[@]} screenshots"
echo

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Nothing to file." >&2
  exit 1
fi

for i in "${!TARGETS[@]}"; do
  IFS='|' read -r path desc <<< "${TARGETS[$i]}"
  if [[ $i -lt ${#FILES[@]} ]]; then
    printf '%2d. %-45s <- %s\n' "$((i+1))" "$path" "$(basename "${FILES[$i]}")"
    printf '    %s\n' "$desc"
    if [[ "$APPLY" == "--apply" ]]; then
      mkdir -p "$DEST/$(dirname "$path")"
      cp "${FILES[$i]}" "$DEST/$path"
    fi
  else
    printf '%2d. %-45s <- (MISSING)\n' "$((i+1))" "$path"
  fi
done

echo
if [[ "$APPLY" == "--apply" ]]; then
  echo "Filed into $DEST"
  echo "Next: git add -A && git commit -m 'Add research screenshots' && git push"
else
  echo "DRY RUN - nothing moved. Verify the mapping above, then re-run with --apply"
fi
