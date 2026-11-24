---
name: super-plan
description: Use only when the request names super-plan, whether the user, another skill or a parent plan makes it. It turns a spec, a brief or a finished discussion into a plan of small tasks before code is written. A request to plan that does not name super-plan is not a call for it.
---

# super-plan

A plan that settles how to build without the user, or that only its writer can follow, gets built wrong or is not read. This skill cuts a job into small tasks that an agent with no context can build, puts each design choice to the user with its options and their costs, and checks each pick with a real run.

It writes no code in the repo. It writes one plan: a folder of notes in the vault.

A design choice is a choice about how something is built. A gap is a point about what the people who use the system get that the input does not decide.

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path, `layout.plan.path` is the folder a plan goes to, and `rules` lists what a note in this vault must follow. Read it with the file tool and pass the path as written, with the `~`. If the layout has no `plan` entry, tell the user to run `maensk-setup` and stop.

## Steps

1. Load the `probe` skill and the `explainer` skill now, before you read anything else.
2. Read the input that the user named: a spec, a brief, a ticket, a note or the conversation. Find the project's folder in the vault and read its glossary, decision records and ADRs. If the input does not say what changes for the people who use the system, list what is missing, write a prompt for a new chat that starts `grill-with-docs` on it, or `to-spec` when only the write-up is missing, put the prompt in a code block, and stop.
3. State the scope in a few lines: what the plan covers and what it leaves out. With a spec these are its Solution and its Out of scope. Then stop and wait for a yes. Ask nothing else in this message. Skip this step when the user already confirmed the scope.
4. Read the code that the job touches, with subagents for the reading, and cut the job into tasks. Look up a fact only where the cut needs it. Collect the design choices and the gaps. A part of a spec that says "Not decided" is a gap. An item that the input leaves to the developer is a design choice when it changes the cut; otherwise it goes to the builder with its task. What the input or the user already decided is never asked again: when the code contradicts it, report that with the evidence.
5. Ask one round, then stop and wait. A round has these parts in this order:
   - `Looked up, not asked:` the facts you found, each with its source.
   - Every design choice and every gap that you can ask now, as numbered questions. There is no limit on questions or on rounds.
   - For each question: one or two plain sentences on what is decided and why it matters, then lettered options. Each option has one benefit and one cost. Mark none, also when a rule of the folder you run in says to recommend one.
   - `Left to the builder:` the details that the agent who builds a task can decide. Name them and give no default.

   "Leave it to the builder" answers any question: record it and do not ask it again. When the user said that the rest is the builder's, ask nothing more.

   Use text. Only for a design choice about structure that text cannot show, or when the user asks, show the options as a page with `explainer`.
6. After each answer, save the draft (`plan.md` with the status `draft`, and `record.md`) and check the pick: each assumption under it, against the documentation of what it uses, and with `probe` where a run can settle it. Use a build when the pick cannot be cut into claims. Put each record into `record.md`. A check that does not hold brings its design choice back in the next round, with the record. Repeat steps 5 and 6 until no design choice and no gap is open and every check is back.
7. Write the plan in the format below.
8. Start two things together:
   - The plan page, with `explainer`. The brief names the plan folder and these sections: today against after on one real example, the tasks in run order with their tests, the design choices with what was refused, what was checked and what was not.
   - Three critics, each a subagent that gets only the plan folder and the repo. The builder: can each task be built from its file alone, and can its `Done when` fail? The scope: a requirement with no task, a task that nothing asked for, work from the left-out part. The tests: does each assertion prove its behaviour, and is something replaced that should run real?

   Give the findings to one more subagent that tries to refute each of them. Fix what stands, note each finding in `record.md`, and send the fixes to the page's subagent. A finding that changes something the user picked is not fixed: it goes to the user in step 9 as a question.
9. Give the user the page, the fixes and what was not verified, in a few lines each, and ask for approval. The page explains the plan; the message does not repeat it. For a change the user asks for: change the files, update the page at the same link, and ask again. After the yes, set the status in `plan.md` to `ready`.
10. End with the plan folder's path, the page, and this: compact the conversation, then say `Use super-implement on <path>`.

## Autopilot

Autopilot is on only when the user said so: in the call, during the run, or earlier in the session by telling you to go on without them. Then no step waits for the user.

- The scope and each gap: settle it, and record it as an assumption with a G id.
- Each design choice: name its options and the one with the smallest change and the best outcome. Before you record anything, put it to subagents. When the pick is easy to reverse, one subagent tries to refute it. When it is hard to reverse, one subagent argues for each option and one more judges. Then record the pick, the refused options, the argument that won, and `Picked in autopilot`. A check that does not hold, or a critic's finding against a pick, goes back to these subagents and not to the user.
- An input that is too unclear, or a missing access or key: go on, mark what rests on it `not verified`, and say so in the last message.
- After the critics and the page, set the status to `ready`. When the call asked for plan and build, load `super-implement` with the Skill tool and give it the path. If it is not installed, say so.

