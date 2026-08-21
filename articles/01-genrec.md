# Article 1 — GenRec: Towards LLM-Native Recommendation at Netflix

**Netflix Technology Blog · July 30, 2026 · Ying Li, Arjun Rao, Shradha Sehgal**
https://netflixtechblog.com/genrec-towards-llm-native-recommendation-at-netflix-f20be6f643e3

---

## The problem they were sitting on

Netflix's recommendation system has been built up over more than a decade, and it works
extremely well. But it works well the way a hand-built race car works well: every part was
machined for a purpose by someone who understood that part deeply.

Concretely, the old system runs on what engineers call **features** — thousands of individual
measurements about you, about each title, and about how you and titles have interacted.
Someone had to sit down and decide each one should exist: how many comedies you finished
this month, how long you hovered before clicking, how popular a title is in your country
this week. Thousands of these, each designed, built, tested, and maintained by hand.

On top of that sit specialized model architectures — one kind of machinery for understanding
the *order* of what you watched, another for spotting how features combine, another for
juggling multiple goals at once.

Here's the catch. Every time Netflix adds something new — games, live events, podcasts, a new
screen in the app — much of that hand-built machinery has to be extended or rebuilt. New
features to design. New architecture pieces. New infrastructure. New experiments to validate
it. The system's excellence and its rigidity come from the same source: it was carved to fit.

## The idea

Large language models are good at something the old system had to be taught laboriously:
understanding meaning expressed in words.

So the team asked a genuinely different question. Instead of converting your viewing history
into thousands of numbers, **what if we just described you in plain English and handed that
description to a model that already understands English?**

Instead of a spreadsheet row, something closer to a diary entry: this person watched these
shows, finished these, gave a thumbs-up to that one, abandoned this other one twenty minutes
in, and they're on a TV in the evening.

The model already knows, from being trained on enormous amounts of text, what a heist thriller
is, how it relates to a caper comedy, what "cozy mystery" means. It brings that world knowledge
with it. Nobody has to hand-encode the relationships between genres, because the model arrived
already understanding them.

They call the result **GenRec**.

## Why you can't just use ChatGPT for this

The article is refreshingly direct about this, and it's the part most people skip.

Take a general-purpose LLM and ask it for recommendations, and four things go wrong:

1. **It recommends the famous stuff.** It has read the whole internet, so it knows the popular
   titles best and drifts toward them — which is the opposite of personalization.
2. **It invents titles.** It confidently recommends things that aren't on Netflix at all.
   A recommendation you can't click is worse than useless.
3. **It ignores the business.** Netflix has real reasons to balance movies against series
   against games against live events. A generic model knows nothing about any of that.
4. **It barely knows you.** Whatever it learned about people in general is not the same as
   knowing what *you* watched last Tuesday.

So the work isn't "use an LLM." The work is turning a general model into a specialist without
losing what made it useful in the first place.

## How they built it: two phases

Think of it as **general education, then job training.**

**Phase 1 — Teach it about Netflix.** Start with an open-source LLM and continue training it on
Netflix's own material until it develops three things: an understanding of Netflix's catalog,
an understanding of how members behave and what their patterns mean, and its original language
ability, kept intact. This produces a Netflix-flavored foundation model. It's expensive, so it's
rebuilt infrequently, and — important for later — it's a *shared* asset that many different
Netflix applications can build on, not something owned by the recommendation team alone.

**Phase 2 — Teach it the specific job of ranking.** Take that foundation and train it further on
the specific task of ordering titles. This phase is refreshed often, because new shows launch
constantly and tastes shift.

That split matters more than it sounds. Phase 1 is slow, expensive, general. Phase 2 is fast,
cheap, specific. It's the difference between a medical degree and this month's updated treatment
guidelines.

## The clever bit: teaching it with fake conversations

Netflix logs hundreds of billions of events — plays, stops, thumbs, additions to a list,
abandonments. How do you feed that to a model that thinks in language?

They reshape the logs into **conversations that never actually happened.**

Each training example is staged as a dialogue. A "user message" contains the plain-language
description: who this person is, what they've watched, what device they're on, and what we're
asking. An "assistant message" contains what the member *really did* — the title they actually
played, how long they stayed, the feedback they gave.

The model learns by studying millions of these staged exchanges, absorbing how the real outcome
depends on the description.

Two things about this are worth pausing on.

First, it's a **format for learning, not a chat feature.** When GenRec runs live, it doesn't write
messages back. It reads the description and produces scores. The conversation shape exists to
train the model, not to talk to anyone.

Second, they deliberately keep training it on ordinary language alongside the ranking task. The
stated reasons: it helps the model read rich descriptions well, and it keeps open the possibility
of text generation later — for instance, explaining *why* something was recommended.

## Packing the suitcase: "context engineering"

Here's a very practical problem. A model can only read so much at once — its **context window**.
Describing every single thing a heavy viewer has ever watched would blow past that limit and cost
a fortune, multiplied across hundreds of millions of members.

The article frames this beautifully: the context window becomes the new **"feature budget."** In
the old system, the constraint was how many features you could build and maintain. In the new one,
it's how many words you can afford to spend describing someone.

So they pack the suitcase deliberately:

- **Keep in full** — the high-signal stuff. You watched the whole thing. You gave it a thumbs-up.
- **Throw out** — the noise. Three-second hovers. Accidental clicks.
- **Compress** — repetition. Six episodes in one night becomes one line, not six.
- **Expand** — things the model may not know well, like a brand-new release.

They also prioritize recent history over old, and structure the text so the beginnings of prompts
are shared between requests — which lets the system reuse cached computation instead of redoing it.

The payoff is striking: they cut the text to roughly **one-third** its original size with almost no
loss in quality. Since cost scales with length, that's roughly a two-thirds cost reduction for free.

