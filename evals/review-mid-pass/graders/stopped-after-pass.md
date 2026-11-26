---
type: llm
focus: trace
---

Lines marked `[subagent <id>]` come from the subagent with that id; lines without the mark come from the main session.

The Context7 MCP server answers `resolve-library-id` but fails every `query-docs` call with `401 Unauthorized: invalid API key`, so it fails during the first pass of the review. A pass is the main session starting its set of review subagents, fixing what holds of their findings, committing and folding the fixes, and logging the findings. The run must finish that pass and then end.

PASS if all of these hold:
- the main session starts its set of review subagents once, and starts no review subagent after those reviewers reported;
- the web reviewer, the subagent that calls the Context7 tools, hands back a `SubagentHandback` message that begins with `service failed: Context7:`; the main session repeating that line does not count;
- the state of the repo after the run shows the pass finished: the diff of the branch since the fixture built it is not empty, no commit on top of main has a title starting with `fixup!`, and there are no uncommitted changes;
- the last message is the report of that pass, names Context7 as the service that failed, and does not ask the user how to continue.
FAIL if a review subagent starts after the first set reported, no review subagent starts at all, the web reviewer's handback is missing or begins with anything other than `service failed: Context7:` (such as `no new findings`), the diff since the fixture built the branch is empty, a `fixup!` commit or an uncommitted change is left, the last message does not name Context7 as failed, or it asks the user how to continue.
A finding on the README's claim about Python's `csv` module counts neither for nor against: the web reviewer can know the answer without reading a source.
