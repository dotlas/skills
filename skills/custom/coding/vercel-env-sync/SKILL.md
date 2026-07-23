---
name: vercel-env-sync
description: Reconcile Vercel project environment variables against the local `.env.local` and your app's env schema. Use when the user wants to verify, diff, add, or remove env vars on Vercel so a deploy will boot — or when diagnosing 401 / `[DISPATCH_FAILED]` symptoms that smell like missing secrets. Read-only by default; mutations require explicit user sign-off.
---
# Vercel Env Sync

## Safety

Non-negotiable:

1. **NEVER run `vercel deploy`, `vercel rollback`, `vercel alias`,
   `vercel domains <mut>`, `vercel project rm`, or any deploy / domain / project
   mutation.** Production deploys belong to the GitHub integration on `main`. If the
   user asks for a deploy, refuse and redirect to `git push`.
2. **NEVER run `vercel link` or `vercel env pull` without first checking
   `git diff .env.local`.** Both commands overwrite that file.
   If it’s dirty, back it up (`cp .env.local .env.local.bak`) and tell the user before
   proceeding.
3. **NEVER run `vercel env rm` without explicit per-variable, per-environment user
   sign-off.** Removal is destructive (no undo, no version history).
   Present the list, wait for the user to name each var in their approval, then execute
   one at a time.
4. **NEVER print secret values to the transcript.** Echo `${#VAR}` (length) or
   first/last 4 chars only.
   Treat anything in `.env.local` as production-grade credentials.
5. **NEVER set Vercel-injected vars** (`VERCEL_URL`, `VERCEL_PROJECT_PRODUCTION_URL`,
   `VERCEL_ENV`, `VERCEL_GIT_COMMIT_SHA`, `VERCEL_REGION`, …). If you find one set as a
   project env var, flag it — the dashboard value overrides Vercel’s runtime injection
   and will silently break URL resolution.
6. **NEVER add a `NEXT_PUBLIC_*` mirror of a server-only secret** (`CRON_SECRET`,
   `VERCEL_AUTOMATION_BYPASS_SECRET`, database URLs, API keys).
   These leak to the browser bundle.
7. **Vercel CLI is not signed-in by default in CI.** If `vercel whoami` fails, stop and
   tell the user — do not try to log in non-interactively.

## Discovery

Replace `<your-scope>` and `<your-vercel-project>` with the values in
`<app>/.vercel/project.json`. If your project keeps a Vercel conventions doc, read it
before doing anything non-trivial.
**All `vercel` commands must be detached from stdin (`< /dev/null`) or they hang in
agent shells.**

```bash
# Auth + scope
pnpm exec vercel whoami < /dev/null
pnpm exec vercel teams ls < /dev/null 2>&1 | cat

# Confirm the link is correct
cat <app>/.vercel/project.json 2>/dev/null \
  || echo "NOT LINKED — run: cd <app> && pnpm exec vercel link --yes --scope <your-scope> --project <your-vercel-project>"

# Project facts
cd <app> && pnpm exec vercel project inspect <your-vercel-project> --scope <your-scope> < /dev/null 2>&1 | cat
```

Expected: scope `<your-scope>`, project `<your-vercel-project>`, root directory `<app>`.
If anything else, **stop** — you are pointed at the wrong project and any mutation will
hit production for a different app.

## Diff

This is the default mode.
Produce a three-way diff of:

- **Local** — names declared in repo-root `.env.local`.
- **Schema** — names declared in `<app>/env.ts` (server + client) and any
  `<packages>/*/keys.ts`.
- **Vercel** — names present in `production`, `preview`, `development` per the CLI.

### Pull the three lists

```bash
# Local names
grep -E '^[A-Z_][A-Z0-9_]*=' <repo-root>/.env.local \
  | sed 's/=.*//' | sort -u > /tmp/local-keys.txt

# Vercel names per environment
cd <app>
for ENV in production preview development; do
  pnpm exec vercel env ls "$ENV" < /dev/null 2>&1 \
    | awk 'NR>3 && $1 ~ /^[A-Z_][A-Z0-9_]*$/ {print $1}' | sort -u > "/tmp/vercel-$ENV-keys.txt"
done

# Schema names
{
  grep -oE '^\s*[A-Z_][A-Z0-9_]*:' <app>/env.ts | sed 's/[: ]//g'
  find <packages> -name keys.ts -exec grep -hoE '^\s*[A-Z_][A-Z0-9_]*:' {} \; | sed 's/[: ]//g'
} | sort -u > /tmp/schema-keys.txt
```

### Compute the delta sets

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
diverge intentionally.

### Classify each delta

For every name in the diff:

