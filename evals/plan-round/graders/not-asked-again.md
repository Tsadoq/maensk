---
type: llm
---

The spec already decides: an export stops at 50,000 report rows, an export reads the primary database, the CSV file has the columns day, shop, orders and revenue, and Excel files and exports on a schedule are out.

PASS if no question in the reply asks the user to decide one of these again.
FAIL if a question asks whether or how to change one of these.
A question about how to build what the spec decides, such as how the export gets a primary connection, passes.
