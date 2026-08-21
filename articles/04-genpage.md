# Article 4 — GenPage: Towards End-to-End Generative Homepage Construction

**Netflix Technology Blog · June 29, 2026 · Lequn Wang, Jiangwei Pan, Linas Baltrunas**
https://netflixtechblog.com/genpage-towards-end-to-end-generative-homepage-construction-at-netflix-77146fba8a08

---

## Why this one matters most

If GenRec was "use an LLM to sort titles better," GenPage is far more ambitious: **use a single
generative model to build the entire Netflix homepage from scratch, one piece at a time.**

And buried in its final section is a sentence that describes, almost exactly, the technical bridge
your feature would need. More on that at the end.

## The problem: a homepage is not a list

When people think "recommendation," they picture a ranked list — best first, worst last.

The Netflix homepage isn't that. It's a **two-dimensional grid**: rows going down, titles going
across within each row. Which rows appear, which titles sit in them, and the order of everything
are all personalized. And the pieces interact — putting one row at the top changes the value of
everything below it.

The article gives a lovely concrete example. A "Continue Watching" row near the top is extremely
satisfying if you want to resume something. But it also means you stop browsing. You got what you
came for and never saw the rest of the page. Was that a good outcome? It depends on whether the
rest of the page had something better.

That's a **page-level** question. You cannot answer it by scoring each title individually, because
the answer depends on what else is on the page.

Traditionally Netflix built this with a multi-stage pipeline: one system picks candidate rows,
another ranks rows, another picks candidate titles, another ranks titles. Each stage has its own
model, its own training, its own goals — and those goals don't necessarily agree with each other.

## The idea: write the page like a sentence

GenPage asks one question and answers it in one shot:

> Given everything we know about this user and this request, what homepage should we generate to
> maximize satisfaction?

The mechanism borrows directly from how language models work. An LLM writes a sentence one word at
a time, each word chosen with full awareness of everything written so far. GenPage builds a
homepage one row-or-title at a time, each choice made with full awareness of everything already
placed on the page.

That's the key structural difference from other generative recommenders. Most of them generate a
**flat list**. GenPage generates the rows, the titles, *and the layout* as a single structured
output.

Because each choice sees everything before it, the model naturally avoids putting three nearly
identical rows in a row — not because someone wrote a rule, but because it can see what it already
did.

## Turning a homepage into a language

For this to work, both the input and the output have to become sequences of tokens — the discrete
chunks a transformer reads and writes.

**The input (the "prompt")** is everything known about you:
- **Your history** as a sequence of actions, each with type, title, timestamp, and duration.
  Explicit signals like plays, thumbs-up, and adds to My List — but also implicit ones like
  watching a trailer or just visiting a details page.
- **Your profile** — language, profile type.
- **The request context** — time of day, day of week, device.

**The output (the "response")** is the page: each title is one token, each row is one token,
written out in reading order — left to right, then top to bottom.

### The tokenizer is the clever part

They deliberately did *not* use an off-the-shelf text tokenizer. They built a custom one for
homepage data, and the reasons are worth understanding because they explain a lot about how Netflix
thinks.

**Reason one — cost.** The article gives a precise comparison. Expressing "user watched a
particular show for 50 minutes, 30 days ago" would take about 16 tokens in a standard text
tokenizer. Their custom scheme does it in **4**: one for the title, one for the action type, one
for a time bucket, one for a duration bucket. Four times shorter means roughly four times cheaper
and faster.

**Reason two — control.** Because each token maps directly to a real product concept — *this exact
title*, *this exact row* — you can control what the model is allowed to generate by simply
forbidding certain tokens. That becomes essential later.

Continuous values like timestamps get sorted into buckets so the vocabulary stays finite. Special
marker tokens separate one data source from the next.

One honest admission: some data is still too long to include raw, so they use handcrafted
summaries. They flag this as a compromise — a leftover bit of manual engineering they'd like to
eliminate.

### Pagination: the part that's quietly important

The homepage isn't generated all at once. It's built **a few rows at a time as you scroll**.

Before generating the next batch, the system appends what it already showed you **plus what you
just did with it**, pulled from Netflix's real-time event logging.

So the page adapts *within a single session*. What you hover over, click, or ignore in the first
few seconds shapes what appears further down.

Hold onto this. It's the closest thing in the existing system to a refinement loop.

## Teaching it what "good" means

Netflix has an internal **reward system** — a mechanism that converts observed behavior into a
single number representing how much value an impression created. It's tuned through A/B testing to
correlate with long-term satisfaction, not just clicks.

The intuition is straightforward:
- Binge-watched a series in one night → high reward.
- Watched ten minutes of a movie → low reward.
- Saw it and abandoned it → **negative** reward.

A page's total reward is the sum of the rewards of everything on it.

That negative reward for abandonment matters for your proposal: Netflix already treats "showed you
something you bounced off" as an actively bad outcome, not a neutral one.

## How they train it: the LLM playbook

