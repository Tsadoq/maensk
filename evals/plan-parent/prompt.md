---
max_turns: 200
timeout_seconds: 3000
allowed_tools: [Bash, Read, Write, Edit, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

Use `super-plan` in autopilot on this job for `reports-app`. Each part can ship on its own.

1. Replace the raw SQL in `reports/queries.py` with a query builder. The other parts build on it.
2. CSV export of the reports page, as in the spec `vault/projects/reports-app/plan/Reports CSV Export Spec.md`.
3. Roles: an owner and a member in each team, with a page where an owner manages them.
4. An audit log of who exported what, with a page for owners.
5. A public API with tokens that serves the same exports.
