# Common

Planning, investigation, and communication skills built around how Dotlas teams work.
These go beyond the [community common skills](../../community/README.md#common).
Where community skills cover general agent utilities, these encode Dotlas-specific
workflows: our planning process, how we write for Slack, and how we hand work off
between sessions.

* * *

### [unpack](./unpack/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdG1nZXA4cjJxMWN5dGZmcG0xYzJ0cnZ6aWZydWNzdm5peWJzbmxnNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/WsNbxuFkLi3IuGI9NU/giphy.gif" width="240" />

Explain anything from first principles, plain, structured, and grounded in context.

**Good for:** understanding anything dense or unfamiliar: a contract, a proposal, a
research paper, a system design, a baffling error, or any concept where you need the
why, not just the what.
Different from community’s teach skill: unpack is reactive (explain this thing) rather
than instructional (teach me this topic).

**Try:** `/unpack` followed by pasting anything you need explained: a document, a spec,
a dense paragraph, a diagram description, or a confusing message.

### [plan-with-me](./plan-with-me/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExa2pnZWkzZ2RubG9iNnkxN2Z2djlscndwNHM3Ym9rOHk5MXptN2ptNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/ZdUGNB3D5Qb6sKKTke/giphy.gif" width="240" />

Co-author a plan with human decisions at every fork, one question at a time.

**Good for:** planning anything with real judgment calls: a product launch, a team
initiative, a process change, a system design.
Any situation where going off and planning alone would make wrong assumptions about
intent, context, or priorities.

**Try:** `/plan-with-me redesign our customer onboarding flow`. The skill resolves one
question at a time, each with a recommendation, before writing a staged plan.

### [where-were-we](./where-were-we/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExeGNzMW9jNXZscmZxZmFmdWR2MG1vbDVqNHJrbHNzeWpyNzVkaDB4ZiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/lQ1AkXFktuJsnoqO3A/giphy.gif" width="240" />

Recap where a conversation left off: locked decisions, open questions, and what needs
your attention now.

**Good for:** returning to a long planning or implementation chat after a break; getting
re-oriented before you continue; picking up a handed-off session without re-reading the
whole transcript. It short-circuits on shipped milestones and locked decisions so the
recap surfaces only what still needs you.

**Try:** `/where-were-we` when you come back to a chat and need a skimmable picture of
where things stand, what’s decided, and what’s still open.

* * *

### [closed-plan](./closed-plan/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMHUydzlxaDY2cHFsZWE1bWRwM2Zmb2h0OXltN2t5Y2ZuNDV4b3gzbCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/ZbOXZEugwT26awakGe/giphy.gif" width="240" />

Turn a task into a fully deterministic checklist, with no deferred decisions and no
gaps.

**Good for:** converting a rough idea or plan-with-me output into a step-by-step
execution checklist; handing work to another agent or session that should execute
without any on-the-fly judgment calls.

**Try:** `/closed-plan` after a plan-with-me session, or
`/closed-plan implement the auth middleware rewrite` on its own.

* * *

### [cc-launch-subagents](./cc-launch-subagents/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3NwOWg2Z25tMmw2ZHlxcHQybGdpMGlkMzhpb2ZkbG5leDJ4dm5iNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/9vk7uNCSJaOqI/giphy.gif" width="240" />

Run every step of a session through fresh Sonnet subagents, with you as the orchestrator.

**Good for:** delegating all exploratory and implementation work to atomic, background
subagent tasks so the main conversation stays unblocked; keeping each worker’s context
fresh and tightly scoped; breaking large work into independent units you dispatch and
supervise.

**Try:** `/cc-launch-subagents` at the start of a session where you want to act as
manager while Sonnet workers do the legwork in the background.

### [cc-launch-workflows](./cc-launch-workflows/)

Launch a finished plan as a background workflow of fresh Sonnet workers, with you as the
orchestrator.

**Good for:** executing a completed plan (from plan-with-me or closed-plan) as atomic,
parallelised worker subagents; keeping the planning session unblocked while the work
runs in the background; large multi-step implementations that should not share a single
context.

**Try:** `/cc-launch-workflows` once a plan is agreed, or after `/closed-plan` say “run
this with cc-launch-workflows”.
The skill orchestrates fresh Sonnet workers as a background workflow you can watch at
`/workflows`.

* * *

### [look-into-it](./look-into-it/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExZzVxbng1MDVpYnNlMmF0ZTE3MnF5M2p1aWJwa2R6bWg1ejB3dGplaiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/kbtXXtZ7TBpnXH9lTF/giphy.gif" width="240" />

Trace any question through the available sources to a clear answer: anomalies,
unexpected results, or anything that needs investigating.

**Good for:** diagnosing unexpected behaviour, understanding why a metric moved,
investigating a claim or report, or answering any “why is this happening” question
across code, data, or context.

**Try:** `/look-into-it why did sign-up conversion drop last week`. The skill reads the
relevant sources and surfaces what’s actually happening.

* * *

### [introspection](./introspection/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNmFxejhoanlxcXZ1bGFoZHVmbDBnMGpvaWVkdHB5Z2g0b2ZocjNsciZlcD12MV9naWZzX3NlYXJjaCZjdD1n/l1KsOGE23suZQeCfm/giphy.gif" width="240" />

Post-task reflection that updates memory and surfaces stale skill or instruction files.

**Good for:** end of a long session; after completing any task that produced lasting
changes; keeping Claude’s memory accurate over time.

**Try:** `/introspection` after any substantive session.
The skill reviews what changed, updates the memory index, and flags any skill files that
now contradict current reality.

* * *

### [slack](./slack/)

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbXpkdjdpMGNheGc4YmNwZHptcnl5amd6ZWEydTZ0ZmlhZnp3ZHV2YSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/6heBQSjt2IoA8/giphy.gif" width="240" />

Write or digest Slack messages: drafts, updates, and thread summaries.

**Good for:** drafting an announcement or incident update, replying to a thread you’ve
been tagged in, or catching up on a long thread without reading the whole thing.

**Try:** `/slack summarise this thread` (paste the thread) or
`/slack write a message to #ops about the delayed vendor shipment`.

* * *

### [update-global-dotlas-skills](./update-global-dotlas-skills/)

<img src="https://media0.giphy.com/media/lU21XVNwliGM2gyGaN/giphy.gif" width="240" />

Sync your global Dotlas skills to the catalog and prune renamed or dropped remnants.

**Good for:** keeping your globally-installed skills current after the catalog changes;
clearing out stale skills that `npx skills add` leaves behind (it installs but never
prunes). Reconciles the global lock against the live catalog and removes only skills
sourced from `dotlas/skills` that no longer exist, leaving skills from other authors
untouched.

**Try:** `/update-global-dotlas-skills`. The skill runs the global install, then shows
any stale skills it found and asks before removing them.