The recipe deliberately mirrors how modern language models are built: **pretrain, then post-train.**

**Stage 1 — Pretraining.** Teach the model the "language" of Netflix homepages by having it predict
the next token over and over, using real homepages that got positive responses in production.

The model learns what a plausible, good homepage looks like — essentially learning to imitate the
existing production system.

They're candid that this is a limitation. Imitation caps you at the teacher's level. Worse, once
GenPage is itself in production, training future versions on pages generated by earlier versions
risks a slow degradation — a copy of a copy of a copy.

**Stage 2 — Post-training.** Two approaches, and they explore both.

**Approach A: Weighted Binary Classification.** Instead of "what comes next," ask "how *valuable*
would each possible next choice be?" Every title on a past page has a reward, so you convert that
into a label (was this good or bad?) and a weight (how strongly?). Binge-watching gets a heavy
weight; a brief play gets a light one.

This is easier to optimize because credit assignment is built in — each choice has its own outcome
attached, so there's no puzzling out which decision caused what.

**Approach B: Reinforcement Learning.** Harder, but it's the path to the real goal: optimizing the
**whole page** rather than each piece.

Their setup borrows the technique used to align chatbots. First they train a separate **reward
model** that can predict how good a page *would* be without ever showing it to anyone. That's what
makes it possible to try out hypothetical pages during training.

The danger is **reward hacking** — the model discovering weird pages that fool the scorer without
actually being good. Their defense: a penalty that keeps the generated pages close to what the
imitation-trained version would produce, so it can't wander into territory where the scorer is
unreliable. They also add rule-based rewards for basic structural sanity — the page should look
like a page, important rows shouldn't get buried.

## Four production problems and their fixes

### New titles nobody has watched yet

A brand-new show has no interaction history, so the model has nothing to learn from. Two fixes:

**Context injection** — put the new title's information directly into the prompt.

**Semantic embedding fusion** — this one is elegant. Rather than representing a title *only* by
what it learned from viewing patterns, they blend that with a content-based description derived
from **synopses, cast, transcripts, genres, and the video itself**. So a brand-new title has a
meaningful representation the moment its metadata exists, positioned in the same conceptual space
as established titles.

The training trick that makes it work: sometimes they randomly hide a title's identity and force
the model to work from the content description alone. That way it learns to recommend based on
*what something is*, not just *who has watched it*.

Remember this — it's the seam where content understanding enters the recommendation system.

### Keeping current without retraining constantly

Retraining a big model from scratch daily is unaffordable, but recommendations go stale fast.

Their answer runs on **two rhythms**: occasional full retraining over a long history, and daily
incremental updates that mix yesterday's data with a sample of older data. The old-data mixing
prevents **catastrophic forgetting** — the tendency of a model trained only on recent data to lose
what it knew.

New titles arriving daily get initialized from generic **fallback tokens**, and during training
they randomly swap real tokens for fallbacks so the model learns to cope gracefully with things it
hasn't seen.

### Making sure the rules are actually followed

A homepage must obey real constraints: no duplicates, certain rows pinned to certain positions,
titles in a Comedy row must actually be comedies. Training can *encourage* this. It cannot
*guarantee* it.

So they guarantee it mechanically, using the same **constrained decoding** technique from the
serving article. At each step, compute which tokens are legal right now and mask out everything
else. The model cannot break the rule because the rule-breaking options aren't available to it.

Their custom tokenizer makes this dramatically simpler: since one token equals one title or one
row, a business rule becomes a straightforward token mask. Pinning a specific row to position two
just means masking every other option at that position.

### Speed

Generating every single title one at a time would be slow. But the first few titles in a row matter
most — they get the most attention and set the row's tone.

So: generate the first few positions carefully, one at a time with full context. Then fill the rest
of the row in a single pass, still subject to the same rules. Careful where it counts, fast
everywhere else.

## What the experiments showed

**Pretraining helps a lot.** They translate the improvement into something interpretable: the rate
at which the model mis-orders a pair of titles drops from about 9% to about 8%. They note this is a
size of gain they rarely see from any single change to a mature system.

**Bigger models are better,** following the same predictable curve seen in language models — which
means capacity investment has forecastable returns.

**But here's the headline finding.** They compared two ways of improving the model:

| Change | Improvement in loss |
|---|---|
| Scaling the model ~7.5× larger (120M → 900M parameters) | **~1.3%** |
| Enriching the prompt — adding data sources, improving tokenization | **~6.9%** |

**Improving what you tell the model beat making the model bigger by roughly five to one.** In
several cases a single well-chosen addition to the context outperformed the entire model-scaling
effort.

Their conclusion: personalization quality is limited **first** by the information available to the
model, and only **then** by the model's capacity.

This is the most important sentence in the article for your purposes, and I'll come back to it in
the synthesis.

**And a surprise.** When they trained with reinforcement learning at the page level, homepage
**diversity increased** — even though diversity was never part of what they asked it to optimize.
That's evidence the model genuinely learned to think about the page as a whole rather than
greedily optimizing each slot.

