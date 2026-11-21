---
type: llm
---

The user gave six picks: the test approach, the view function `export_csv`, the query `export_rows`, the returned dict, who can export, and that the page's message is not part of the plan. The spec decides the 50,000 limit, the primary database and the columns.

PASS if the reply asks the user to decide none of these again.
FAIL if the reply asks the user about one of them with no new finding behind it. A request to approve the finished plan passes, and so does a question that reports what a check or a critic found against a pick.
