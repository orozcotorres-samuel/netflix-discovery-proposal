# Netflix Engineering — Plain-Language Explanations

Eleven Netflix Technology Blog articles, rewritten as detailed explanations rather than summaries.
Each one covers what problem they faced, how the system works with analogies for the technical
parts, what they found, a jargon decoder, and notes carried forward to the systems synthesis.

**Read the original articles too** — these are companions, not replacements. Links are at the top
of each file.

---

## Reading order

The articles were published across 18 months and build on each other. Chronological order tells the
story better than the order they were collected:

| # | Article | Published | What it establishes |
|---|---|---|---|
| [11](11-foundation-model.md) | **Foundation Model for Personalized Recommendation** | Mar 2025 | The central member-preference model everything else builds on. Start here. |
| [10](10-fm-intent.md) | **FM-Intent** | May 2025 | Predicting *why* a member is here, not just what they'll watch. **Most relevant to this proposal.** |
| [9](09-knowledge-graph.md) | **Entertainment Knowledge Graph** | Nov 2025 | How titles, talent, and companies connect. |
| [8](08-mediafm.md) | **MediaFM** | Feb 2026 | Understanding content by watching it — video, audio, dialogue. 100 tone categories. |
| [7](07-vector-api.md) | **Optimizing with JDK's Vector API** | Mar 2026 | Inside the Ranker service. Novelty scoring, and how much cost matters. |
| [6](06-llm-as-judge.md) | **Evaluating Synopses with LLM-as-a-Judge** | Apr 2026 | Grading generated text at scale. Take fraction and abandonment. |
| [5](05-fast-slow-notifications.md) | **Thinking Fast & Slow for Notifications** | Jun 2026 | Splitting strategy from tactics across two time scales. |
| [4](04-genpage.md) | **GenPage** | Jun 2026 | One model generates the entire homepage. Names the bridge to natural language. |
| [3](03-measuring-impact.md) | **Measuring the Impact of Recommendations** | Jul 2026 | The economics. Exposure vs. selection vs. targeting. |
| [2](02-llm-serving.md) | **In-House LLM Serving** | Jul 2026 | Netflix runs its own LLM stack. Constrained decoding in production. |
| [1](01-genrec.md) | **GenRec** | Jul 2026 | An LLM-native ranker. Names natural-language steering as the door this opens. |

---

## If you only read four

- **[FM-Intent](10-fm-intent.md)** — Netflix modeling the exact thing a member could simply state.
- **[GenPage](04-genpage.md)** — the generation machinery, and the prompt-beats-capacity finding.
- **[MediaFM](08-mediafm.md)** — the tone and genre vocabulary a mood query would resolve against.
- **[Measuring Impact](03-measuring-impact.md)** — how to argue a discovery feature's value rigorously.

---

## Themes that recur across all eleven

1. **Cost and latency decide architecture.** Repeatedly, the more accurate option was rejected as
   too expensive. Any proposal needs a cost story.
2. **Netflix moved from many specialized models to shared foundations.** New capabilities are
   expected to build on existing backbones, not introduce new stacks.
3. **Representation beats raw capacity.** Enriching the prompt beat scaling the model ~5:1;
   contextualizing shots beat adding modalities. *How* information is structured matters more than
   how much there is.
4. **Constrained generation is a solved problem.** Output can be structurally guaranteed valid.
5. **Abandonment is a first-class harm**, negatively weighted in the reward system and tracked as
   its own metric.
6. **Long-horizon value over short-term engagement**, explicitly, in every system that touches
   members.
