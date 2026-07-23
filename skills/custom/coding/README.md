# Coding — Custom

Coding workflows built around Dotlas’s stack — Next.js, Vercel (team account), and our
codebase conventions.
These go beyond the [community coding skills](../../community/README.md#coding) — where
community skills cover general code quality and review patterns, these add
Vercel-account-aware integrations, opinionated commit conventions, and refactor
workflows tuned to how we actually ship.

* * *

### [commit](./commit/)

Group uncommitted changes into atomic conventional commits with repo-matching messages.

**Good for:** end-of-session cleanup before opening a PR; ensuring commit messages
follow conventional format without writing them by hand; splitting a messy working tree
into logical commits.

**Try:** `/commit` for a careful review-then-commit flow, or `/commit asap` to commit
immediately without a review pass.

* * *

### [vercel-logs](./vercel-logs/)

Query and stream Vercel runtime and build logs for the production deployment.

**Good for:** diagnosing a 500 or 401 that appeared in prod; confirming a fix deployed
cleanly; watching a deploy land in real time.
Read-only — never deploys or mutates project state.

**Try:** `/vercel-logs` — the skill connects to the Vercel CLI and surfaces the most
relevant runtime errors from the last deployment.

* * *

### [vercel-env-sync](./vercel-env-sync/)

Reconcile Vercel environment variables against `.env.local` and your app’s env schema.

**Good for:** diagnosing a deploy that boots locally but fails on Vercel; auditing which
secrets are missing before a new environment goes live; keeping `.env.local` in sync
after a teammate adds a new variable.

**Try:** `/vercel-env-sync` — the skill diffs your local env against Vercel’s and flags
anything missing or mismatched.

* * *

### [codebase-integrity](./codebase-integrity/)

Audit for dependency conflicts, loose types, duplicated patterns, and import boundary
violations.

**Good for:** before a major refactor; after merging a large feature branch; catching
drift between what the codebase intends and what it actually does.

**Try:** `/codebase-integrity` — produces a prioritised list of issues with file and
line references.

* * *

### [tidy-next-codebase](./tidy-next-codebase/)

Dead code and duplication audit for Next.js, executed as a gated background workflow.

**Good for:** post-feature cleanup after a large build; reducing bundle size before a
performance sprint; removing the accumulation of one-off experiments that never got
deleted. Pure refactor — no behaviour or UX changes.

**Try:** `/tidy-next-codebase` — the skill audits, proposes a plan, and executes in
gated stages so you review before each batch lands.

* * *

### [ui-consolidation](./ui-consolidation/)

Merge fragmented UI components into canonical shared versions without changing
behaviour.

**Good for:** after a period of fast shipping where similar components were created in
multiple places; preparing a shared component library; reducing the surface area before
a design system migration.

**Try:** `/ui-consolidation` — maps the component tree, identifies duplicates, and
proposes a consolidation plan for review.

* * *

### [import-skill](./import-skill/)

Vendor a third-party skill into this catalog from skills.sh or a GitHub URL.

**Good for:** adding a new community skill to the Dotlas catalog; keeping vendored
skills pinned to a known-good version; importing a skill from a `npx skills add …`
command someone shared.

**Try:** `/import-skill https://skills.sh/vercel-labs/agent-skills/deep-research` or
paste a `npx skills add …` command directly.
