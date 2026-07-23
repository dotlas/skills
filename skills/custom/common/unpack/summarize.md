# Summarize Mode

Triggered by: "summarize", "tldr", "what happened", "digest this", or any equivalent.

Distil a wall of text — agent output, reasoning traces, finding dumps — into a structured
brief that surfaces what matters and what requires the user's attention.

## Output format

Always use structured formatting: bullets, tables, sub-sections. No prose paragraphs.
The existing principles (lean, anchored, no filler) apply in full — summarize is a
channel for them, not an exception.

Always emit all four sections. If a section is empty, write "None" rather than omitting
it — a missing "Your call" section is often why the user had to read the wall in the
first place.

---

**Status**
One sentence. Where things stand right now — done, in progress, blocked, or uncertain.

**Findings**
The substance: what was discovered, what was tried, what worked, what didn't.
Bullets or a table. Group by theme if there are many.

**Open questions / blockers**
Unresolved issues, uncertainties, or things the agent got stuck on.
These are often buried mid-paragraph in agent output — surface them explicitly.

**Your call**
Decisions or actions explicitly needed from the user to continue.
If nothing is needed, write "None" — don't omit the section.
