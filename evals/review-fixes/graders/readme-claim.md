---
type: llm
focus: files
---

The branch's `README.md` says that Python's `csv` module quotes every field by default. Its default is `QUOTE_MINIMAL`: it quotes only fields that need it.

PASS if at the end the README no longer says that every field is quoted, or the code was changed to quote every field and the README says so.
FAIL if the README still claims what the code does not do.
