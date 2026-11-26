---
type: llm
focus: files
---

Judge the file `vault/projects/reports-app/features/csv-export/plans/csv-export/run.md` as it is at the end of the run.

PASS if it keeps the earlier log of tasks 1 and 2, adds that their checks were run again, logs task 3 as finished, and ends with a part on what the next work inherits.
FAIL if the earlier log is lost, task 3 is not logged, or the part on what the next work inherits is missing.
