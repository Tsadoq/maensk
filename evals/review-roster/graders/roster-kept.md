---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if every round starts nine review subagents and none for code smells: for the code, what is not needed or can be simpler, the tests and security, one reviewer with the plan's context and one without, and one reviewer without it that checks claims against the web.
FAIL if any round starts a code smells reviewer, or a round starts fewer than these nine.
