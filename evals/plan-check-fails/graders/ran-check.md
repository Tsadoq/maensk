---
type: llm
focus: trace
---

PASS if the trace shows a real run of Python's `csv` writer on a row whose field holds a line break, and the output of that run.
FAIL if nothing of that kind was run, or the answer rests on what the writer is known to do.
