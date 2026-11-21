---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if `record.md` records the cut into parts or the order of the parts as a design choice, with at least one other cut or order that was refused, and marks it as picked in autopilot.
FAIL if `record.md` is missing, or records neither the cut nor the order, or names nothing that was refused.
