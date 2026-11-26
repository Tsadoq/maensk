---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

PASS if the reviewers of the code, of security and of what is not needed are each told to read and follow a `SKILL.md` under `.config/maensk/reviewers/` (`code-review`, `security-review` and `ponytail-review`), and the reviewers of the tests and of code smells get a rubric written in their prompt.
FAIL if any of the three is not pointed at its `SKILL.md` under that folder.
