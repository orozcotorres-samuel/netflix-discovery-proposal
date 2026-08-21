# Article 9 — Unlocking Entertainment Intelligence with Knowledge Graph

**Netflix Technology Blog · November 11, 2025 · Himanshu Singh**
https://netflixtechblog.medium.com/unlocking-entertainment-intelligence-with-knowledge-graph-da4b22090141

---

## The one-line version

Netflix built a giant map of how everything in entertainment connects — titles, actors, directors,
books, characters, production companies — so that questions about relationships between things
become easy to answer.

This is the oldest article in your set (late 2025) and the least AI-focused. It's about **data
architecture**. But it describes a structural asset that a natural-language feature would lean on
heavily.

## The problem with ordinary databases

Most data lives in tables — rows and columns, like an enormous spreadsheet. One table for titles,
another for people, another for companies.

That works fine when your questions match your table structure. It gets painful when your questions
are about **relationships**, especially chains of them.

Consider: *which actors have repeatedly worked with a particular director?* In a table-based
system, you'd fetch films by that director, then fetch cast lists for each, then cross-reference,
then count. Each hop is a separate expensive operation. Now try: *which novels became successful
films?* You need books, adaptations, films, and performance data joined together.

The article's diagnosis is that entertainment data ends up in disconnected silos with rigid
structures, and getting new data into the system is slow.

## The alternative: store the connections

A **knowledge graph** flips the model. Instead of tables, you store facts as simple three-part
statements: *this thing — has this relationship — with that thing.*

- *This film — was directed by — this person.*
- *This person — also directed — that film.*
- *This film — was adapted from — this novel.*

Each statement is tiny. Millions of them together form a network you can walk through. Relationship
questions stop being expensive gymnastics and become simple traversals: start at a director, follow
the "directed" links, follow the "acted in" links, count what repeats.

Crucially, **relationships are stored as first-class things** rather than being inferred by matching
identifiers across tables.

## Three benefits they highlight

**Semantic connectivity.** Questions about how things relate become straightforward instead of
requiring elaborate multi-step queries.

**Conceptual consistency.** Everything is defined against a shared **ontology** — a formal
vocabulary specifying what kinds of things exist and how they can relate. When every team and every
pipeline references the same definitions, "genre" means the same thing everywhere. This kills a
whole category of quiet bugs where two teams use the same word differently.

**Agile evolution.** Entertainment keeps producing new formats — live events, podcasts, games. In a
rigid schema, a new content type means restructuring databases and rewriting interfaces. Here you
extend the vocabulary and start adding facts. They report onboarding a new entity type dropping
from weeks to days.

## What they use it for

Four areas, per the article:

- **Content evaluation** — comparing titles by narrative, theme, or production elements.
- **Market intelligence** — spotting emerging talent and popular genres across regions.
- **Talent insights** — understanding a person's roles, genres, and affiliations.
- **Machine learning** — feeding entity embeddings and structured relationships into models for
  **personalization, search, demand prediction, and recommendations.**

That last one is the connection to everything else in your reading. The knowledge graph isn't
purely an analyst tool — its structured relationships flow into the recommendation and search
models.

## Three architectural details worth knowing

**The ontology comes first.** Before storing anything, they define the blueprint: what kinds of
entities exist, what attributes they have, how they can relate. Everything downstream references
this single definition.

**Facts carry their own paperwork.** Each stored statement carries metadata alongside it — where it
came from, when it was recorded, and a **confidence score** indicating how reliable it is.

That last one is quietly important. Entertainment data comes from wildly varying sources, from
authoritative internal records to scraped web pages. Rather than pretending everything is equally
true, each fact records its own trustworthiness, so consumers can demand high confidence for
critical decisions.

**One store, many views.** The same underlying data can be read at different levels — an individual
episode, or an entire content category — and different teams can get custom views tailored to their
needs, all derived from one source of truth rather than duplicated copies.

## How data gets in

A six-stage pipeline, and the interesting part is how much of it is about **reconciliation**:

1. **Ingest** from the open web, licensed datasets, and Netflix's own metadata.
2. **Map** the incoming data onto the internal vocabulary, aligning different terminologies.
3. **Normalize** formats, units, and naming so everything is uniform.
4. **Match and merge** — recognize that the same film or person appearing in five different sources
   is one entity, not five, and reconcile them.
5. **Curate** — enrich with derived facts, additional relationships, and corrections.
6. **Publish** to downstream consumers via APIs, tools, relational views, and query clients.

Step 4 is the genuinely hard one. Determining that a person named in one dataset is the same person
named slightly differently in another, across millions of records, is the central difficulty of
building any knowledge graph.

## The honest section about what's hard

I appreciate that they included this.

**Nobody wants to query a graph.** Netflix's analysts and data scientists work in SQL and think in
tables. Graph query languages are unfamiliar. Meanwhile plenty of Netflix data legitimately still
lives in relational form, so people constantly need to combine graph data with table data — and
mixing the two formats is awkward and slows analysis down.

Their solution is pragmatic rather than purist: **transform the graph back into tables.** They
materialize relational views of graph data so analysts can work in the environment they already
know, while the graph remains the underlying source of truth.

The lesson generalizes well beyond data architecture: *the technically superior representation
loses to the one people will actually use, so meet users where they are and translate.*

## Where it's going

- **Inference** — automatically deriving new relationships from existing ones rather than only
  storing stated facts.
- **Federated access** — extending unified access across datasets that haven't been modeled into
  the graph.
- **Faster schema evolution** — adapting the vocabulary even more quickly as new needs appear.

---

## Jargon decoder

| Term | What it means |
|---|---|
| **Knowledge graph** | Data stored as entities plus the relationships between them, forming a network. |
| **Entity** | A thing in the graph — a film, person, company, character, book. |
| **Ontology** | The formal blueprint: what kinds of things exist and how they may relate. |
| **RDF triple** | A three-part fact: subject, relationship, object. The atomic unit of storage. |
| **Triple store** | The database holding those facts. |
| **Schema** | The structure data must conform to. Rigid in tables, flexible here. |
| **Provenance** | Where a piece of data came from. Tracked per fact. |
| **Confidence score** | How reliable a fact is judged to be. Attached to each fact. |
| **Match and merge** | Recognizing that records from different sources describe the same entity. |
| **Normalization** | Making formats, units, and names consistent. |
| **ETL** | Extract, Transform, Load — the standard shape of a data pipeline. |
| **Entity embedding** | A numeric representation of an entity derived from its position in the graph. |
| **Federated access** | Querying across multiple systems as if they were one. |

---

## Notes for the synthesis

- Netflix maintains an **Entertainment Knowledge Graph**: a unified network of titles, talent,
  companies, characters, books, and their relationships, built on a shared ontology.
- It explicitly **feeds entity embeddings and structured relationships into models for
  personalization, search, and recommendations** — not just analytics.
- **Relationship questions are cheap** here — who works with whom, what was adapted from what, how
  titles relate by theme or production. The structural layer for queries like *"more from the people
  behind X"* or *"the book version"* already exists.
- Every fact carries **provenance and a confidence score**, so unreliable data can be filtered
  rather than trusted blindly — relevant to any feature that must not state things falsely.
- The **ontology is a shared vocabulary** across teams and pipelines, so entity definitions are
  consistent system-wide.
- **New entity types onboard in days, not weeks** — the structure was built to absorb new content
  formats.
- Practical lesson they learned the hard way: **the elegant representation loses to the familiar
  one**, so they translate graph data back into tables for the people who consume it.
- Sources span **the open web, licensed data, and internal metadata**, reconciled through match and
  merge into single entities.
