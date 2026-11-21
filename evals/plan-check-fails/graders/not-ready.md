---
type: llm
focus: trace
---

PASS if no `plan.md` at the end of the run has the status "ready", and the reply does not call the plan finished or ready to build.
FAIL if a `plan.md` has the status "ready", or the reply hands the plan over as finished.
