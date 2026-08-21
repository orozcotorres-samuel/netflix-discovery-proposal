# 01 — Research

Evidence that viewers routinely leave Netflix to decide what to watch on Netflix.

**Scope:** United States · Desktop · Captured August 2026
**Tools:** Google Keyword Planner · Semrush · Ubersuggest · Clicks.so · Google Trends
**Raw evidence:** [screenshots/](screenshots/) · **Tabular data:** [data/](data/)

---

## Summary of findings

| # | Finding | Headline number |
|---|---|---|
| 1 | The intent is already Netflix's — it's just happening on Google | 1.52M+ monthly U.S. searches across 14 measured terms |
| 2 | People don't search once; they search five or six times | 8 overlapping queries in a single "feel good movies" session |
| 3 | Then they search again to find where it's streaming | 57,700 monthly "where to watch" searches |
| 4 | Publishers spend real money to own this traffic | 17K backlinks; ~$113K/mo in equivalent paid search value |
| 5 | Netflix ranks #2 by position but 6th by traffic | Under 5% of ~975,000 monthly visits |

---

## The demand

| Search | Monthly U.S. volume | Source |
|---|---|---|
| what to watch | 1,220,000 | Semrush |
| good movies to watch | 165,000 – 246,000 | Semrush / Ubersuggest |
| comedy shows | 49,500 | Semrush |
| good shows to watch | 33,100 | Semrush |
| new movies to watch | 33,100 | Semrush |
| feel good movies | 22,200 | Semrush |
| good action movies | 14,800 | Semrush |
| good shows to watch **on netflix** | 12,100 | Semrush |
| family friendly movies | 9,900 | Semrush |
| comedy movies to watch | 8,100 | Semrush |
| movies that will make you cry | 6,600 | Semrush |
| crime shows to watch | 1,000 | Semrush |
| drama movies to watch | 720 | Semrush |
| crime movies to watch | 260 | Semrush |
| short shows to watch | 260 | Semrush |

**~1.52M monthly searches across 14 measured terms**, using the lower estimate on every one.

That is a floor, not a ceiling. Semrush counts **70,400 keyword variations** of "what to watch" (2.5M combined volume) and **61,900 question-form variations** — "what's a good show to binge watch," "what's a good action movie to watch on netflix." "Good shows to watch" alone carries a 3,228-keyword long tail worth 184,600 searches a month.

📎 [`keyword-planner/`](screenshots/keyword-planner/) · [`semrush/`](screenshots/semrush/) · [`data/keyword-volumes.csv`](data/keyword-volumes.csv)

---

## Finding 1 — The intent is already Netflix's

Netflix-qualified searches sit at the top of the demand curve:

- "what to watch on netflix" — **49,500/mo**
- "good shows to watch on netflix" — **12,100/mo**
- "feel good movies on netflix" — **4,400/mo**
- "good drama movies on netflix" — **480/mo**

In Google Trends' related-query data, users searching "good movies to watch" *also* search **"netflix movies," "netflix," "good netflix movies,"** and **"good movies to watch on netflix"** — four of the top eight related queries are Netflix-branded.

These are not undecided viewers choosing between services. They are Netflix viewers who left the app to work out what to press play on.

📎 [`google-trends/03-good-movies-to-watch.png`](screenshots/google-trends/)

---

## Finding 2 — The reformulation loop

Google Trends' *"people who searched for X also searched for"* data shows discovery unfolding as a chain, not a query.

**A viewer searching "feel good movies" also runs:**

| Related query | Change |
|---|---|
| best feel good movies | +1% |
| feel good movie | +30% |
| best movies | −9% |
| netflix movies | +8% |
| good movies to watch | +40% |
| feel good netflix movies | +20% |
| feel good movies to watch | +40% |
| movies to watch | +40% |

Eight overlapping attempts at the same question — seven of them trending up.

**A viewer searching "good drama movies to watch" also runs:** "the drama" (+250%), "good movie to watch" (+200%), "good new movies to watch" (+500%), "best drama movies" (**breakout**), "good movies on netflix" (**breakout**).

Each rephrasing is a viewer telling the search engine the last answer didn't fit. **The reformulation loop is the wasted time** — and it's the part a conversational interface removes, because refinement happens in the same thread instead of a new search.

**The queries are also getting more specific, not less.** Growth concentrates in mood-and-constraint phrasing — "best drama movies" at **+900% YoY** in Keyword Planner, "good movies on netflix" flagged **breakout** in Trends — while generic terms like "good movies" sit flat at 0%. People aren't asking for *a movie*. They're asking for a comedy with some action, a drama they haven't seen, a scary show that isn't too scary. That is a natural-language query, and it's the exact query no browse row can answer.

📎 [`google-trends/`](screenshots/google-trends/) (all four captures)

---

## Finding 3 — Then they have to find out where it's streaming

"New movies to watch" carries **3,928 question-form variations totaling 57,700 monthly searches**, and the top ones share one shape:

| Query | Monthly volume |
|---|---|
| where to watch the new avatar movie | 1,900 |
| where to watch new demon slayer movie | 1,600 |
| where to watch new avatar movie | 1,300 |
| where to watch the new demon slayer movie | 1,300 |
| where to watch the new superman movie | 1,300 |

**The full journey:** leave Netflix → search a vibe → refine it five times → pick a title → search *again* to find which app has it → hope it's Netflix.

By the time the viewer gets back, the enthusiasm that started the session is spent.

📎 [`semrush/13-new-movies-to-watch.png`](screenshots/semrush/)

