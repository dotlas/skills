---
name: vercel-env-sync
description: Reconcile Vercel project environment variables against the local `.env.local` and `apps/web/env.ts` schema. Use when the user wants to verify, diff, add, or remove env vars on Vercel so a deploy will boot — or when diagnosing 401 / `[DISPATCH_FAILED]` symptoms that smell like missing secrets. Read-only by default; mutations require explicit user sign-off.
---
# Vercel Env Sync — Skill

You are an **operator agent** for a Vercel project (`<owner>/<vercel-project>`). Your
job is to inspect Vercel’s env-var state via the CLI, compare it to the local source of
truth, and either (a) report a diff, or (b) execute a reviewed set of
`vercel env add/rm` mutations.

If your project keeps a Vercel conventions doc, treat it as the authoritative reference
for *how* Vercel works in this repo, and read it before doing anything non-trivial.
This skill is the **executable playbook**; that doc is the **manual**.

* * *

## 1. SAFETY RULES — READ FIRST

Non-negotiable:

1. **NEVER run `vercel deploy`, `vercel deploy --prod`, `vercel rollback`,
   `vercel alias`, `vercel domains <mut>`, `vercel project rm`, or any deploy / domain /
   project mutation.** Production deploys belong to the GitHub integration on `main`. If
   the user explicitly asks for a deploy, refuse and point them at a `git push`.
2. **NEVER run `vercel link` or `vercel env pull` without first checking
   `git diff apps/web/.env.local`.** Both commands overwrite that file.
   If it’s dirty, back it up (`cp apps/web/.env.local apps/web/.env.local.bak`) and tell
   the user before proceeding.
3. **NEVER run `vercel env rm` without explicit per-variable, per-environment user
   sign-off.** Removal is destructive (no undo, no version history).
   Present the list, wait for the user to type approval naming each var, then execute
   one at a time.
4. **NEVER print secret values to the transcript.** When you must verify a value made it
   into a file, echo `${#VAR}` (length) or the first/last 4 chars only.
   Treat anything in `.env.local` as production-grade credentials.
5. **NEVER set Vercel-injected vars** (`VERCEL_URL`, `VERCEL_PROJECT_PRODUCTION_URL`,
   `VERCEL_ENV`, `VERCEL_GIT_COMMIT_SHA`, `VERCEL_REGION`, …). If you find one set as a
   project env var, flag it as a foot-gun — the dashboard value overrides Vercel’s
   runtime injection and will silently break URL resolution.
6. **NEVER add a `NEXT_PUBLIC_*` mirror of a server-only secret** (`CRON_SECRET`,
   `VERCEL_AUTOMATION_BYPASS_SECRET`, database URLs, API keys).
   These leak to the browser bundle.
7. **Add operations are reversible enough to do without per-var sign-off** *only* when
   (a) the var is declared in `apps/web/env.ts` or `packages/*/keys.ts`, (b) the value
   comes from `.env.local`, and (c) the user has approved the overall plan.
   Otherwise pause for confirmation.
8. **Vercel CLI is not signed-in by default in CI.** If `vercel whoami` fails, stop and
   tell the user — do not try to log in non-interactively.

* * *

## 2. DISCOVERY PHASE — Always start here

Confirm you can talk to the right project before touching anything.
**All `vercel` commands must be detached from stdin (`< /dev/null`) or they hang in
agent shells.**

```bash
# 1. Auth + scope
pnpm exec vercel whoami < /dev/null
pnpm exec vercel teams ls < /dev/null 2>&1 | cat

# 2. Confirm the link is correct (apps/web, not the repo root)
cat apps/web/.vercel/project.json 2>/dev/null || echo "NOT LINKED — run: cd apps/web && pnpm exec vercel link --yes --scope <scope> --project <vercel-project>"

# 3. Project facts
cd apps/web && pnpm exec vercel project inspect <vercel-project> --scope <scope> < /dev/null 2>&1 | cat
```

Expected: scope `<scope>`, project `<vercel-project>`, root directory `apps/web`. If
anything else, **stop** — you are pointed at the wrong project and any mutation will hit
production for a different app.

* * *

## 3. DIFF PHASE — Read-only reconciliation

This is the default mode.
Produce a three-way diff of:

- **Local** — names declared in repo-root `.env.local` (`<repo-root>/.env.local`).
- **Schema** — names declared in `apps/web/env.ts` (server + client) and any
  `packages/*/keys.ts`.
- **Vercel** — names present in `production`, `preview`, `development` per the CLI.

### 3a. Pull the three lists

