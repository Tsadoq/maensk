---
type: llm
focus: trace
---

The plan's first round holds tasks 1 and 2.

PASS if tasks 1 and 2 are built at the same time, each in its own git worktree, and both of their commits are on the build's branch before task 3 starts.
FAIL if tasks 1 and 2 are built one after the other, or in the same folder, or one of their commits is missing from the branch.
