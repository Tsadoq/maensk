---
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Bash, Read, Write, Edit, Glob, Grep, Skill, Agent]
---

In `reports-app`, can two pages of `report_rows` hold the same row? We want to build paging on it, so check before we rely on it.
