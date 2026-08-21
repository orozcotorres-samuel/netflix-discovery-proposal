# Data

Machine-readable versions of the figures cited in the [research summary](../README.md).

| File | Contents |
|---|---|
| [`keyword-volumes.csv`](keyword-volumes.csv) | 33 keywords with monthly U.S. volume, difficulty, CPC, intent, source tool, and the screenshot each figure came from. |
| [`serp-what-to-watch.csv`](serp-what-to-watch.csv) | Top 20 Google results for "what to watch," with authority metrics, monthly organic traffic, and a category label per result. Sorted by traffic. |

**Captured:** August 2026 · United States · Desktop

### Notes on the columns

- `monthly_us_volume` — average monthly searches, per Semrush unless noted. Where a second tool disagreed, its figure is in `volume_alt_source` and the **lower** number is used in all totals.
- `monthly_search_traffic` (SERP file) — each URL's **total** monthly organic traffic across every keyword it ranks for, not its traffic from "what to watch" alone. Used to compare competitors on a consistent metric. See [methodology](../../README.md#methodology--data-notes).
- `category` — added by hand to distinguish cross-service aggregators, publishers, and user-generated results.

### Quick checks

```bash
# Total monthly traffic across the top 20 SERP results
awk -F, 'NR>1 {s+=$8} END {print s}' serp-what-to-watch.csv     # 974894

# Netflix's share of that traffic
awk -F, 'NR>1 {s+=$8; if ($3=="netflix.com") n=$8} END {printf "%.1f%%\n", n/s*100}' serp-what-to-watch.csv

# Traffic to where-to-stream aggregators
awk -F, '$10=="Where-to-stream aggregator" {s+=$8} END {print s}' serp-what-to-watch.csv
```
