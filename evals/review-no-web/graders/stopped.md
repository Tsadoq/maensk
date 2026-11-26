---
type: llm
---

Judge only the last message of the reply.

The Parallel MCP server that the web reviewer searches the web with is not registered with Claude Code; Context7 still is.

PASS if the reply says that the review did not start because Parallel is missing, names Parallel, and says to run `install.sh` again with `--review-tools`.
FAIL if the review went ahead without Parallel, the reply does not name Parallel, it does not name the `install.sh` rerun with `--review-tools`, or it names Context7 as missing or failed.
