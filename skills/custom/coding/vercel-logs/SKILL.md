---
name: vercel-logs
description: Query and stream Vercel runtime/build logs for the production deployment via the CLI. Use when diagnosing errors, investigating 500s/401s, confirming a fix deployed cleanly, or watching a deploy land. Read-only — never deploys, rolls back, or mutates project state.
---
# Vercel Logs

## Safety

1. **Read-only.** NEVER run `vercel deploy`, `vercel rollback`, `vercel alias`,
   `vercel env add/rm`, `vercel project rm`, or any mutation.
   This skill only reads logs.
2. **NEVER print secrets from log output.** If a log line contains env var values, API
   keys, or tokens, redact before presenting.
3. **Use `--no-branch` always.** The CLI auto-detects the local git branch and silently
   filters to it — wrong for production debugging.
   Always pass `--no-branch` or `--environment production` explicitly.
4. **Detach stdin.** Append `< /dev/null` to every `vercel` command.
   Without it the CLI sniffs the TTY and hangs in agent shells.
5. **Bound output.** Always pass `--limit N` (default 20, max 100). For `--follow` runs,
   cap the observation window and kill the terminal when done — do not follow
   indefinitely.

## Prerequisites

```bash
cd <repo-root>/<app>
pnpm exec vercel whoami < /dev/null 2>&1
cat .vercel/project.json 2>/dev/null | grep -o '"projectId":"[^"]*"'
```

If `whoami` fails → stop, tell user to run `pnpm exec vercel login`. If
`.vercel/project.json` is missing → run:
```bash
cd <app> && pnpm exec vercel link --yes --scope <your-scope> --project <your-vercel-project>
```

**Retention:** Hobby = 1h · Pro = 24h · Pro + Observability Plus = 30 days · Enterprise
= 3 days. If the user asks for logs beyond the retention window, tell them and suggest
checking external log drains if configured.

## Query modes

### Recent errors (default diagnostic)

The go-to when the user reports “something broke in prod”:

```bash
cd <repo-root>/<app> && \
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

**Important:** The CLI emits non-JSON preamble lines.
Always filter with `grep -E '^[{]'` before piping to `jq`. Use `[{]` not `^\{` — zsh
interprets bare braces.

Each line:
```jsonc
{
  "id": "...",
  "timestamp": 1779108733174,
  "level": "error",
  "message": "...",
  "source": "serverless|edge-middleware|edge-function",
  "requestMethod": "GET|POST",
  "requestPath": "/api/...",
  "responseStatusCode": 500,
  "environment": "production",
  "logs": [{ "level": "error", "message": "..." }]  // with --expand
}
```

### Filtered by route/status

```bash
pnpm exec vercel logs \
  --no-branch --environment production \
  --status-code 500 \
  --query "/api/your-route" \
  --since 6h --limit 30 --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### Filtered by search query

```bash
pnpm exec vercel logs \
  --no-branch --environment production \
  --query "DISPATCH_FAILED" \
  --since 24h --limit 20 --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### Trace a single request

```bash
pnpm exec vercel logs \
  --request-id req_xxxxx \
  --json --expand --no-follow \
  < /dev/null 2>&1 | cat
```

### Live streaming

Use async terminal mode.
Kill when observation is done.

```bash
pnpm exec vercel logs \
  --no-branch --environment production \
  --follow \
  --level error \
  --json \
  < /dev/null 2>&1
```

Check output periodically with `get_terminal_output`. Kill when done observing.

### Build logs

```bash
# Get the latest production deployment ID
DEPLOY_ID=$(pnpm exec vercel ls <your-vercel-project> --scope <your-scope> --prod < /dev/null 2>&1 \
  | awk '/dpl_/ {print $2; exit}')

pnpm exec vercel inspect "$DEPLOY_ID" --logs < /dev/null 2>&1 | tail -50
```

## Correlate to code

After pulling logs:

1. **Map `requestPath` → route file** using your project’s directory structure:
   - `/api/trpc/<router>.<procedure>` → `<trpc-routers>/<router>.ts` (for tRPC projects)
   - `/api/cron/<name>` → `<app>/app/api/cron/<name>/route.ts`
   - Other `/api/*` routes → `<app>/app/api/<name>/route.ts`

   Check your project’s route conventions to establish this mapping before starting.

2. **Extract the inner error from `message`:**
   - `[tRPC] <router>.<procedure> failed: <error>` → search `<trpc-routers>/` for the
     procedure
   - `[DISPATCH_FAILED] HTTP 401 — <!doctype html>` → Deployment Protection gate (check
     Vercel conventions doc)
   - `[DISPATCH_FAILED] HTTP 401 — {"error":"Unauthorized"}` → Bearer auth mismatch
   - `[DISPATCH_FAILED] fetch failed` → URL resolution failure (check
     `NEXT_PUBLIC_APP_URL`)

3. **Search the codebase** for the error string to find the throw site.

4. **Report** with: error count and time range · grouped by route/error type · source
   file + line for each unique error · suggested fix or next diagnostic step.

## Common recipes

### “Is prod healthy right now?”

```bash
cd <repo-root>/<app> && \
pnpm exec vercel logs \
  --no-branch --environment production \
  --level error --since 30m --limit 50 \
  --json --no-follow \
  < /dev/null 2>&1 | grep -E '^[{]' | jq -s '
    group_by(.requestPath) |
    map({route: .[0].requestPath, count: length, last: (max_by(.timestamp) | .timestamp | . / 1000 | todate)}) |
    sort_by(-.count)
  '
```

### “Did my fix deploy cleanly?”

```bash
cd <repo-root>/<app> && \
pnpm exec vercel logs \
  --no-branch --environment production \
  --query "<error-string-that-should-be-gone>" \
  --since 10m --limit 5 \
  --json --no-follow \
  < /dev/null 2>&1 | grep -E '^[{]' | jq .
```

Zero results = fix is live.
Results still appearing = not deployed yet or fix didn’t work.

### “What’s the current deployment?”

```bash
cd <repo-root>/<app> && \
pnpm exec vercel ls <your-vercel-project> --scope <your-scope> --prod < /dev/null 2>&1 | head -5
```
