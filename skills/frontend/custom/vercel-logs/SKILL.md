---
name: vercel-logs
description: Query and stream Vercel runtime/build logs for the production deployment via the CLI. Use when diagnosing errors, investigating 500s/401s, confirming a fix deployed cleanly, or watching a deploy land. Read-only — never deploys, rolls back, or mutates project state.
---
# Vercel Logs — Skill

You are a **diagnostics agent** for a Vercel project (`<owner>/<vercel-project>`). Your
job is to pull runtime and build logs from Vercel, parse them, correlate errors to
source code, and report findings to the user.

The authoritative reference for *how* Vercel works in this repo is your project’s Vercel
conventions doc. This skill is the **executable playbook** for log inspection; the
conventions doc is the **manual**.

* * *

## 1. SAFETY RULES

1. **Read-only.** NEVER run `vercel deploy`, `vercel rollback`, `vercel alias`,
   `vercel env add/rm`, `vercel project rm`, or any mutation.
   This skill only reads logs.
2. **NEVER print secrets from log output.** If a log line contains env var values, API
   keys, or tokens, redact before presenting to the user.
3. **Use `--no-branch` always.** The CLI auto-detects the local git branch and silently
   filters to it — this is wrong for production debugging.
   Always pass `--no-branch` or `--environment production` explicitly.
4. **Detach stdin.** Append `< /dev/null` to every `vercel` command.
   Without it the CLI sniffs the TTY and hangs in agent shells.
5. **Bound output.** Always pass `--limit N` (default 20, max 100) unless the user
   explicitly asks for more.
   Pipe through `| head -N` as a safety net for streaming mode.
6. **Do not follow indefinitely.** If using `--follow` (live streaming), run in async
   terminal mode and cap at a reasonable observation window.
   Kill the terminal when done.

* * *

## 2. PREREQUISITES

Before pulling logs, confirm CLI access:

```bash
cd <repo-root>/apps/web
pnpm exec vercel whoami < /dev/null 2>&1
cat .vercel/project.json 2>/dev/null | grep -o '"projectId":"[^"]*"'
```

If `whoami` fails → stop, tell user to run `pnpm exec vercel login`. If
`.vercel/project.json` is missing → run:
```bash
cd apps/web && pnpm exec vercel link --yes --scope <scope> --project <vercel-project>
```

* * *

## 3. QUERY MODES

### 3a. Recent errors (default diagnostic)

The go-to when the user reports “something broke in prod”:

```bash
cd <repo-root>/apps/web && \
pnpm exec vercel logs \
  --no-branch \
  --environment production \
  --level error \
  --since 1h \
  --limit 20 \
  --json \
  --expand \
  --no-follow \
  < /dev/null 2>&1 | grep -E '^[{]' | jq .
```

**Important:** The CLI emits non-JSON preamble lines (`Retrieving project…`,
`Fetching logs...`, summary line).
Always filter with `grep -E '^[{]'` before piping to `jq`. Use `[{]` not `^\{` — zsh
interprets bare braces.

Parse the JSON Lines output.
Each line has:
```jsonc
{
  "id": "...",
  "timestamp": 1779108733174,   // ms epoch
  "level": "error",
  "message": "...",             // top-level summary
  "source": "serverless|edge-middleware|edge-function",
  "domain": "...",
  "requestMethod": "GET|POST",
  "requestPath": "/api/trpc/<router>.<procedure>",
  "responseStatusCode": 500,
  "environment": "production",
  "branch": "main",
  "logs": [                     // nested log lines (with --expand)
    { "level": "error", "message": "..." }
  ]
}
```

### 3b. Filtered by route/status

```bash
# All 500s on a specific route in the last 6 hours
pnpm exec vercel logs \
  --no-branch --environment production \
  --status-code 500 \
  --query "/api/agent/execute" \
  --since 6h --limit 30 --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### 3c. Filtered by search query

```bash
# Find logs mentioning a specific error string
pnpm exec vercel logs \
  --no-branch --environment production \
  --query "DISPATCH_FAILED" \
  --since 24h --limit 20 --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### 3d. Trace a single request

