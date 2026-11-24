---
type: llm
focus: trace
---

PASS if the trace shows a run of the mutation tool `mutmut` (for example `python3 -m mutmut run`) on the code of at least one task, and its surviving mutants, if any, are sent back to be tested or dismissed with a reason.
FAIL if `mutmut` never runs.