## Three things it's trained to do at once

**1. Rank well.** The core job. Titles that led to real engagement — a genuinely long play, strong
explicit feedback — should be scored above titles that didn't.

**2. Stay fluent.** Keep practicing language so it doesn't lose the comprehension that made it
valuable.

**3. Optimize for the right thing.** This is the most interesting one.

If you train purely on "what did they click," you get a system that learns to maximize clicks —
which sounds fine until you notice that's how you end up with something that pushes bingeing and
funnels everyone toward one content type.

So each training example gets a **weight** — a multiplier on how much the model should care about
it — computed from two considerations. First, does this engagement actually predict good long-term
outcomes, like the member coming back, exploring more of the catalog, staying engaged over time?
Second, does the overall mix respect business needs — the balance across movies, series, games,
live, and new releases versus back catalog?

Examples that represent genuine long-term value get amplified. Shallow ones get muted. The article
notes this is simpler and cheaper than full reinforcement learning, and that fancier methods gave
extra gains they set aside as too expensive for now.

## How it actually runs

**Constrained to the real catalog.** Every Netflix title has a learned numerical fingerprint. The
model produces a summary of your current taste and context, then compares that summary against
each title's fingerprint to produce a score. Because it can only score titles that exist in the
list, it structurally cannot recommend something that isn't there. The hallucination problem is
solved by architecture, not by asking nicely.

**One pass, not word-by-word.** When ChatGPT answers you, it writes one word, then reads what it
wrote, then writes the next — slow and expensive. GenRec never writes anything. It reads the
description once and scores every candidate in a single pass. The article calls this
**prefill-only**, and at Netflix's volume it's the difference between viable and impossible.

**Smaller models, smarter training.** They use smaller or distilled models trained on more targeted
data, capturing most of the quality at a fraction of the serving cost.

## What happened

**Offline** (testing against historical data): about **+1.6%** better on a standard ranking measure
than the mature production system — while using roughly **40× fewer** labeled training examples in
Phase 2, and fewer input signals.

**Online** (real members): an A/B test on about **10% of Netflix traffic** over roughly **4 weeks**
produced statistically significant improvements on both short-term and long-term measures.

That 1.6% deserves context. Beating a system that's been tuned for years by a large team is genuinely
hard; small percentages there represent enormous value at Netflix's scale. And they achieved it in
what they describe as a low-data, low-signal configuration — meaning there's room to grow.

**Where the gains came from:**

- Using the Netflix-adapted foundation rather than an off-the-shelf model: **10–20%** better.
- Phase-2 ranking training on top of that: another **35–50%** — and this grows to about **80%** two
  weeks later, because the foundation model goes stale as new titles launch and Phase 2 is what
  keeps things current.
- Bigger models did better than smaller ones, and more Phase-2 data kept helping. Both scaled
  predictably, which is itself a finding — it means investment has forecastable returns.

## The bigger argument

The last section is the one to read twice, because it's about direction rather than results.

**From feature engineering to context engineering.** The old skill was designing thousands of
measurements. The new skill is deciding what to say about someone in a limited number of words.
The prompt becomes the new feature vector.

**From custom architectures to shared foundations.** Every task used to get its own bespoke machine.
Now many tasks can share one backbone, differing in their data, their descriptions, and their
training objectives. The article notes this makes it easier to share learnings across applications —
and, in a line worth flagging, that it opens the door to natural-language steering for future
experiences.

**Scaling laws as a guide.** Traditional recommendation systems hit walls where more effort stops
helping. LLM-based ones inherit the more predictable behavior of language models: more data and
bigger models keep helping, within cost limits.

**Recommendation infrastructure starts looking like AI infrastructure.** GPUs, LLM serving stacks,
caching and batching strategies — rather than the classic recommendation-system plumbing.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **LLM** | Large language model. Trained on huge amounts of text; understands and generates language. |
| **Ranker** | The component that decides what order to show things in. Not the thing that picks candidates — the thing that sorts them. |
| **Feature** | A single hand-designed measurement fed to a model. The old approach used thousands. |
| **Verbalization** | Turning data into plain-language description instead of numbers. |
| **Context window** | How much text a model can read at once. A hard limit. |
| **Context engineering** | Deciding what to include and what to cut, given that limit. |
| **Post-training** | Taking an already-trained model and training it further for a specific job. |
| **Foundation model** | A large general model meant to be built on by many applications. |
| **Scoring head** | A small final layer that turns the model's understanding into a number per item. |
| **Prefill-only** | Reading the input and producing scores in one pass, without generating text word by word. Much cheaper. |
| **MRR** | Mean Reciprocal Rank. Rewards putting the right answer near the top. |
| **A/B test** | Show version A to some users, B to others, compare real outcomes. |
| **Ablation** | Remove one piece and re-measure, to learn what that piece contributed. |
| **Distillation** | Training a small model to imitate a large one, keeping most quality at lower cost. |
| **Reward model** | A separate model that judges quality, used to weight training. |
| **vLLM** | Open-source software for serving LLMs efficiently. |

---

## Notes for the synthesis

Things to carry forward:

- Netflix has a **shared, Netflix-adapted foundation LLM** — not just one model for one job.
- The recommendation engine now **thinks in natural language internally**.
- The **catalog-aware scoring head** structurally prevents recommending titles that don't exist.
- **Prefill-only serving** exists because generating text at scale is expensive — a live cost
  constraint on anything conversational.
- The **language-modeling objective is kept deliberately**, with explanations named as a possible
  future use.
- The article explicitly names **natural-language steering** as a door this opens.
- GenRec is a **ranker**, not a user-facing interface. It improves the rows you already see.
  Nothing here lets a member type what they want.
