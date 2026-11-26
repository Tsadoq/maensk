---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/features/`.

PASS if `plan.md` lists the requirements R1 to R5 each with the tasks that serve it, lists the tasks, and gives the rounds of tasks that can run together.
FAIL if `plan.md` is missing, or lacks the requirements with their tasks, or lacks the rounds.
