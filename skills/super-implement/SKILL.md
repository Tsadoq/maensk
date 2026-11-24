---
name: super-implement
description: Use only when the request names super-implement, whether the user or super-plan makes it. It builds a plan that super-plan wrote and the user approved, task by task with subagents, test first. A request to build or implement that does not name super-implement is not a call for it.
---

# super-implement

A build that one agent runs alone writes the code and the tests that agree with it, stops between tasks, and ends with changes nobody can explain. This skill builds an approved plan with subagents: one writes each task's tests from the task file, another writes the code, and both prove that the tests catch a broken code. It ends with a branch and a report of a few lines.

| Term | Meaning |
| --- | --- |
| Build | One execution of this skill on one plan, from the call to the final report. |
| Orchestrator | The session that loads this skill. It starts the agents and builds no task itself. |
| Test writer | The agent that writes a task's tests and breaks the code to see them fail. |
| Builder | The agent that writes a task's code. It never changes a test. |
| Judge | A fresh agent on the biggest model that settles one dispute. |

The settings file is `~/.config/maensk/config.json`. Its `mutation` key maps a language to the command of its mutation tool, such as `"python": "mutmut"`. The plan folder holds `plan.md`, `record.md`, `tasks/` and, once a build started, `run.md`. Only the orchestrator writes `run.md`, and it changes nothing else in the plan folder but the status line.

This skill's folder is the base directory given when the skill loaded; do not search the disk for its files. Each agent gets the path of `roles.md` in that folder and the name of its role in that file, the paths it needs, and nothing from this session. Agents that only read or search run on the small model, judges on the biggest, every other agent on the session's model.

## Steps

1. Read `plan.md`. A relative path to the plan folder is relative to the folder the session started in.
   - `Kind: parent`: go to "A parent plan".
   - Status `done`: say that the plan is built, give the branch from `run.md`, and stop.
   - Any status but `ready`: say that the plan needs the user's approval in `super-plan`, and stop.
   - `ready` with a `run.md`: this is a restart. Take the branch and the worktree from `run.md`.
2. Start check, in one agent (`start-check` in `roles.md`): the repo named on the `Repo:` line exists and has no uncommitted change; the build's worktree sets up; the repo's test command runs there; the mutation tool for the repo's language runs; when the settings name none for that language, the build goes on without one, and `run.md` and the report say so; the agent wrote and deleted a file there without being asked for permission. On a new build the agent makes the branch and the worktree: the branch is named after the plan folder, the worktree sits beside the checkout as `<checkout>-<plan folder>`, both from the checkout's last commit. On a restart it also runs the `Done when` of each task that `run.md` logs as finished; a check that fails opens that task again. Anything missing stops the build before any code, with what is missing; the agent removes a branch and a worktree it made. Then write the head of `run.md` (below).
3. Build the plan round by round, in the order of `Rounds`. In a round of one task the task works in the build's worktree. In a round of two or more, make one worktree for each task from the build's last commit, in the temp folder, and start the tasks together, at most six at a time. A task runs as in "One task".
4. After a round of two or more, bring each task's commit into the build's worktree with `cherry-pick`, in task order. On a conflict, start a `merger` agent in the build's worktree; it resolves the conflict and runs the `Done when` of both tasks. Remove the task worktrees.
5. After a task fails, go on with every task that does not depend on it, and stop before the first that does.
6. When every task is finished: start a `historian` agent that rewrites the branch into small commits, each passing the tests. Then set the status line of `plan.md` to `Status: done`. With failed or open tasks, keep one commit per task and leave the status `ready`.
7. Push only when the call says so, or in autopilot, the way the repo documents it (README, CONTRIBUTING, agent instructions); with nothing documented, `git push -u origin <branch>`. After a push, remove the build's worktree. Without a push, keep it.
8. Write "What the next work inherits" at the end of `run.md`, also on a restart whose earlier build ended without it, and give the final report.

## One task

1. With tests: start the test writer with the task file. It writes the tests the task lists, runs them and returns them red, failing because the behaviour is missing. A task with no tests has one builder, and its `Done when` must fail before the change and pass after it.
2. Start the builder with the task file and the paths of the tests. It makes them pass without changing them. It may start helpers of its own.
3. Continue the test writer. It breaks the code once for each test, aimed at that test's behaviour, in a copy of the worktree in the temp folder, and runs the mutation tool there. A break or a surviving mutant that no test catches makes it strengthen the test; the builder then makes the new test pass. It may judge a mutant equivalent, with a reason, which goes to `run.md`.
4. Start four reviewers together, one concern each: the task meets its requirement; the change is the smallest and writes nothing the repo already has; the repo's rules and the user's code rules hold; the tests check behaviour from the outside. Each gets the task file, the task's worktree and the commit it started from, `plan.md`, `record.md` and the equivalent mutants. Reviewers change nothing.
5. Give all findings to one `refuter` agent. A finding that stands goes to the builder, or to the test writer when it is about a test, also when its fix is in a file that the task's `Touches:` does not name: that line is a hint. After a fix, the reviewer of that concern looks once more; what still stands after that goes to `run.md` and to the report.
6. Run the `Done when`. When it passes, commit the task in its worktree with the task's title as the message. Log the task in `run.md`: finished or failed, its commit, its breaks and mutants, the findings that stood. Write one line in chat: the task and finished or failed. Write one line for each stop too.

