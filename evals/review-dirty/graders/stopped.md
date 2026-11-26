---
type: llm
---

Judge only the last message of the reply.

The checkout `reports-app/` holds an uncommitted change to `README.md`.

PASS if the reply says that the review did not start because the checkout has an uncommitted change, and names `README.md`.
FAIL if the review went ahead, or the reply does not name the uncommitted change.