---

## Finding 4 — Publishers spend real money to own this traffic

This is not idle curiosity traffic. It is a monetized industry.

- Pages ranking for "good movies to watch" have accumulated **17,000 backlinks** (Ubersuggest) — years of deliberate SEO investment aimed at a single query.
- Keyword Difficulty across these terms runs **47–81%** (Semrush); the broader "movie" category tops out at **95/100** (Clicks.so).
- At Ubersuggest's **$0.46 CPC**, the traffic on that one keyword is worth roughly **$113,000/month in equivalent paid search spend**.

Every dollar of it is currently earned by someone other than Netflix — for a question Netflix could answer better than any listicle, using a catalog it owns and a personalization engine no publisher can match.

📎 [`ubersuggest/`](screenshots/ubersuggest/) · [`clicks-so/`](screenshots/clicks-so/)

---

## Finding 5 — Netflix ranks #2 by position, 6th by traffic

Top 20 Google results for "what to watch" (1.2M searches/month), **ranked by monthly organic traffic** rather than position:

| By traffic | Result | Google position | Monthly traffic |
|---|---|---|---|
| 1 | **Rotten Tomatoes** — /browse/movies_at_home | 14 | 369,100 |
| 2 | **Rotten Tomatoes** — /guide/popular-tv-shows | 4 | 230,600 |
| 3 | **New York Times** — /spotlight/what-to-watch | 3 | 131,000 |
| 4 | **IMDb** (Amazon) — /what-to-watch/watch-guides | 1 | 83,200 |
| 5 | **JustWatch** — /us | 8 | 57,000 |
| **6** | **Netflix Tudum** — /topics/what-to-watch | **2** | **47,800** |
| 7 | Variety | 5 | 20,000 |
| 8 | Reelgood | 9 | 9,400 |
| 9 | Reddit — r/televisionsuggestions | 6 | 7,000 |
| 10 | Collider | 20 | 4,800 |
| 11 | NPR | 16 | 4,300 |
| 12 | what-to-watch.com | 17 | 3,100 |
| 13 | Decider | 11 | 2,300 |
| 14 | Facebook group post | 13 | 1,700 |
| 15 | YouTube | 18 | 1,500 |
| 16 | AARP | 12 | 1,000 |
| 17 | Entertainment Weekly | 7 | 953 |
| 18 | Instagram Reel | 10 | 63 |
| 19 | YouTube | 19 | 54 |
| 20 | IMDb (title page) | 15 | 24 |

**Total: ~975,000 monthly visits. Netflix captures 47,800 — 4.9%.**

> Position and traffic diverge because a URL's pull depends on what it actually delivers, not just where it sits. Rotten Tomatoes' at-home browse hub ranks twelve places below Netflix and still draws 7.7× the visits — because it's a working tool, while Netflix's entry is an article.

**Four observations:**

**A competitor owns the #1 result.** IMDb belongs to Amazon. When an American types "what to watch," the top answer is a property of Prime Video's parent company — recommending Netflix titles and Prime titles with equal enthusiasm.

**The most-visited answer on the internet is a cross-service browse tool.** Rotten Tomatoes' `/browse/movies_at_home` pulls 369,100 monthly visits and is precisely what this proposal describes: one place to see what's watchable at home right now, across every service. Its neutrality *is* the product. Rotten Tomatoes' two pages together account for roughly 62% of all traffic on this SERP.

**Netflix is the only streaming service on either page.** No Hulu, no Max, no Disney+, no Prime Video. Every other result is an intermediary — a critic site, a newspaper, an aggregator, or a stranger on Reddit. The category's discovery layer has been ceded wholesale to third parties, and Netflix's lone entry is a blog rather than the app.

**Four of the top twenty exist solely to answer "where can I stream this?"** JustWatch (57,000), Reelgood (9,400), what-to-watch.com (3,100), and Rotten Tomatoes' at-home hub (369,100) — **438,600 monthly visits** to tools built entirely around the friction in Finding 3.

**And ~10,300 visits/month go to humans, not algorithms** — a Reddit thread, a Facebook group post, and two YouTube videos, most with zero backlinks and zero page authority. They rank because people want a *person* to talk them into something. That is the interaction model this feature proposes.

📎 [`semrush-serp/`](screenshots/semrush-serp/) · [`data/serp-what-to-watch.csv`](data/serp-what-to-watch.csv)

---

## What the data does *not* say

Stated plainly, because the limits matter as much as the findings:

1. **`Search Traffic` is URL-level, not query-level.** Semrush reports each URL's total monthly organic traffic across all keywords it ranks for. Rotten Tomatoes' `movies_at_home` ranks for 4,600 keywords. The 4.9% figure describes Netflix's share of traffic flowing to these competing pages — it is *not* a share of the 1.2M "what to watch" searches, and shouldn't be read as one.
2. **Volume estimates are modeled, not measured.** Every tool here infers volume from clickstream panels and Google's own bucketed ranges. Disagreement between tools is expected; that's why the lower figure is used throughout, and why five tools were consulted rather than one.
3. **Search volume is not lost revenue.** These searches demonstrate *unmet intent*, not churn. Establishing a link between discovery friction and retention would require Netflix's internal session data — which is exactly the analysis this proposal recommends running before committing engineering resources.
4. **Correlation in Trends' related queries is not a session replay.** "People also searched for" reflects aggregate co-occurrence, not one user's literal sequence. It is strong evidence of a reformulation pattern, not a timestamped user journey.
