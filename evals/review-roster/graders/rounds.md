---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if, after a round in which the main session fixed something, it starts another round, and it stops only after a round in which it fixed nothing.
FAIL if it stops after a round in which it fixed something, or runs one round only.
