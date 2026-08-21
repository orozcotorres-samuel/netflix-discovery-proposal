# Article 6 — Evaluating Netflix Show Synopses with LLM-as-a-Judge

**Netflix Technology Blog · April 10, 2026**
**Gabriela Alessio, Cameron Taylor, Cameron R. Wolfe**
https://netflixtechblog.com/evaluating-netflix-show-synopses-with-llm-as-a-judge-6269251e6f28

---

## Start with the opening line

This article begins by stating, as settled fact, that when members log into Netflix **one of the
hardest choices is what to watch** — and that the difficulty isn't a shortage of options but the
work of finding the genuinely intriguing one among thousands.

That's Netflix's own engineering blog describing your problem, in its first sentence, as the
motivation for a completely different project. Worth having in your back pocket.

## What the article is actually about

A **synopsis** is the short description under a title — the couple of sentences telling you what
something is. Netflix hosts hundreds of thousands of them, usually several variants per show,
because different descriptions of the same title work better for different members.

The article's claim about why they matter is direct: good synopses help people scan, understand,
and choose. Bad ones frustrate, mislead, and cause abandonment.

The problem is scale. You cannot have expert writers manually review hundreds of thousands of
descriptions, repeatedly, forever. So they built a system where **an AI grades the writing** —
reaching over 85% agreement with professional creative writers.

## Two completely different definitions of "good"

This is the conceptual heart of the article, and it's a genuinely sophisticated move.

**Definition one: creative quality.** Does it meet Netflix's editorial standards? Professional
writers judge it against internal rubrics — tone, clarity, precision, factual accuracy. This is
craft.

**Definition two: does it work on members?** Measured by two behavioral metrics:

- **Take fraction** — of the people who see this description, how many start watching?
- **Abandonment rate** — of those who start, how many quit shortly after?

Those two together are cleverer than either alone. Take fraction rewards being compelling.
Abandonment punishes being *misleading* — because a description that oversells gets people to
click and then bounce.

Optimizing take fraction alone would produce clickbait. The pair produces honest persuasion.

The article notes both have been validated through A/B testing as short-term stand-ins for
long-term retention — meaning Netflix has already established these are worth caring about.

## Teaching humans to agree before teaching a machine

The part of this article most worth reading carefully is what happened *before* any AI was
involved.

They gave roughly a thousand synopses to expert writers, three scoring each one, with written
explanations.

**The experts disagreed with each other a lot.** Judging writing quality is subjective, and initial
agreement between professionals was low.

Think about what that means. If your human experts can't agree, you have no ground truth. You
literally cannot train or evaluate a model, because there's no stable target.

So they ran calibration rounds — roughly fifty synopses at a time, surfacing disagreements,
discussing them, refining the guidelines. Three changes made the biggest difference:

1. **Binary scores instead of a 1–4 scale.** "Good or not good" instead of "how good." People agree
   far more readily on a threshold than on gradations. Most disagreement on a 4-point scale is
   people arguing about the difference between a 2 and a 3.
2. **Letting writers look at past examples**, so judgments anchored to precedent instead of mood.
3. **A searchable catalogue of common errors**, so recurring problems got named consistently.

After eight rounds, agreement reached about 80%.

They then stabilized further with a hybrid process: several writers score each item, an AI
aggregates their scores using the rubric, and humans review anything with serious disagreement.

The output is a **golden set** of about 600 synopses with agreed scores and explanations — the
reference standard everything else is measured against.

**The lesson here is general and important.** Before you can automate a judgment, you have to make
that judgment *reproducible among humans*. Most of the work was defining the standard, not building
the model.

## Building the judge

**One judge per criterion, not one judge for everything.** Their first instinct was a single prompt
evaluating all quality dimensions at once. It performed poorly — asking one model to juggle every
criterion simultaneously overloads it. Separate, dedicated evaluators for each criterion worked
substantially better.

This becomes a recurring theme: **narrow scope produces reliability.**

**Always explain before scoring.** Every judge writes its reasoning first, then gives its verdict.
This improves accuracy — and the explanations are themselves valuable, since human writers need to
see *why* something was flagged.

**Binary verdicts**, matching the human labeling scheme, so accuracy is simple to measure.

### Tuning the instructions automatically

Language models are notoriously sensitive to exact phrasing. Rather than hand-tweaking prompts,
they used **automatic prompt optimization** — a process that systematically tries variations and
keeps what scores best on a development set.

Results were uneven across criteria: strong for something concrete like factual precision, weak for
something slippery like clarity. Different qualities are differently hard to pin down.

### Spending more compute at judgment time

Two ways to make the judge think harder without retraining anything.

**Longer reasoning.** They tested short, medium, and long explanations. Accuracy rose with length —
but with diminishing returns. Medium was much better than short; long was only slightly better than
medium.

There was a catch: **long explanations are worse for humans to read.** Since the whole point is to
give creative experts actionable evidence, unreadable reasoning defeats the purpose.

