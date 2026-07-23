---
name: slack
description: >
  Compose a Slack message, or digest a Slack thread into compact context.
  Use when the user asks to reply to a person or channel, write a Slack post,
  or catch up on a thread without reading the whole transcript. This skill covers
  how to write well for Slack — both jobs share the same standard.
---
# Slack

Two jobs, one standard: respect the reader’s time.

- **Compose** — write a message for a thread or channel.
- **Digest** — turn a thread into a short briefing.

If the context was set in a thread, keep replies in the thread.
Don’t open a DM.

## The standard

Say the most with the least, then stop.
Every line earns its place; most first drafts shed half their words without losing a
fact. Do that cutting yourself.

There is no floor. If one line does the job, send one line — the shapes and limits below
are ceilings, not quotas.
Never manufacture adjectives, articles, clauses, or extra bullets to fill a gap; length
follows the content, nothing else.

- **Lead with the point.** First line is the takeaway, not a windup — no “here’s why”,
  no scene-setting.
- **Pitch to the reader, not the code.** Name what changed and what it does, not how
  it’s wired. File and table names, function, column, and param names, internal job or
  step names, library internals, and side metrics belong in the PR — not the message.
  Unsure how deep to go?
  Go shallow and offer the detail on request.
- **Decode, don’t lecture.** Whoever the reader is, they’re capable but not steeped in
  this domain. Spell out an in-house name the first time it appears — “the bronze layer
  (the raw-data table)” — but don’t explain what a table or a function is.
  Lead with the plain idea and name the term second, only when the name earns its place.
- **Exact where it counts.** State the numbers that carry the message precisely (2,616,
  not ~2,600). Don’t smuggle in every metric you measured — precision isn’t
  completeness.
- **One pass through the logic.** State the finding, then the single chain that explains
  it — cause to effect, once.
  Don’t narrate the investigation.
- **Cut what the reader knows.** If the thread or context already established it, drop
  it.
- **Clarity is literal, one idea per line.** Write for the least-technical likely
  reader; load-bearing meaning never hides in a metaphor or in-house shorthand.
  Compress by cutting facts, not cramming them.
- **Format in service of the content.** Structure supports the message, never decorates
  it — enough to make the point scannable, no more.
  One explanation or cause-chain stays prose; a set of parallel points becomes bullets,
  one per line; a genuine comparison becomes a table.
  But a wall of text, a backtick on every term, or bold on every line buries the point
  instead of surfacing it.
  When you do format, use Slack’s mrkdwn so it renders: single-asterisk `*bold*` (not
  `**bold**`, which shows literal asterisks), and `<url|text>` for links.
- **No filler.** No emojis, no sign-off pleasantries.
  (An offer of the specific detail you left out is not filler — it’s what earns the
  brevity.)
- **Link sparingly.** Only when it saves the reader a hunt, inlined on the words it
  describes. No link piles, no “References” section.

## Compose

When a message needs structure, shape it as **lead → body → (optional) kicker**:

- **Lead** — one line, the point.
  If it says everything, that’s the whole message — stop here.
- **Body** — only if the point needs unpacking.
  Shape it to the content, per *Format in service of the content* above: a tight
  paragraph for a single chain, scannable bullets for parallel points, and never a
  single point padded into a list.
- **Kicker** — at most one dry closing line, and only if it lands.
  See Voice.

A message about a change describes what the system does differently now and why it
matters — not the mechanics of shipping it.
Whether it’s committed, run, deployed, or verified, the run order, and the steps to
apply it are operational chatter; leave them out unless the reader has to act on them.
A one-line “not live yet” flag is fine when it sets expectations; the runbook behind it
is not.

Before writing, know the message’s job — answer a question, unblock a decision, report a
result, correct a misread — and that it fits here in the conversation.
No job, no message.

Cut on sight:
- a setup sentence before the lead, or any line that restates the lead in other words;
- a closing paragraph that recaps what you just said, reframes it ("so it’s not X, it’s
  Y"), or bolts on a fix nobody asked for;
- rollout mechanics beyond a one-line status flag — commit / run / deploy / verify
  state, run order, apply steps — unless the reader has to act on them;
- adjectives and intensifiers that don’t change a fact.

Over ~10 sentences or ~200 words, distill again.

## Voice

Plain is the default and always enough.
When a message can carry it, close with a single dry, understated line — the register of
a competent aide (Alfred, Jarvis), never a stand-up bit.
The wit rides on the material itself — a name, the failure mode, an irony already in the
facts — and reinforces the point instead of distracting from it.
Never at a colleague’s expense, never at the cost of clarity.
If it doesn’t land in one try, cut it: silence reads classier than a forced joke.

For the fuller craft — choosing the reader’s altitude, distilling to the bone, and
landing the wit — see [voice.md](voice.md).

## Digest

Return a layered briefing, not the transcript:

- One line: what the thread is about and where it stands (open / decided / blocked).
- A few bullets: decisions, the open question, who owns what — only what bears on the
  reader’s task.
- A table only when comparing options or tracking items.

Quote verbatim only when exact wording matters (a decision, a number, an error).
Offer to go deeper rather than front-loading everything.
