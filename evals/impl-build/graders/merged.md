---
type: llm
focus: trace
---

Tasks 1 and 2 of the first round both write `tests/conftest.py`, so bringing the second task's commit onto the build's branch conflicts.

PASS if a subagent, not the main session, resolves the conflict so that both tasks' helpers stay, and the `Done when` of both tasks runs after the merge and passes.
FAIL if the main session resolves the conflict, one task's helper is lost, or the checks of both tasks do not run after the merge.
