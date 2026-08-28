# Netflix Discovery — Product Proposal

## What this is

A product proposal for **Netflix Discovery**: a conversational discovery surface inside Netflix
where a member types, says, or taps what they're in the mood for — *"good drama movie I haven't
seen before"* — and gets back a row of real titles, each with a one-line reason.

It is a **hiring artifact**, written by Samuel Orozco to send to Netflix PMs and hiring managers.
It is not affiliated with Netflix. Tone should be that of a capable outside product person who
did the reading, not a fan.

## The thesis (settled — do not relitigate)

> **Netflix built an intent-driven recommendation system and then had to guess the intent.**

FM-Intent predicts four dimensions of session intent *before* predicting titles, and describes
latent intent as "often not directly observable." It is unobservable because **there is no input
for it**. This feature is not new intelligence — it is the missing input to intelligence that
already exists.

Two load-bearing supports, both Netflix's own measurements:

1. **GenPage:** scaling the model ~7.5× (120M→900M) cut loss ~1.3%; enriching the context cut it
   ~6.9%. Their conclusion: quality is bottlenecked first by information about the request, then
   by capacity. A typed intent is the highest-value input available.
2. **Foundation Model:** homepage inference is capped at *milliseconds* — stated explicitly as a
   service constraint, not a model limitation — and contrasted with LLM applications where
   *seconds are tolerable*. A member who types and waits is in the second regime.

Framing for measurement: this is a **targeting** play (Netflix measures targeting at ~7× exposure),
though it may partly be **selection**. Mid-catalog share is the diagnostic that distinguishes them.

## Repo layout

| Path | Contents |
|---|---|
| `screenshots/` | 18 captured keyword/SERP research screenshots, indexed with captions |
| `articles/01-11` | Plain-language rewrites of 11 Netflix Tech Blog posts |
| `articles/00-SYNTHESIS.md` | **Read this first.** The systems map: 5 layers, 7 connections, the 9-step flow, the honest seams |
| `diagrams/how-it-works.svg` | The overview diagram (+ PNG export and `export-png.sh`) |

## Status

**DONE — the short version (2–3 pages).** Problem statement, the insight section, the feature
description, measuring success, and "what I don't know." All drafted and approved. Do not rewrite
these; the technical version must not repeat them.

**NEXT — the technical version.** An expansion covering only what is technical, difficult, or
inferred. The user wants to take a real stab at *how they would build this*.

### Scope for the technical version

1. **The parse/router** — the biggest inferred piece. A sentence decomposes into typed components
   routed to different subsystems: intent dimensions → FM-Intent, tone → MediaFM, entities and
   relationships → Knowledge Graph, novelty → viewing history. It is a router, not a classifier.
   No single Netflix model absorbs a natural-language query whole.
2. **Intent reconciliation** — queries are always partial. Stated intent overrides predicted intent
   on specified dimensions; FM-Intent supplies the rest. Nothing documents how Netflix would handle
   a stated intent, so this is proposed architecture.
3. **Catalog resolution** — tone matching (and the intensity problem), the unseen filter as a
   negative constraint, graph traversal for talent/relational queries.
4. **Ranking and constraint** — catalog-aware scoring head, constrained decoding as token masks.
5. **Response assembly** — GenPage rows; the row header in the mockup is a presentation-layer
   label, NOT a GenPage row token (those come from a daily-updated vocabulary).
6. **The refinement loop** — mechanically the same as GenPage pagination: append prior output plus
   latest engagement, regenerate. Do not restart.
7. **Latency and cost budget**, **cold start**, **failure modes and fallbacks**, **eval harness**.

## Working rules

- **Mark every claim `[documented]` or `[inference]`.** This discipline is the document's main
  credibility asset. A Netflix reader will spot the difference; better that the line was drawn first.
- **Never write a quote that hasn't been verified character-for-character against the source.**
  A misquote from Netflix's own blog, in a document sent to Netflix, is disqualifying.
- **Facts and figures must be verified before they enter the document.** Several numbers in
  `articles/` were written before source verification. Confirm before citing.
- Netflix never names its **core engagement metric used for launch decisions** — refer to it exactly
  that way and add nothing.
- **Rationale lines appear in no Netflix article.** They are this proposal's design. Take fraction
  and abandonment rate are real, validated Netflix metrics — but validated on *synopses*, so
  applying them here is a proposed extension.
- The user is a coding beginner but this project is writing and systems thinking, not code. Explain
  technical concepts plainly; he pushes back well and catches real errors.

## Known unknowns (already written up; keep consistent)

- Search volume proves unmet intent, **not** churn. No retention link established.
- Semrush `Search Traffic` is URL-level across all keywords, not per-query. The 4.9% is a share of
  traffic to competing pages, not of the 1.2M query.
- **Tone intensity is undocumented.** MediaFM classifies *into* ~100 tone categories; nothing
  establishes degree. Per-label scores make a gradient plausible — that is inference.
- MediaFM operates at **shot/clip level**; title-level embedding was named as a follow-up post.
- **GenPage cannot read text** — vocabulary is entity/row/action tokens. Parsing must happen
  outside it. Netflix names hybrid tokenization as future work.
- FM-Intent's **+7.4% is vs TransAct**, an external baseline, not vs Netflix production.
- Whether a session ending with **no playback at all** is a tracked production metric is unknown.

## Environment gotchas

- `netflixtechblog.com` sits behind Cloudflare and often blocks automated fetches. The
  `netflixtechblog.medium.com` variant sometimes works. Article rewrites in `articles/` are the
  working reference, but they are paraphrase — verify against source before quoting.
- macOS TCC blocks this app from `~/Downloads` and `~/Documents` ("Operation not permitted").
  `~/Desktop` works. `find ... 2>/dev/null` hides the error and looks like "file not found."
- `gh` is at `~/.local/bin/gh`, authenticated as `orozcotorres-samuel`.
- Repo is **public**: https://github.com/orozcotorres-samuel/netflix-discovery-proposal
- The user wants the repo minimal — **add folders only when asked.** `diagrams/` is currently
  untracked by choice.
