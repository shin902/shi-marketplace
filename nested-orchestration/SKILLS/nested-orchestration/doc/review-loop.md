# Dev–Review Loop

The coordinator alternates fresh dev and reviewer workers. They converse through one file, `review-NN.md`, never through the coordinator — it sees only verdicts, so any participant can be swapped between rounds.

- The reviewer writes numbered findings, each tagged `must-fix` / `suggestion` / `question`, and returns only a verdict (`approve` or `N must-fix open`). must-fix means broken, unsafe, or violates the brief — not style. Everything else is a suggestion, and suggestions never block.
- The dev replies inline under each finding: `fixed <how>`, `rejected <why>`, or an answer. Rejecting with a reason is legitimate — a dev who must accept everything teaches the reviewer nothing.
- The next reviewer round adjudicates only: verify items marked fixed, rule on each rejection (`accepted` / `escalate`), answer questions. No re-review of untouched code — re-reviewing from scratch is how nits multiply and rounds stop converging.
- A disagreement that survives one full round is a judgment call, not a bug. The coordinator puts it in its digest as a decision item and moves on; root or the user decides. Agents must not burn rounds on taste.
- The loop ends when a round produces zero open must-fix findings. Suggestions remaining open is a normal end state; log them in the digest.
