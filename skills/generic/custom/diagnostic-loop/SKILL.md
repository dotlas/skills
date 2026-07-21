---
name: diagnostic-loop
description: >
  Start from a Slack thread, trace an issue through the codebase, resolve
  open questions with the operator, then plan and implement the fix — posting throttled
  milestone updates back to the thread. Use when a Slack thread reports a bug, asks
  "why is X happening", or requests a fix, and you want an attended run that investigates,
  grills you for business context, plans the fix, and implements it without spamming the thread.
---
# Diagnostic Loop

Attended skill. Trace the issue from a Slack thread through the codebase, settle open
questions with the operator, then plan and implement the fix.
Run under a 1-minute loop whose only job is to post throttled milestone updates back to
the thread.

## Quick start

Launch with a 1-minute interval: `/loop 1m /diagnostic-loop <thread permalink>`. Each
tick the loop only checks whether a whitelisted milestone has been reached and needs to
go to the thread — most ticks send nothing.
Anti-spam comes from the milestone whitelist, not the interval.

Flow: **Digest → Understand → Grill → Plan → Implement.** Understand and Grill cycle
back as needed; the fix plan is written only once the investigation is settled.

## 1. Digest

Read the thread once with `slack_read_thread`. Digest it using the
[slack](../slack/SKILL.md) skill’s standard — what is asked, where it stands, and the
identifiers (file/table names, error strings, source, country, ids).
Post the **ack** milestone.

## 2. Understand (trace)

First orient to the codebase: look for agent-context that grounds the investigation —
`.agents/` / `.agent/` / `.cursor/` dirs, instruction or manifest files, `docs/`,
`CONTRIBUTING`, and the nearest READMEs.
Use them to learn the repo’s conventions and where things live, and note the repo’s
plans directory for step 4. Do not assume any specific layout — discover what this repo
actually has.

Then locate where the issue originates: which files, directories, and scopes are in
play, and what the fix would touch.
Read and search freely.
But **do not be eager with experiments** — any trial-and-error that runs code,
reproduces the issue, or has side effects must be proposed to the operator and vetted
(Grill) before you run it; favor static reading and reasoning first.
**No plan yet** — this step only builds understanding.

- If the candidate file set is too large, the thread does not localize the issue, or you
  need business context to judge correct behavior → **Grill** (step 3), then return
  here. Understand ↔ Grill cycle until the origin and intended behavior are clear.

## 3. Grill

Invoke [grill-me](../grill-me/SKILL.md) to resolve what the code can’t tell you:
business context and scope (during Understand), **and how the operator wants to approach
the problem and shape the fix** (going into Plan).
One question at a time, each with a recommended answer; explore the code instead of
asking when the code can answer it.
Questions go to the operator at the terminal — **never to Slack**. Fold answers back
into Understand or carry the chosen approach into Plan, and continue.

Exception: post a **blocked-needs-thread** update to the thread only when a participant
alone can unblock you (e.g. a product decision from whoever raised it).

## 4. Plan

Only after the investigation is settled and the operator’s chosen approach is grilled
out: write the **fix-implementation plan** to the repo’s plans directory found while
orienting (default `.agents/agent_plans/` if the repo has no clear plans location),
named `diagnostic-<slug>.md` (slug from the thread topic).
Follow the approach agreed in Grill.
The plan covers the fix — the files to change, the exact changes, and how to verify.

## 5. Implement

Execute the plan: make the fix.
Verify it against the problem the thread reported.
Once the fix is in and verified complete, delete the plan file written in step 4 from
the plans directory — it has served its purpose and should not linger.

## The loop — Slack updates only

The loop’s sole purpose is to decide, each tick, whether a whitelisted milestone update
needs to go to the thread — and send it if so.
The work happens regardless of the loop; the loop is just the recurring “does Slack need
to know anything yet?”
check.

- **Default per tick is silence.** Most ticks send nothing.
  Never post progress filler ("still investigating").
- **Whitelist only:** (1) **ack** on start, (2) **blocked-needs-thread**, (3) **root
  cause settled** (one line, after Understand concludes), (4) **resolution** (fix
  implemented and verified).
- **Compose** per the [slack](../slack/SKILL.md) standard: lead with the takeaway, facts
  only, short, no jargon.
- **Dedupe:** track what you have already posted (a small note keyed by thread ts under
  `${TMPDIR:-/tmp}`) and never repeat a milestone.
  End the loop once the resolution is posted.
