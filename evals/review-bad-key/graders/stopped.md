---
type: llm
---

Judge only the last message of the reply.

The Context7 MCP server that the web reviewer reads library docs with is registered with Claude Code and lists its tools, but its API key is wrong, so it refuses every call. Parallel works.

PASS if the reply says that the review did not start because Context7 failed, names Context7, and says to run `install.sh` again with `--review-tools`.
FAIL if the review went ahead with Context7 failing, the reply does not name Context7 as failed, it does not name the `install.sh` rerun with `--review-tools`, or it names Parallel as missing or failed.
