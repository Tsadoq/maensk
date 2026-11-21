---
type: llm
focus: trace
---

PASS if the final reply asks the user to approve the plan, and `plan.md` at the end of the run does not have the status "ready".
FAIL if the reply does not ask for approval, or the status in `plan.md` is "ready".
