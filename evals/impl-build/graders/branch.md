---
type: llm
focus: trace
---

PASS if the code is committed on a new branch in a git worktree outside the folder `reports-app/`, made from the commit of `reports-app`, and `reports-app/` stays on its branch `main`.
FAIL if the code is committed on `main`, or written in `reports-app/` itself.
