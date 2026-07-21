---
name: tidy-next-codebase
description: Audit a Next.js codebase for stale/dead code and duplication, turn the findings into a fully deterministic cleanup plan, then execute it as a gated, sequential background workflow. Pure refactor — no behaviour/UX regressions, no DB/schema changes. Use when the user wants to tidy, clean up, de-duplicate, consolidate, or refactor-audit a Next.js codebase (often after a large change), or invokes /tidy-next-codebase.
---
# Tidy Next Codebase

Audit → deterministic plan → gated execution.
The goal is a codebase with no dead weight and no duplicated definitions, reached
without changing what the app does.

## Invariants (hold for every step and every agent you spawn)

- **Pure refactor.** Preserve all runtime behaviour, UI, UX, and public API. Data-layer
  rewrites must be result-identical (same columns/filters/order).
  The ONLY allowed behaviour change is one the user explicitly approves.
- **No DB/schema changes.**
- **Never commit or push** — leave changes in the working tree for review (unless the
  user says otherwise).
- **Preserve uncommitted WIP.** Read a file’s current content before editing; never
  revert or clobber unrelated changes.
- **Honour the repo’s own conventions.** Read `CLAUDE.md`/`AGENTS.md`/`.cursorrules` and
  any `docs`/instruction files; match its component model, import boundaries, naming,
  and lint rules. Don’t impose conventions it doesn’t use.
- **Verify before acting.** A “duplicate” or “orphan” is a hypothesis until you read
  both sides / grep for importers.
  Discard false positives.

## 1. Orient

- Detect from `package.json` + `turbo.json`/monorepo config: the package manager and the
  **exact** typecheck / lint / test / build commands (record them).
  Detect the data layer (tRPC, REST handlers, server actions), ORM, state library, and
  linter.
- Establish a clean baseline: run the typecheck command and require it **green before
  changing anything**. If it’s red, surface that and stop.
- Map the app: routes & route groups, shared-component locations, data/router files,
  schema & type modules, stores, lib/utils.

## 2. Investigate (parallel, read-only)

Fan out independent read-only agents — one per dimension — each instructed to cite
`file:line` evidence and rate severity + removal risk:

1. **Dead/stale** — files with zero importers (exclude framework entrypoints:
   `page`/`layout`/`route`/`loading`/`error`/`middleware`/etc.), references to deleted
   modules, unused exports/routes, mock or placeholder endpoints with no callers,
   dormant-but-still-wired features, and names left misleading after a move/rename.
2. **Data layer** — duplicate or overlapping procedures/route-handlers/queries; repeated
   query/SQL/filter fragments; validation schemas declared inline that belong in the
   shared schema layer.
3. **UI components** — the same component re-implemented across pages (card/panel
   shells, avatars, toolbars, table wrappers, empty/skeleton states); inline
   subcomponents repeated; hand-rolled equivalents of primitives that already exist.
4. **Helpers / constants / types / schemas** — duplicated formatting/color/number/date
   logic, repeated constants & enums, types that restate inferred ones, overlapping
   schemas.
5. **State** — the same state defined in multiple stores, triplicated derivations,
   shared-persist-key or scoping bugs.
6. **Comments** — commented-out code and edit-narration/debug remnants (e.g. “fixed…”,
   “now we…”) → REMOVE; a contextual comment hiding a real caveat → rewrite to a clean
   `NOTE:`/`TODO:`; leave genuine WHY-comments untouched.

Then read the high-value/high-risk findings yourself to confirm them.
Distinguish **exact** duplicates (extract as-is) from **variations** (need a
parameterised shared module, not a naive merge).

## 3. Resolve scope with the user

Ask, in one batch and with a recommended answer each, ONLY what you cannot decide from
the code:
- **Depth** — which dimensions / risk tiers to include.
- **Behaviour-change tolerance** — fix a latent bug you found (slight behaviour change)
  vs strictly no change.
- **Feature-vs-debris calls only the user knows** — e.g. remove a dormant feature vs
  keep it as scaffolding.

Decide everything else (module naming, placement, sequencing) yourself.

## 4. Write the closed plan

Produce a **fully deterministic checklist** and save it to
`<plans-dir>/tidy-next-codebase/PLAN.md` (reuse the repo’s existing plans location if it
has one). Rules:
- Every step names the concrete file/symbol and the exact change.
  Banned: “TBD”, “as appropriate”, “handle edge cases”, “if needed”, “etc.”
  — resolve the decision first, then write the step.
- Order so each step’s precondition is produced by an earlier step: **deletions →
  comment cleanup → renames/moves → UI consolidation → data-layer consolidation →
  helper/schema consolidation → state → docs → verification.**
- Renames enumerate every import to rewrite.
  Consolidations list every call site.
  Each new shared module gets a path + signature.
- End with a **Done-when** block: typecheck/lint/test/build green + zero-reference greps
  for everything removed + manual parity notes.

## 5. Gate

Summarise the plan (phases, change counts, risk tier, any approved behaviour change) and
ask for **one go-ahead** before executing.
(If the user chose plan-only, stop here.)

## 6. Execute via a background workflow

Launch ONE workflow that runs the plan stage-by-stage:
- **One agent per plan phase** (split oversized phases), run **strictly sequentially** —
  the stages share one working tree and depend on each other, so parallel edits would
  corrupt them. Do **not** use worktree isolation.
- **Plug context into each agent**: a shared PREAMBLE (the invariants above + the exact
  typecheck command + “do not commit” + “preserve WIP file X” + “return only the
  structured status”) **plus** that stage’s specific brief (files + exact changes)
  **plus** a pointer to its phase in `PLAN.md`. No agent reads another’s work — fresh
  context each stage.
- **Gate** each stage on the typecheck command staying green; **halt the whole
  workflow** on the first stage that fails or reports `blocked`.
- **Structured return** per stage:
  `{ stage, filesChanged[], filesDeleted[], typecheckPassed, blocked, blockReason, notes }`.
  Tell agents that conservative deviations (skipping a merge to stay result-identical)
  are allowed and must be reported in `notes`.
- **Final stage**: run lint/test/build + the zero-reference greps and report; treat
  unrelated/pre-existing failures as non-blocking but surface them.

Skeleton:
```js
for (const st of STAGES) {
  phase(st.title)
  const r = await agent(PREAMBLE + st.brief, { label: st.title, phase: st.title, schema: STATUS })
  if (!r || r.blocked || r.typecheckPassed === false) { log('HALT at ' + st.title); return { halted: true, at: st.title, results } }
  results.push(r)
}
return { halted: false, results }
```

## 7. Report

Independently re-verify: run typecheck, run the zero-reference greps, check
`git status`, confirm HEAD is unchanged and the WIP file is still modified.
Then report: what completed, any stage that halted (and why), the conservative
deviations agents made, one-line caveats (incl.
unrelated pre-existing failures), and that all changes are uncommitted for review.
