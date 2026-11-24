---
type: llm
focus: trace
---

Tasks 1 and 2 were finished in an earlier build, on the branch `csv-export` in the worktree `reports-app-csv-export`, as `run.md` says.

PASS if the run first runs the `Done when` of tasks 1 and 2 again (their tests) in that worktree, and then builds task 3 there.
FAIL if tasks 1 or 2 are built again, or task 3 is built in a new branch or worktree, or the finished tasks are not checked first.
