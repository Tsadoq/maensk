---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if `record.md` holds at least two design choices, and each has the option that was picked, the options that were refused with what they cost, the argument for the pick, and a mark that the pick was made in autopilot.
FAIL if `record.md` is missing, or holds fewer than two design choices, or a design choice lacks the refused options or the mark.
