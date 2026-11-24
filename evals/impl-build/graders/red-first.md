---
type: llm
focus: trace
---

PASS if, for each of the three tasks, the trace shows a run of the task's tests that fails before the task's code exists, and a later run of the same tests that passes.
FAIL if for one task the tests are never seen failing before its code is written.
