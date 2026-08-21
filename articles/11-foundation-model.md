# Article 11 — Foundation Model for Personalized Recommendation

**Netflix Technology Blog · March 21, 2025 · Ko-Jen Hsiao, Yesu Feng, Sudarshan Lamkhede**
https://netflixtechblog.com/foundation-model-for-personalized-recommendation-1a0bd8e02d39

---

## Read this one first, chronologically

This is the oldest article in the recommendation series and the **foundation the others stand on**.
FM-Intent extends this model. GenRec follows its philosophy. When later articles say "our
foundation model," this is what they mean.

## The problem: too many models

Netflix's recommender wasn't one system. It was **many specialized models**, each built for a
specific job — one for "Continue Watching," another for "Today's Top Picks for You," and so on.

Each worked well. Collectively they created two problems.

**Maintenance got expensive.** Every model needs training pipelines, monitoring, updating,
debugging. Multiply by dozens.

**Improvements didn't travel.** A clever technique that improved one model stayed there. Because
each was trained independently — *despite drawing on the same underlying data* — there was no
mechanism for one model's learning to benefit another. Every team re-solved the same problems in
parallel.

There was a third, subtler issue. Most of these models could only look at a **short window** of
recent history — not because longer history wouldn't help, but because reading more history costs
more time and money. So they all shared the same blind spot: they knew what you did recently and
had little sense of who you are over the long run.

## The idea, borrowed from language models

The proposal: stop building many small specialized models. Build **one large model that learns
member preferences centrally**, then let every other system draw on it.

This mirrors what happened in natural language processing — a shift away from many task-specific
models toward one large model that handles many tasks directly or with light adaptation.

They call out two lessons from that shift:

**Be data-centric, not model-centric.** The old approach put effort into hand-designing features.
The new one puts effort into accumulating large-scale, high-quality data and learning end to end.

**Use semi-supervised learning.** Predicting the next token turned out to be a remarkably powerful
training objective — it works on unlabeled data, so you can use everything you have, and it produces
models with surprisingly deep understanding.

Netflix has an enormous advantage here. Over 300 million users at the end of 2024, generating
hundreds of billions of interactions — a dataset they explicitly compare in scale to what large
language models train on.

## Turning behavior into a language

To feed interaction history to a transformer, it has to become a sequence of tokens.

**Merging actions into meaningful units.** Raw actions aren't equally informative. They merge
adjacent related actions into higher-level tokens — the same idea as how text tokenizers merge
common character sequences into single units.

But there's a wrinkle text doesn't have: when you merge, you must decide what to preserve. Combining
several viewing sessions of the same title means summing durations, aggregating engagement types.
Merge carelessly and you throw away the signal.

They frame the tradeoff precisely: **detail per token versus length of history covered** — analogous
to the balance in language models between vocabulary size and context window. Too lossy and you lose
signal; too granular and you exceed what's practical to process.

### The latency constraint, stated plainly

This paragraph is one of the most important in all eleven articles.

Active members accumulate **thousands** of events — more than a standard transformer can attend to.
At inference time, context is often limited to **hundreds** of events. And they're explicit that
this limit is **not because the model can't handle more**, but because these services must respond
in **milliseconds**.

Then the comparison that matters: this is **more stringent than typical LLM applications, where
response times measured in seconds are tolerable.**

Sit with that. The reason Netflix's recommender can't use richer, longer, more expensive reasoning
is that it must render a homepage instantly, unprompted, before you've asked for anything.

A feature where the member *types a request and waits for an answer* operates under a completely
different latency budget — the one where seconds are acceptable. That's not a minor detail; it
changes what's computationally possible.

Their workarounds for training: sparse attention techniques that stretch the affordable context
window, and sampling overlapping windows of history across training runs so the model sees all of a
member's history over time without ever needing it all at once.

### What's inside each token

Unlike a word, each interaction token carries many different kinds of information at once:

- **About the action** — locale, time, duration, device type.
- **About the content** — which title, plus metadata like genre and release country.

