# Article 10 — FM-Intent: Predicting User Session Intent with Hierarchical Multi-Task Learning

**Netflix Technology Blog · May 21, 2025**
**Sejoon Oh, Moumita Bhattacharya, Yesu Feng, Sudarshan Lamkhede, Ko-Jen Hsiao, Justin Basilico**
https://netflixtechblog.com/fm-intent-predicting-user-session-intent-with-hierarchical-multi-task-learning-94c75e18f4b8

---

## Read this one twice

Of all eleven articles, this is the one that most directly concerns your feature — because it is
Netflix, at length and with real engineering investment, **trying to guess the thing your feature
would simply let members say out loud.**

## The core idea

Most recommendation systems answer one question: *what will this person watch next?*

FM-Intent argues that's the wrong first question. Before you can predict *what*, you should
understand *why they're here right now.*

Are they looking for something new, or continuing a show? In the mood for a comedy or a thriller?
Do they want a two-hour movie or a twenty-minute episode? Something brand new, or something from
the back catalog?

Those aren't preferences about titles. They're **the shape of what this person wants from this
particular session.** And once you know that, the question of which specific title to recommend
gets dramatically easier.

## The four dimensions of intent Netflix models

This list is the single most useful thing in the article, because it's Netflix's own working
definition of what a viewer's intent consists of:

**1. Action type.** Are you **discovering new content** or **continuing something you already
started**? Playing the next episode of a show in progress is a fundamentally different act from
looking for something fresh.

**2. Genre preference.** Which genres you're drawn to in this session. And the article makes a
pointed observation: these **shift significantly between sessions, even for the same person.** You
are not a "comedy person." You're someone who wanted comedy on Tuesday and something bleak on
Thursday.

**3. Movie or show.** A film is one long sitting. A series is a different commitment with a
different rhythm. Which one you want is a real decision, separate from subject matter.

**4. Time since release.** Do you want something brand new, something from the last week or month,
or an evergreen catalog title?

Now hold your three canonical queries up against that list:

> *"A comedy movie with a bit of action."* → genre preference + movie/show type
> *"A drama movie I haven't seen before."* → genre + type + discovery-vs-continue
> *"A scary show that isn't too scary, with some comedy."* → genre blend + show type

**Every one of your example queries decomposes cleanly into dimensions Netflix already models.**
That's not a coincidence — it's because these dimensions are how viewers actually think.

## The sentence that is the whole argument for your feature

The article describes these dimensions as proxies for the underlying intent, which it characterizes
as **often not directly observable, yet crucial for relevant recommendations.**

Read that carefully.

Netflix's own engineers state that what a member actually wants is (a) essential to good
recommendations and (b) **not directly observable.**

It isn't directly observable *because there is nowhere for the member to say it.* The intent exists,
fully formed, in the head of a person sitting on their couch. The system can't see it, so it builds
a transformer model to infer it from behavioral traces.

That inference is impressive engineering. It's also a workaround for a missing input.

## How it works

Three stages, and the ordering is the point.

**Stage 1: Build a rich picture of recent behavior.** Combine everything about each interaction —
categorical facts and numerical measures — into a representation of what this person has been doing.

**Stage 2: Predict the intent.** Run that history through a transformer encoder, which is good at
weighing which past actions matter for understanding the present. Produce predictions along each of
the four intent dimensions.

Then a nice piece of design: rather than treating those four predictions as separate outputs, they
**combine them using attention** into a single unified intent representation — one that reflects
*which dimensions matter most for this particular person right now.* For a viewer mid-series,
continue-vs-discover dominates. For a browser, genre may matter more.

The article notes this representation is valuable for **personalization and explanation** — meaning
it's interpretable enough to justify a recommendation with.

**Stage 3: Predict the title, informed by the intent.** Feed both the behavioral history *and* the
predicted intent into the next-item prediction.

**The hierarchy is the innovation.** Prior approaches bolt an intent prediction onto a
next-item model as a side task — two outputs from one model, learned in parallel, neither informing
the other. FM-Intent makes it sequential: **figure out intent first, then use that answer as an
input to the title question.**

The reason it works is that this mirrors how the decision actually happens. You decide you're in
the mood for a comedy, then you pick one. Not both at once.

## Results

