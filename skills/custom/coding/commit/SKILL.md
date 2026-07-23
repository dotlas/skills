---
name: commit
description: "Commit local changes — inspect the working tree, group into atomic conventional commits, and write messages that match the repo's conventions. Two modes: full (default, careful) and asap (fast). Use when the user has uncommitted changes, asks to commit, or invokes /commit, /commit full, or /commit asap."
---
# Commit

Commit the local changes: review the working tree, group them into atomic commits, and
commit. Runs in one of two modes — **`full`** (default) or **`asap`** — sharing one
process and differing only in how much they slow down for proposals, hooks, and docs.
The [Modes](#modes) table at the end is the at-a-glance summary; the sections below
define the process it summarizes.

## Process

1. Inspect staged and unstaged changes (`git status`, `git diff`, `git diff --cached`).
2. Check the change set against plans (see [Plans](#plans)).
3. Group files into one logical change per commit.
4. Order commits so prerequisites land before dependents: dependency and config changes
   (manifests, lockfiles, tooling) before code that relies on them; shared code before
   its consumers; tests alongside the code they cover.
5. Stage files by name and commit, handling any failing pre-commit hook per the active
   mode (see [Rules](#rules)). In `full`, present the plan first when the grouping is
   non-trivial; `asap` commits directly without proposing.
6. In `full` only, update in-situ subdir documentation where it applies (see
   [Subdir documentation](#subdir-documentation)). `asap` skips this.

## Plans

Before committing, check whether the current change set completes or supersedes any plan
in the repo — tracked **or** untracked.
Plans live in no fixed place or format: a `.plans/` directory, an `agent_plans/` folder,
a top-level `PLAN.md`, or any variant.

- If it does, ask the user with `AskUserQuestion` whether to resolve or delete that
  plan.
- Commit the plan’s final state before deleting it, so it survives in git history; then
  delete it in a later commit if the user chose deletion.
- If no plan matches, proceed silently — do not prompt.

This runs in **both** modes.

## Message format

```text
type(scope): description

[body]

[footer]
```

**Subject** — `type(scope): description`. Common types: `feat`, `fix`, `refactor`,
`perf`, `docs`, `test`, `build`, `chore`, `style`, `ci`, `revert`, `ai`. `ai` is for
agent and AI-tool config — `.agents/`, `CLAUDE.md`, `.cursorrules`,
`.github/copilot-instructions.md`.

**Body — required, in both modes, whenever the commit is a breaking change, a security
fix, a data migration, or a revert of a prior commit.** These must never be
subject-only: a future debugger needs the why and the blast radius.
Elsewhere a body is optional — add one when the change isn’t self-evident from the diff.

**Footer** — for breaking changes and references.
Mark a breaking change either as `type!: description` (a `!` before the colon) or with a
`BREAKING CHANGE: <detail>` footer; for a serious break, use both.

## Conventions

- Keep the description lowercase, imperative, and short.
- Refer to the existing git log for scope conventions.
- Use backticks for scope paths, code symbols, and new source files in the description.

## Subdir documentation

`full` mode only; `asap` skips it entirely.

After the code commits, update the documentation that lives with the changed code — a
subdirectory’s README, knowledge file, or equivalent — when it records behaviour these
changes alter. Both conditions must hold, or skip:

- The repo already has a documentation convention defined at a top level or agent level
  (e.g. a docs policy, or `CLAUDE.md` / `.agents/` guidance describing how subdir docs
  work).
- The changed subdirectory itself has a doc/knowledge/readme capturing behaviour that
  these changes affect.

Work only with what exists — never create a documentation convention where the repo has
none. If an update needs a design judgement that can’t be deduced from the code or the
conversation, ask the user with `AskUserQuestion` rather than guessing.

## Rules

- Never use `git add .` or `git add -A` — stage files by name.
- When a pre-commit hook fails, fix it if the fix is within the same scope of work.
  If it can’t be fixed: `full` stops and asks via `AskUserQuestion`; `asap` bypasses
  with `git commit -n`. Bypass is an `asap`-only exception, not a licence to skip hooks
  in `full`.
- In `full`, present the commit plan before executing when the grouping is non-trivial.
  `asap` skips the proposal and commits directly.

## Safety

- Never run `git push` (or any variant) without explicit sign-off; never force-push.
- Never run destructive commands that discard work — `git reset --hard`,
  `git clean -fd`, `git checkout -- .`. To undo a commit, prefer
  `git reset --soft HEAD~1` and explain what happened.

## Modes

Bare `/commit` runs **`full`**. Both modes run the same Process above and remove
completed plans; they differ only here:

|  | `/commit full` (default) | `/commit asap` |
| --- | --- | --- |
| **Non-trivial grouping** | Propose the plan, then commit on approval. | Commit directly, no proposal. |
| **Failing pre-commit hook** | Fix within scope; if unfixable, stop and ask via `AskUserQuestion`. Never bypass. | Fix within scope; if unfixable, bypass with `git commit -n`. |
| **In-situ subdir docs** | Update where a convention exists. | Skip. |
| **Completed plans** | Remove. | Remove. |
