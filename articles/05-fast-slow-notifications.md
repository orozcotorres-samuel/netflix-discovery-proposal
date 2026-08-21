# Article 5 — Thinking Fast & Slow for a Personalized Notification System

**Netflix Technology Blog · June 5, 2026**
**Matthew Wood, Ishan Gupta, Kevin Mercurio, Devon Bryant, Claire Dorman**
https://netflixtechblog.com/thinking-fast-slow-for-a-personalized-notification-system-4d89b26525cd

---

## The short version

This is about notifications — the push alerts and emails Netflix sends to tell you something new
is out. But the *architectural idea* in it is much more broadly applicable than notifications, and
it's one of the most directly borrowable patterns in the whole set of articles.

The idea: **split one decision-making system into two layers that operate on different time
scales.** A slow, thoughtful planner that sets strategy. A fast, reactive executor that works
within it.

## The borrowed framing

The article opens with psychologist Daniel Kahneman's well-known distinction between two modes of
human thinking: one that's fast, automatic, and effortless, and one that's slow, deliberate, and
attention-demanding.

They point out this same split shows up all over engineering. Self-driving cars separate route
planning from moment-to-moment steering. Robots separate goal-setting from motor control. AI agents
separate deciding on a plan from executing individual steps.

The pattern is always the same: **strategy and tactics operate on different clocks and shouldn't be
crammed into one system.**

## The tension they're managing

Netflix sends hundreds of millions of personalized notifications. Each one is an opportunity and a
risk at the same time.

Send more: people become aware of things they'd genuinely enjoy. Also, people get annoyed, tune
out, and eventually turn notifications off entirely.

Send less: fewer annoyances, but people miss things they'd have loved.

The crucial thing is that these two effects operate on **different time horizons**. The benefit of
a notification shows up today. The cost — fatigue, irritation, someone finally hitting "turn these
off" — accumulates invisibly over weeks. Any system that only measures today will systematically
underestimate the damage it's doing.

## What was wrong with the old approach

The previous system used a model that estimated the causal effect of sending one particular message
over a short window. Reasonable, and it worked. Two problems:

**Problem one: it could only see the near future.** Trained on what happens shortly after a message
goes out, it captured the immediate benefit perfectly and the cumulative cost not at all. A message
that gets a click today might also nudge someone one step closer to opting out next month. The
model has no way to see that. The signals that actually matter — sustained viewing habits, slow
drift toward opting out — only become visible over long periods.

**Problem two: two decisions were tangled together.** One system decided both *whether* to send
anything and *which* thing to send. Frequency wasn't something you set — it emerged as a
side effect of daily relevance decisions.

They controlled it indirectly, with a quality threshold: only send if the predicted value clears
some bar, with the bar tuned to hit a target overall send rate.

That works in aggregate but creates a nasty coupling. **Raise the bar to send fewer messages, and
you also change which messages get selected.** Adjust one and the other moves. You can't tune
frequency without disturbing quality, or quality without disturbing frequency. Two things you care
about, one knob.

And personalizing frequency per member — some people want a lot, some want almost none — was
essentially impossible under a single global threshold.

## The fix: two policies on two clocks

**The Slow policy — the planner.** Runs on a long cadence, weekly for instance. It looks at a
member's long-term engagement patterns and decides that member's *messaging plan*: roughly how many
pushes and how many emails they should get over the coming week.

To keep this tractable they don't let it pick any number — they discretize it into a set of
distinct options combining push and email frequencies, on the order of a hundred combinations.
Enough to be genuinely personal, small enough to reason about.

**The Fast policy — the executor.** When an actual opportunity to send arises, this layer decides
what the single best message would be right now. It doesn't think about pacing at all. That's
already been decided.

**The division of labor:** the slow layer answers *how much*, the fast layer answers *what*.
Neither has to solve the other's problem.

## Getting the incentives right

The slow policy picks a plan by maximizing a score that weighs benefits against costs:

- **Positive signals** — how likely is this member to find value and engage?
- **Negative signals** — how likely are they to get fatigued or opt out?

In theory the negative signals should naturally restrain over-messaging. In practice they hit a
problem worth understanding, because it's a general trap in this kind of design.

**Explicit negative feedback is extremely rare.** Almost nobody actually opts out. Almost nobody
complains. So when the model estimates the cost of one more message, it computes something very
close to zero. And if each additional message costs nothing measurable, the optimal strategy is:
send the maximum, always, to everyone.

The model wasn't broken. It was correctly optimizing a badly specified objective. The harm was real
but nearly invisible in the data.

