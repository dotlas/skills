---
name: closed-plan
description: Produce a closed-loop, fully deterministic implementation checklist for a software/coding task — from a draft plan, the user's instructions, or the conversation — where every step is executable with zero on-the-fly decisions, no deferred tasks, and no gaps. Design and scope questions only the user can answer are settled with them; codebase, language, structure, and convention details are decided autonomously by inspecting the code. 
---
# Closed Plan

Turn a task into a **closed, deterministic checklist** — a plan that can be executed top
to bottom with no decisions left for execution time.

Treat the plan as a **contract**: everything is agreed up front, and execution only
honours the terms — it never renegotiates.
That means the discovery, code-reading, and judgement all happen now, during planning,
so whoever executes it later (you or another agent) can work mechanically — no fresh
decisions, no second pass over the codebase.

## The two hard guarantees

1. **No open-ended decisions.** Nothing is “decided during execution”, “as appropriate”,
   or “TBD”. Every choice is already made and written into the step.
2. **No gaps or deferrals.** The plan covers the whole task end to end.
   No “handle edge cases later”, no orphaned step whose inputs nothing produces.
   The output/postcondition of step N satisfies the precondition of step N+1.

If you cannot write a step without leaving a decision open, the plan is **not done** —
resolve the decision first (see triage below), then write the step.

## Procedure

### 1. Fix the source and restate the task

Decide what to plan from, then restate it in 1-2 sentences.
Do not start planning until the goal and its source are unambiguous.

- **Plan only what the user actually asked for.** If they invoked with an explicit
  target ("create a /closed-plan to implement X"), plan X — do not fold in unrelated
  things from the conversation.
- **Use the conversation as the source only when prompted** ("based on our
  conversation") or when there is no explicit target.
  Don’t assume the chat history is always the spec.
- **When mining the conversation, ignore what was discarded.** If an idea was raised and
  then rejected, superseded, or abandoned as the discussion veered, it is out of scope —
  plan the *current* conclusion, not the dead branches.
  If it is unclear whether something was settled or dropped, that is a Bucket-A question
  (resolve it with the user, step 3) — never silently plan a discarded idea.

### 2. Triage every open question into exactly one bucket

Each open question is a contract term, and it belongs to exactly one party — the user
sets it, or you settle it from the code.
Never leave a term unassigned.

| Bucket | What it is | How to resolve |
| --- | --- | --- |
| **A — Design / problem** | What the thing should *do* or *be*: requirements, scope, business rules, data semantics, UX behaviour, acceptance criteria, tradeoffs only the user can judge. | **Do NOT guess.** Put these to the user (step 3) until every Bucket-A question is resolved. |
| **B — Implementation** | *How* to build it within this codebase: file/module layout, naming, language idioms, existing conventions, reuse of helpers, library choices the repo already implies. | **Do NOT ask the user.** Read the codebase, follow its conventions, and decide. Plan a modular, reusable, neat implementation. |

When unsure which bucket a question is in: if a competent engineer who knows this
codebase could answer it correctly without the user, it is Bucket B. Otherwise it is
Bucket A.

### 3. Resolve Bucket A with the user

If any Bucket-A question exists, put it to the user with AskUserQuestion — each question
carrying a recommended answer — and do not proceed to step 5 until all are resolved.
If there are zero Bucket-A questions, skip this — do not invent questions to ask.

### 4. Resolve Bucket B autonomously

Explore the relevant code: directory structure, neighbouring modules, naming and import
conventions, existing utilities to reuse.
Note which plan directory the project uses (`.plan/`, `.plans/`, `plans/`) — fall back
to `.plan/` if none exists. Plans will be saved there.
Make each implementation decision and bake it into the plan.
Never surface these to the user as questions.

### 5. Write the closed checklist

Output a numbered (or `- [ ]`) checklist where **every** item:
- Names the concrete file/function/symbol it touches and the exact change.
- Has a clear precondition (what must exist before it) and postcondition (what it
  produces).
- Contains no decision verbs deferred to later — see the banned list below.
- Is ordered so dependencies come first; no forward references to things not yet
  created.

End with a short **Done-when** section — the contract’s acceptance clause: the
objective, checkable conditions that mean the whole task is complete (tests pass,
command runs, output matches).
This closes the loop.

## Banned in the output

Reject your own draft if any step contains: “TBD”, “decide later”, “as needed / as
appropriate”, “figure out”, “handle edge cases” (name them instead), “etc.”, “and so
on”, “if necessary”, “something like”, or any unresolved either/or.
Each of these is an open decision that must be resolved before the plan is finished.

## Output rules

- This skill produces a **plan only** — no production code.
  Reading code and running read-only commands to settle Bucket-B decisions is expected;
  writing the implementation is not.
- After writing the plan to the response, save it to the plan directory detected in
  Step 4. Filename: `YYYY-MM-DD-{topic-slug}.md` (kebab-cased from the task statement).
  Tell the user the path.
- Do not pad the plan with optional or speculative steps.
  Closed means complete, not bloated.
