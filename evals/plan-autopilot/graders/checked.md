---
type: llm
focus: trace
---

PASS if the trace shows at least one real run, inside a subagent, that tests an assumption under a design choice: a command that runs code or a query and prints a result.
FAIL if nothing was run, or every check was done by reading the code.
