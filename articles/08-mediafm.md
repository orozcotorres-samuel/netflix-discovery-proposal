# Article 8 — MediaFM: The Multimodal AI Foundation for Media Understanding

**Netflix Technology Blog · February 23, 2026**
**Avneesh Saluja, Santiago Castro, Bowei Yan, Ashish Rastogi**
https://netflixtechblog.com/mediafm-the-multimodal-ai-foundation-for-media-understanding-at-netflix-e8c28df82e2d

---

## The one-line version

Every other article so far understands titles by watching **who watches them**. This one builds a
system that understands titles by **actually watching them** — the pictures, the sound, and the
dialogue.

## Why Netflix needs this

Netflix's stated mission is connecting members with stories they'll love. Doing that requires the
machines to genuinely understand what each piece of content *is* — from the biggest blockbuster to
the most obscure documentary. And as new formats arrive (live events, podcasts), that need grows.

The hard part is that entertainment is **long-form**. Understanding a film means grasping things
that unfold across its whole length — how a story builds, how emotion shifts from scene to scene.
You can't understand a movie by looking at one frame any more than you can understand a novel by
reading one sentence.

They make a specific point about **sound**. The audio track isn't decoration; it carries critical
information that pictures alone don't. Music tells you when something has turned tense. A change in
soundscape tells you a new scene has begun. Analyzing only the visuals throws away a whole channel
of meaning.

## The building block: a "shot"

Rather than treating a film as one object or as thousands of disconnected frames, they break it
into **shots** — the continuous segments between camera cuts, found automatically.

A shot is a sensible unit. It's short enough to be about one thing, long enough to have content.

For each shot, they produce three separate descriptions:

- **Video** — what it looks like, produced by an internal model built for understanding video.
- **Audio** — what it sounds like, using an open model from Meta's research lab.
- **Text** — what's being said, from subtitles, closed captions, or audio descriptions, encoded
  with an OpenAI text-embedding model.

Note what that mix says about Netflix's engineering culture: **internal model where they have a
unique advantage, open-source where it's a solved problem, third-party API where it's commodity.**
No dogma about building everything.

Those three descriptions get combined into one 2,304-number description of the shot. That's the
atom of the whole system.

## Reading shots in sequence, not isolation

Here's the crucial design choice. The model doesn't look at shots one at a time. It reads
**sequences of up to 512 consecutive shots** from the same episode or film.

Why this matters: the same shot means different things depending on what surrounds it. Two people
talking quietly is a completely different beat if it follows an explosion versus if it follows a
wedding. Meaning is contextual, and long-form storytelling is built out of that context.

They also inject **title-level information** — synopses and tags — as a special marker at the start
of the sequence, so every shot is interpreted with awareness of what the overall title is. A tense
scene in a comedy is not the same as a tense scene in a horror film.

The architecture is a transformer encoder, the same family of model behind modern AI, arranged so
that every shot can attend to every other shot in the sequence.

## How it learns: fill in the blank

The training method is elegant and requires **no human labeling at all**.

Take a sequence of shots. Randomly hide 20% of them. Ask the model to reconstruct what the hidden
shots were, based purely on the shots around them. Score it on how close its guess is.

That's it. Repeat across tens of millions of shots.

To do this well, a model has to learn how stories actually work — pacing, how scenes connect, what
typically follows what, how tone develops. You can't fill in a missing beat without understanding
the narrative around the gap.

This is **self-supervised learning**: the data labels itself, so you can train on the entire
catalog without anyone annotating anything.

## What the resulting understanding is used for

They test by freezing the model and training tiny task-specific layers on top — a standard way to
check whether a representation captured genuinely useful information.

The tasks are revealing, because they show what Netflix actually wants from content understanding:

- **Ad relevancy** — categorizing clips so ads can be placed appropriately.
- **Clip popularity ranking** — predicting which clip from a show will perform best as promotion.
- **Clip tone** — classifying clips into **100 tone categories**, with examples given as *creepy*,
  *scary*, *humorous*.
- **Clip genre** — classifying into eleven core genres: Action, Anime, Comedy, Documentary, Drama,
  Fantasy, Horror, Kids, Romance, Sci-fi, Thriller.
