# Article 3 — Measuring the Impact of Personalized Recommendations

**Netflix Technology Blog · July 10, 2026**
**Kevin Zielnicki, Guy Aridor, Aurélien Bibaut, Allen Tran, Winston Chou, Nathan Kallus**
https://netflixtechblog.medium.com/measuring-the-impact-of-personalized-recommendations-4c26be3a4d96

*Also published in the International Journal of Industrial Organization and presented at the ACM
Conference on Economics & Computation 2026.*

---

## What makes this article different

The other articles are engineering: here's what we built and how it runs. This one is **economics**.
It asks a question that sounds simple and turns out to be genuinely hard:

**How much value do recommendations actually create?**

Not "do people watch recommended things" — obviously they do. The real question is whether the
recommendation *caused* the watching, or whether it just correctly guessed something you'd have
found anyway.

For your purposes this is the most useful article in the set, because it's the one that shows how
Netflix thinks about *proving* a discovery feature is worth something.

## The trap in the obvious metric

Here's the tempting measurement: what percentage of viewing comes from titles we recommended?

It's easy to compute, and it's close to meaningless. Here's why.

A title shows up on your homepage *precisely because* the system predicted you'd like it. So when
you watch it, two explanations are tangled together. Maybe the recommendation genuinely put
something in front of you that you'd never have found. Or maybe you love that kind of thing, would
have searched for it, and the system merely noticed what was already true.

The article's phrasing of the problem is exact: **recommendations are targeted to demand.** The
system aims at what you already want, which means "you watched what we recommended" is partly a
measure of how well it predicted you — not how much it changed you.

Think of it like a store putting umbrellas by the door when rain is forecast. Umbrella sales go
up. How much of that is the clever placement, and how much is that it's raining and people came
in wanting umbrellas? Counting umbrella sales near the door can't separate the two.

## Why you can't just run the experiment

In science the clean answer is a controlled experiment: turn personalization off for a big random
group, see what happens.

Netflix explicitly rules this out — not because it wouldn't work, but because it would be a bad
experience for real people. Personalization is how members navigate an enormous catalog. Turning it
off for a large group means deliberately making the product worse for them, for a long enough
period to measure. They won't do it.

That constraint drives everything else in the article, and it's a good thing to notice about how
Netflix operates: **measurement strategies are bounded by member experience, not just by
statistics.**

## The hybrid approach

So they do something more clever, in two parts.

**Part one: build a model of how members choose.** A simulation detailed enough to answer
"what would have happened if we'd recommended differently?"

**Part two: validate it with small, safe experiments.** Rather than switching personalization off
wholesale, run small tests that gently nudge certain titles up or down in visibility. That produces
real-world ground truth on a limited scale, which you then check the model against.

The logic: modeling gives you scale and the ability to ask hypothetical questions; experiments give
you credibility. Neither alone is enough.

## How the model works

**The basic setup.** Each day, a member either watches something from the catalog or watches
nothing. The model estimates the probability of each possible choice, given the member's
preferences, their history, and what they were shown.

Note that "watch nothing" is a real option in the model — which matters, because a discovery
feature's failure mode is exactly that: the member gives up.

**Why a naive version fails.** A simple model might assume that if you remove one title, viewing
spreads evenly across everything else. That's not how people work. Pull a romantic comedy and those
viewers mostly go to *other romantic comedies*, not evenly across documentaries and horror. And two
different members react completely differently to the same suggestion.

**The actual approach.** They use a low-rank choice model, which is a technical way of saying: the
system learns a compact numerical description of every title, and a matching description of what
each member currently wants, then compares them.

The important part is that these descriptions are **learned from behavior, not hand-written**.
Nobody labels a title "romantic comedy, 2019, light tone." The model works out what titles have in
common by watching who watches what. That lets it capture similarities too subtle to name — the
resemblance between two films that share no genre tag but attract the same people.

**Preferences move.** Rather than assigning each member one fixed taste profile, the model
summarizes your recent history into a *current preference state*. Someone who just finished a crime
thriller is in a different state than the same person after a stand-up special. The same human, a
different mood — and the model treats them differently.

That's worth sitting with, because it's the closest thing in these articles to what you're
proposing. Netflix already models the fact that **what you want right now depends on where you just
were.** What it lacks is a way for you to *tell* it where you are.

**The recommendation "bonus."** The key move: when a title is recommended, the model adds a
specific bonus to its chance of being chosen. That bonus is what they're trying to measure. It
bundles two effects — recommendations make you *aware* of something you didn't know existed, and
recommendations *signal* that something is probably a good match for you.

Because preferences, title appeal, and this bonus are represented separately, you can hold two
fixed and vary the third. That's what makes hypothetical questions answerable.

## Checking that the model isn't fooling itself

A model that fits history can still be wrong about the future. So they tested it against reality.

They randomly assigned members to groups where certain categories of titles were nudged slightly
more or less visible. Then they measured **diversion ratios** — when a title gets less visible,
where does that viewing go? To similar titles? To unrelated ones? Out of Netflix entirely?

Then they estimated the model on the untouched control group, simulated the same nudges, and
compared its predictions to what actually happened.

The agreement was strong: correlation of **0.86**, R-squared of **0.73**. In plain terms, the model
predicted most of what really happened when they perturbed the system for real. That's what earns
the right to trust its answers to bigger hypothetical questions.

## The headline results

With a validated model, they asked: what if Netflix used a *different* recommendation system?

Three comparisons, each stripping away a layer of sophistication:

