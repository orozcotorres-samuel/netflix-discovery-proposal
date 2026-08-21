# Article 7 — Optimizing Recommendation Systems with JDK's Vector API

**Netflix Technology Blog · March 2, 2026 · Harshad Sane**
https://netflixtechblog.com/optimizing-recommendation-systems-with-jdks-vector-api-30d2830401ec

---

## Why you should read this one anyway

On the surface this is a deep performance-engineering article about making Java math faster. It's
the least product-oriented piece in the set.

But it contains two things that matter for you: a name for the service that builds your homepage
rows, and a description of a scoring feature that is **startlingly close to one of your three
canonical queries.** Stick with it.

## The setup

**Ranker** is described as one of Netflix's largest and most complex services. Among other things,
it powers the personalized rows on the homepage. It runs at enormous scale.

When engineers profiled it — measuring where the CPU time actually goes — one calculation stood out
as unusually expensive. It answers this question:

> **How different is this new title from what you've been watching?**

That's called **serendipity scoring**, and it was eating about **7.5% of all CPU** on every machine
running the service.

Sit with that number. A single scoring feature, one input among many, consuming roughly a
thirteenth of the total computing power of one of Netflix's biggest services. That's the scale at
which a small inefficiency becomes a budget line item.

## What serendipity scoring actually does — and why it matters to you

Here's the mechanism in plain terms.

Every title is represented as an **embedding** — a list of numbers capturing what that title is
like. Titles that are similar in tone, subject, and feel end up with similar numbers. Your viewing
history is a collection of such embeddings.

To score a candidate title:
1. Compare it against every title in your history, measuring similarity.
2. Find the **highest** similarity — the thing in your history it most resembles.
3. Flip that around into a **novelty** score. Very similar to something you've watched → low
   novelty. Unlike anything you've watched → high novelty.

That novelty number is then fed as an input into the recommendation logic.

**Why this matters for your proposal:** one of your three canonical queries is *"a drama movie I
haven't seen before."* Netflix is already computing, for every candidate title, a number
representing how different it is from your viewing history — and it considers that number important
enough to spend 7.5% of a major service's CPU on.

The machinery for "give me something genuinely new to me" exists. It's a ranking input, not
something a member can ask for. But it exists.

## The optimization story

The original approach was simple and readable: for each candidate title, loop through every item in
the history, compute similarity one pair at a time, keep the biggest. If you have M candidates and
N history items, that's M×N separate small calculations.

Easy to understand, and at Netflix's scale, wasteful — lots of sequential work, repeated lookups,
and memory accessed in a scattered pattern that defeats the CPU's caching.

### An interesting detour about traffic shape

While investigating, they measured what requests actually look like, and found something
counterintuitive.

About **98% of requests involve a single title.** Only about **2% are large batches.**

But those batches are *so* large that when you count total titles processed, it's roughly **50:50**
between the two.

The conclusion: optimizing for batches was worth doing even though it wouldn't help the typical
request at all. Half the actual work lives in 2% of the requests.

That's a nice lesson in measuring the right thing. Optimizing for the median request would have
addressed half the workload.

### Step 1: Think in matrices, not loops

Rather than many small comparisons, treat it as one big mathematical operation: stack all candidate
embeddings into one grid, all history embeddings into another, and multiply. Out comes every
pairwise similarity at once.

This is exactly the shape of computation processors are built to do fast.

### Step 2: It got *slower*

They deployed it and saw roughly a **5% performance regression.**

The math was sound. The implementation was working against them in three ways:

- Building fresh grids for every batch created large short-lived allocations, which pressures
  Java's garbage collector.
- The nested-array structure they used isn't stored as one continuous block of memory. The
  processor has to chase pointers around, defeating the cache.
- Their first matrix multiply was written straightforwardly, so it didn't use the CPU's special
  parallel-math hardware at all.

They paid all the costs of restructuring and captured none of the benefits.

The stated lesson is worth generalizing: **a better algorithm doesn't help if memory layout,
allocation, and the actual compute kernel are working against you.**

### Step 3: Fix the memory

Two changes. First, store everything in one long continuous block of memory instead of a structure
of separate pieces — so the processor reads predictably instead of jumping around.

