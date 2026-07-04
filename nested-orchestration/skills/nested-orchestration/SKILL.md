---
name: nested-orchestration
description: Run multi-hour jobs without context compaction by routing all work through disposable, generation-swapped coordinator subagents. Use when a task will read or produce more than fits one context window.
---

# Disposable Orchestration

The root agent cannot be discarded — its context only accumulates, and compaction is lossy. So root must absorb nothing: every task runs inside a disposable coordinator, spawned per task and thrown away with everything it read. Generational turnover of the middle layer is the whole mechanism; everything below exists to make any agent killable at any moment.

## Workflow

1. Information flows down as self-contained briefs, up as digests (`STATUS / ARTIFACTS / DIGEST ≤10 lines`). Bulk data lives only on disk — never in a brief or digest, always as a path.
2. Each task gets a dir: `run/NN-task/` with `brief.md`, `digest.md`, artifacts. Root keeps `run/plan.md` current. Disk is the source of truth; any conversation is just a cache of it.
3. Root only plans, dispatches, reads digests. Never reads artifacts, never runs heavy commands, never debugs.
4. A coordinator owns one task: spawns workers, verifies their artifacts by sampling, returns one digest, dies.
5. Any agent that estimates a task will flood its own context becomes a coordinator for it instead of doing it. Nesting depth emerges from data volume, not a fixed hierarchy — but Claude Code caps subagent nesting at depth 5; an agent at that depth loses the Agent tool and cannot spawn further, so keep decomposition shallow and prefer generational handoff (rule 6) over adding another layer. Requires Claude Code v2.1.172+ (nested subagent spawning). This applies to `coordinator`, `dev`, and `fixer`, which carry the Agent tool; `explorer` and `reviewer` are read-only leaves and never spawn.
6. A coordinator that grows heavy mid-task writes its state to disk, returns a digest, and exits; the parent spawns a successor that resumes from disk. Swap generations early — ending an agent is free, compacting one is not.
7. Failures return the error's location (log path, file:line), never the dump. The parent spawns a fresh fixer. If the same issue survives two generations, the brief is wrong: re-decompose instead of retrying.

## Dispatch

Behavior is fixed; tasks carry only data. Spawn agents with the fixed role prompts in `agents/` (`coordinator`, `explorer`, `dev`, `reviewer`, `fixer`) plus a task dir path — never restate behavioral rules per task. Write task files at decomposition time, while you still understand the task; `plan.md` is then a queue of ready-to-launch tasks that a successor — or a crash-restarted root — can dispatch with zero context.

## Reference

Load on demand, only by whoever needs it:

- `doc/task-generation.md` — resolving unknowns, delegate-ready criteria, where to cut. Read before writing any plan.
- `doc/review-loop.md` — the dev/review loop protocol and its termination rules. Read before running a loop.
