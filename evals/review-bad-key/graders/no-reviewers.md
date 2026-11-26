---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if no review subagent is started and no file of `reports-app/` is changed.
FAIL if a review subagent starts or a file is changed.