An agent that is unsure ends its turn with the question. Answer it from the plan files and continue the same agent with the answer (SendMessage in Claude Code). A question the plan does not answer is a plan change, below. When the builder says a test is wrong, a judge gets the task file, `plan.md`, `record.md`, the test and the builder's reason, and decides whether the test goes back to the test writer.

An agent about to rely on a fact that the code alone does not show, such as how a library or a service behaves, checks it with `probe`. The record comes back in its reply and goes to `run.md`.

### A stalled agent

Start every agent in the background. After the start check, start `watch.sh` from this skill's folder in a background shell. It ends with `stalled: <id>` when an agent that has not finished, and every helper it started, wrote nothing to their transcripts for 15 minutes. For an agent that waits for an answer, from you or from the user, the stall means nothing: start the watch again. Otherwise stop that agent, start a fresh one on the same step, once, and start the watch again. A second stall fails the task. Stop the watch before the final report, and before you wait for an answer from the user. In pi, which keeps no such transcripts, give each agent the host's limit on turns instead.

## When the plan is wrong

When a task cannot be built as written, a judge gets the task file, `plan.md`, `record.md` and the agent's finding, also when the answer looks plain to you. If the change keeps the task's requirement and touches no design choice in `record.md`, the judge picks it, it goes to `run.md`, and the task goes on. Any other change is asked: put it to the user as a numbered question, with what the code shows and its file and line, and lettered options with one benefit and one cost each, none marked. Go on with the tasks that do not depend on it.

The task files, `record.md` and the rest of `plan.md` stay as approved. A change lives in `run.md`.

## Autopilot

Autopilot is on only when the user said so: in the call, during the build, or earlier in the session by telling you to go on without them. `super-plan` in autopilot starts this skill in its own session.

- The start check stops nothing: go on as far as you can, and the report names what was missing. With uncommitted changes, build from the last commit and say what was left out.
- A plan change that touches a design choice or a requirement is settled as `super-plan` settles a pick in autopilot: when it is easy to reverse, the judge picks and one agent tries to refute the pick; when it is hard to reverse, one agent argues for each option and the judge decides. It goes to `run.md` with `Picked in autopilot`.
- Nothing stops for the user. The build pushes at the end.

## A parent plan

Outside autopilot, build nothing. Find the first part in the order of `Rounds` that is not `done`: with no folder `<plan folder>/NN-<short name>/`, give `Use super-plan on <path of its brief>`; with a `ready` plan in that folder, give `Use super-implement on <that folder>`; with a `draft`, say that it waits for approval in `super-plan`. When every part is `done`, set the parent's status to `done`.

In autopilot, for each part in order: load `super-plan` with the Skill tool in autopilot on its brief, then build that part by these steps.

## run.md

```
# Build: CSV export of the reports page

Branch: csv-export
Worktree: /home/ana/gits/reports-app-csv-export
Started from: 3f2a91c on main

## Log

- Start check: tests run with `python3 -m pytest`, mutation tool `mutmut`, checkout clean.
- Task 1 finished. Commit 8c1d0e2. Red before the code, green after. 3 breaks caught; 2 mutants survived, one test strengthened, one equivalent: `x >= 0` against `x > 0` on a count.
- Task 2: the plan named `report_rows` ordered oldest first; the code orders newest first. Asked the user.

## What the next work inherits

What now exists, what was decided during the build and by whom, known gaps.
```

## The final report

Five lines, in plain words, in this form. Commits, breaks, mutants and findings are in `run.md`, not here. In autopilot, two lines come before `Left for you`: `Picked in autopilot:` each pick, stated as done, and `Missing or left out:` what the start check found. No line asks the user to confirm or decide. An open question for the user follows the five lines, as "When the plan is wrong" asks it.

```
Built: an export of the team's report rows as CSV, read from the primary database, stopped at 50,000 rows.
Failed or waiting: none.
Left for you: the push; the worktree stays at ~/gits/reports-app-csv-export.
Branch: csv-export. Log: ~/notes/projects/reports-app/plan/csv-export/run.md.
Want an explainer page of the build?
```

## Red flags

| If you are about to | Then |
| --- | --- |
| Write or edit code or a test in this session | Start the agent whose role it is. |
| Judge a dispute or a plan change yourself | Start a judge. |
| Read a task against the code to find a conflict before its agents ran | Start the task; its agents find what does not hold. |
| Let the builder change a test | Send it to the test writer, or to a judge. |
| Trust a test you never saw fail on broken code | Have the test writer break the code. |
| Change a task file, `record.md` or a line of `plan.md` but the status | Write it to `run.md`. |
| Stop between tasks to report or to ask leave | Write one line and go on. |
| Build in the user's checkout | Use the build's worktree. |
| Push without the call saying so, outside autopilot | Leave the branch and say so. |
| Set `done` with a task failed or open | Leave the status `ready`. |
