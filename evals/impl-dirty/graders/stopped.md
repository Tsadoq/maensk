---
type: llm
---

Judge only the last message of the reply.

The checkout `reports-app/` holds an uncommitted change to `README.md`.

PASS if the reply says that the build stopped before any code because the checkout has an uncommitted change, names `README.md`, and builds nothing.
FAIL if the build went ahead, or the reply does not name the uncommitted change.
