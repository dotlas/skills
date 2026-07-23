---
name: look-into-it
description: >
  Investigate any issue brought to you — a bug report, a "why is X happening", a fix
  request — trace it through the codebase (or whatever materials hold the answer), resolve
  open questions with the operator, then plan and implement the fix. If the issue arrived
  over a chat channel (Slack, or another IM exposed through an MCP), post throttled
  milestone updates back to the thread without spamming it; with no channel available,
  investigate and report inline. Use when a thread or the operator hands you an issue to
  look into and fix.
---
# I’ll Look Into It

Take an issue, investigate it end to end, fix it — and keep whoever reported it informed
without spamming them.
This is an **attended** skill: the operator is at the terminal to answer questions as
you go.

The investigation is the same whether or not there’s a channel to report to; the channel
is an optional layer, detected at the start.

## Start

Launch:
- **With a channel** — the issue is in a Slack (or other IM) thread:
  `/loop 5m /look-into-it <thread permalink>` (the loop only posts milestones — see
  Updates).
- **Without** — the issue is handed to you directly:
  `/look-into-it <what to look into>`.

At the start, detect the channel and bind updates to it:
- A thread permalink names the channel explicitly — read that thread first.
- With no permalink, check whether a communication MCP (Slack, Teams, or similar) is
  connected and a relevant thread is identifiable.
- If no channel is available, run **investigation-only**: do the full investigation,
  surface milestones inline to the operator, and skip the update loop.

Slack is the reference channel — the tool names and the [slack](../slack/SKILL.md)
compose/digest standard below assume it; another IM routes the same milestones through
whatever MCP is available.

Anti-spam comes from the milestone whitelist, not the interval — most ticks send
nothing.

## The investigation

Flow: **Digest → Understand → Grill → Plan → Implement.** Understand and Grill cycle
back as needed; the fix plan is written only once the investigation is settled.

### 1. Digest

If there’s a thread, read it once (`slack_read_thread`, or the channel’s equivalent) and
digest it per the [slack](../slack/SKILL.md) skill’s standard — what is asked, where it
stands, and the identifiers (file/table names, error strings, source, country, ids).
Then **ack** by reacting to the linked message with the detective emoji (🕵️) via
`slack_add_reaction` — a silent “being looked into” signal, no posted message.
In investigation-only mode, digest the issue as the operator stated it.

### 2. Understand — establish scope, then trace

**Establish the context scope first.** The answer usually lives in what’s already in
front of you — the codebase, docs, or files in the current working scope.
Start there; a monorepo you’re already inside likely holds both the issue and its fix.

Find the material that grounds the investigation — where things live, the local
conventions, and anything you can reuse rather than reinvent.
Note the conventional plans location within it for step 4. *In a codebase:*
agent-context and conventions (`.agents/` / `.agent/` / `.cursor/` dirs, instruction or
manifest files, `docs/`, `CONTRIBUTING`, the nearest READMEs), plus any skills, standing
instructions, or memory (`CLAUDE.md`, a `memory/` dir) you can lean on.
*In other work:* the equivalent source material — prior filings and precedent, existing
designs and assets, records and ledgers, whatever the domain keeps.
Don’t assume a layout — discover what’s actually here.

If the relevant context isn’t in the current scope and you can’t locate it, ask the
operator (`AskUserQuestion`) to point you to it — the directory, the files, where the
material lives — rather than guessing.

**Then trace the origin.** Locate where the issue comes from: which files, directories,
and scopes are in play, and what the fix would touch.
Read and search freely.
But **do not be eager with experiments** — any trial-and-error that runs code,
reproduces the issue, or has side effects must be proposed to the operator and vetted
(Grill) before you run it; favor static reading and reasoning first.
**No plan yet** — this step only builds understanding.

- If the candidate material is too large, the source doesn’t localize the issue, or you
  need business context to judge correct behavior → **Grill** (step 3), then return
  here. Understand ↔ Grill cycle until the origin and intended behavior are clear.

### 3. Grill

Resolve what the code can’t tell you: business context and scope (during Understand),
**and how the operator wants to approach the problem and shape the fix** (going into
Plan). Ask with `AskUserQuestion` — one question at a time, each with a recommended
answer; explore the code instead of asking when the code can answer it.
Questions go to the operator at the terminal — **never to the channel**. Fold answers
back into Understand or carry the chosen approach into Plan, and continue.

Exception: post a **blocked-needs-thread** update to the channel only when a participant
alone can unblock you (e.g. a product decision from whoever raised it).

### 4. Plan

Only after the investigation is settled and the operator’s chosen approach is grilled
out: write the **fix-implementation plan** to the conventional plans location within the
current scope (the one noted while establishing scope; if the scope has no such
convention, a sensible location within it), named `diagnostic-<slug>.md` (slug from the
issue topic). Follow the approach agreed in Grill.
The plan covers the fix — the files to change, the exact changes, and how to verify.

### 5. Implement

Execute the plan: make the fix.
Verify it against the problem as reported.
Once the fix is in and verified complete, delete the plan file written in step 4 — it
has served its purpose and should not linger.
Then post the **resolution** milestone.

## Updates

**Channel mode.** Run under a 5-minute loop whose only job is to decide, each tick,
whether a whitelisted milestone needs to go to the thread — and send it if so.
The work happens regardless of the loop; the loop is just the recurring “does the thread
need to know anything yet?”
check.

- **Default per tick is silence.** Most ticks send nothing.
  Never post progress filler ("still investigating").
- **Whitelist only:** (1) **ack** — a 🕵️ reaction on the linked message at start (not a
  posted message), (2) **blocked-needs-thread**, (3) **root cause settled** (one line,
  after Understand concludes), (4) **resolution** (fix implemented and verified).
- **Compose** per the [slack](../slack/SKILL.md) standard: lead with the takeaway, facts
  only, short, no jargon.
- **Dedupe:** track what you have already posted (a small note keyed by thread ts under
  `${TMPDIR:-/tmp}`) and never repeat a milestone.
  End the loop once the resolution is posted.

**Investigation-only mode.** No loop.
Surface the same substance inline to the operator as it occurs — root cause when
Understand concludes, resolution when the fix is verified.
`ack` and `blocked-needs-thread` are channel concepts and don’t apply: the operator is
already present and answering, so there’s nothing to throttle.
