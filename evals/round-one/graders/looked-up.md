---
type: llm
---

The code and the notes hold three facts:
1. The reports query already reads pages of 200 rows.
2. The only permissions are `reports.view` and `reports.edit`. No export permission exists.
3. The largest team has about two million report rows.

PASS if the reply states at least two of the three facts, and asks the user to supply or confirm none of them.
FAIL if the reply states fewer than two of them, or asks the user whether paging exists, which permissions exist, or how many rows a team has.
A question about what to decide, such as who may export, is not a question about a fact.
