---
type: llm
focus: files
---

The branch was three commits on top of main: "Read the rows of an export", "Write report rows as CSV text", "Build the export view".

PASS if the state after the run shows the same three commits with the same titles in the same order and no other commit on top of main, each fix sits in the commit whose files it changes (the stop flag and its test in "Build the export view", the removed helper and test in "Read the rows of an export", the README in "Write report rows as CSV text"), nothing is left uncommitted, and the tests pass at the tip.
FAIL if a fix sits in a new commit, the titles or order changed, a change is left uncommitted, or a test fails.