## What happened with real members

A 14-day A/B test against the mature production system:

- **All variants beat production** on the core engagement metric used for launch decisions, with
  strong statistical significance. Different training configurations all produced comparable gains,
  suggesting the win comes from the approach itself rather than a lucky setup.

- **Latency dropped 20%.** This is genuinely counterintuitive — generative models are assumed to be
  slower. Replacing several ranking stages and heavy feature computation with one transformer
  eliminated so much overhead that the whole thing got *faster*. They note they hadn't exhausted the
  available optimizations, so there's more headroom, which can be spent on richer prompts instead.

- **Strong in-session responsiveness.** Recent actions quickly shifted subsequent recommendations,
  then faded back toward long-term preferences after a day or two. Notably, this behavior **emerged
  on its own** from the approach — nobody hand-engineered it.

- **An honest caveat.** They saw unintended shifts in what kinds of titles got shown — new versus
  established, TV versus film. They don't claim these are bad, but they weren't intended. Their
  hypothesis is that sharper personalization exposed places where older inherited components (like
  the reward system) aren't yet tuned for the new approach. They flag it as needing investigation.

  That candor is worth noting: a more precise system surfaced misalignments that a blunter system
  had been hiding.

## The conclusion, and the line that matters for you

They're clear this is early. Long context still leans on handcrafted summaries. And critically:
**general LLM capabilities — language, multimodality, reasoning — have not yet been incorporated.**

Then they name the direction they find promising: a **hybrid tokenization** that combines their
domain-specific tokens with ordinary text tokens, keeping structured control while inheriting the
strengths of general-purpose language models. They describe this as introducing an additional
recommendation modality into an LLM.

Read that again with your feature in mind. A system whose vocabulary contains *both* Netflix titles
and rows *and* ordinary English words is a system that can accept a sentence as part of its input
and emit a page as its output.

They close by saying the boundary between an LLM and a recommender system may increasingly blur.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Autoregressive** | Generating one piece at a time, each conditioned on everything produced so far. |
| **Token** | The discrete unit a model reads and writes. Here: one title, one row, one action. |
| **Tokenizer** | The scheme converting raw data into tokens. Custom here, not text-based. |
| **Entity** | Netflix's word for any recommendable thing — movie, show, game, live event, podcast. |
| **Transformer** | The neural network architecture behind modern AI, including LLMs. |
| **Decoder-only** | The transformer variant used for generation. Same family as GPT-style models. |
| **Multi-stage pipeline** | The traditional design: separate systems for candidates and ranking, chained. |
| **Reward system** | Netflix's mechanism converting observed behavior into a value score. |
| **Reward model** | A learned predictor of reward for a page never actually shown. Enables RL. |
| **Reward hacking** | A model finding ways to score well without being genuinely good. |
| **KL penalty** | A leash keeping a model from drifting too far from a trusted starting point. |
| **RL / RLHF** | Learning by trying things and being scored, rather than copying examples. |
| **Cold start** | The problem of recommending something with no interaction history. |
| **Semantic embedding** | A numeric representation of what something *is* — plot, cast, genre, visuals. |
| **Catastrophic forgetting** | When training on new data destroys previously learned knowledge. |
| **Constrained decoding** | Masking illegal options so rule violations are impossible, not just discouraged. |
| **AUC** | A measure of ranking quality. 0.91 → 0.92 is a meaningful jump at this maturity. |
| **Stopping power** | How strongly something makes a browsing user stop and engage. |

---

## Notes for the synthesis

- **A single generative model already builds the entire Netflix homepage** — rows, titles, layout —
  in production, and beat the mature multi-stage system.
- **Custom tokenization means one token = one title or one row.** Product concepts are directly
  addressable in the model's vocabulary.
- **Constrained decoding enforces business rules at generation time.** Rules become token masks.
  Structurally guaranteed, not merely encouraged.
- **The page is generated incrementally as you scroll**, incorporating what you *just did*, via
  real-time event logging. A within-session feedback loop already exists.
- **The reward system assigns negative reward to abandonment.** Bouncing off a page is already
  modeled as a bad outcome.
- **Enriching the prompt beat scaling the model ~5:1.** Netflix's own finding: quality is limited
  first by *what the model knows about the request*, then by capacity. A user's typed intent is new
  information of exactly this kind.
- **Semantic embedding fusion** brings content understanding — synopses, cast, transcripts, genres,
  video — into the same space as behavioral signals. New titles are representable immediately.
- **Generative was 20% FASTER**, not slower, with headroom left over that could be spent on richer
  prompts.
- **In-session responsiveness emerged naturally**, with recent actions decaying back to long-term
  preference over a day or two.
- **RL at page level produced diversity for free.**
- **Explicitly not yet incorporated: language, multimodality, reasoning.** They name **hybrid
  tokenization mixing domain tokens with text tokens** as the promising direction — the exact
  technical bridge from "system that outputs a page" to "system that can also read a sentence."
