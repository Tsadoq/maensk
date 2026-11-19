---
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Bash, Read, Write, Edit, Glob, Grep, Skill, Agent]
---

Use `probe` to build a throwaway version of this design for `reports-app` and tell us what we missed.

What we settled:

1. An export is one CSV file with the report rows of one team.
2. The export reads the rows page by page with `report_rows`.
3. The export stops at 50,000 rows and says so.
