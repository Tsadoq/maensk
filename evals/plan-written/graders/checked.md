---
type: llm
focus: trace
---

PASS if the trace shows at least one real run, inside a subagent, that tests an assumption under one of the user's picks: a command that runs code, a query or the `csv` module and prints a result.
FAIL if nothing was run, or every check was done by reading the code.
