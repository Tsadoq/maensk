---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

We finished a `grill-with-docs` session on CSV export for the reports page of `reports-app`. Write the spec with `to-spec` and publish it to our tracker. The tracker of this project is the folder `tracker/` in the working folder: one Markdown file is one issue.

What we settled:

1. An "export" is one CSV file with the report rows of one team.
2. An export stops at 50,000 rows, and the page says so when it stops.
3. The CSV has one column for each field of a report row: day, shop, orders, revenue.

Left to the developer: who can export, and where the button goes.
