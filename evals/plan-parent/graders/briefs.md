---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if each part has its own file that says what the part delivers and which parts it comes after, and no part file lists build tasks with a test for each.
FAIL if the parts have no files of their own, or a part file is cut into build tasks with their tests.
A part file that names what must hold when the part is done passes.
