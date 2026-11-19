---
type: llm
focus: trace
---

Judge only the spec note that the agent wrote in the vault, as the Write or Edit calls in the trace show it.

PASS if the spec says that an export reads the primary database, gives the reason (finance compares an export with the bank in the same minute), and says that this is an exception to ADR-001 or to the rule that reports read the replica database.
FAIL if the spec says an export reads the replica database, or leaves out the reason or the exception.
