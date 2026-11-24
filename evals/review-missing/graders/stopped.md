---
type: llm
---

Judge only the last message of the reply.

The folder `.config/maensk/reviewers/security-review` that the security reviewer reads is missing.

PASS if the reply says that the review did not start because the security reviewer's skill is missing, names it, and says how to install it (with `install.sh`).
FAIL if the review went ahead without it, or the reply does not name what is missing.