## A job too big for one plan

When the parts of a job can each be built and used alone, or the job needs more than about fifteen tasks, propose a parent plan. The cut into parts is a design choice.

A parent plan goes through the same steps and has the same files. `plan.md` says `Kind: parent`. Each file in `tasks/` is the brief of one part: what the part delivers in at most five lines, `After:` and `Serves:`, with no tests and no steps in the code. `plan.md` gives for each part the line that starts it: `Use super-plan on <path of the brief>`. Each part is planned by its own call, just before it is built, in the folder `<plan folder>/NN-<short name>/`, and has its own status.

## The plan

The folder is the layout's path. For `<title>` use a short name of the job in lowercase, with hyphens and no spaces, such as `csv-export`. The file names are fixed: `plan.md`, `record.md` and `tasks/NN-<short name>.md`. Every file follows `rules`.

`plan.md` is the index:

```
# CSV export of the reports page

Status: draft
Repo: ~/gits/reports-app
Input: [[Reports CSV Export Spec]]
Goal: A member of finance gets the report rows of the team as one CSV file.
Scope: in, the export and its limit. Out, Excel files and exports on a schedule.

## Requirements

| Id | Requirement | Tasks |
| --- | --- | --- |
| R2 | An export shall stop at 50,000 report rows. | 1, 2 |
| G1 | The export is tested against a database in memory. | 1 |

## Tasks

| # | Task | After | File |
| --- | --- | --- | --- |
| 1 | Read the rows of an export | none | tasks/01-export-rows.md |

## Rounds

1. Tasks 1, 3
2. Task 2
```

`Repo:` is the path of the checkout the plan is built from. The R ids are the spec's. With no spec, list what the people who use the system get and number it yourself. A G id is a gap that was settled in planning; a design choice has no row here. `Rounds` lists the tasks that can run together.

One file for each task, `tasks/NN-<short name>.md`, that a builder can follow with no other file:

```
# Task 1: Read the rows of an export

Plan: CSV export of the reports page. A member of finance gets the report rows of the team as one CSV file.
Rests on: one query reads up to 50,001 rows, and a 50,001st row means that the export stopped.

Add `export_rows(primary, team_id)` to `reports/queries.py`. It returns up to 50,001 rows of the team in the order of `report_rows`.
It reads the primary database, never the replica database.
Tests:
- A team gets its own rows only. Asserts: with 3 rows of team 1 and 2 rows of team 2, `export_rows(db, 1)` returns the 3 rows of team 1. Level: component. Real: the query on SQLite in memory. Replaced: nothing.
Done when: `pytest tests/test_export_rows.py` passes.
After: none
Touches: `reports/queries.py`, `tests/test_export_rows.py`
Serves: R2, G1
```

A task is one sentence on what to do and at most two more lines. It says what the code does and leaves the code to the builder. A task file that grows past about 250 words is two tasks: split it. `Rests on:` states in words each design choice the task needs. `Tests:` lists the behaviours the task makes pass, at the outer boundary; a task with no code has none. `Done when:` is one command or observation that can fail. `Touches:` is a hint, not a limit.

`record.md` holds why the plan is what it is. The builder does not need it.

```
# Record: CSV export of the reports page

## Design choices

### 1. How the export reads its rows
Picked: one query with a limit of 50,001. Picked by the user.
Refused: page by page with `report_rows`, which costs 250 queries for one export.
Why: the user's reason, or in autopilot the argument that won.
Checked: the record of the check, or `not verified:` and why.

## Settled in planning

- G1. How the export is tested: against a database in memory. Answered by the user.

## Checks

Each record of `probe` as it came back. For a build: its path, what it found, and the few lines of its code that show it.

## Critics

- Task 2 named no file for its test. Fixed in task 2.
```

`super-implement` builds only a plan with the status `ready`, and writes its own notes to `run.md` in the plan folder. The plan's files stay as approved, but for the status line, which it sets to `done` when every task is built.

## Red flags

| If you are about to | Then |
| --- | --- |
| Say which option you would pick, outside autopilot | Delete it. The options are equal. |
| Ask again what the spec or the user decided | Use the decision. |
| Settle a design choice or a gap yourself, outside autopilot | Ask it. |
| Trust an assumption because the code reads that way | Check it with `probe`. |
| Record a pick in autopilot that no subagent argued against | Start the subagent first. |
| Write the code of a task into its file | Say what the code does. |
| Write a task that points at another file for what it needs | Say it in the task. |
| Set the status to `ready` before the user's yes, outside autopilot | Leave it `draft`. |
| Write code in the repo | Stop. This skill ends with a plan. |
