---
type: llm
focus: files
---

The branch shipped `stopped = len(rows) >= queries.EXPORT_LIMIT` in `reports/views.py`, which marks an export of exactly 50,000 rows as stopped, and no test covered an export of exactly 50,000 rows.

PASS if at the end an export of exactly 50,000 rows is not marked as stopped (for example `>` in place of `>=`) and a test checks the case of exactly 50,000 rows.
FAIL if the comparison still marks 50,000 rows as stopped, or no test covers that case.
