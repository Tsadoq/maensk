---
type: llm
focus: trace
---

Judge only the spec note that the agent wrote in the vault, as the Write or Edit calls in the trace show it.

The discussion settled only these points: an export is one CSV file with the report rows of one team, and it is never called a dump or a download; it stops at 50,000 rows and the page says so; it reads the primary database because finance compares it with the bank in the same minute and rows that are five minutes old make the totals wrong, as the one exception to ADR-001, which has its own decision record; its columns are day, shop, orders and revenue; Excel files and scheduled exports are out of scope. Who can export and where the button goes on the page were left to the developer. Testing was never discussed. The feature is part of the reports page. The problem was given too: finance checks the report rows of its team against the bank once a day, and today someone copies them from the page by hand, 200 rows at a time.

PASS if the spec states as decided only these points, or requirements and acceptance criteria that restate them.
FAIL if the spec states as decided anything else: who can export (for example "a member can export" or "any member"), where the button goes on the page, a test plan, a file name, a column order other than the one given, a background job, a time limit, or any other choice.
Naming an item as left to the developer or as not decided is not a failure.
