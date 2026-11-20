---
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Bash, Read, Write, Edit, Glob, Grep, Skill, Agent]
---

Use `explainer` to show the two ways the CSV export of `reports-app` could read the report rows of a team, page by page:

a. Offset pages, as `report_rows` does today.
b. Keyset pages: each page asks for the rows after the last day and shop of the page before.

We picked b. With a, the database reads and skips every row before a deep page, and the largest team has about 10,000 pages.
