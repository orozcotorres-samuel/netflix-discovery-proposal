# 03 — Designs

Wireframes, mockups, and interaction flows for the proposed conversational discovery surface.

| Folder | Contents |
|---|---|
| [`wireframes/`](wireframes/) | Low-fidelity structure and layout exploration |
| [`mockups/`](mockups/) | High-fidelity screens in Netflix's existing design language |
| [`flows/`](flows/) | End-to-end interaction flows and state diagrams |

---

## Design principle

**The feature has to feel like Netflix, not like a chatbot bolted onto Netflix.** The recommendation engine already exists and is world-class; this is an *input* problem, not an intelligence problem. Every screen should look like it shipped from the existing design system — same typography, same card treatments, same row behavior — with one new thing: somewhere to say what you're actually in the mood for.

The output of a query is **not a wall of text**. It's the same title cards Netflix already renders, filtered and ordered by an engine that finally received the constraint the viewer had in their head.

---

## The three canonical test queries

Every design should be evaluated against these. They come from real sessions and each stresses a different capability:

| # | Query | What it stresses |
|---|---|---|
| 1 | *"A comedy movie with a bit of action."* | **Blended genre** — two genres with unequal weighting. Existing browse rows force a single-genre choice. |
| 2 | *"A drama movie I haven't seen before."* | **Viewing history as a negative constraint** — the one thing Netflix can do that no third-party site can. |
| 3 | *"A scary show that isn't too scary, with some comedy."* | **Intensity as a dial, not a switch** — a tonal constraint with no equivalent in any existing taxonomy. |

Query 2 is the strategic one. Rotten Tomatoes and IMDb cannot answer it. Netflix can answer it instantly, and it's the strongest argument for why this belongs inside the app rather than as another listicle.

---

## Screens to design

### Entry points
- [ ] **Home row / hero placement** — where does this live so it's discoverable without displacing existing merchandising?
- [ ] **Search bar evolution** — the existing search field accepting natural language rather than title strings
- [ ] **Empty-state prompt** — what it says before the viewer has typed anything (this determines whether they understand what they can ask)

### Core interaction
- [ ] **Input state** — typed and voice; suggested prompts for first-time users
- [ ] **Thinking/loading state** — brief, and it should communicate *what it's considering*
- [ ] **Results state** — title cards with a one-line rationale per pick ("comedy-forward, with a heist plot")
- [ ] **Refinement** — the critical screen. *"Something lighter," "shorter than two hours," "nothing with subtitles."* This is where the 5-search Google loop collapses into one thread.
- [ ] **Empty/no-good-match state** — what happens when the catalog genuinely doesn't have it

### Group viewing
- [ ] **Multi-profile mode** — the original use case: two or more people deciding together, reconciling both viewing histories

### Post-selection
- [ ] **Handoff to playback** — how a pick becomes a press of play with no additional steps

---

## Flows to map

- [ ] Happy path: prompt → results → refine → play
- [ ] Refinement loop: how many turns before the viewer gives up (design target: **under 3**)
- [ ] Group session: two profiles, conflicting preferences, one outcome
- [ ] Fallback: intent understood, catalog can't satisfy it
- [ ] Cold start: a brand-new profile with no viewing history

---

## Before/after framing

The most persuasive single artifact in this section will be a side-by-side:

| Today | With this feature |
|---|---|
| Open Netflix → browse → give up → open Google → search → refine 5× → pick a title → search where it's streaming → return to Netflix → search the title → play | Open Netflix → say what you're in the mood for → refine once → play |

Build that as a flow diagram in [`flows/`](flows/) and reference it from the proposal. It converts the [research data](../01-research/) into a picture in a way a table cannot.

---

## File naming

```
wireframes/01-home-entry-point.png
mockups/01-input-state.png
flows/01-happy-path.png
```

Numbered, lowercase, hyphenated. Add a caption row to the tables above as each lands.
