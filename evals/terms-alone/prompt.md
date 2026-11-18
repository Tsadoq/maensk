---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
append_system_prompt: "The home folder of this session is the parent folder of the working folder."
---

Help me settle the terms of `reports-app` and write its glossary. In meetings people say "account", "customer" and "user", and the code says something else. I have decided two of them:

1. A "team" is the group of people that shares one set of reports. Never call it an account or a customer.
2. A "member" is one person who signs in. Never call a member a user.

Write these down. Then tell me which other terms are still unclear.
