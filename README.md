# What to Watch — A Conversational Discovery Feature for Netflix

**A product proposal by [Samuel Orozco](https://github.com/orozcotorres-samuel)**

---

## The Problem

Every month, more than 1.5 million Americans open Google — not Netflix — to answer the question Netflix exists to answer: *what should I watch tonight?* "What to watch" alone draws 1.2 million U.S. searches a month, "good movies to watch" another 165,000–246,000, and the long tail runs past 70,000 keyword variations. And they don't search once: Google Trends shows the same viewer cycling through five or six rephrasings — "feel good movies" → "best feel good movies" → "feel good netflix movies" → "good movies to watch" — before landing on a single title. Then comes a second search entirely, just to find out which service has it; "where to watch" queries add another 57,700 searches a month.

Netflix is barely in this conversation. On the results page for "what to watch," Netflix holds the **#2 position but ranks 6th in actual traffic**, capturing under 5% of the ~975,000 monthly visits flowing to the top twenty results. The #1 result belongs to IMDb, owned by Amazon. The highest-trafficked result is a Rotten Tomatoes browse page that sits twelve positions *below* Netflix and still pulls 7.7× the visits — because it's a working cross-service tool, while Netflix's only entry is a Tudum blog post. Four of the top twenty results exist for no reason other than telling people where something is streaming, drawing 438,600 monthly visits between them.

Netflix has the most sophisticated personalization engine in streaming and knows its catalog better than anyone. What it doesn't have is a place for a viewer to simply say what they're in the mood for — so night after night, they say it to Google instead.

---

## The Proposal, in one line

A conversational discovery surface inside Netflix that accepts natural-language intent — *"a comedy with some action," "a drama I haven't seen," "something scary but not too scary, with some humor"* — and resolves it against the catalog and the personalization models Netflix already runs.

---

## Contents

| Section | What's in it |
|---|---|
| **[01 — Research](01-research/)** | Keyword volume, search-behavior, and SERP-competition data establishing the problem's scale. Every figure is backed by a dated screenshot. |
| **[02 — Articles & Sources](02-articles/)** | Reading log — Netflix engineering posts, earnings commentary, and industry coverage informing the proposal. |
| **[03 — Designs](03-designs/)** | Wireframes, mockups, and interaction flows for the proposed feature. |
| **[04 — Proposal](04-proposal/)** | The written proposal: problem, solution, scope, metrics, and risks. |

---

## How to read this

This repository is the **appendix** to a written proposal. It exists so the evidence can be examined at full resolution without turning the main document into fifty pages of pasted images.

- If you have five minutes → read **The Problem** above, then [the research summary](01-research/).
- If you want to verify the data → every claim in the research section links to the [screenshot](01-research/screenshots/) it came from, with the tool, region, and date it was captured.
- If you want to see the feature → go to [03 — Designs](03-designs/).

---

## Methodology & data notes

All search data is **United States, desktop**, captured **August 2026**, across five independent tools: Google Keyword Planner, Semrush, Ubersuggest, Clicks.so, and Google Trends.

A few deliberate choices, stated up front:

- **Search volumes are average monthly searches**, not daily. Where tools disagree — Semrush reports 165,000 for "good movies to watch" while Ubersuggest reports 246,000 — the **lower figure is used** in all totals.
- **Semrush's `Search Traffic` column is a URL's total monthly organic traffic across every keyword it ranks for**, not its traffic from a single query. It is used here to compare page-1 competitors against one another on a consistent metric, not to apportion the 1.2M "what to watch" searches.
- **Percentage-growth figures** (e.g. "+900% YoY," "breakout") are relative movements on small bases. They are cited as directional evidence that queries are becoming *more specific*, not as headline growth claims. The absolute volumes carry the argument.
- **Theatrical-intent keywords were excluded.** "Movie theaters near me" (2.7M/mo) is real search volume but reflects a different problem, so it is not counted in any total.

---

*This is an independent proposal. It is not affiliated with, endorsed by, or produced on behalf of Netflix, Inc. All trademarks belong to their respective owners.*
