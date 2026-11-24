---
type: llm
focus: files
---

The branch shipped `rows_to_dicts` in `reports/queries.py`, which nothing calls.

PASS if `rows_to_dicts` is gone at the end.
FAIL if it is still in the code.