- **Clip retrieval** — judging whether a clip is a good showcase for its title, against human
  annotator judgments.

**Stop on the tone one.** Netflix maintains a taxonomy of a hundred tone categories, and has a
model that can place content within it from the actual audio and video. Their own examples are
creepy, scary, and humorous.

Your third canonical query is *"a scary show that isn't too scary, with some comedy."* That query
is asking for a point in exactly this space — a blend of tone categories at particular intensities.
The vocabulary for expressing it already exists inside Netflix.

## The results, and the interesting ablation

MediaFM beat every comparison: Netflix's own previous video-only model, Google's multimodal
embeddings, and a specialized commercial video-understanding product. Gains were largest on tasks
requiring **narrative** understanding — the things that depend on context rather than surface
appearance.

Then they asked which of their two ideas actually mattered: combining three modalities, or reading
shots in context?

**Context was the dominant factor.** Adding audio and text helped somewhat, particularly for tone.
But reading shots in sequence was where most of the improvement came from.

One result is genuinely strange and they flag it honestly: for predicting clip popularity,
combining the three modalities *without* context actually made things **worse** than using video
alone. Adding context then improved it substantially. More information, poorly organized, hurt.
Structure mattered more than raw signal.

There's a lesson there that echoes GenPage's finding about prompts: **how information is
represented can matter more than how much of it you have.**

## A design decision worth noticing

In a footnote, they explain why MediaFM outputs **embeddings** — numerical representations — rather
than generated text descriptions.

The reasoning is modularity. Compute the representation once, and every service across Netflix can
consume it. Text descriptions would lock in one interpretation; embeddings stay flexible. They also
note this avoids the architectural fragility that comes from fine-tuning models for each use.

This is a platform-thinking decision, and it recurs throughout these articles: **build a shared
representation once, let many consumers use it.**

## Where it's going

They're exploring whether pretrained multimodal LLMs — models that already understand images,
audio, and text together — could serve as a stronger starting point than assembling separate
encoders themselves.

And they promise a follow-up on embedding **title-level metadata**, which is the natural companion
piece.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Multimodal** | Working with multiple kinds of input at once — here video, audio, and text. |
| **Tri-modal** | Specifically three. |
| **Foundation model** | A large general model trained once, used as a base for many applications. |
| **Shot** | A continuous camera segment between cuts. The atomic unit here. |
| **Embedding** | A list of numbers representing something's characteristics. |
| **Self-supervised learning** | Learning from unlabeled data by hiding part of it and predicting it. |
| **Masked modeling** | The specific technique: hide pieces, predict them. Same idea behind BERT. |
| **Transformer encoder** | A network where every element can attend to every other element. |
| **Contextualization** | Interpreting something in light of what surrounds it. The main win here. |
| **Linear probe** | Freezing a model and training a tiny layer on top to test what it learned. |
| **Cold start** | Recommending something with no viewing history. Content understanding solves this. |
| **Ablation** | Removing one component to measure its contribution. |
| **Timed text** | Subtitles, captions, audio descriptions — text synced to the video. |

---

## Notes for the synthesis

- Netflix has an in-house **tri-modal content understanding model** analyzing video, audio, and
  dialogue across the catalog. It understands what content *is*, independent of who has watched it.
- **A 100-category tone taxonomy exists**, with a model that can classify content into it — Netflix's
  own examples being *creepy*, *scary*, *humorous*. This is the vocabulary a mood-based query would
  need to resolve against.
- **Eleven core genres** are classified at clip level, derived from parent titles.
- Understanding is **contextual across long form** — sequences of up to 512 shots, aware of the
  title's overall identity via a global context token.
- **Context mattered more than adding modalities.** Structure beat raw information volume — an echo
  of GenPage's prompt-versus-capacity finding.
- Output is deliberately **embeddings, not text**, so one representation serves many consumers.
  A platform decision, and a reusable one.
- These embeddings are named as **the backbone for cold start in recommendations** — and connect
  directly to GenPage's "semantic embedding fusion" over synopses, cast, transcripts, genres, and
  video.
- Training is **self-supervised**, so it scales across the catalog without human labeling.
- Netflix mixes **internal models, open-source models, and third-party APIs** without dogma.
