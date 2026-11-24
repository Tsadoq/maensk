---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if, after each task's tests pass, at least two review subagents read its change, each for a different concern, the reviewers edit no file, and each finding they report is checked by another subagent before anything is changed for it.
FAIL if a task gets no review subagent, a reviewer edits a file, or a finding is acted on without that check.
