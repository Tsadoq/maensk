---
type: llm
focus: trace
---

Judge only the files of the plan as they are at the end of the run, in the folder under `vault/projects/reports-app/plan/`.

PASS if every task file that changes code has all of these: one sentence that says what to do; for each test what it asserts, with an input and the expected output or error, its level (unit, component or system), and what runs real against what is replaced; a line "Done when:" with one command or observation; a line "After:"; a line "Touches:"; and a line "Serves:" with ids such as R2 or G1.
FAIL if there are no task files, or a task file that changes code lacks one of these.
