---
name: cc-launch-workflows
description: On Claude Code, once the planning stage is completed, and if the user prompts you to use this skill, launch the execution of the plan as a workflow.
---
After planning is complete and the user asks to execute, launch the plan as a background
workflow of fresh Sonnet worker subagents, with the current agent (you) as orchestrator.
If you do not have necessary context, you must launch “Explore” subagents to gather the
required information before launching the workflow.

Ultracode: create a workflow based on the current active conversation’s plan.
You are the manager / orchestrator and the subagents of the workflow are the workers.

### Key Attributes of the workflow declaration:

- The model used for implementation must be Sonnet only, for every worker.
  If you cannot guarantee Sonnet, you must resolve this with the user.
  Every `agent()` call in the workflow script must pass `{ model: 'sonnet' }`
  explicitly. The Workflow tool defaults each worker to the planning session’s model, so
  workers silently inherit that expensive model unless you override.
  This is the one place you deliberately ignore the default workflow tool’s “omit model”
  preset. Set an appropriate effort too.
  Look at the effort matrix below to decide per-worker effort levels.

| Worker Effort | Type of Problem | Example Use-Cases |
| --- | --- | --- |
| medium | Pure mechanical changes. File locations, what code to add or change are all resolved already, and its just low cognitive effort to implement. | Add a new utility function, refactor a function, add a parameter to an endpoint, etc. When the worker doesn’t see more than 10 or so simple / small files. |
| high | Lower mechanical, higher cognitive load when making changes or adding code. | Adding a new endpoint, adding a new feature, creating a new table, etc. When the worker needs to know how the codebase is strung up so that it doesn’t trip any wiring. |
| xhigh | Mission critical workloads, or highly cognitive code changes that require presence and mindfulness. | Adding a new page, building a new notebook or subdir, adding code for authentication or authrorization / security workloads, etc. When the worker needs to seriously consider surfaces and blast radius without causing regressions. |

- The context must be fresh for each worker, and only relevant context should be passed
  to launch each worker.
  Common information that is required for all workers can be passed as a shared context
  or through a common file on disk.
- If each worker starts with needing to build context itself again, the prompt and
  context injected is not complete enough.

### How to create the workflow:

- You may use parallel tasks where applicable to speed up the execution.
  Try to logically validate and isolate subagent work when they work in parallel so they
  don’t have race conditions on the same files.
- Tasks need to be atomic and independent where possible.
  No worker should have an overload of work or context.
  If a worker has too much work, you must break it down into smaller tasks and launch
  more workers.
- Dependent tasks can be chained with the right dependencies.
  You must ensure that the workers are launched in the right order and that the output
  of one worker is passed to the next worker as input either through you or through a
  common file on disk.
  Return structured data via a schema on `agent()`, and use `pipeline()` so item B’s
  stage 2 gets item A’s stage-1 result directly.
  Reserve the shared file for large/common context.
- Where necessary, add a review subagent at the end of the workflow that validates the
  work of all ancestor agents and if the goal has been met.
- Do not make a worker wait on a long-running task that lives outside Claude — an async
  job on another platform, an external run you would poll until it completes, or anything
  that cannot return within a couple of minutes.
  When a step depends on such a task, do not chain further workflow tasks behind it.
  Instead, launch a background task yourself (outside the workflow) that wakes you when
  the external task finishes, then define a new workflow for whatever comes after.

You must launch the workflow as a background task / process so that the current
conversation is not blocked.
Launched workflows must be viewable by the user at `/workflows` in Claude code.
Any blockers to setup or launch the workflow can be resolved by asking the user for more
information or context.

### Do-Nots

- Do not ask the user to do your work for you.
- Do not use worktrees to maintain state across subagents.
- If the skill is invoked, do not ignore it if you feel you can do it without subagents
  or workflows. Talk it over with the user first, using AskUserQuestion, or by a direct
  chat message.
