---
name: probe
description: Use before relying on or stating a fact about code, a system, a library or a model that a run can settle; when the user asks to prove, verify, test or probe a claim; or to build a throwaway version of a design to find what it misses.
---

# probe

A claim checked by reading the code, or by a test that could not fail, gets trusted and breaks later. This skill settles a claim with the smallest real run that could prove it wrong, and says what that run does not show.

It works in a subagent, so the session that asked goes on. It writes nothing in the user's working copy.

## Steps

In the session that loads this skill:

1. Write each claim as one sentence that a run can prove wrong. A design to try is a build: its claim is that the design works for the cases the user named.
2. Start one subagent in the background for each claim or build, and go on with your work. Give it the claim, the paths it needs, what is already known, and this line: load the `probe` skill and run steps 4 to 10. With no subagent tool, run them yourself.
3. When a record comes back, show it to the user as it is.

In the subagent that runs one claim or build:

4. Make a new folder under the temp folder (`mktemp -d`). When the run needs the repo's code, import it from the repo or put a git worktree in that folder. Write nothing in the user's working copy.
5. Test the claim as it was stated, with a real run of the real code or system. Reading the code is not a proof. For a claim about how a model behaves, a run of a subagent is the experiment.
6. Before you trust a pass, see the test fail once: run it on a case where the claim must not hold.
7. For a claim about speed or size, run each case at least ten times on the same data, and give the mean and the range. A build times nothing unless the design states a speed or a size.
8. Load a key from its file into the environment (`set -a; . ./file; set +a`). Never read, print or write its value.
9. A change outside the folder: run the command that the repo documents for it (README, Makefile, agent instructions) for a deploy or a test, name it in the record, and undo the change afterwards. For any other change, such as a paid call or a write to a shared system, stop and report what you need.
10. Delete the folder of a claim. Keep the folder of a build and give its path. Then return the record below and nothing else.

## The record

```
Claim: the retry wrapper gives up after three attempts.
Ran: python3 /tmp/tmp.k3Jd/retry_probe.py, against a stub server that always fails.
Can fail: with the limit set to five, the same script counted five attempts.
Observed: three attempts in 10 of 10 runs, 0.6 s apart.
Result: holds.
If it had failed: a dead server would get calls without end.
Not shown: the real server's errors; only a refused connection was tested.
```

`Result` is one of `holds`, `does not hold` or `not settled`. A build adds `Found:`, the points the design does not cover or gets wrong, and `Kept: <path>, until the user says to delete it.`

## Red flags

| If you are about to | Then |
| --- | --- |
| Run the experiment in the session that asked | Start a subagent and go on. |
| Answer from reading the code | Run it. |
| Trust a pass you never saw fail | Make it fail once first. |
| Test an easier claim near the one asked | Test the claim as stated, or mark it `not settled`. |
| Time something once | Run it ten times and give the mean and the range. |
| Print, read or echo a key | Load it into the environment from its file. |
| Write in the user's working copy | Use the temp folder. |
| Leave out what the run did not cover | Put it under `Not shown`. |
