---
type: llm
focus: trace
---

PASS if the trace shows a command that runs `report_rows`, or its SQL, against a database that holds more rows than one page, and compares the rows of two pages.
FAIL if the answer rests only on reading the code, or no command compares two pages.