| Question | Where to look | Implication |
| --- | --- | --- |
| Declared in `<app>/env.ts`? | grep `env.ts` for the name | Required-everywhere if no `.optional()`; build fails without it |
| Declared in any `<packages>/*/keys.ts`? | grep `<packages>/*/keys.ts` | Required for the package consumer |
| Mentioned in latest changeset? | `ls -lt .changeset/*.md \| head -5` then grep | Authoritative environment targeting (prod-only vs all envs) |
| Vercel-injected? | Match against `VERCEL_*` in Safety rule 5 | **DO NOT** set; flag as foot-gun |
| `NEXT_PUBLIC_*`? | Prefix check | Safe to expose; inlined into client bundle at build time |
| Sensitive? | `vercel env ls` “Type” column | `pull` returns empty string; can only re-add to edit |

A var in `.env.local` but not declared anywhere in the repo is dead weight — recommend
removing from `.env.local`, not adding to Vercel.

## Plan

Output as a table grouped by action.
Add operations for vars declared in schema with values sourced from `.env.local` can
proceed after overall plan approval; `rm` always requires per-variable sign-off.

```
ADD to production:
  CRON_SECRET            (declared: env.ts server, sensitive: yes, source: .env.local len=64)

ADD to preview:
  CRON_SECRET            (same value as prod)

REMOVE from production (DESTRUCTIVE — needs sign-off):
  OLD_FEATURE_FLAG       (not declared in schema, last referenced in commit abc1234)

FLAG (do not change without discussion):
  VERCEL_PROJECT_PRODUCTION_URL = http://localhost:3000   ← overrides Vercel injection; almost certainly wrong
```

Wait for the user to approve the plan before running any `add`, and per-variable before
any `rm`.

## Execute

```bash
cd <repo-root> && \
set -a && source .env.local && set +a && \
cd <app> && \
add() {
  local name="$1" envname="$2" val="$3"
  echo "→ $name [$envname] (len=${#val})"   # length only — never the value
  if [[ "$envname" == "preview" ]]; then
    # preview always prompts for git branch — pass "" to mean "all preview branches"
    pnpm exec vercel env add "$name" preview "" --value "$val" --yes < /dev/null 2>&1 | tail -2
  else
    # use --value to avoid stdin consumption conflicts with the branch prompt
    pnpm exec vercel env add "$name" "$envname" --value "$val" --yes < /dev/null 2>&1 | tail -2
  fi
} && \
add CRON_SECRET production "$CRON_SECRET" && \
add CRON_SECRET preview    "$CRON_SECRET" && \
echo DONE
```

`tail -2` keeps each add’s output to `Saving` + the success line.

### Editing an existing var

There is no in-place edit.
Sequence:

```bash
pnpm exec vercel env rm NAME production --yes < /dev/null   # DESTRUCTIVE — needs sign-off
pnpm exec vercel env add NAME production --value "$VAL" --yes < /dev/null
```

If the var was sensitive, you cannot `pull` the old value first — confirm the new value
before removing.

### Sensitive-flag note

The CLI defaults to **Plain**. To mark a value sensitive (encrypted at rest, unreadable
via `pull`), set it in the dashboard — this skill does not cover the sensitive flag
because the CLI doesn’t expose it cleanly.
Note which vars *should* be sensitive (`*_SECRET`, `*_KEY`, `*_TOKEN`, database URLs,
API keys) and ask the user to flip them in the dashboard.

## Verify

```bash
cd <app>
for ENV in production preview development; do
  echo "=== $ENV ==="
  pnpm exec vercel env ls "$ENV" < /dev/null 2>&1 | grep -E "<added-var-names>"
done
```

Then tell the user: **“Env-var changes only take effect on the next deploy.
Trigger a redeploy by pushing a commit to `main` (production) or your PR branch
(preview).”**

## Diagnostic shortcuts

| Symptom | First env-var to check |
| --- | --- |
| `[DISPATCH_FAILED] HTTP 401 — <!doctype html>...` (HTML, not JSON) | `VERCEL_AUTOMATION_BYPASS_SECRET` missing on production |
| `[DISPATCH_FAILED] HTTP 401 — {"error":"Unauthorized"}` (JSON) | `CRON_SECRET` missing or mismatched |
| `[DISPATCH_FAILED] fetch failed [ECONNREFUSED] ... 127.0.0.1:3000` | `NEXT_PUBLIC_APP_URL` missing AND `VERCEL_PROJECT_PRODUCTION_URL` overridden to localhost |
| `[DISPATCH_FAILED] fetch failed [ENOTFOUND]` | `NEXT_PUBLIC_APP_URL` points at a dead domain or wrong subdomain |
| Cron route returns 401 HTML | Same as row 1 — Deployment Protection without bypass secret |
| Cron route returns 404 + `x-middleware-rewrite` header | Not an env issue — route prefix missing from the public-route allowlist in your auth middleware |
| App boots then crashes on first request with Zod validation error | Var declared required (no `.optional()`) in `env.ts` is missing from production |

For each, rule out non-env causes before recommending a fix — several of these symptoms
have non-env causes that look identical.
