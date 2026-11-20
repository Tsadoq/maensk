---
type: llm
focus: trace
---

Judge the HTML page that the trace writes.
PASS if the page shows example report rows with the fields day, shop, orders and revenue, and states the page size of 200 from the code. A picture may draw fewer rows per page than that, if the page says so.
FAIL if the page shows no example rows, uses placeholder values such as "foo" or "Row 1", or uses another page size.
