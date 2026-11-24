---
type: llm
---

Judge only the last message of the reply.

PASS if the final reply is a few lines that say what changed and why, name the branch and the path of `run.md`, say what is left for the user, and offer an explainer page without having built one.
FAIL if the reply is long, misses the branch or `run.md`, or says a page was built that the user did not ask for.
