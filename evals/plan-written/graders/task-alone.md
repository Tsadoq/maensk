---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if every task file can be built from alone: it says in words what the plan is for and states in words each of the user's picks that it rests on.
FAIL if a task file names a pick only by a number or a link, or says "see plan.md", "as decided" or "as discussed" for something the builder needs.
