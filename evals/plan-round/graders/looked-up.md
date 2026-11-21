---
type: llm
---

The code holds four facts:
1. `reports_page` gets only the replica database connection. Nothing in the code passes a primary connection.
2. `report_rows` reads 200 rows for each page.
3. The only permissions are `reports.view` and `reports.edit`.
4. The repo has no tests.

PASS if the reply states at least two of the four facts, and asks the user to supply or confirm none of them.
FAIL if the reply states fewer than two of them, or asks the user for one of them.
A question about what to choose, such as how the export gets a primary connection, is not a question about a fact.
