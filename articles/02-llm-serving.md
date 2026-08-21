# Article 2 — In-House LLM Serving at Netflix

**Netflix Technology Blog · July 17, 2026 · AI Platform Model Runtime team and Inference team**
https://netflixtechblog.com/in-house-llm-serving-at-netflix-a5a8e799ea2c

---

## The one-sentence version

Almost every company that uses AI models rents them from someone else — you send a request to
OpenAI or Anthropic and get an answer back. Netflix decided to run the entire thing itself, on its
own machines, inside the same production system that already serves everything else. This article
is about the engineering decisions that required, and what broke once real traffic hit.

## Why this is a strange choice, and why they made it

Renting is easier. You don't buy GPUs, you don't babysit servers, you don't get paged at 3am
because a model failed to load.

But renting means your data leaves your building, you pay someone else's margin on every request,
you're stuck with their latency, and you can't modify the model's behavior below the surface.
At Netflix's scale — and with the deeply customized models described in the other articles — those
stop being acceptable trade-offs. So they built the whole stack.

The article is unusually honest about the consequences. Several decisions "revealed their trade-offs
only under production load," which is a polite way of saying: it looked fine on paper and then
real traffic found the cracks.

## The shape of the system

Picture a layered stack.

**At the top: one unified serving system.** Everything member-facing goes through a single
JVM-based system. It handles the whole flow — figuring out which A/B test you're in, generating
candidates, fetching the data the model needs, running the model, cleaning up the output, and
logging every stage. It supports both live real-time requests and pre-computed batch results.

The important structural fact: **this one system fronts everything.** It isn't a separate "AI
department" bolted onto the side. Machine learning lives inside the main production path.

**In the middle: where the model actually runs.** Small models that only need a CPU run right
inside that serving system, avoiding the delay of a network hop. Big models need GPUs, so the
serving system does the prep and cleanup locally but ships the actual computation to a separate
service — the **Model Scoring Service**.

That service is deliberately generic. It runs older-style models, deep learning models, and LLMs
behind one interface. Underneath it, NVIDIA's Triton software manages loading models onto GPUs,
grouping requests together, and scheduling the hardware.

**On top of that: a control plane.** Handles deployments, version tracking, health checks,
automatic scaling, and rolling out across regions. Whoever builds a model packages it up and
describes how it should be deployed; the control plane provisions the GPUs and orchestrates the
upgrade without downtime.

## Four decisions, each constraining the next

The article walks through these in dependency order, which is a nice bit of writing — each choice
narrows the options for the one after it.

### Decision 1: Which engine actually runs the model

An "inference engine" is the software that takes a model and runs it efficiently on a GPU. The
platform originally used **TensorRT-LLM**, NVIDIA's highly optimized option.

By mid-2025 two things changed. Open-source engines had roughly caught up on raw speed, and
Netflix's workload had diversified — they now needed embedding generation, scoring-only inference
for ranking, ordinary text generation, and custom models with unusual logic in the middle.

So they re-tested everything and switched to **vLLM**, notably *not* primarily for speed. They
switched for what they call operational fit:

- It loads custom model designs without a slow compilation step, so experiments move faster.
- It offers hooks to inject custom logic into how text is generated — which turns out to be
  essential later.
- When something breaks, you can actually see inside it.
- Their researchers already used it, so moving work from research into production got cheaper.

That last reason is a systems-thinking point worth noticing: they optimized for the *handoff
between teams*, not just for machine performance.

### Decision 2: How models get packaged

Two ways to wrap a model so the system can run it.

**The manual way:** the author declares exactly what goes in and comes out, frozen into the
package. Precise, but every time the surrounding software updates, someone has to update the
packages to match — or requests fail in production.

**The automatic way:** the package is just a small config file pointing at the model, and the
system works out the input/output details itself at deployment time. Models and platform can then
evolve independently.

The automatic way is the right default. Two things bit them anyway:

**Version mismatches.** The connector between Triton and vLLM is compiled against a specific
version of vLLM. When one updates and the other doesn't, the whole thing refuses to load — the
article gives a real example where a module was removed from vLLM and the connector, still
expecting it, broke entirely. Their fix is to pin compatible versions centrally and stop
individual model authors from overriding them.

**Custom logic still needs the manual path.** Models that need unusual preprocessing or
non-standard execution can't use the automatic packaging. They keep the manual path as an escape
hatch and expect to need it indefinitely.

### Decision 3: How callers talk to it

The design principle here is stated bluntly and is worth quoting to yourself: **LLMs should not be
special snowflakes.** Every model — the simplest old-school one and the largest language model —
is called the same way, so everything around it (client libraries, health checks, deployment
pipelines) is shared rather than duplicated.

But they also added a second door. The interface style OpenAI popularized has become the industry's
common language — nearly every AI tool speaks it. So Netflix exposes an OpenAI-compatible interface
*alongside* their internal one.

The payoff is a smooth path from prototype to production. A team can build against a hosted model,
then swap in Netflix's own fine-tuned version — for better quality, lower latency, lower cost, or to
keep data in-house — with barely any code change.

One bug from this is a good lesson in why "compatible" is a strong claim. A field where callers ask
for strictly formatted output was accepted by the interface but silently dropped before reaching the
engine. Callers who requested clean structured output got malformed output instead, with no error
telling them anything went wrong. They had to patch the code themselves to wire it through properly.

### Decision 4: How new versions roll out

GPU services take a long time to start, and a new model version may expect different inputs than
the old one.

