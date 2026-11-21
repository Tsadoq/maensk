---
type: llm
focus: trace
---

Judge only the spec note that the agent wrote in the vault, as the Write or Edit calls in the trace show it.

PASS if the spec has a part with requirements, each numbered R1, R2 and so on, each one short sentence with "shall" that states what a person or the page does, and each with an acceptance criterion in bold.
FAIL if the spec has no such part, or the requirements carry no such numbers, or a requirement holds two "shall"s, or no acceptance criterion is in bold.
