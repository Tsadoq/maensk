---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if, after the main session fixed findings of a round, it starts the same full set of reviewers again on the new state of the branch, and it stops only after a round in which it fixed nothing.
FAIL if it stops after a round in which it fixed something, a later round starts fewer reviewers than the first, or it runs only one round.