Timestamps get special handling to capture both absolute time (it's Friday night) and relative time
(this was three weeks ago).

They then draw a distinction that's directly relevant to your feature:

**Request-time features** — known at the moment of prediction. Login time, device, location.
**Post-action features** — known only after something happens. What was watched, for how long.

To predict what comes next, they combine the request-time features of the current moment with the
post-action features of the previous step.

**A member's typed request would be a new request-time feature** — a fundamentally new kind of
information available at the exact moment of prediction, of a type the system has never had.

## Training objective, with three modifications

The base approach is predicting the next token, like GPT. Three changes for the recommendation
setting:

**Not all events are equal.** A five-minute trailer play shouldn't count the same as finishing a
two-hour film. Language models weight every token equally; here that would be wrong.

**Predict several steps ahead, not just one.** Predicting the next *n* events rather than only the
next one pushes the model to capture longer-range patterns instead of optimizing myopically for the
immediate next click.

**Predict other things alongside the title — especially genre.** In addition to predicting which
title comes next, they have the model predict the *genre* sequence as a secondary objective. This
does three jobs:

- Reduces overfitting to noisy title-level predictions.
- Yields insight into member intentions and long-term genre preferences.
- Most interestingly: when structured as a hierarchy, **predicting genre first narrows the candidate
  list, making the title prediction easier.**

That last point is the seed that grew into FM-Intent. Predict the *category* of what someone wants,
then use it to constrain the specific choice. Here it's a training trick; in FM-Intent it becomes
the architecture.

## Cold start: recommending what nobody has watched

New titles arrive constantly with zero interaction history. Two mechanisms:

**Incremental training.** Retraining from scratch is impractical, so new models warm-start from
previous ones, keeping learned parameters and initializing new titles sensibly — either as slight
variations of an average, or as a blend of similar titles based on metadata.

**Learning from what a title *is*.** Each title gets two representations: one learned purely from
interactions, and one built from **metadata such as genres, storylines, and tones.**

The combination is the elegant part. Rather than simply adding them, a mixing mechanism weights them
by the **age of the title.** A brand-new title leans on its metadata description. An established
title leans on what's been learned from actual viewing.

And during training they deliberately introduce randomness so the model can't simply ignore metadata
and rely on identity — forcing it to genuinely learn from content descriptions.

Note "tones" appearing again, as a first-class metadata type feeding the recommendation model. The
tone vocabulary from MediaFM connects here.

## How other systems use it

**As a predictor directly.** It has multiple output heads for different tasks — including
forecasting a member's genre preferences.

**As embeddings.** It produces numerical representations of members and of entities — videos, games,
genres. These are computed in batch, stored, and used as inputs to other models, for finding
candidate titles, and for title-to-title recommendations.

There's a practical problem they solve neatly. Embedding dimensions are arbitrary and meaningless in
themselves, and they come out *differently every time the model is retrained.* Downstream systems
built on them break with each redeployment.

Their fix: a mathematical transformation applied to stabilize the space, so dimensions keep
consistent meaning across retraining. That's an infrastructure-maturity detail — the difference
between a research result and something other teams can safely build on.

**As a starting point for fine-tuning.** Teams can take the whole model or parts of it and adapt it
with far less data and compute than training from scratch, reaching comparable quality.

## Scaling

They confirm that the **scaling law holds** for recommendation: more data and bigger models produce
consistently better results, the same predictable relationship seen in language models.

They also note what scaling means here isn't just more parameters — it includes **context scaling**:
incorporating user engagement, external reviews, multimedia assets, and high-quality embeddings.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Foundation model** | One large model trained centrally, used by many downstream applications. |
| **Semi-supervised learning** | Learning from unlabeled data by predicting parts of it. |
| **Tokenization** | Converting raw data into the discrete units a model processes. |
| **Context window** | How much history the model can consider at once. Limited by latency here. |
| **Sparse attention** | Techniques letting a model handle longer sequences affordably. |
| **Sliding window sampling** | Training on overlapping slices so the model sees all history over time. |
| **KV caching** | Reusing prior computation to avoid redoing work. Keeps responses fast. |
| **Request-time features** | Known at prediction time — device, location, time of day. |
| **Post-action features** | Known only after the fact — what was watched, how long. |
| **Auxiliary objective** | A secondary training target that improves the primary one. |
| **Multi-token prediction** | Predicting several steps ahead to capture longer-range structure. |
| **Cold start** | Handling entities with no interaction history. |
| **Warm start** | Initializing a new model from an older one's parameters. |
| **Embedding space stability** | Keeping dimensions meaningful across retraining runs. |
| **Scaling law** | The predictable relationship between more data/parameters and better performance. |

---

## Notes for the synthesis

- Netflix built **one central foundation model for member preference learning**, replacing many
  independently-trained specialized models. Everything else in the recommendation stack draws on it.
- The stated motivation was **cost of maintenance and inability to transfer improvements** between
  models — an architectural argument, not a modeling one.
- **The latency constraint is explicit and quantified**: recommendation inference must complete in
  **milliseconds**, which they contrast with LLM applications where **seconds are tolerable.** This
  constraint — not model capability — is what limits how much history and reasoning is affordable.
  A member-initiated, member-awaited request sits in a different latency regime entirely.
- **Request-time vs. post-action features** is Netflix's own framing for what's known when. A typed
  request would be an entirely new *request-time* signal.
- **Predicting genre first narrows the candidate list** and improves title prediction — hierarchical
  prediction as a training technique here, later promoted to architecture in FM-Intent.
- Titles are represented by **both interaction-learned and metadata-learned embeddings** — metadata
  including **genres, storylines, and tones** — mixed by title age so new titles lean on content.
- The model produces **stable, reusable embeddings for members, titles, games, and genres**, kept
  consistent across retraining so other teams can build on them safely.
- **Scaling laws hold**, and "scaling" explicitly includes context — engagement, reviews, multimedia
  assets, embeddings.
- Netflix has **300M+ members and hundreds of billions of interactions**, a corpus they compare in
  scale to what LLMs train on.
