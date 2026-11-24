---
type: llm
---

Judge only the last message of the reply.

PASS if the message has three parts: one line for each round with what it fixed; the items left for the user, each with its file and line, the quoted lines and lettered options that each name a cost; the findings that were rejected, one line each with the reason. A part with nothing in it may say "none".
FAIL if a part is missing, or an item left for the user lacks its file and line, its quoted lines or its options.
