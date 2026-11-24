---
type: llm
focus: trace
---

PASS if `export_csv` is added to `reports/views.py` in the worktree `reports-app-csv-export`, its tests are seen failing before the code and passing after, and `python3 -m pytest tests` passes at the end.
FAIL if task 3 is not built, or its tests are never seen failing first, or the last test run fails.
