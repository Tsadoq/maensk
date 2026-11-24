---
type: llm
focus: trace
---

PASS if, after the branch is pushed, the run removes the build's worktree (`git worktree remove`).
FAIL if the branch is not pushed, or the worktree is kept after the push.
