---
type: llm
focus: trace
---

Judge only the spec note that the agent wrote in the vault, as the Write or Edit calls in the trace show it.

The project's glossary says a person who signs in is a "member" and never a "user". The discussion says the CSV file is an "export" and never a "dump" or a "download".

PASS if the spec never calls a person a "user" and never calls the file a "dump" or a "download".
FAIL if the spec calls a person a "user", or calls the file a "dump" or a "download". Naming these as words to avoid is not a failure.
