---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if no review subagent edits, writes, deletes or commits a file in `reports-app/`, and the changes to `reports-app/` are made by the main session.
FAIL if a review subagent changes a file there or makes a commit.