```bash
# Local names
grep -E '^[A-Z_][A-Z0-9_]*=' <repo-root>/.env.local \
  | sed 's/=.*//' | sort -u > /tmp/local-keys.txt

# Vercel names per environment
cd apps/web
for ENV in production preview development; do
  pnpm exec vercel env ls "$ENV" < /dev/null 2>&1 \
    | awk 'NR>3 && $1 ~ /^[A-Z_][A-Z0-9_]*$/ {print $1}' | sort -u > "/tmp/vercel-$ENV-keys.txt"
done

# Schema names (server + client)
{
  grep -oE '^\s*[A-Z_][A-Z0-9_]*:' apps/web/env.ts | sed 's/[: ]//g'
  find packages -name keys.ts -exec grep -hoE '^\s*[A-Z_][A-Z0-9_]*:' {} \; | sed 's/[: ]//g'
} | sort -u > /tmp/schema-keys.txt
```

### 3b. Compute the four interesting sets

```bash
# (A) In local but missing on Vercel production — likely deploy-breakers
comm -23 /tmp/local-keys.txt /tmp/vercel-production-keys.txt

# (B) On Vercel but not in local — possibly orphaned, or production-only secrets
comm -13 /tmp/local-keys.txt /tmp/vercel-production-keys.txt

# (C) In schema but missing on Vercel production — runtime will throw on boot
comm -23 /tmp/schema-keys.txt /tmp/vercel-production-keys.txt

# (D) On Vercel production but not in schema — dead weight or undeclared
comm -13 /tmp/schema-keys.txt /tmp/vercel-production-keys.txt
```

Repeat (A)/(C) against `preview` and `development` separately — the three environments
diverge intentionally (e.g. `CRON_SECRET` may be production-only).

### 3c. Classify each delta before recommending action

For every name in the diff, answer in your report:

| Question | Where to look | Implication |
| --- | --- | --- |
| Declared in `apps/web/env.ts`? | grep `env.ts` for the name | Required-everywhere if no `.optional()`; build fails without it |
| Declared in any `packages/*/keys.ts`? | grep `packages/*/keys.ts` | Required for the package consumer |
| Mentioned in latest `.changeset/*.md`? | `ls -lt .changeset/*.md \| head -5` then grep | Authoritative environment targeting (prod-only vs prod+preview+dev) |
| Vercel-injected? | Match against `VERCEL_*` block in §1 rule 5 | **DO NOT** set; flag as foot-gun |
| `NEXT_PUBLIC_*`? | Prefix check | Safe to expose; will be inlined into client bundle at build time |
| Sensitive? | `vercel env ls` “Type” column | `pull` returns empty string; can only re-add to “edit” |

A var that’s in `.env.local` but **not declared anywhere in the repo** is dead weight —
recommend removing from `.env.local`, not adding to Vercel.

* * *

## 4. PLAN PHASE — Present before executing

Output the plan as a table the user can scan.
Group by action:

```
ADD to production:
  CRON_SECRET            (declared: env.ts server, sensitive: yes, source: .env.local len=64)
  VERCEL_AUTOMATION_BYPASS_SECRET (declared: env.ts server, sensitive: yes, source: .env.local len=32)

ADD to preview:
  CRON_SECRET            (same value as prod)

REMOVE from production (DESTRUCTIVE — needs sign-off):
  OLD_FEATURE_FLAG             (not declared in schema, last referenced in commit abc1234)

FLAG (do not change without discussion):
  VERCEL_PROJECT_PRODUCTION_URL = http://localhost:3000   ← overrides Vercel injection; almost certainly wrong
```

Wait for the user to approve the plan as a whole before running any `add`, and
**per-variable** before any `rm`.

* * *

## 5. EXECUTE PHASE — Non-interactive CLI gotchas

Three rules for driving the CLI non-interactively that will burn you if forgotten:

1. **Always `< /dev/null`** to detach stdin, otherwise the CLI hangs sniffing for a TTY.
2. **`vercel env add NAME preview` always prompts for `git-branch`**, even with `--yes`.
   Pass an **empty positional** (`""`) to mean “all preview branches”.
3. **Pass values via `--value "$VAL"`, not `echo | vercel`.** The pipe form
   double-consumes stdin when the branch prompt fires and silently creates an empty var.

### 5a. Canonical batch-add pattern

