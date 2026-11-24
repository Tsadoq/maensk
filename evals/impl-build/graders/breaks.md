---
type: llm
focus: trace
---

PASS if, after a task's tests pass, the code is broken on purpose for each of its tests (a changed line, a removed condition), a run shows the test failing on that break, and the code is restored; this happens for at least two of the three tasks.
FAIL if the code is never broken on purpose to see a test fail after it passed.
