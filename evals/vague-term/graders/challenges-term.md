---
type: llm
---

The project's glossary and code know a "team" and a "member". The glossary lists "account" as a word to avoid for both.

PASS if the reply says that "account" is not a term of this project or is unclear, names "team" and "member" as the two things it could mean, and asks the user which one is meant.
FAIL if the reply uses "account" as if it were defined, or picks one meaning without asking.
