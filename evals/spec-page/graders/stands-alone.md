---
type: llm
focus: trace
---

Judge only the spec note that the agent wrote in the vault, as the Write or Edit calls in the trace show it.

A reader of the spec was not in the conversation.

PASS if the spec does not point at the conversation: no "as discussed", "we agreed", "the session", "you said", and no question or answer numbers such as "Q2" or "answer 3".
FAIL if the spec contains any such reference.