**Red-Black:** bring up the new version alongside the old, health-check it, then shift traffic
gradually while scaling the old one down. If anything fails, roll back instantly. Great — as long
as the interface didn't change. Production exposed the gap: if the new version needs different
inputs, whoever calls it can't update until the new version is live, so during the switchover they
keep sending old-style requests to a new-style model, and those fail.

**Versioned:** keep a fully separate deployment for every version. Multiple versions run at once,
so callers switch on their own schedule while old traffic keeps working. Costs more GPU time during
the overlap.

Their guidance: design models to be version-agnostic so you can use the cheap path, and reserve the
expensive path for genuinely breaking changes.

## Two operational details worth knowing

**Cold starts.** Downloading a huge model from ordinary cloud storage at startup is so slow that
the scheduler gives up before it finishes. So they pre-load models onto a high-speed file system
when the model is first announced, meaning startup reads from fast storage instead of slow storage.

**Metrics that didn't add up.** The engine and the server each report their own health statistics,
and neither knows about the other. Worse, the built-in bridge between them exposed only about 9 of
40-plus available measurements — missing critical ones like how fast tokens are being produced and
how well the cache is working. They wrote a small proxy that merges both into one feed, so existing
dashboards kept working unchanged.

## The deep dive: making the model physically unable to give a bad answer

This is the most interesting section, and the one most relevant to anything user-facing.

**The problem.** Some Netflix workloads need the model's output to follow strict rules — valid
structure, only certain allowed values. The obvious approach is to generate freely, then check
whether the output is valid, then retry if it isn't. That means paying for wasted generations,
adding latency, and still occasionally failing.

**Their approach.** Push the rules *inside* the generation process, so invalid output can't be
produced in the first place.

Here's the mechanic, plainly. A language model generates text one piece at a time, and at each
step it produces a score for every possible next piece. Normally it picks a high-scoring one.
Netflix inserts logic between the scoring and the picking, which zeroes out every option that
would violate the rules. The model literally cannot choose them.

They model each set of rules as a **state machine** — a little tracker that knows where you are in
the output and therefore what's legal next. Different requests can carry different rules.

**Why version one didn't scale.** Functionally it worked. Under load it fell apart. In the older
engine, this filtering ran separately for each request, one after another, on the CPU — and because
of a fundamental limitation in how Python runs, it *couldn't* be parallelized. So the more requests
you batched together, the longer the filtering took, in direct proportion. The GPU was doing its
work efficiently in parallel and then everything sat waiting on the CPU.

The article makes a sharp point about this: the bottleneck was **invisible in single-request
benchmarks**. It only appeared under realistic concurrency. That's a testing lesson well beyond
this specific problem.

**The fix.** A newer engine version let them process the whole batch at once instead of
request-by-request, and they rewrote the hot path in C++ with proper multi-threading to escape the
Python limitation. Filtering time then stayed flat as batch size grew, instead of climbing.

**Then reality found two more edges.** Long inputs get processed in chunks, and the system couldn't
tell whether a request was fully or partially processed — so they added their own tracking. And
under memory pressure the engine can evict a half-finished request and restart it later, which
breaks the assumption that output only ever grows. They detect the shrink and reset the tracker.

## Where they're going next

Four stated investments: compressing the standing instructions sent with every request, more
efficient scheduling, moving that constraint-filtering work onto the GPU instead of the CPU, and
running models at lower numerical precision to fit more in memory and go faster.

Every one of those is a **cost** optimization. That's the theme of the whole article.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Inference** | Running a trained model to get an answer. Training is learning; inference is using. |
| **Inference engine** | Software that runs models efficiently on GPUs. vLLM and TensorRT-LLM are two. |
| **Triton** | NVIDIA software that manages models on GPUs — loading, batching, scheduling. |
| **Control plane** | The management layer: deploys, versions, health checks, scales. |
| **gRPC / HTTP** | Two ways programs talk to each other over a network. |
| **Batching** | Processing many requests together for efficiency. |
| **Logits** | The raw scores a model produces for every possible next token before one is chosen. |
| **Constrained decoding** | Filtering those scores so illegal options can't be picked. Guarantees valid output. |
| **State machine** | A tracker that knows what state you're in and what transitions are legal next. |
| **GIL** | A Python limitation preventing true multi-threading. Why the first version didn't scale. |
| **KV cache** | Memory holding a model's work-in-progress so it doesn't recompute. Scarce and important. |
| **Prefill** | Reading the input. Distinct from decoding, which is writing the output. |
| **Cold start** | The delay when a service starts before it can serve traffic. |
| **Red-Black deploy** | New version alongside old, shift traffic gradually, roll back on failure. |
| **Quantization / lower precision** | Storing numbers less precisely to save memory and gain speed. |

---

## Notes for the synthesis

- Netflix runs **its own complete LLM infrastructure** — not rented APIs. Data stays in-house,
  cost is theirs to optimize, behavior is theirs to modify.
- **One unified serving system fronts all member-facing ML.** LLMs deliberately are not a separate
  silo — same call path, same pipelines, same tooling.
- The serving path already includes **A/B test routing, candidate generation, feature fetching,
  post-processing, and logging** — everything a new feature would need to be experimented on.
- **Constrained decoding at scale is solved and in production.** Netflix can force a model to
  produce only structurally valid, in-vocabulary output. Directly relevant to any feature that
  must return real catalog items or well-formed structured queries.
- They support **both prefill-only scoring and full text generation** on the same platform.
- An **OpenAI-compatible interface exists**, so prototyping against a hosted model and then
  swapping in an internal one is a supported, low-friction path.
- **Cost is the dominant constraint**, stated repeatedly. Every forward-looking investment listed
  is about making inference cheaper.
- Latency is treated as a first-class concern — cold starts, cache warming, batch behavior.
