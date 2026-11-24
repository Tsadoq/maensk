---
type: llm
focus: files
---

The branch shipped `test_the_limit_is_fifty_thousand` in `tests/test_export_rows.py`, which only asserts that a constant equals itself.

PASS if that test is gone at the end, or replaced by a test of behaviour.
FAIL if a test that only compares `EXPORT_LIMIT` to 50,000 is still there.
