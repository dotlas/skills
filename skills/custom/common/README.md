# Common — Custom

Planning, investigation, and communication skills built around how Dotlas teams work.
These go beyond the [community common skills](../../community/README.md#common) — where
community skills cover general agent utilities, these encode Dotlas-specific workflows:
our planning process, how we write for Slack, and how we hand work off between sessions.

* * *

### [unpack](./unpack/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdG1nZXA4cjJxMWN5dGZmcG0xYzJ0cnZ6aWZydWNzdm5peWJzbmxnNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/WsNbxuFkLi3IuGI9NU/giphy.gif" width="240" />

Explain anything from first principles — plain, structured, grounded in context.

**Good for:** understanding an unfamiliar part of the codebase, a dense PR, a baffling
error message, or any concept where you need the why, not just the what.
Different from community’s teach skill — unpack is reactive (explain this thing) rather
than instructional (teach me this topic).

**Try:** `/unpack` followed by pasting a confusing stack trace, a PR description, or a
section of code.

### [plan-with-me](./plan-with-me/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExa2pnZWkzZ2RubG9iNnkxN2Z2djlscndwNHM3Ym9rOHk5MXptN2ptNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/ZdUGNB3D5Qb6sKKTke/giphy.gif" width="240" />

Co-author a plan with human decisions at every fork, one question at a time.

**Good for:** planning a new feature that spans multiple surfaces (DB, API, UI); any
situation where going off and planning alone would make wrong assumptions about product
intent, business context, or team preferences.

**Try:** `/plan-with-me add multi-tenant support to the billing API` — the skill
resolves one design question at a time, each with a recommendation, before writing a
staged plan.

* * *

### [closed-plan](./closed-plan/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMHUydzlxaDY2cHFsZWE1bWRwM2Zmb2h0OXltN2t5Y2ZuNDV4b3gzbCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/ZbOXZEugwT26awakGe/giphy.gif" width="240" />

Turn a task into a fully deterministic checklist — no deferred decisions, no gaps.

**Good for:** converting a rough idea or plan-with-me output into a step-by-step
execution checklist; handing work to another agent or session that should execute
without any on-the-fly judgment calls.

**Try:** `/closed-plan` after a plan-with-me session, or
`/closed-plan implement the auth middleware rewrite` on its own.

* * *

### [look-into-it](./look-into-it/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZzVxbng1MDVpYnNlMmF0ZTE3MnF5M2p1aWJwa2R6bWg1ejB3dGplaiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/kbtXXtZ7TBpnXH9lTF/giphy.gif" width="240" />

Trace any issue — bug report, anomaly, “why is X happening” — through the codebase to a
root cause.

**Good for:** diagnosing unexpected behaviour, Slack bugs reported by teammates, Vercel
errors that don’t have an obvious source, or any “why is this broken” question.

**Try:** `/look-into-it checkout is throwing a 500 on the third payment attempt` — the
skill reads the relevant code paths and surfaces what’s actually happening.

* * *

### [introspection](./introspection/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNmFxejhoanlxcXZ1bGFoZHVmbDBnMGpvaWVkdHB5Z2g0b2ZocjNsciZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l1KsOGE23suZQeCfm/giphy.gif" width="240" />

Post-task reflection that updates memory and surfaces stale skill or instruction files.

**Good for:** end of a long session; after completing a task that changed how the
codebase or team conventions work; keeping Claude’s memory accurate over time.

**Try:** `/introspection` after any substantive session — the skill reviews what
changed, updates the memory index, and flags any skill files that now contradict current
reality.

* * *

### [slack](./slack/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbXpkdjdpMGNheGc4YmNwZHptcnl5amd6ZWEydTZ0ZmlhZnp3ZHV2YSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/6heBQSjt2IoA8/giphy.gif" width="240" />

Write or digest Slack messages — drafts, updates, and thread summaries.

**Good for:** drafting an announcement or incident update, replying to a thread you’ve
been tagged in, or catching up on a long thread without reading the whole thing.

**Try:** `/slack summarise this thread` (paste the thread) or
`/slack write a message to #product about the API latency incident`.

* * *