FM-Intent improved next-item prediction accuracy by **7.4%** over the strongest baseline — a
transformer-based model published by Pinterest.

It also beat Netflix's own production foundation model, which predicts next items without modeling
intent. (They're careful to note this comparison used a smaller training set for fairness, and the
real production model trains on much more data.)

Most competing models couldn't even be compared properly, because they either can't predict intent
at all or can't feed intent predictions into their recommendations.

**7.4% from a structural change** — not more data, not a bigger model, just reorganizing the problem
so intent comes first.

## What they found when they grouped people by intent

They clustered members by their intent representations and found ten distinct groups with genuinely
different behavior:

- People who mainly **discover new content** versus people who mainly **continue** things.
- **Genre enthusiasts** — the article names anime and kids' content as examples.
- **Rewatchers** versus casual viewers.

These aren't demographic segments. They're **behavioral modes** — descriptions of how someone uses
Netflix. And a single person can move between them depending on the evening.

## The applications they list

Four, and two of them are worth flagging:

**Personalized UI optimization.** Predicted intent could shape the homepage layout itself —
emphasizing different rows depending on whether someone is in discovery mode, continue-watching
mode, or hunting a specific genre.

So: **Netflix has already considered restructuring the interface around inferred intent.** The idea
that intent should drive presentation, not just ranking, is established.

**Search optimization.** Real-time intent predictions help prioritize search results according to
the current session's intent.

That's the closest thing in these articles to your feature — intent meeting an explicit query
surface. It's just applied to conventional search over titles, rather than to a member describing a
mood.

The other two: intent embeddings as analytics for content decisions, and intent predictions as
input features to other recommendation models.

## The gap this article defines

Put plainly:

- Netflix knows **what** dimensions constitute a member's intent.
- Netflix has built a **model to infer** those dimensions from behavior.
- Netflix has demonstrated that **knowing intent makes recommendations 7.4% better.**
- Netflix has considered **reshaping the UI** around inferred intent.
- Netflix describes intent as **not directly observable.**

Every piece of the intent-driven recommendation system exists — except a way for the member to
simply state the intent they already have.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Intent** | What a user is trying to accomplish right now, as distinct from their general preferences. |
| **Session** | One continuous visit. Intent is a per-session property, not a permanent trait. |
| **Latent** | Present but not directly visible. Must be inferred. |
| **Proxy** | An observable stand-in for something you can't measure directly. |
| **Next-item prediction** | The standard recommendation task: what will they engage with next? |
| **Multi-task learning** | Training one model to do several jobs, so they reinforce each other. |
| **Hierarchical multi-task learning** | Ordering those jobs so one's output feeds the next. The key idea here. |
| **Transformer encoder** | Architecture that weighs which parts of a sequence matter for understanding it. |
| **Attention-based aggregation** | Combining several signals while learning how much each should count. |
| **Embedding** | A numeric representation — here, of a member's current intent. |
| **K-means clustering** | Grouping similar items automatically. Used here to find behavioral segments. |
| **Foundation model (FM)** | Netflix's large shared recommendation model. See article 11. |
| **SOTA** | State of the art — the best published result to beat. |

---

## Notes for the synthesis

- **Netflix models user intent as a first-class concept**, separate from title preference, and
  predicts it per session.
- The four modeled dimensions are **action type (discover vs. continue), genre preference,
  movie-vs-show, and time-since-release.** All three canonical queries decompose into these.
- Netflix's own characterization: intent is **crucial to good recommendations and "often not
  directly observable."** It is unobservable because there is no input for it.
- **Genre preference shifts between sessions for the same member.** Netflix explicitly models mood
  as transient rather than treating people as fixed types.
- **Hierarchy matters: predict intent first, then use it to pick titles.** A structural reordering
  worth 7.4% over the best baseline — more than most modeling improvements.
- The intent representation uses **attention to weigh which dimensions matter most right now**, and
  is described as useful for **explanation** as well as personalization.
- Netflix has already proposed **using intent to reshape the homepage UI** — emphasizing different
  rows for discovery mode vs. continue-watching mode vs. genre hunting.
- Netflix has already proposed **using real-time intent to prioritize search results.**
- Members cluster into **behavioral modes** — discoverers, continuers, genre enthusiasts,
  rewatchers — that a person moves between across sessions.
