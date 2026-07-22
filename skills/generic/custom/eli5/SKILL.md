---
name: eli5
description: Explain any topic — code or not — from first principles, in plain, analogy-driven language. Not a dumbing-down mode: the reader is sharp, just unfamiliar with this one thing. Use for onboarding, mid-task questions, debugging help, or translating user intent into precise agent instructions.
---
# ELI5 — Plain, First-Principles Explanations

## When To Use

Use this when the user wants to understand something — a codebase, a document, a
decision, a process, any unfamiliar mechanism — build intuition, decode an error, or
translate intent into precise instructions for another agent.
The user may already be an expert elsewhere; they just don’t know this specific thing
yet. Don’t assume the topic is technical.

## Not The Same Axis As Compression

A compression mode (e.g. a terse/caveman-style mode) shortens phrasing you already have
— same facts, same order, fewer words.
This skill changes the *shape* of the explanation instead — what comes first, whether an
analogy carries the weight, whether reasoning is narrated as elimination or listed as
conclusions. Both can be active at once; they don’t compete.

## Core Principles

### 1. Start With The Story, Carried By One Analogy

Every mechanism exists because something was awkward, risky, or unclear without it.
Open there — the problem, not the name.
Then, if the mechanism itself is unintuitive (a sharding key, a fallback chain, a legal
structure), map it to something the reader already has a working model for, and let that
analogy do the explaining.
State it plainly — don’t decorate it.

Less helpful: “`menu_id` is a monotonically-increasing attribute used for adaptive
bisection windowing to circumvent the index’s result-count ceiling.”

More helpful: “Think of the index as a phone book too big to read in one request — the
scraper can only ask for slices, like `entries 0-50,000`, then `50,000-100,000`.
`menu_id` is just the number it slices on.
It has nothing to do with which restaurant is which.”

Same technique, a different domain — less helpful: “A living trust avoids probate by
holding legal title to your assets in the name of the trust.”

More helpful: “When you die without one, a court has to verify your will and approve
each asset transfer by hand — months of delay, public record.
A trust is a container that already owns the assets while you’re alive, so when you die
there’s nothing for the court to transfer — the container just changes hands to whoever
you named.”

One analogy per idea.
Needing a second one is a sign it’s actually two ideas — give them their own paragraphs.

### 2. Narrate Elimination, Don’t List Conclusions

When the question is “why this, and not the obvious simpler thing,” walk through each
simpler option in the order it’d be tried, and state plainly why it failed, before
landing on what’s left.

Less helpful: “Coordinates aren’t recoverable from the API. Triangulation is also
impossible. Hence geocoding.”
— three true facts, no line connecting them.

More helpful: “First option: fetch the coordinate properly — doesn’t work, the API that
returns it refuses to answer for these outlets no matter how it’s asked.
Second option: work it out from data already collected, by triangulating from places
it’s been seen before — doesn’t work either, it’s never been seen anywhere.
That rules out both free options; geocoding the name and neighborhood is what’s left.”

### 3. Write Lean And Clear

Open with the answer.
Don’t tour the vocabulary — define a term in the sentence where it first appears, if at
all. One idea per paragraph: if a sentence needs three em-dashes or two “which means”
clauses to hold together, that’s two ideas — split it.
State what a thing does, not how impressively it does it — “robust,” “seamless,”
“genuinely,” “stable” are usually filler riding on a claim; replace them with the
concrete fact underneath ("the same call failed the same way on two different days"
beats “the failure is remarkably stable”).

### 4. Assume Capability, Not Context

The reader is sharp, just not steeped in this specific thing.
This is not a mode for talking down to a child — don’t explain what a function or a term
is unless that’s the actual question.
Explain why the mechanism needs to do what it does; name the underlying tool only as the
thing that makes it possible.

### 5. Let The Source Anchor The Explanation

Read the code, docs, thread, or data before describing it — but the finished explanation
should read like someone who already knows the answer telling you plainly, not a
research report with a citation on every clause.
State the fact; name the source once, at the end of the point, if the user needs to
verify it or hand it to another agent — not woven through every sentence.

### 6. Show The Journey When It Helps

When something moves through several steps and the order matters, a tiny flow can do
more work than a paragraph:

```text
idea -> draft -> review -> ship
```

Build it from what actually happens, not a template.

### 7. Give A Useful First Layer

The first answer should feel satisfying on its own — enough to make the mechanism less
mysterious, not every branch and edge case.
Go deeper only on the part the user pulls on next.

## Procedures

- **Default** — read what’s needed, then answer directly; don’t ask for context the
  source already gives.
- **Overview requested** — 4-6 sentences: what it’s for, the main pieces, how
  control/data moves end to end, how it’s validated.
  Discover this from the source, don’t assume it.
- **Debugging (code)** — read the error yourself, state what broke in one sentence,
  explain the mechanism that produced it, give a concrete fix.
- **Directing another agent (code)** — translate intent into a precise instruction: name
  the exact files/tests to attach and the exact change to make, not a vague pointer.

## Rules

- Don’t ask about the user’s background — adapt to capability, not credentials.
- Don’t assume the topic is technical, or that a codebase-flavored example is the only
  kind that counts.
- Don’t chain citations inside one sentence ("per X, confirmed by Y, per Z") — state the
  fact, name the source once if needed.
- Don’t lean on adjectives to carry a technical claim.
- Don’t list conclusions when the question is “why not the simpler option” — narrate the
  elimination in order.
- Don’t invent source content — read it before citing it.
- Don’t dump every detail at once, and don’t end with empty filler like “let me know if
  you want more detail.”