```bash
pnpm exec vercel logs \
  --request-id req_xxxxx \
  --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### 3e. Live streaming (watch a deploy)

Use async terminal mode.
Kill when observation is done.

```bash
# Run in async mode — returns a terminal ID
pnpm exec vercel logs \
  --no-branch --environment production \
  --follow \
  --level error \
  --json \
  < /dev/null 2>&1
```

Check output periodically with `get_terminal_output`. Kill the terminal when done
observing.

### 3f. Build logs for a specific deployment

```bash
# Get the latest production deployment ID
DEPLOY_ID=$(pnpm exec vercel ls <vercel-project> --scope <scope> --prod < /dev/null 2>&1 \
  | awk '/dpl_/ {print $2; exit}')

# Pull build logs
pnpm exec vercel inspect "$DEPLOY_ID" --logs < /dev/null 2>&1 | tail -50
```

* * *

## 4. POST-PROCESSING — Correlate to code

After pulling logs, correlate each error to its source:

1. **Map `requestPath` → route file:**
   - `/api/trpc/*` → `packages/trpc/routers/<router>.ts`
   - `/api/cron/sweep` → `apps/web/app/api/cron/sweep/route.ts`
   - `/api/agent/execute` → `apps/web/app/api/agent/execute/route.ts`
   - `/api/ai/*` → `apps/web/app/api/ai/<name>/route.ts`

2. **Extract the inner error from `message`:**
   - `[tRPC] <router>.<procedure> failed: <error>` → search for the procedure in
     `packages/trpc/routers/`
   - `[DISPATCH_FAILED] HTTP 401 — <!doctype html>` → Deployment Protection gate (see
     your project’s Vercel conventions doc)
   - `[DISPATCH_FAILED] HTTP 401 — {"error":"Unauthorized"}` → Bearer auth mismatch
   - `[DISPATCH_FAILED] fetch failed` → URL resolution failure (check
     `NEXT_PUBLIC_APP_URL`)

3. **Search the codebase** for the error string to find the throw site.

4. **Report to the user** with:
   - Error count and time range
   - Grouped by route/error type
   - Source file + line reference for each unique error
   - Suggested fix or next diagnostic step

* * *

## 5. COMMON RECIPES

### “Is prod healthy right now?”

```bash
cd <repo-root>/apps/web && \
pnpm exec vercel logs \
  --no-branch --environment production \
  --level error \
  --since 30m \
  --limit 50 \
  --json --no-follow \
  < /dev/null 2>&1 | grep -E '^[{]' | jq -s '
    group_by(.requestPath) |
    map({route: .[0].requestPath, count: length, last: (max_by(.timestamp) | .timestamp | . / 1000 | todate)}) |
    sort_by(-.count)
  '
```

### “Did my fix deploy cleanly?”

```bash
cd <repo-root>/apps/web && \
pnpm exec vercel logs \
  --no-branch --environment production \
  --query "<error-string-that-should-be-gone>" \
  --since 10m \
  --limit 5 \
  --json --no-follow \
  < /dev/null 2>&1 | grep -E '^[{]' | jq .
```

Zero results = fix is live.
Results still appearing = either not deployed yet or fix didn’t work.

### “What’s the current deployment?”

```bash
cd <repo-root>/apps/web && \
pnpm exec vercel ls <vercel-project> --scope <scope> --prod < /dev/null 2>&1 | head -5
```

* * *

## 6. RETENTION LIMITS

| Plan | Runtime log retention |
| --- | --- |
| Hobby | 1 hour |
| Pro | 1 day (24h) |
| Pro + Observability Plus | 30 days |
| Enterprise | 3 days |

This assumes the team is on Vercel’s Pro plan.
Logs older than 24h are unavailable unless Observability Plus is enabled.
If the user asks for logs beyond the retention window, tell them it’s not available and
suggest checking external log drains if configured.

* * *

## 7. PRESENTATION FORMAT

When reporting findings to the user:

- Lead with a **one-line health summary** (e.g., “3 distinct errors in the last hour, 47
  total occurrences”).
- **Group by error type**, not chronologically.
  Show count + last seen for each.
- **Link to source files** using workspace-relative markdown links.
- For each error, include the **raw message** (truncated if needed) and the **suggested
  action**.
- If no errors found, say so explicitly — “Production is clean in the last N hours.”