**Their fix:** add a flat **universal message cost** to every send, on top of the personalized
prediction. Every message now costs something by construction, regardless of what the sparse
feedback says.

Mathematically this keeps the objective well-behaved — each additional message is worth less than
the one before, so there's a natural stopping point instead of a runaway "always send." The size of
that cost is tuned through live experiments and offline evaluation.

The general lesson generalizes far beyond notifications: **when a real cost is hard to observe, an
optimizer will conclude it doesn't exist.** Sometimes you have to assert the cost rather than
measure it.

## Spreading messages over time

Once you've decided someone should get, say, three messages this week, how do you distribute them?

The simplest approach, and their baseline: convert the target into a probability, then at each
opportunity flip a weighted coin. Over the week the expected count works out, and the pattern looks
naturally irregular rather than robotically scheduled.

They note the framework extends easily to more structured patterns — day-of-week preferences,
timing around when someone is actually active, deliberate bursts around a big launch — whenever
there's a product reason to want one.

## How the two layers talk

This is the part I'd pay attention to architecturally, because it's clean.

The two policies don't call each other. They communicate **asynchronously through a feature store**
— a fast database holding precomputed information that models read at decision time.

- The **planner** runs on its schedule, computes the member's pacing plan, and writes it to the
  store.
- The **executor** runs when a send opportunity arises, reads that stored plan as just another
  input, and makes its tactical decision inside those bounds.

Two benefits they call out:

**Consistency.** The plan is computed once and then honored. The member gets a coherent experience
across the week rather than a series of unrelated daily decisions.

**Independent evolution.** You can retrain, tune, or A/B test the weekly pacing strategy without
touching the real-time message-selection logic — and vice versa. Two clean variables instead of one
tangled knob.

That second point is a systems-design argument, not a machine-learning one. They're buying the
ability to *change things independently*, which is often worth more than any single model
improvement.

## The results

They describe this as producing one of their largest production metric gains to date, with three
takeaways:

**The biggest wins came from casual viewers.** Members who watch less often benefited most —
because for someone not already in the habit of browsing regularly, timely awareness of something
relevant is precisely what's missing.

Underline that for your proposal. The people the system helps most are the ones who *aren't* deeply
engaged already.

**Decoupling mattered as much as the modeling.** They're explicit that separating the two decisions
was as transformative as any improvement to the models themselves. Better architecture, not just
better prediction.

**Long-term effects now have a home.** Fatigue and opt-out risk build up over time. By giving
pacing its own dedicated strategic layer, there's finally a place in the system where that
accumulation can be explicitly managed rather than hoped away.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **System 1 / System 2** | Kahneman's fast-automatic vs. slow-deliberate modes of thinking. |
| **Policy** | In this context, a rule or model that decides what action to take. |
| **Causal model** | Estimates whether an action *caused* an outcome, not just whether they co-occurred. |
| **Reward horizon** | How far into the future you measure consequences. Short horizons miss slow harms. |
| **Utility function** | The score being maximized, combining benefits and costs. |
| **Pacing** | How actions are distributed over time, distinct from how many there are. |
| **Feature store** | A fast database of precomputed values that models read at decision time. |
| **Concave objective** | Diminishing returns — each additional unit is worth less. Creates a natural stopping point. |
| **Degenerate policy** | A strategy that technically maximizes the objective while obviously being wrong ("always send"). |
| **Opt-out propensity** | Predicted likelihood someone turns notifications off. |
| **Discretized action space** | Reducing infinite options to a manageable finite set. |

---

## Notes for the synthesis

- Netflix uses a **hierarchical slow/fast decomposition**: a strategic planner on a long cadence and
  a tactical executor in real time. Explicitly compared to planning-vs-execution in robotics and AI
  agents.
- The two layers **communicate asynchronously through a feature store** rather than calling each
  other. Reusable pattern for any feature needing both standing context and per-moment decisions.
- **Decoupling was as valuable as the modeling.** Netflix explicitly credits architecture, not just
  model quality — useful framing when proposing a new component.
- **Casual, less-frequent viewers benefited most.** The strongest gains came from members who
  aren't already deeply engaged — the same population most likely to give up and search elsewhere.
- **Sparse negative feedback caused an "always send" failure.** They had to *assert* a cost that
  couldn't be reliably measured. A generalizable warning: real harms that are hard to observe get
  optimized away.
- Netflix explicitly manages **long-horizon costs** — fatigue, opt-out risk — as first-class
  concerns, not just immediate engagement.
- **Frequency and quality had to be separated** to be tunable at all. Two things you care about
  need two knobs.
