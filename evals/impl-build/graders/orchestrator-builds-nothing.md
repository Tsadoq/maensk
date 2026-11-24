---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if every Write or Edit of a code or test file in a folder whose name starts with `reports-app` is made by a subagent, and the main session writes no code and no test.
FAIL if the main session writes or edits a code or test file itself, or no subagent writes code.
