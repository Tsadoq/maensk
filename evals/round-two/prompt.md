---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

We are settling the open decisions for CSV export on the reports page of `reports-app`. No code yet. You asked a first round of questions. My answers:

1. What do we call the CSV file that a team gets? Answer: an "export". One export is one CSV file with the report rows of one team. Never call it a dump or a download.
2. Large reports: send every row, or stop at a limit? Answer: stop at 50,000 rows and say so on the page.
3. Who can export: every member who can view, or a new permission? Answer: leave it to the developer.

Go on from here.