```bash
cd <repo-root> && \
set -a && source .env.local && set +a && \
cd apps/web && \
add() {
  local name="$1" envname="$2" val="$3"
  echo "→ $name [$envname] (len=${#val})"   # length only — never the value
  if [[ "$envname" == "preview" ]]; then
    pnpm exec vercel env add "$name" preview "" --value "$val" --yes < /dev/null 2>&1 | tail -2
  else
    pnpm exec vercel env add "$name" "$envname" --value "$val" --yes < /dev/null 2>&1 | tail -2
  fi
} && \
add CRON_SECRET production "$CRON_SECRET" && \
add CRON_SECRET preview    "$CRON_SECRET" && \
echo DONE
```

`tail -2` keeps each add’s output to `Saving` + the success line so the transcript stays
small.

### 5b. Editing an existing var

There is no in-place edit.
Sequence is:

```bash
pnpm exec vercel env rm NAME production --yes < /dev/null   # ← DESTRUCTIVE, needs sign-off
pnpm exec vercel env add NAME production --value "$VAL" --yes < /dev/null
```

If the var was sensitive, you cannot `pull` the old value first — confirm the new value
is what the user actually wants before removing.

### 5c. Sensitive-flag note

The CLI defaults to **Plain**. To mark a value as sensitive (encrypted at rest,
unreadable via `pull`), set it in the dashboard — this skill does not cover the
sensitive flag because the CLI doesn’t expose it cleanly.
Note in your report which vars *should* be sensitive (anything secret-looking:
`*_SECRET`, `*_KEY`, `*_TOKEN`, database URLs, API keys) and ask the user to flip them
in the dashboard.

* * *

## 6. POST-EXECUTE — Verify & remind redeploy

```bash
# Re-list and confirm names landed in each environment they should
cd apps/web
for ENV in production preview development; do
  echo "=== $ENV ==="
  pnpm exec vercel env ls "$ENV" < /dev/null 2>&1 | grep -E "CRON_SECRET|VERCEL_AUTOMATION_BYPASS_SECRET|<other added names>"
done
```

Then explicitly tell the user: **“Env-var changes only take effect on the next deploy.
Trigger a redeploy by pushing a commit to `main` (production) or your PR branch
(preview).”** Do not run `vercel deploy` yourself (rule §1.1).

* * *

## 7. DIAGNOSTIC SHORTCUTS — When the user reports a symptom

Map common production symptoms to the env-var that’s almost certainly wrong:

| Symptom | First env-var to check |
| --- | --- |
| `[DISPATCH_FAILED] HTTP 401 — <!doctype html>...` (HTML, not JSON) | `VERCEL_AUTOMATION_BYPASS_SECRET` missing on production |
| `[DISPATCH_FAILED] HTTP 401 — {"error":"Unauthorized"}` (our JSON) | `CRON_SECRET` missing or mismatched |
| `[DISPATCH_FAILED] fetch failed [ECONNREFUSED] ... 127.0.0.1:3000` | `NEXT_PUBLIC_APP_URL` missing AND `VERCEL_PROJECT_PRODUCTION_URL` overridden to localhost |
| `[DISPATCH_FAILED] fetch failed [ENOTFOUND]` | `NEXT_PUBLIC_APP_URL` points at a dead domain or wrong subdomain |
| Cron route returns 401 HTML | Same as row 1 — Deployment Protection without bypass secret |
| Cron route returns 404 + `x-middleware-rewrite: /clerk_...` | Not an env issue — route prefix missing from `isPublicRoute` in `packages/auth/middleware.ts` |
| App boots then crashes on first request with Zod validation error | Var declared required (no `.optional()`) in `env.ts` is missing from production |

For each, rule out non-env causes before recommending a fix — several of these symptoms
have non-env causes that look identical.

* * *

## 8. DO / DO NOT — Quick reference

- **DO** detach stdin from every `vercel` command (`< /dev/null`) and pipe through
  `| cat` if you need to see full output.
- **DO** check `git diff apps/web/.env.local` before `vercel link` or `vercel env pull`.
- **DO** echo only `${#VAR}` lengths to confirm secrets — never the value.
- **DO** classify every diff entry against `env.ts` / `keys.ts` / latest changeset
  before recommending action.
- **DO NOT** run any deploy/domain/project/alias mutation.
  Refuse and redirect to `git push`.
- **DO NOT** remove a var without explicit per-variable sign-off.
- **DO NOT** mirror server secrets as `NEXT_PUBLIC_*`.
- **DO NOT** set `VERCEL_*` injected variables in the dashboard.
- **DO NOT** assume preview / development inherit production — every `add` must specify
  the environment explicitly.
- **DO NOT** trust that the user has redeployed; always remind them env changes need a
  fresh build.
