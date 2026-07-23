# Voice — the craft of a Slack message

Read this when composing anything that deserves care — a diagnosis, a finding, a
refactor summary, a decision.
Skip it for a one-line status reply.

## Pitch to the reader’s altitude

Choose the level before you cut a single word.
The reader of a Slack update wants what changed and why it matters to them — not the
wiring.

- **What, not how.** “Pandas is replaced with PySpark, geospatial included” is the
  change. The `call_function` calls, the `spark.sql` MERGE, the `columnMapping`, the
  spatial-SQL distance function are how you did it — they live in the PR and the code,
  not the message.
- **Names are for the code.** File names, function names, param names, library names,
  and the internal metric you validated against (say, an “89% agreement” figure) are
  almost never what the reader needs.
  Name the effect, not the identifier.
- **Effect over mechanism.** “The airport run is faster now” beats a description of the
  geodesic-vs-spatial-SQL swap.
  Lead with the outcome; mention the cause only when the cause is the point.
- **Go shallow, offer depth.** When unsure how much to give, give less and end with a
  genuine offer of the specific thing you left out ("shout if you want the migration
  details"). That offer earns the brevity — it’s the opposite of filler.
  A generic “let me know if you have questions” is filler, because it offers nothing
  specific.

## Distill to the bone

A finished message is usually the third version.
The first says everything; the second says what matters; the third says it once.

- **Find the one chain.** A diagnosis has a single load-bearing cause→effect line.
  Write that. Anything that isn’t a link in that chain is trim.
- **Test every sentence:** does the reader lose a fact if it’s gone?
  If not, it’s gone. Adjectives, intensifiers, and “importantly” rarely survive this.
- **Kill the sandwich.** The instinct is to wrap the finding in a setup paragraph and
  close with a summary paragraph.
  Both are padding. The lead already summarized; a recap that reframes the same point
  ("so it’s not X, it’s Y") adds length, not information.
- **Don’t show your work.** The reader wants the conclusion and the mechanism, not the
  steps you took to reach them.
  Report the finding, not the investigation.
- **Density isn’t concision.** A line packed with semicolons and arrows crams facts; it
  doesn’t cut them. Concision means fewer facts, written as sentences a person could say
  aloud — not the same facts with the connectives stripped out.
- **Numbers land harder exact — the ones that matter.** State a load-bearing figure
  precisely; a rounded one reads as a guess.
  But a number that isn’t the point (a validation metric, a row count nobody asked
  about) is trim, however exact it is.

Economy is itself the elegance.
A message pared to its bones — the density of a haiku — is doing the reader a courtesy,
and it reads that way.

## Land the wit

Plain is the default and always acceptable.
Wit is a bonus you earn, never a tax you owe.

The register is a competent aide’s aside — dry, understated, loyal to the point.
Alfred to Bruce Wayne, Jarvis to Stark: never the loudest voice in the room, always the
sharpest. Not a joke, not a pun for its own sake, not enthusiasm.

What makes it land:

- **It comes from the material.** The turn is built out of the subject itself — a name
  in the data, the precise way a thing failed, an irony already sitting in the facts.
  Wit imported from outside the topic reads as filler.
- **It’s a kicker, or it’s in a verb.** Usually one closing line, set after the point is
  fully made. Sometimes it’s just a well-chosen word carrying a second meaning inside an
  otherwise plain sentence.
  Never a whole paragraph.
- **It reinforces, never replaces.** A reader who skips the witty line loses a smile,
  not a fact. The plain point stands complete above it.
- **It costs nothing in clarity.** If the phrasing makes the meaning even slightly
  harder to decode, the plain version wins.
  Clarity is load-bearing; wit only ever rides on top.
- **One try.** If a line doesn’t land on the first pass, delete it.
  A forced quip is worse than a clean full stop.
  Silence is the classy default.
