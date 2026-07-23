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
