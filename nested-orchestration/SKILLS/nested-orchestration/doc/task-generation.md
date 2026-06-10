# Task Generation

Unknowns come in two kinds; resolve both before writing the plan, never mid-run.

- **Only the user can answer** — requirements, preferences, trade-offs. Collect every such question and ask them in one batch before spawning anything. A question discovered at hour 6 means the plan was written too early.
- **The codebase or environment can answer** — spawn explorers and decompose from their digests. If you cannot write a self-contained brief for a task, you don't understand it yet; explore first, plan second.

## Delegate-ready criteria

A task is ready to delegate when all three hold:

1. **Self-contained brief** — the receiver needs nothing from your conversation; everything is in the brief or in files it names by path.
2. **Artifact-verifiable** — done-ness is checkable from files or exit codes, not from trusting the report. Write the done-criterion into the brief.
3. **Single deliverable** — if you'd describe the output with "and", split it.

## Where to cut

- **Split along narrow interfaces.** Good seams exchange a small file, a schema, a list — not shared mutable state. If two tasks would edit the same files, they are one task.
- **Split by data, not by verb.** "Handle files A–M" / "handle N–Z" beats "read everything" / "transform everything" — the latter pushes the full dataset through one context twice.
- **Size to one sitting.** A brief longer than a page, or raw input beyond ~10 files, is a coordinator's job, not a worker's.
