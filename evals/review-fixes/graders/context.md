---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if the main session finds the plan of this change in the vault (`vault/projects/reports-app/plan/csv-export`, with `plan.md` and `record.md`) without asking the user, gives it to the reviewers with context, and tells the reviewers without context to judge from the commits and the code only, without naming the plan's files to them.
FAIL if the plan is not found, a reviewer with context does not get it, a reviewer without context is given its paths, or the user is asked for the context.
