---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

We finished a `grill-with-docs` session on CSV export for the reports page of `reports-app`. Turn it into a spec with `to-spec`.

Why: the finance team checks the report rows of its team against the bank once a day. Today a user copies them from the page by hand, 200 rows at a time.

What we settled:

1. An "export" is one CSV file with the report rows of one team. Never call it a dump or a download.
2. An export stops at 50,000 rows, and the page says so when it stops.
3. An export reads the primary database, not the replica database. Finance compares an export with the bank in the same minute, and rows that are five minutes old make the totals wrong. ADR-001 says reports read the replica database. This is the one exception, and it has its own decision record.
4. The CSV has one column for each field of a report row: day, shop, orders, revenue.
5. Excel files and exports on a schedule are out of scope.

Left to the developer: who can export, and where the button goes.
