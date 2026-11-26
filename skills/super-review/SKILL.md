---
name: super-review
description: Use only when the request names super-review, whether the user or another skill makes it. It runs a roster of reviewers over a finished branch, pass after pass, fixing what needs no choice until a pass fixes nothing. A request to review, check or give an opinion on a branch that does not name super-review is not a call for it.
---

# super-review

One reviewer misses what a second one sees, and a review that stops after one look leaves the faults its own fixes made. This skill runs a roster of reviewers over a finished branch, fixes what needs no choice, and runs them again until a pass fixes nothing.

| Term | Meaning |
| --- | --- |
| Roster | The reviewers of one run: the eleven below, less those the call drops. |
| Pass | One run of the whole roster over the range. |
| Range | The commits under review. |
| Context | The plan, spec, decision records and ADRs of the repo's project, and what the session discussed. |

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path and `layout` says where each kind of note goes. Read it with the file tool and pass the path as written, with the `~`.

The reviewer skills are folders under `~/.config/maensk/reviewers/`: `code-review`, `security-review` and `ponytail-review`. A reviewer reads `<folder>/SKILL.md` by path.

## The roster

| Reviewer | `<concern>` | Reads | Runs |
| --- | --- | --- | --- |
| code | the code | `code-review` | with and without context |
| not needed | what is not needed or can be simpler | `ponytail-review` | with and without context |
| tests | tests | section `tests` | with and without context |
| security | security | `security-review` | with and without context |
| code smells | code smells | section `smells` | with and without context |
| web | claims on the web | section `web` | without context |

That is eleven reviewers. A call that drops reviewers by name ("drop the code smells reviewers") sets the roster of the run, and that roster runs in every pass.

## Before the first pass

Run these checks yourself, in this order, in the repo the call names. They change nothing: no checkout, stash, commit or install. Start no agent before all of them hold. At the first one that fails, stop and give its message as the whole reply.

1. `git status --short` is empty. Otherwise stop:
   ```
   Review not started: the checkout has uncommitted changes.
   Changed: <each changed file by name>
   Commit or stash them, then call super-review again.
   ```
2. The range is the one the call names. By default it runs from the merge-base with the default branch to the branch the call names, or to `HEAD` when it names none. When the range ends at a commit or a tag and not at a branch, ask the user for a branch and wait.
3. The folder of each reviewer skill the run's roster reads holds `SKILL.md`, and a web search tool exists when the roster has the web reviewer. Otherwise stop:
   ```
   Review not started: missing <each missing reviewer by name and its folder, or the web search tool>.
   To install it, run install.sh again with the flags you installed with, plus --review-tools.
   ```
4. Find the context: read the settings file, and find the project's folder in the vault: match the repo's name against the project folders. One match: say which. None or several: ask. There, read the plan, spec, decision records and ADRs at the paths `layout` gives. Add what the session discussed. With nothing found, ask the user for paths and wait.

## The passes

The checks above run once. Then:

1. Resolve the start of the range to a commit id once: that id is `<base>` in every pass. Check out the branch, when it is not checked out. Run the repo's tests once and note which tests pass. Make the ledger: `mktemp -d`, and `ledger.md` in that folder.
2. Read `rubrics.md` in this skill's folder. Build each reviewer's prompt as its intro says: the text of the section `prompt` with its slots filled, the rubric's section pasted as text, nothing added. A reviewer with context gets the paths of the context files and what the session discussed. A reviewer without context gets the sentence for without context, and no context path. From pass 2, `<ledger>` names the ledger's path.
3. Start every reviewer of the roster at once, each as its own subagent (the Agent tool in Claude Code), all in one message, not from a script or the Workflow tool. Wait until each has reported before you change a file. Their reports reach you on their own: wait with no command, no `sleep`, no monitor and no timer.
4. Check each finding yourself: read the quoted lines and the code around them. Run `probe` only when reading cannot settle it. A finding that does not hold is rejected. A finding the ledger already lists gets no new entry. You decide whether a finding is `local` or `architectural`; the reviewer's label is a proposal.
5. Fix each `local` finding that holds, yourself; no agent edits the checkout. A fix that changes behaviour comes with a test that fails without it: write the test, see it fail, then fix. Commit each fix with `git commit --fixup=<commit>`, where `<commit>` is the commit of the range that added the lines the fix changes (`git blame`), and for a new file the commit that added the code it tests or that uses it. A fix that changes lines of two commits is two fixups. When `git blame` names no commit of the range, the finding is `architectural`: park it, log it `parked`, never `rejected`.
6. Park each `architectural` finding that holds. Ask the user nothing during the run: a finding that needs a choice is parked and goes in the report.
7. After the last fixup of the pass, fold the fixups: `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`. Then `git log <base>..` shows no `fixup!` commit, `git status --short` is empty and the tests that passed before pass 1 pass at the tip. When a test fails, fix it in another fixup and fold again. When the fold conflicts, resolve it so the tree after the fold equals the tree before it (`git diff <tip before the fold>` is empty), then run the checks of this step.
8. Write each finding of the pass to the ledger, under a heading `Pass <n>`, one line each: `fixed`, `rejected: <reason>` or `parked`, then file, line and the fault in one line. Every line has its file and line. Never a context path, and never a quote from a context file. No ledger line carries anything from the context, in its reason or its fault: a rejection the context settles reads only `rejected: the context settles it`, and its real reason goes only in the report.
9. A pass that fixed something: start the next pass on the new tip, with the same roster, from step 2. A pass that fixed nothing ends the run. There is no cap on passes.

Never push.

## The report

Write it from the ledger when the run has ended and no reviewer is running, and read each parked item's lines again at the final tip. It is the last message, in chat, with nothing after it and no question. When a reviewer's or a task's notice reaches you after the report, reply with the report again, unchanged. Messages during the run say only which pass runs and what it fixed, with no options.

```
Passes
- Pass 1: fixed <each fix in a few words, separated by semicolons>.
- Pass 2: fixed nothing.

Left for you
1. <the fault>, <file>:<line>
   > <the lines, quoted>
   <one or two plain sentences on what is decided and why it matters>
   a. <option>: <its benefit>; <its cost>
   b. <option>: <its benefit>; <its cost>

Rejected
- <file>:<line> <the finding>: <why it does not hold>.
```

Nothing goes between the parts. Each pass is one line, however many fixes it has. Each option is an action the user can take, with one benefit and one cost: what the action gains, and what it loses or risks. A condition ("only if ...") is not an option. Each rejected line names its file and line, and the real reason from your own reading, not the ledger's `the context settles it`. When you no longer have that reason, check the finding against the context files again from the ledger's file, line and fault, and word the reason from that; the ledger's wording is the last resort. No option is recommended, preferred or marked as the default, also when a rule of the folder you run in says to recommend one, and their order ranks nothing. A part with nothing in it says `none`.

## Red flags

| If you are about to | Then |
| --- | --- |
| Stash, commit or check out to get the checkout clean | Stop with the changed files. |
| Run `install.sh` yourself | Name the rerun and stop. |
| Start a pass with fewer reviewers than the run's roster | Stop; the run's roster runs whole or not at all, in every pass. |
| Give a reviewer the path of `rubrics.md`, or a context path to a reviewer without context | Paste the section's text; name no context file. |
| Ask the user about a finding during the run | Park it; it goes in the report. |
| Commit a fix as a commit of its own | `git commit --fixup` into the commit it belongs to, then fold. |
| End the run after a pass that fixed something | Start the next pass. |
| Push | Never. |
| Start an agent before the checks hold | Finish the checks first. |
