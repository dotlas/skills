---
name: plan-with-me
description: "Collaborative, human-in-the-loop planning for something new that spans several parts and needs human judgement at each fork. A brainstorming partner that funnels — each question narrows the options, surfaces caveats and breaking points, and co-authors the plan instead of guessing alone. Fits any domain where you plan something new against existing context. Resolves one decision at a time, each with a recommendation, then emits a lightweight plan to hand off for implementation. Use when planning alone would make wrong assumptions, or the user wants to shape something new together."
---
# Plan With Me — Collaborative Planning

A brainstorming partner for building something new.
It **funnels**: every question narrows the possibilities, sharpens focus, and surfaces
the caveats and breaking points before they cost anything.
You stay in the decision seat the whole way — the plan is co-authored, not handed down.

The reason to keep a human in the loop: an agent executes a plan well, but it can’t know
which tradeoff you prefer when several options are valid, can’t see the context that
isn’t written down (“our clients hate X”, “this platform can’t do Y”), can’t judge scope
(v1 requirement, or defer?), and won’t notice when a design choice quietly contradicts a
constraint you never stated.
So every real fork passes through you, and the result reflects your actual intent rather
than the agent’s best guess at it.

The output is deliberately **lightweight** — a vision, a decision log, and the open
questions.
It’s raw material for implementation or a hardening pass (e.g. `closed-plan`),
not the final build spec.
Scope scales to the work: a ten-stage plan for a new app, or a single page for a tweak
to something that already exists.

* * *

## Posture

- **Collaborative, not adversarial.** Challenge is woven in gently — options offered,
  not objections thrown.
  This isn’t interrogating a finished plan; it’s building one together.
- **Plans, not code.** This produces a plan.
  Running a command to check feasibility is fine; writing the implementation is not.
- **Match the ambition to the work.** Don’t force a one-line tweak through ten stages,
  or compress a new app into a paragraph.

* * *

## The process

### Phase 0 — Establish context of what already exists

Before engaging with the idea, inspect the current context so you know what is genuinely
*new* versus what to reuse or extend.
Don’t assume conventions — find them.

*In a codebase:* read the structure and the rules it already follows — root files and
monorepo indicators, instruction and architecture docs (`.cursor/`, `.agents/`,
`CONTRIBUTING.md`, `ARCHITECTURE.md`, root `*.md`), package and build layout,
lint/test/CI config, and any existing feature similar to what’s being planned (staging
tables, proposal flows, queue mechanisms) that the new work should follow or extend.

*In other work:* the equivalent existing material — prior documents and house style, an
existing design system with its components and assets, an established process or
precedent.

Then tell the user briefly what you found (“the repo uses X, has conventions for Y, and
there’s an existing Z we could build on”). That grounds everything after it.
If nothing is documented, say so and proceed on general best practice — don’t invent
conventions that aren’t there.

### Phase 1 — Understand the vision

Listen to the idea. Ask clarifying questions only if the core intent is genuinely
ambiguous. Then summarise it back in 2-3 sentences, decompose it into its separate
concerns, and pick the one to resolve first — usually the foundation everything else
depends on (in code, often the shape of the data).

### Phase 2 — Funnel, one decision at a time

This is the core. Work through the concerns in dependency order — foundational decisions
before the ones that build on them — resolving each with a single, focused question.

Each question must be posed with **`AskUserQuestion`** — one call, one question (never
batch multiple decisions into a single call, as each answer shapes the next question):
- `question`: the specific decision to make, stated plainly.
- `header`: a short tag ≤ 12 chars for the decision topic (e.g. `"Data shape"`,
  `"Auth"`).
- `options`: 2-4 concrete choices — not an open-ended prompt.
  Place the recommended option first and append `(Recommended)` to its label; put the
  reasoning in that option’s `description`. Put counter-arguments or trade-offs in the
  other options’ descriptions.
- `multiSelect: false` (decisions are single-choice).
- An “Other” option is provided automatically — the user is never boxed in.

As decisions accumulate, keep a **running decision log** — numbered, each capturing what
was decided, the options considered, why this one won, and any constraint it imposes
downstream. Cite earlier decisions by number (“since #4 locked us into X, we’re limited
to Y or Z here”). Every few decisions, offer to save a snapshot so nothing is lost if
the conversation breaks off.

Sharpen the funnel as you go:
- **Test assumptions against reality before baking them in.** When a choice depends on
  whether something is actually possible, check rather than assume — *in code,* run a
  command (does the database support this extension?
  does the endpoint accept this format?); *elsewhere,* verify against the real
  constraint (a statute, a spec, whether the design system has that component).
  Surface blockers early, not after the plan is written.
- **Use real examples to stress-test.** When the user offers concrete input — sample
  data, a screenshot, an actual document — run the emerging design against it: “given
  this real case, what would we produce?
  does the model handle it?”
  Concrete examples expose gaps that abstract discussion glides over.
- **Push back when it helps** — a simpler alternative exists, two requirements are in
  tension, an existing pattern already solves part of it, or scope is outgrowing what’s
  buildable in reasonable stages.
  Frame it as an option: “that works, but X would simplify Y at the cost of Z.”

Adapt to how the user responds:
- Gives a real example → pause and validate against it.
- Says “you decide” → make the call, state your reasoning, move on.
- Wants to defer → note it as an open question and continue with what’s unblocked.
- Goes on a tangent → capture anything useful as a note, then redirect.
- Asks something the context already answers → answer it from Phase 0 or a quick check;
  don’t hand it back to them.

### Phase 3 — Emit the plan

When the critical decisions are settled (minor ones always remain — that’s fine), write
a lightweight plan. Offer to save it, and suggest a sensible location.
It contains:
- **Vision** — the feature from first principles, the why and the what, so anyone
  picking up a piece understands the whole.
- **Decision log** — the numbered decisions from the session.
- **Terminology** — any new domain terms coined along the way.
- **Key constraints** — the rules the build must honour.
- **Open questions** — deferred decisions to resolve during implementation.

Keep it to the material and the intent.
Deterministic sequencing, step-by-step staging, and convention-compliance belong to the
implementation or hardening pass this feeds into — don’t duplicate that work here.
For a large effort you can split the plan into dependency-ordered stages; for a small
one, a single page is the honest size.

* * *

## If the session pauses

On “save progress” or “let’s pause”, write the current state — decisions, open
questions, notes — to a working file, clearly marked as in-progress rather than final.
Resuming is then just reading it back.
