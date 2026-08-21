# 04 — Proposal

The written proposal. This section holds the argument; [01](../01-research/) holds the evidence and [03](../03-designs/) holds the interface.

---

## The Problem

Every month, more than 1.5 million Americans open Google — not Netflix — to answer the question Netflix exists to answer: *what should I watch tonight?* "What to watch" alone draws 1.2 million U.S. searches a month, "good movies to watch" another 165,000–246,000, and the long tail runs past 70,000 keyword variations. And they don't search once: Google Trends shows the same viewer cycling through five or six rephrasings — "feel good movies" → "best feel good movies" → "feel good netflix movies" → "good movies to watch" — before landing on a single title. Then comes a second search entirely, just to find out which service has it; "where to watch" queries add another 57,700 searches a month.

Netflix is barely in this conversation. On the results page for "what to watch," Netflix holds the **#2 position but ranks 6th in actual traffic**, capturing under 5% of the ~975,000 monthly visits flowing to the top twenty results. The #1 result belongs to IMDb, owned by Amazon. The highest-trafficked result is a Rotten Tomatoes browse page that sits twelve positions *below* Netflix and still pulls 7.7× the visits — because it's a working cross-service tool, while Netflix's only entry is a Tudum blog post. Four of the top twenty results exist for no reason other than telling people where something is streaming, drawing 438,600 monthly visits between them.

Netflix has the most sophisticated personalization engine in streaming and knows its catalog better than anyone. What it doesn't have is a place for a viewer to simply say what they're in the mood for — so night after night, they say it to Google instead.

→ *Full evidence: [01 — Research](../01-research/)*

---

## Sections to write

### The Solution
- [ ] What the feature is, in one paragraph
- [ ] The three canonical queries it must handle ([see designs](../03-designs/))
- [ ] Why *inside* the app and not another Tudum article
- [ ] The strategic moat: viewing history as a negative constraint — *"a drama I haven't seen"* is a query only Netflix can answer

### Why Netflix, Why Now
- [ ] The personalization engine already exists; this is an input problem, not an intelligence problem
- [ ] Competitors are one product decision away from shipping it first
- [ ] The aggregators' 438,600 monthly visits are a market already validated by someone else

### Scope
- [ ] V1 — what ships first, and deliberately what doesn't
- [ ] Surfaces: TV, mobile, web — and which one leads
- [ ] What is explicitly out of scope

### Success Metrics
- [ ] **Primary:** time-to-play from session start
- [ ] **Primary:** browse-abandonment rate (sessions ending without playback)
- [ ] Secondary: refinement turns per successful session (target <3)
- [ ] Secondary: completion rate of titles selected via the feature vs. browse rows
- [ ] Guardrail: no reduction in catalog breadth surfaced — the feature must not collapse into the same 20 titles

### Risks & Open Questions
- [ ] Latency — a conversational surface that's slower than scrolling has already lost
- [ ] Cold start on new profiles
- [ ] Merchandising conflict — this may surface titles Netflix isn't currently promoting
- [ ] Cost per query at Netflix's scale
- [ ] Failure mode: what a wrong answer costs in trust vs. a bad browse row

### What I'd Need to Validate This
- [ ] Internal session data: how long does a browse session run before playback, and what share end without it?
- [ ] The honest limit of the external research — search volume proves *unmet intent*, not churn. Linking discovery friction to retention requires data only Netflix has.

---

## Notes on tone

This is a proposal from outside the company. That means:

- **Lead with the evidence, not the idea.** The data section is what earns the right to the recommendation.
- **State the limits of the research before anyone asks.** The [methodology notes](../README.md#methodology--data-notes) do this deliberately — a reviewer who spots an overstated number stops trusting the rest.
- **Don't claim to know Netflix's internal priorities.** Frame V1 scope as a proposal to be cut down, and name the internal data that would confirm or kill it.
