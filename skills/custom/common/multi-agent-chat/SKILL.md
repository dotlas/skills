---
name: multi-agent-chat
description: >
  Open a chatroom — a plain .txt log on disk — so agents in separate sessions (Claude,
  Codex, others) whose work has collided or become correlated can talk to each other:
  resolve the conflict, trade the context each is missing, and settle who owns what.
  The agent that opens the room moderates it; the operator relays the room path to the
  other agents. Use when two sessions are stepping on each other or one needs what the
  other knows, or when handed a room path and asked to join.
---
# Multi-Agent Chat

The room is a file. Anyone who can read and append to it is in the room — that is the
whole transport. No agent can see any other agent’s session, so everything that matters
gets written down or it does not exist.

The **operator** is the human at the terminals, and the only thing that moves between
sessions: they carry the room path to each agent and nudge a session that has gone
quiet. You are **attended** — ask them, don’t guess.

Two branches: **open** a room (you are the moderator), or **join** one you were handed.

## Open

1. **Name yourself.** Pick a nickname from the work you are doing, not from your model —
   `api`, `migrator`, `reviewer`. Take its first letter as your initial.
   If two agents collide on a letter, go to two (`Cl`, `Co`).

2. **Settle the roster.** Ask the operator (`AskUserQuestion`) which agents are joining
   and what each is working on, unless they already said.
   You need a nickname and a one-line job for every seat.

3. **Write the topic and the goal.** The topic is the collision — *both sessions are
   editing `schema.prisma`*. The goal is the outcome that ends the room — *agree who
   owns the migration and what the other does instead*. One line each; a room without a
   stated goal never closes.

4. **Create the room** at a path every agent can reach: `/tmp/agent-chat-<slug>.txt`. A
   session-private scratchpad is not reachable by another agent — use shared `/tmp`.
   Fill [`room-header.txt`](room-header.txt) and write it as the file’s head, then post
   your own join line.

5. **Hand the path to the operator** with a one-line instruction they can paste verbatim
   into each other session: *“Join this chatroom: `<path>` — read it, follow the rules
   at the top, announce yourself.”* The header onboards the joining agent by itself; the
   other agent needs no skill installed.

6. **Take the floor** and run the conversation to a resolution.

When the operator tells you someone new is expected, post it for them:
`[OP] expecting R = reviewer, auditing the same migration`.

## Join

Read the room file top to bottom — header, roster, and every line of the log so far.
Post `[X] joined, <what you are working on>` as your first act, then watch.
If the header names something you already disagree with, say so in the room rather than
to your own operator.

## The floor

One speaker at a time.
You hold the floor, you use it, you give it up — and you do not take it back until the
file has changed.

- After you append a message, **stop and watch**. Writing twice in a row is taking the
  floor from someone who was drafting a reply.
- In a room of three or more, hand the floor explicitly: end with a question addressed
  by initial (`[A] C — does that break your worktree?`). The named agent speaks next;
  everyone else keeps watching.
- The operator can cut in at any time as `[OP]`; that overrides whoever held the floor.

## Speaking

Append, never rewrite — the file only ever grows:

```bash
printf '[A] %s\n' "renaming users.email to users.email_address in 3 files" >> "$R"
```

One message, one line; wrap a long one onto continuation lines indented two spaces.

Every claim carries the identifier that makes it checkable — path, symbol, command,
branch, id. “I changed the model” is unusable to an agent that cannot see your diff;
`changed prisma/schema.prisma:41, User.email → User.emailAddress, not yet migrated` is.
State what you have **already written to disk** separately from what you **intend** to
do — the second is negotiable, the first is a fact the other agent has to work around.

## Watching

An agent only notices the room while it is running the watch command; between turns it
is asleep and blind.
The watch loop is how you stay in the room:

```bash
R=/tmp/agent-chat-<slug>.txt; s=$(wc -c <"$R")
for i in $(seq 120); do [ "$(wc -c <"$R")" != "$s" ] && break; sleep 5; done; tail -n 20 "$R"
```

On Claude Code, run it through `Monitor` with an until-loop on the byte count rather
than a foreground `sleep`.

If the watch times out with nothing new, the other session is idle, not thinking.
Tell the operator which agent has gone quiet and what you are waiting on, so they can
poke that session — then resume watching.

## Closing

The room closes on a **resolution written into the log**: one line naming the decision
and what each agent does next, posted by the moderator and acknowledged in the room by
every agent on the roster.

```
[A] resolved: A owns prisma/schema.prisma and the migration. C rebases onto A's branch
  after it lands and touches no schema files. C reviews src/api/ as planned.
[C] ack
```

Until that line exists and is acknowledged, the conversation is still open, however
agreeable it has become.

Each agent then posts `[X] leaving, <why>` and stops watching.
The moderator posts last, appends `== closed ==`, and reports the resolution to the
operator inline — including anything the room deliberately left unsettled.
