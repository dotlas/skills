---
name: unpack
description: Explain an unfamiliar thing plainly and from first principles, structured so the reader sees why it is true. Use when someone is trying to understand something — a dense or jargon-heavy passage, a baffling error, an unfamiliar mechanism, a codebase, or a document — asks to break something down ("walk me through this", "what does this actually mean"), or wants their intent turned into a precise instruction for another agent. Trigger on confusion or a request to understand, not on difficulty alone; technical or long content is not itself a signal.
---
# Unpack — Plain, First-Principles Explanations

* * *

## When To Use

Use this when the user wants to **understand** something — a codebase, a document, a
decision, a process, any unfamiliar mechanism — build intuition, decode an error, or
translate intent into precise instructions for another agent.

- The user may already be an expert elsewhere; they just don’t know *this* thing yet.
- Don’t assume the topic is technical.

* * *

## Procedures

Pick the situation first, then apply the principles below as the craft underneath it.

| Situation | Approach |
| --- | --- |
| **Default** | Read what’s needed, then answer directly; don’t ask for context the source already gives. |
| **Overview requested** | 4–6 sentences: what it’s for, the main pieces, how control/data moves end to end, how it’s validated. Discover this from the source. |
| **Debugging (code)** | Read the error yourself, state what broke in one sentence, explain the mechanism that produced it, give a concrete fix. |
| **Directing another agent (code)** | Translate intent into a precise instruction — name the exact files/tests to attach and the exact change to make, not a vague pointer. |

* * *

## Not The Same Axis As Compression

Compression and this skill operate on different axes and can both run at once — they
don’t compete.

|  | Compression mode (e.g. terse/caveman) | This skill |
| --- | --- | --- |
| Changes | the **phrasing** — same facts, order | the **shape** — order, what’s earned |
| Goal | fewer words | less confusion |

* * *

## Core Principles — Always On

Apply these to every explanation, in roughly this order — it follows the arc of
composing one: find what’s being asked, nail what the thing is, frame the problem it
solves, pitch it to a capable reader, anchor it to the source, then write it lean and
clear.

### 1. Answer What Was Actually Unclear

Before answering, read the recent conversation — that’s what triggered the invocation.
Something there was unclear; the first answer covers *that* specific confusion, not a
general overview of the topic.

- **“Satisfying” means** the thing that was unclear is now clear — not every branch and
  edge case, but not a generic summary either.
- **Go deeper only on the part the user pulls on next.**
- **Don’t close with empty filler** like “let me know if you want more” — stop when the
  confusion’s cleared.

### 2. Pin Down What It Actually Is

The one-line core the rest of the explanation hangs on has to cut cleanly.
A wrong characterization is worse than none — it feels like understanding while sending
the reader confidently wrong.

| The definition is… | …when it |
| --- | --- |
| Too broad | fits things that aren’t the thing |
| Too narrow | excludes real cases |
| Empty | is so loose it says nothing |

> “A trust is a legal arrangement for managing assets” is **too broad** — that also fits
> a will, a power of attorney, an escrow.
> The clean version names the one thing that’s only true of a trust.

Sometimes two or more things in the material overlap so closely they read as one.
The fix isn’t more explanation — it’s pulling them apart and showing *this, not that*.
Name each one, say how they differ — one difference or several — and point out which
applies here.

### 3. Start With The Problem, Support With Analogy

Every mechanism exists because something was awkward, risky, or unclear without it.
Open there — the problem, then the plain explanation of how the mechanism addresses it.

- **Analogy never opens** — state the mechanism first.
- **Analogy only illustrates** — never let it carry what a plain statement could have
  said. An analogy doing a direct explanation’s job is a crutch.
- **One analogy per idea** — needing a second means it’s two ideas; give them their own
  paragraphs.

### 4. Assume Capability, Not Context

The reader is sharp, just not steeped in this specific thing.

- **Adapt to capability, not credentials** — don’t ask about their background.
- **Don’t talk down to a child** — don’t explain what a function or a term is unless
  that’s the actual question.
- **Explain the why** — why the mechanism needs to do what it does; name the underlying
  tool only as the thing that makes it possible.

### 5. Let The Source Anchor The Explanation

Read the code, docs, thread, or data before describing it — but the finished explanation
should read like someone who already knows the answer telling you plainly, not a
research report with a citation on every clause.

- State the fact; **name the source once**, at the end of the point, only if the user
  needs to verify it or hand it to another agent — not woven through every sentence.

### 6. Write Lean And Clear

Goal: reduce cognitive load.
Each sentence sets up the next, so the reader moves forward without backtracking — not
because anything’s simplified, but because the order is right.

- **Open with the answer.**
- **Don’t tour the vocabulary** — define a term in the sentence where it first appears,
  if at all.
- **One idea per paragraph** — if a sentence needs three em-dashes or two “which means”
  clauses, that’s two ideas; split it.
- **Keep language compact** — cut filler, hedges, and adjectives that don’t carry
  information.
- **Prefer the checkable over the taken-on-trust** — “the same call failed the same way
  on two different days” beats “the failure is remarkably stable.”
- **Brevity comes from tighter phrasing, never from dropping a real point** — compress
  the words around an idea, not the idea.
  If shortening loses a step the reader needs, it wasn’t fluff.
- **Match the format to the shape of the content** — a table for comparing things across
  shared dimensions, bullets for genuinely parallel items, prose for connected
  reasoning. Prose is the default; reach for a table or bullets only when the shape calls
  for it. A comparison table is especially sharp when separating things that look alike
  (see *Pin Down What It Actually Is*).

* * *

## Situational Moves

Fire these only when the situation calls for them — not every explanation needs them.

### 7. Narrate Elimination, Don’t List Conclusions

When the question is “why *this*, and not the obvious simpler thing,” walk through each
simpler option in the order it’d be tried, and state plainly why it failed before
landing on what’s left.
Each “doesn’t work” should rest on a reason the reader could check — *why* it can’t
work, in terms they could confirm — so the elimination is earned, not asserted.

> “Coordinates aren’t recoverable; triangulation’s impossible; hence geocoding” lists
> three facts with no thread.
> Walk each option in order and say why it failed — then what’s left is earned, not
> announced.

### 8. Show The Journey When It Helps

When something moves through several steps and the order matters, a tiny flow can do
more work than a paragraph.
Build it from what actually happens, not a template.

```text
idea -> draft -> review -> ship
```