Second, **reuse the workspace.** Instead of allocating fresh scratch space per request, each thread
keeps its own buffers and reuses them, growing when needed and never shrinking. No per-request
allocation, and because each thread has its own, no contention between them.

This alone made things far more predictable.

### Step 4: The obvious library didn't work

The standard answer for fast matrix math is a well-known family of numerical libraries. In isolated
benchmarks it looked promising. In the real system, the gains evaporated.

Three reasons: the default setup wasn't actually using the fast native implementation; calling out
from Java into native code carries per-call overhead; and Java stores grids in the opposite
orientation from what those libraries expect, forcing conversions and temporary copies.

They kept it as a diagnostic rather than a solution. What they needed was something that stayed in
pure Java, matched their memory layout, and still used the CPU's parallel-math hardware.

### Step 5: SIMD in pure Java

Modern processors can perform the same operation on several numbers **simultaneously** — a
capability called SIMD (single instruction, multiple data). Instead of multiplying one pair of
numbers, multiply four or eight pairs in one instruction.

Java has an experimental **Vector API** that lets you write this kind of parallel math in normal
Java code. The runtime maps it to whatever parallel instructions the actual machine supports, and
falls back to ordinary code where it doesn't.

That was the right fit: no calling out to native code, no platform-specific assembly, and it worked
naturally with the continuous memory layout they'd already built.

Because the feature is still experimental and requires a special startup flag, they made it
optional by design. At startup the system checks whether the fast path is available and uses it if
so; otherwise it uses a carefully hand-tuned ordinary implementation. Performance is opt-in;
correctness never is.

## The results

- **~7% lower CPU** usage overall
- **~12% lower average latency**
- **~10% better CPU-per-request**, meaning the same traffic on about 10% less hardware
- The specific hotspot dropped from **7.5% of CPU to roughly 1%**

The closing point is that this wasn't about finding a magic library. It was about getting
fundamentals right — the right shape of computation, memory the processor can read efficiently, and
no overhead eating the theoretical gains. Only once those were in place did the fancy tool help.

They also note the final version was **less code** than what it replaced, and easier to read.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Ranker** | The Netflix service that produces the personalized homepage rows. Very large. |
| **Serendipity / novelty scoring** | How unlike your viewing history a candidate title is. |
| **Embedding** | A list of numbers representing something's characteristics. Similar things, similar numbers. |
| **Cosine similarity** | A standard way to measure how alike two embeddings are. |
| **CPU profiling / flamegraph** | Measuring and visualizing where a program spends its time. |
| **Cache locality** | Whether memory is read in a predictable nearby pattern. Hugely affects speed. |
| **Garbage collection** | Java automatically reclaiming unused memory. Frequent allocation makes it work harder. |
| **SIMD** | One instruction operating on multiple numbers at once. |
| **Vector API** | Java's way of writing SIMD code portably. |
| **Fused multiply-add** | Multiply and add in a single hardware step. The core operation here. |
| **JNI** | Java's bridge to native code. Fast code, but each crossing costs. |
| **Canary** | Trying a change on a small slice of real production traffic first. |
| **CPU/RPS** | CPU consumed per unit of traffic — a fair comparison metric. |

---

## Notes for the synthesis

- **"Ranker"** is a named, very large Netflix service that powers the personalized homepage rows.
- Netflix already computes a **serendipity / novelty score for every candidate title**: how
  different it is from your viewing history, derived from embedding similarity against your history.
  This is the exact machinery behind *"something I haven't seen before"* — the query no external
  site can answer.
- **Titles and viewing history are represented as embeddings** in a shared space, compared by
  similarity. The semantic comparison layer is production infrastructure.
- **Extreme cost sensitivity, quantified.** One scoring feature at 7.5% of CPU justified a
  multi-stage engineering project. Any proposal adding computation per request must have a cost
  story.
- **Latency is tracked and optimized aggressively** — a 12% average improvement was a headline
  result.
- Request patterns are **highly skewed** (98% single-item, 2% batch, but 50:50 by volume). Netflix
  reasons carefully about traffic shape rather than averages.
- Recurring engineering culture: **measure first, expect the obvious fix to fail, keep a safe
  fallback path.** The first optimization attempt made things worse and they published that.
