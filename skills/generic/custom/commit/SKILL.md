---
name: commit
description: Group related changes into atomic commits and write commit messages that match this repo's conventions. Use when the user has uncommitted changes to commit, asks to commit their work, or wants a commit plan for a messy working tree.
---
# Commit

Review the working tree, propose atomic commit groupings, then commit once the grouping
is approved.

## Process

1. Inspect staged and unstaged changes (`git status`, `git diff`, `git diff --cached`).
2. Check the change set against plans (see [Plans](#plans)).
3. Group files into one logical change per commit.
4. Order commits so prerequisites land before dependents: dependency and config changes
   (manifests, lockfiles, tooling) before code that relies on them; shared code before
   its consumers; tests alongside the code they cover.
5. Stage files by name and commit.
   If grouping is non-trivial, present the plan first.

## Plans

Before committing, check whether the current change set completes or supersedes any plan
in the repo — tracked **or** untracked.
Plans live in no fixed place or format: a `.plans/` directory, an `agent_plans/` folder,
a top-level `PLAN.md`, or any similar variant.

- If it does, ask the user with the `AskUserQuestion` tool whether to resolve or delete
  that plan.
- Commit the plan’s final state before deleting it, so it survives in git history; then
  delete it in a later commit if the user chose deletion.
- If no plan matches, proceed silently — do not prompt.

## Message Format

Use `type(scope): description`.

Common types: `feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `style`, `ci`,
`revert`, `ai`.

`ai` is for agent and AI-tool config — `.agents/`, `CLAUDE.md`, `.cursorrules`,
`.github/copilot-instructions.md`.

## Conventions

- Keep the description lowercase, imperative, and short.
- Refer to the existing git log for scope conventions.
- Use backticks for scope paths, code symbols, and new source files in the description.

## Rules

- Never use `git add .` or `git add -A` — stage files by name.
- Do not skip hooks. If a hook fails, fix it when the fix is within the same scope of
  work.
- Present the commit plan before executing when the grouping is non-trivial.

## Safety

- Never run `git push` (or any variant) without explicit sign-off; never force-push.
- Never run destructive commands that discard work — `git reset --hard`,
  `git clean -fd`, `git checkout -- .`. To undo a commit, prefer
  `git reset --soft HEAD~1` and explain what happened.
