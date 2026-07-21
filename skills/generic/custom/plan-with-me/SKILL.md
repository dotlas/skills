---
name: plan-with-me
description: "Human-in-the-loop collaborative planning for major features that touch multiple surfaces. Unlike autonomous agent planning (where the agent goes off and produces a plan alone), this keeps the human in the decision seat at every fork — asking one design question at a time, providing recommendations, challenging assumptions, verifying feasibility, and only writing the plan after all critical decisions are resolved together. Use for features that span multiple layers, where an agent planning alone would make wrong assumptions."
---
# Plan With Me — Collaborative Multi-Stage Planning

## When to use

The user has a feature idea that:
- Touches multiple surfaces (database, API, AI, UI, infrastructure)
- Has design decisions that require human judgment (tradeoffs, product instinct,
  business context)
- Would produce a wrong or incomplete plan if an agent just went off and built it alone
- Benefits from sequential resolution of dependencies (you can’t decide the retrieval
  strategy before the storage model)

## What this is NOT

- **Not autonomous planning.** An agent planning alone reads the codebase and produces a
  plan. This keeps the human in the loop at every decision point — the plan is
  co-authored.
- **Not a grilling skill.** Grilling challenges an existing plan adversarially.
  This builds a plan from scratch collaboratively, with challenge woven in when
  assumptions need testing.
- **Not implementation.** This produces plans, not code.
  It may run commands to verify feasibility (test an API, check if an extension exists)
  but never writes production code.

## Why this exists (vs letting the agent plan alone)

Coding agents are good at executing plans.
They’re bad at:
- Knowing which tradeoff the human prefers when multiple valid options exist
- Understanding business context that isn’t in the code ("our clients hate X", “this
  platform doesn’t support Y”)
- Judging scope ("is this a v1 requirement or can it be deferred?")
- Catching when a design decision contradicts an unstated constraint

This skill forces every critical fork to pass through the human.
The result is a plan that reflects actual product intent — not the agent’s best guess at
what was meant.

* * *

## Core principles

### 1. Discover the codebase’s conventions before advising

Do NOT assume the codebase has specific conventions, skills, instructions, or patterns.
Instead:
- Look for instruction files, manifests, or convention docs (common locations:
  `.agents/`, `.cursor/`, `docs/`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, root `*.md`
  files)
- Look for existing skills or workflows that might overlap with or inform the feature
  being planned
- Check the package structure, build system, and dependency patterns
- Check for linting/formatting config, test patterns, and CI/CD setup

Use what you find to inform recommendations.
If the repo has no conventions documented, note that and proceed with general best
practices — don’t invent conventions the repo doesn’t have.

### 2. Ground in real examples

When the user provides concrete examples (meeting notes, screenshots, sample data, API
responses), use them to stress-test the emerging design.
“Given this actual input, what would the system produce?
Does our model handle this edge case?”
Real examples expose gaps that abstract discussion misses.

### 3. One decision at a time

Ask design questions sequentially — never dump a list of 10 questions.
Each question should:
- State the specific decision needed
- Present 2-3 concrete options (not open-ended)
- Provide your recommended option with reasoning
- Wait for the user’s answer before proceeding

The order matters: resolve foundational decisions first (data model, storage) before
downstream ones (UX, retrieval logic).
If a later decision depends on an earlier one, make the dependency explicit.

### 4. Verify feasibility

When a design decision depends on technical feasibility (does the database support this
extension? does the API endpoint accept this format?
does the library handle this case?), run a command to verify rather than assuming.
Surface blockers early — not after the plan is written.

### 5. Take notes as decisions accumulate

Maintain a **running decision log** in session memory throughout the conversation.
After every 3-5 decisions, offer to save a snapshot so progress isn’t lost if the
conversation is interrupted.
The notes should capture:
- The decision (what was resolved)
- The options that were considered (for audit trail)
- The reasoning (why this option won)
- Any constraints it imposes on downstream decisions

When referencing an earlier decision, cite it by number: “Since decision #4 locked us
into X, this limits us to Y or Z here.”

### 6. Challenge the user’s assumptions (lightly)

This is collaborative, not adversarial — but still push back when:
- The user’s stated approach has a simpler alternative they may not have considered
- Two of their requirements are in tension with each other
- An existing codebase pattern already solves part of their problem
- The scope is growing beyond what’s implementable in reasonable stages

Frame pushback as options, not objections: “That works, but have you considered X? It
would simplify Y at the cost of Z.”

### 7. Compliance check uses discovered conventions

