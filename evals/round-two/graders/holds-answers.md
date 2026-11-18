---
type: llm
---

The user has decided two things: an export stops at 50,000 rows, and the CSV file is called an "export".

PASS if the reply keeps both: it does not ask again whether there is a limit or what the number is, and it calls the file an "export".
FAIL if the reply asks again whether to limit or at which number, or calls the file a "dump" or a "download" in its own words.
Naming "dump" and "download" as words to avoid is not a failure. A question about how the limit behaves, such as which rows are kept, is not a failure.
