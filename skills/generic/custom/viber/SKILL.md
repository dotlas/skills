---
name: viber
description: Explain any part of this codebase from first principles. Use for onboarding, mid-task questions, debugging help, or translating user intent into precise agent instructions.
---
# Viber — First-Principles Codebase Explanations

## When To Use

Use this skill when the user wants to understand this codebase, direct another agent,
decode an error, review an implementation, or build intuition about how a part of the
system works. The user may be technical, but they should not have to already know this
repo’s habits, folder layout, variable names, or configuration details.

## Core Principles

### 1. Start With The Story

Every piece of code exists because something was awkward, repetitive, fragile, or
unclear to do directly.
Start there. Explain the little problem the code is solving, then walk through how it
solves it, and only then name the pattern or object if the name helps.

Less helpful: “This module maps an input into a normalized model.”

More helpful: “The raw input is rarely ready to use as-is — fields are nested, renamed,
missing, or mixed with details only the source cares about.
This module is a small translator: it reads the raw input, pulls out the useful pieces,
and returns data in the shape the rest of the system expects.”

Use this rhythm for functions, modules, schemas, jobs, and architecture:

- What was messy, risky, or unclear before this code existed?
- What does the code read, change, check, or write?
- What name does the repo give this idea, if naming it makes the explanation easier?

### 2. Be Clear Before Being Complete

Open with the answer the user came for.
Skip the vocabulary tour unless a term is needed right now, and when it is needed,
explain it in the sentence where it appears.

If a technical word is unavoidable, keep it light: define it in the same breath — “the
cache layer (where computed results are kept so they don’t have to be recomputed)” is
better than making the user pause for a separate glossary.

### 3. Assume Capability, Not Context

Treat the user as sharp, just not necessarily steeped in this repo.
Do not explain what a function or a table is unless that is the actual question.
Explain why this code needs to do what it does, then name the underlying tool only as
the thing that makes it possible.

### 4. Let The Code Anchor The Explanation

Read the relevant files before you describe them.
File paths are useful when they orient the user, but they should not crowd out the
explanation. Mention locations when they answer “where is this?”, reveal who owns the
logic, show a dependency, or help the user give another agent exact instructions.

Before explaining an unfamiliar area, get your bearings from whatever the repo actually
provides — the README, any docs or instruction files, the configuration, and the entry
points — rather than assuming a layout.

### 5. Show The Journey When It Helps

When data or control moves through several steps, a tiny flow can do more work than a
long paragraph. Use one when the order matters, and keep it plain.
For example:

```text
input -> validate -> transform -> persist -> downstream consumers
```

Build the flow from what the code actually does, not from a template.

### 6. Give A Useful First Layer

The first answer should feel satisfying on its own: enough of the mechanism to make the
code less mysterious, not every branch and edge case.
If the user asks a follow-up, go deeper into the part they pulled on.

## Procedures

### Default: Answer The Question

Read the relevant files, then explain directly.
Do not ask for more context if the repo can answer it.

### Onboarding Mode

If the user asks for an overview, give 4-6 dense sentences covering:

- What this project is for and who uses it.
- The main surfaces or directories and what each is responsible for.
- How data or control moves through the system end to end.
- How work is validated (tests, type checks, builds, manual review).

Discover these from the repo itself before describing them, then stop and let the user
choose the next thread.

### Debugging Help

1. Read the error/log/diff yourself when available.
2. State what went wrong in one sentence.
3. Explain the mechanism that produced the failure.
4. Give a concrete fix an agent can apply.

Trace failures to their mechanism rather than guessing: follow the data or call path
from the symptom back to the first place an assumption broke — a wrong value, a wrong
shape, a broken contract between two parts, or a wrong configuration.

### Agent-Directing Help

Translate intent into a precise instruction.
Name the relevant files or docs to attach and the exact change to make.

Good: “Attach the module that’s failing and its test, and ask the agent to reproduce the
failure first, then fix the code or the expectation based on what the reproduction shows
— keeping unrelated changes out of the commit.”

## Rules

- Do not ask about the user’s programming background.
- Do not lead with vocabulary tables.
- Do not use jargon without a short inline definition on first use.
- Do not anchor every sentence to file paths.
- Do not invent file contents; read files before citing them.
- Do not assume a particular language, framework, or architecture — learn the stack from
  the repo before explaining it.
- Do not explain patterns abstractly when the repo has a real implementation to inspect.
- Do not dump all details at once.
- Do not end with empty filler such as “let me know if you want more detail.”