Don’t hardcode what to check.
After writing the plan, look at whatever conventions the codebase actually has (found in
Phase 0) and verify the plan doesn’t violate them.
Common things to check (if the repo has them):
- Import boundaries or package rules
- Database access patterns
- API/route conventions
- Test requirements
- Naming conventions
- Code organization rules

If the repo has no documented conventions, skip this step — don’t invent violations.

* * *

## Procedure

### Phase 0: Orient

Before engaging on the feature itself:

1. **Discover the repo structure.** List root files, check for monorepo indicators
   (workspace files, multiple apps/packages), identify the tech stack.
2. **Find conventions.** Look for instruction files, architecture docs, contributing
   guides, skill definitions, or any existing “how we do things” documentation.
   Skim the manifest or index if one exists.
3. **Find overlapping patterns.** Search for existing features similar to what’s being
   planned — the repo may already have patterns (staging tables, proposal flows,
   sub-agent systems, queue mechanisms) that the new feature should follow or extend.
4. **Note what you found.** Briefly tell the user: “I see the repo uses X, has
   conventions for Y, and there’s an existing Z pattern we might build on.”
   This grounds the conversation.

### Phase 1: Understand the vision

Listen to the user’s feature description.
Ask clarifying questions only if the core intent is genuinely ambiguous.
Then:

1. Summarize what you understood back to them (2-3 sentences)
2. Decompose the feature into its constituent concerns (data model, retrieval, UX,
   integration points)
3. Identify which concern to resolve first (usually: what’s the shape of the data?)

### Phase 2: Sequential design resolution

For each concern, ask a targeted design question following the “one decision at a time”
principle. After each answer:

- Record the decision (number it)
- Check if it constrains or resolves any downstream questions
- Move to the next unresolved question

**Adapt to user signals:**
- If the user provides real examples → pause and use them to validate the design
- If the user says “you decide” → make the call, state your reasoning, and move on
- If the user wants to defer a decision → note it as deferred, add it to the “open
  questions” list, continue with what’s unblocked
- If the user goes on a tangent → capture the useful information as a note, then
  redirect: “Good context — I’ve noted that.
  Back to the question at hand …”

If a question can be answered by exploring the codebase or running a command, do that
instead of asking the user.

### Phase 3: Write the plan

When all critical decisions are resolved (there will always be minor ones left — that’s
fine), write the implementation plan:

1. Ask the user where to save the plan files (suggest a sensible default based on repo
   structure)
2. Create a `PLAN.md` with:
   - **Vision** — first-principles, non-technical description of the feature (the why +
     the what, so a coding agent working on one stage understands the broader intent)
   - **Decision log** — numbered, all decisions made during the session
   - **Terminology** — canonical terms defined during the session (if the feature
     introduces new domain concepts)
   - **Key constraints** — rules the implementation must follow
   - **Stage file index** — with dependency order
   - **Open questions** — deferred decisions that will need resolving during
     implementation
3. Create one file per implementation stage, ordered by dependency
4. Each stage file should be self-contained enough for a coding agent to execute without
   reading every other stage — include the vision context and relevant decisions inline

### Phase 4: Compliance check

Review the plan against whatever conventions were discovered in Phase 0. Surface and fix
any violations in the plan files.
If no conventions exist, skip this phase.

* * *

## Notes & Session Persistence

### During the session

After every few decisions, save a snapshot to session memory:
```
Decisions locked so far:
1. [decision]
2. [decision]
...
Open questions: [list]
Next to resolve: [topic]
```

This serves two purposes:
- If the conversation is interrupted, the user can resume by saying “continue planning”
  and the agent can read the session notes
- The final plan’s decision log is already written incrementally — Phase 3 just formats
  it

### If the user says “save progress” or “let’s pause”

Write the current state (decisions + open questions + notes) to the plan directory as a
`_session-notes.md` file.
This is a working document, not a final plan — mark it clearly as such.

* * *

## Rules — DO NOT

- DO NOT ask multiple design questions in one message
- DO NOT present options without a recommendation
- DO NOT assume technical feasibility — verify when in doubt
- DO NOT write production code (testing an API endpoint for feasibility is fine;
  implementing the feature is not)
- DO NOT dump all decisions at the end — track them incrementally
- DO NOT produce a monolithic plan file — stage it so agents can work independently
- DO NOT ask the user questions that the codebase already answers
- DO NOT assume the repo has specific conventions — discover them first
- DO NOT hardcode file paths, package names, or patterns from any specific repo into
  this skill
- DO NOT skip Phase 0 (orient) — understanding the repo’s existing patterns prevents bad
  recommendations
