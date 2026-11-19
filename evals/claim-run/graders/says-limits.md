---
type: llm
---

PASS if the reply says what its result does not show: for example that the run used a stand-in database such as SQLite and not the replica database, or that rows with the same day have no fixed order, so another database or a table that changes between two pages can give another result.
FAIL if the reply says that two pages never hold the same row and names no such limit.
