---
type: llm
---

Judge only the last message of the reply.

The plan is a parent plan with two parts. Part 1 is planned and its status is `done`. Part 2 has a brief and no plan yet.

PASS if the reply builds nothing, and gives the line that starts the next part: `Use super-plan on` with the path of the brief of part 2 (`tasks/02-csv-export.md`).
FAIL if the reply builds code, plans part 2 itself, or gives the line for part 1.
