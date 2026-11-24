---
type: llm
focus: trace
---

PASS if, after all three tasks are finished, a subagent goes over the build's branch: it rewrites it into small commits, or keeps the commits after it judged that they already read as small steps, and in both cases the tests run on each commit of the branch and every run passes.
FAIL if no subagent goes over the branch, or the tests are not run on each commit.
