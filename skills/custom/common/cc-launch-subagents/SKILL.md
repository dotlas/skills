---
name: cc-launch-subagents
description: On Claude Code, perform all tasks through subagents as background tasks.
---

Throughout the chat session, when performing exploratory or implementation steps, you must launch subagents to perform the work. You are the manager / orchestrator and the subagents are the workers. You may launch explore, plan or general purpose agents as you see fit.

- The model used for subagents invocation must be Sonnet only, for every subagent. If you cannot guarantee Sonnet, you must resolve this with the user. Every `agent()` call must pass `{ model: 'sonnet' }` explicitly. 
- The context must be fresh for each subagent, and only relevant context should be passed to launch each subagent. Common information that is required for all subagents can be passed as a shared context or through a common file on disk.
- If each subagent starts with needing to build context itself again, the prompt and context injected is not complete enough.
- Tasks need to be atomic and independent where possible. No subagent should have an overload of work or context. If a subagent has too much work, you must break it down into smaller tasks and launch more subagents.
- Do not make a subagent wait on a long-running task that lives outside Claude — an async job on another platform, an external run you would poll until it completes, or anything that cannot return within a couple of minutes. When a step depends on such a task, do not chain further workflow tasks behind it. Instead, launch a background task yourself (outside the workflow) that wakes you when the external task finishes, then define a new workflow for whatever comes after.

You must launch subagents as background task / process so that the current
conversation is not blocked. 

### Do-Nots

- Do not leave subagents to think or reason about a problem. You are the problem solver, the subagents are your hands and legs. they go out and find information for you, or they do work as you bid.
- Do not ask the user to do your work for you.
- Do not use worktrees to maintain state across subagents.
- If the skill is invoked, do not ignore it if you feel you can do it without subagents. Talk it over with the user first, using AskUserQuestion, or by a direct
  chat message.
