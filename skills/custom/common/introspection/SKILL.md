---
name: introspection
description: Post-task reflection — review what happened during a task, update repository memory, and propose instruction/skill file updates when gaps or staleness are found.
---
# Post-Task Introspection

You are a **Self-Improvement Agent**. After completing a task, you review what happened
and determine whether the agent instruction system needs updates.

* * *

## 1. WHEN TO RUN

Run this skill after completing any non-trivial task.
Skip for simple lookups, single-file edits, or conversational responses.

* * *

## 2. REFLECTION CHECKLIST

Work through these questions honestly.
Only flag items where you have **concrete evidence** from the task you just completed.

### Process friction

- [ ] Did I have to read source code to understand something an instruction file claims
  to cover?
- [ ] Did an instruction file say one thing but the codebase did another?
- [ ] Did I make an assumption that turned out wrong because of ambiguous or missing
  instructions?
- [ ] Did I discover a pattern or convention not documented anywhere?

### Instruction health

- [ ] Would a different agent, starting fresh with only these instructions, get stuck
  where I did?
- [ ] Do two instruction files give conflicting guidance on something I encountered?
- [ ] Are any code examples in the instructions using outdated APIs, paths, or patterns?

### What’s worth capturing

Apply these filters before proposing changes:

- Is this a **durable pattern** or a one-off workaround?
- Would this update **prevent a real mistake**, or is it just “nice to know”?
- Can I state the change in **one or two sentences**?

* * *

## 3. OUTPUT FORMAT

If you found issues, present them grouped:

> **Post-task observations:**
> 
> 1. **[Verified/Suspected]:** Description of what you found — cite the instruction
>    file, section, and the code that contradicts or is missing from it.
>    Proposed action.
> 2. …
> 
> Want me to make these changes?

If nothing was stale, missing, or contradictory, say:

> No instruction updates needed from this task.

* * *

## 4. RULES

- **Never silently update** instruction or skill files — always propose and wait for
  approval
- **Only flag issues you actually encountered** during the just-completed task
- **Don’t speculatively audit** instruction files you didn’t use
- **Don’t invent problems** — “no update” is a valid and common outcome
- If the project keeps an index or manifest of its instruction/skill files, update it to
  match any changes you make
- Optionally record durable facts learned during the task in the project’s memory store,
  if one exists
