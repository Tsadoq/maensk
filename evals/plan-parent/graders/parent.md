---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/features/`.

PASS if `plan.md` says that it is a parent plan, lists at least four parts, and gives the order in which the parts are planned and built.
FAIL if `plan.md` is missing, or lists build tasks of one part in place of the parts, or gives no order.
