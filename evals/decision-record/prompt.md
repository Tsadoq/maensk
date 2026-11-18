---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

We are in a `grill-with-docs` session on CSV export for the reports page of `reports-app`. No code yet. Two rounds are done. My last answers:

1. Which database an export reads: the primary database, not the replica database. The finance team compares an export with the bank in the same minute, and rows that are five minutes old make the totals wrong. I know that ADR-001 says the opposite. This is the one exception.
2. You asked if this decision should be written down, so that nobody undoes it later: yes, write it.

Nothing else is open. I confirm.
