---
max_turns: 120
timeout_seconds: 2400
allowed_tools: [Bash, Read, Write, Edit, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

Use `super-plan` on the spec of the CSV export for `reports-app`: `vault/projects/reports-app/plan/Reports CSV Export Spec.md`.

I confirm the scope: what the spec's Solution says is in, what its Out of scope says is out. We went through the design choices already, and these are my picks:

1. Testing: `pytest` tests against a SQLite database in memory that holds report rows. Nothing is replaced.
2. The export is a new view function `export_csv` beside `reports_page`. It gets the primary database connection as an argument, the way `reports_page` gets the replica.
3. A new query `export_rows` reads up to 50,001 rows in one statement, in the order of `report_rows`. A 50,001st row means that the export stopped.
4. The view returns 200 and a dict with the CSV text under `csv` and a flag `stopped`, built with Python's `csv` module.
5. A member with `reports.view` can export. No new permission.
6. The repo holds no page template, so the message on the page is not part of this plan. For R3 the plan ends at the flag `stopped`.
7. One report row is one line of the CSV file, because the import of finance reads the file line by line. We assume that Python's `csv` writer keeps a row on one line also when a shop name holds a line break.
