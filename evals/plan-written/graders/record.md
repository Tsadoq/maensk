---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if `record.md` holds the user's six picks, marks them as the user's, gives the pick on testing an id of its own such as G1, and holds at least one check with what was run and what was observed.
FAIL if `record.md` is missing, or lacks the picks, or holds no check that was run.
