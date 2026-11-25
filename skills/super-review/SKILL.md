---
name: super-review
description: Use only when the request names super-review, whether the user or another skill makes it. It runs a roster of reviewers over a finished branch, pass after pass, fixing what needs no choice until a pass fixes nothing. A request to review, check or give an opinion on a branch that does not name super-review is not a call for it.
---

# super-review

One reviewer misses what a second one sees, and a review that stops after one look leaves the faults its own fixes made. This skill runs a roster of reviewers over a finished branch, fixes what needs no choice, and runs them again until a pass fixes nothing.

| Term | Meaning |
| --- | --- |
| Roster | The reviewers of one run. |
| Pass | One run of the whole roster over the range. |
| Range | The commits under review. |
| Context | The plan, spec, decision records and ADRs of the repo's project, and what the session discussed. |

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path and `layout` says where each kind of note goes. Read it with the file tool and pass the path as written, with the `~`.

The reviewer skills are folders under `~/.config/maensk/reviewers/`: `code-review`, `security-review` and `ponytail-review`. A reviewer reads `<folder>/SKILL.md` by path.

## Before the first pass

Run these checks yourself, in this order, in the repo the call names. They change nothing: no checkout, stash, commit or install. Start no agent before all of them hold. At the first one that fails, stop and give its message as the whole reply.

1. `git status --short` is empty. Otherwise stop:
   ```
   Review not started: the checkout has uncommitted changes.
   Changed: <each changed file by name>
   Commit or stash them, then call super-review again.
   ```
2. The range is the one the call names. By default it runs from the merge-base with the default branch to the branch the call names, or to `HEAD` when it names none. When the range ends at a commit or a tag and not at a branch, ask the user for a branch and wait.
3. Each reviewer folder holds `SKILL.md`, and a web search tool exists. Otherwise stop:
   ```
   Review not started: missing <each missing reviewer by name and its folder, or the web search tool>.
   To install it, run install.sh again with the flags you installed with, plus --review-tools.
   ```
4. Find the context: read the settings file, and find the project's folder in the vault: match the repo's name against the project folders. One match: say which. None or several: ask. There, read the plan, spec, decision records and ADRs at the paths `layout` gives. Add what the session discussed. With nothing found, ask the user for paths and wait.

## Red flags

| If you are about to | Then |
| --- | --- |
| Stash, commit or check out to get the checkout clean | Stop with the changed files. |
| Run `install.sh` yourself | Name the rerun and stop. |
| Start a pass with the reviewers that are there | Stop; the roster runs whole or not at all. |
| Start an agent before the checks hold | Finish the checks first. |