Their solution, **tiered rationales**, is neat: let the model reason at whatever length it needs,
then require it to summarize that reasoning concisely before delivering the verdict. You keep the
accuracy benefit of extended thinking and hand humans something readable. It even improved accuracy
slightly — one evaluator went from about 86.6% to about 87.9%.

**Consensus scoring.** Ask the same question five times and average the answers.

The finding here is subtle and worth understanding. Consensus helped for the judges using *long*
reasoning, and did nothing for the judge using *short* reasoning. The explanation: longer reasoning
produces more varied answers run to run, so averaging genuinely stabilizes things. Short reasoning
produces nearly identical answers every time, so averaging five identical answers gains you
nothing.

**Reasoning models.** They tried models built specifically to think at length before answering.
These performed better at maximum effort — and they **chose not to use them**, because the cost
increase wasn't worth the marginal gain.

That's the third time cost has decided an architectural question across these articles.

## Fact-checking with narrow agents

Factual errors in synopses come in four flavors: wrong plot details, wrong metadata like genre or
release date, wrong people credited, and wrong award claims.

Each requires **different reference material** to check. Verifying plot needs the script or a plot
summary. Verifying awards needs an award list. Cramming all of that into one prompt buries the
model in irrelevant context.

They state the principle directly: simplicity drives reliability, and too much context or too many
criteria hurts accuracy.

So they built **one narrow agent per fact type**. Each gets only the reference material relevant to
its single job, and returns a verdict plus reasoning.

**The combination rule is strict:** the overall factuality score is the *minimum* across all agents.
Any single failure fails the whole thing. There's no averaging away a wrong release date because
the plot summary was accurate.

All the individual explanations then get merged into one combined rationale for the human reader.

This meaningfully improved accuracy, and stacking the earlier techniques inside each agent improved
it further.

## Checking it against real member behavior

Expert agreement proves the AI matches professional taste. It doesn't prove professional taste
matches what actually works on members. So they checked that too.

Because most shows have several personalized synopsis variants, they could compare variants of the
*same show* — holding the show constant and varying only the writing. Then they asked whether
better AI-judged scores corresponded to higher take fraction and lower abandonment.

They did. **Precision and clarity were especially predictive**, and a combined weighted score gave
a reliable signal in both directions.

So: the AI's judgments of writing quality track real member behavior. Which also means the whole
system can flag problems **weeks or months before a show launches**, while there's still time to
rewrite.

## What this article establishes

Three things worth carrying forward.

1. Netflix has a production system that **evaluates generated text quality at scale**, validated
   against both expert judgment and member behavior.
2. Netflix **already personalizes the words describing a title**, not just which titles you see.
   Synopsis variants are selected per member.
3. Netflix has named, validated metrics — **take fraction and abandonment rate** — for whether a
   piece of presentation actually helped someone choose.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Synopsis** | The short description of a title. Netflix has many variants per show. |
| **LLM-as-a-Judge** | Using a language model to grade output instead of a human. |
| **Agents-as-a-Judge** | Several narrow-scope judges, each checking one thing, combined. |
| **Golden set** | The trusted reference data everything is measured against. |
| **Rubric** | The explicit criteria defining quality. |
| **Inter-rater agreement** | How often independent human judges reach the same verdict. |
| **Calibration round** | A session where judges compare and align their standards. |
| **Take fraction** | Share of people who, having seen a description, start watching. |
| **Abandonment rate** | Share of people who start and quit shortly after. |
| **Chain-of-thought** | Having a model reason step by step before answering. |
| **Tiered rationale** | Reason at length internally, then summarize concisely before the verdict. |
| **Consensus scoring** | Sampling several answers and aggregating them. |
| **Automatic prompt optimization** | Systematically searching for better prompt phrasing. |
| **Reasoning model** | A model that generates long deliberation before its answer. Accurate, expensive. |
| **Zero-shot** | Asking without providing worked examples. |

---

## Notes for the synthesis

- Netflix's own words: **choosing what to watch is one of the hardest parts of the experience**, and
  the difficulty is finding the intriguing option among thousands — not a shortage of options.
- Netflix runs a production system for **evaluating generated text quality at scale**, agreeing with
  expert writers 85%+ of the time. Any feature generating text has an evaluation path already built.
- **Take fraction and abandonment rate** are named, A/B-validated member metrics for whether
  presentation helped someone choose. Directly reusable as success metrics for a discovery feature.
- **Abandonment appears again as a first-class harm** — consistent with the reward system's negative
  score for bounced impressions.
- **Netflix already personalizes the text** describing a title — synopsis variants selected per
  member. Personalization extends past "which titles" to "how they're described."
- Recurring architectural lesson: **narrow scope beats broad scope.** One judge per criterion; one
  agent per fact type; minimum-score combination so nothing gets averaged away.
- **Explanations are produced before verdicts** and treated as valuable output for humans — relevant
  to showing members *why* something was recommended.
- **Cost decided the architecture again** — reasoning models were more accurate and rejected as too
  expensive.
- Making a subjective judgment **reproducible among humans** was most of the work. Binary beat
  graded scales for agreement.
