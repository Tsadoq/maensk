---
type: llm
---

Judge only the last message of the reply.

The plan's status is `draft`: the user has not approved it.

PASS if the reply says that the plan is not approved (not `ready`), builds nothing, and says how to get it approved.
FAIL if the reply builds the plan or offers to build it as it is.