| Alternative system | Effect on engagement |
|---|---|
| **Random** — titles picked at random from the catalog | **−16%** |
| **Popularity-based** — everyone sees what's broadly popular | **−12%** |
| **Matrix factorization** — a classic personalized approach, older generation | **−4%** |

Two things jump out.

**Personalization is worth a lot.** The gap between the current system and no relevance at all is
16% of engagement — enormous at Netflix's scale.

**Being personalized isn't enough; being *well* personalized matters.** Matrix factorization is
genuinely personalized, and it still loses 4%. Continued improvement in personalization keeps
producing real gains — the problem is not "solved."

Also notice: **popularity-based only loses 12%**, less than random. Recommending famous things is a
mediocre strategy that still beats chaos. That's a quietly useful benchmark, because most
non-Netflix discovery — listicles, "top 10" articles, trending pages — is essentially
popularity-based.

## The part about diversity

They then ask a sharper question. A recommender could boost viewing by shoving everyone toward the
same handful of hits. Engagement up, catalog wasted, and members with unusual taste badly served.

So they measure **consumption diversity** — how broadly viewing spreads across the catalog.

The current system does well on both dimensions at once. Popularity-based and matrix-factorization
recommendations both **concentrate** viewing onto fewer titles. Random recommendations spread
viewing slightly wider, as you'd expect, but at a brutal engagement cost.

The conclusion: good personalization increases viewing **and** spreads it across more of the
catalog. Those aren't in tension when the system is good enough.

## The most interesting section: why does a recommended title get watched?

They break the effect into three distinct channels. This framework is genuinely useful and worth
learning properly.

**1. Exposure.** You saw it. Simply putting something in front of someone raises the chance they
watch it, regardless of fit. This is the value of visibility alone.

**2. Selection.** The system showed it to people who were already likely to watch it. This creates
no *additional* viewing — those people were going to get there. But it isn't worthless: it makes
the experience feel smooth and makes the system feel like it understands you.

**3. Targeting.** The system found the people for whom *this specific recommendation changes the
decision* — people who watch it when recommended and wouldn't have otherwise. This is the real
magic: not showing things to people, but showing the right thing to the person it will move.

**The numbers:**

- Exposure is real — showing a title to an average member roughly **triples** its chance of being
  watched compared to not showing it.
- But mechanical exposure explains only about **7%** of the gap in consumption under the current
  system.
- The **targeting effect is nearly seven times larger than the exposure effect.**

So the value isn't in visibility. It's in match quality.

**And the comparison across systems is elegant.** Random recommendations are almost entirely
exposure — nothing personal is happening, so differences just reflect what got shown. Matrix
factorization splits roughly evenly across all three. The current system leans hardest on targeting.

That's a clean way to describe what improving a recommender actually *means*: you're converting
value-from-visibility into value-from-match.

## The finding most useful to you

**Targeting works best for mid-popularity titles.**

The logic is intuitive once stated. Blockbusters don't need help — everyone already knows about
them. Extremely niche titles have audiences too small to target reliably. The biggest gains sit in
**the middle of the catalog**: titles with real potential audiences who simply don't know they
exist yet.

That is a precise, Netflix-authored description of the catalog region a good discovery feature
would unlock. It also connects directly to the diversity result: helping middle-of-catalog titles
find their people is what keeps viewing from collapsing onto the same hits.

## What this article is really arguing

Three things, worth separating:

1. **Recommendations create genuine causal value**, not just correlation — and they've now measured
   it rigorously enough for an economics journal.
2. **The value comes from matching, not exposure.** Being shown something matters far less than
   being shown the *right* something.
3. **Better personalization keeps paying.** Even against a competent personalized baseline, the
   modern system wins by 4%. There's no plateau in sight.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Causal effect** | Did X actually *cause* Y, or did they just occur together? The whole difficulty here. |
| **Counterfactual** | What would have happened under a different choice. Unobservable, so it must be modeled. |
| **Endogeneity** | When your cause and your outcome are both driven by something hidden. Why the naive metric fails. |
| **Low-rank model** | Describing complex things with a small set of learned numbers instead of many hand-written labels. |
| **Preference state** | A summary of what a member wants *right now*, derived from recent history. |
| **Diversion ratio** | When one option becomes less available, where does demand go instead? |
| **Matrix factorization** | A classic recommendation technique. Personalized, but an older generation. |
| **Correlation / R²** | Measures of how well predictions match reality. 0.86 and 0.73 here mean "quite well." |
| **Consumption diversity** | How broadly viewing spreads across the catalog rather than concentrating on hits. |
| **Exposure / Selection / Targeting** | The three channels: you saw it / you'd have liked it anyway / it changed your mind. |

---

## Notes for the synthesis

- Netflix models member choice as a **daily decision that includes "watch nothing"** — an explicit
  model of the failure this proposal targets.
- Preferences are modeled as a **dynamic current state driven by recent history**, not a fixed
  profile. The system already understands mood shifts; it just can't be told about them.
- Title and member representations are **learned from behavior, not hand-labeled genres** — so the
  system understands similarities finer than any genre taxonomy.
- **Turning off personalization at scale is off-limits** because it harms members. Measurement must
  work around member experience. Relevant to how any new feature would have to be evaluated.
- The **exposure / selection / targeting** framework is Netflix's own vocabulary for the value of a
  recommendation. A discovery feature should be argued in these terms.
- **Targeting is ~7× exposure.** Value comes from match quality, not visibility.
- **Mid-popularity titles benefit most from targeting** — the catalog's middle is where discovery
  creates the most value.
- Good personalization raises engagement **and** diversity together.
- **Popularity-based recommendation costs 12% engagement** — a direct measure of how weak the
  external listicle/top-10 approach is compared to real personalization.
