---
name: grill-with-docs
description: Use when the user brings an idea, a ticket or a plan and wants its open decisions settled before any code is written, or says "grill me".
---

# grill-with-docs

An agent that recommends an answer gets a yes, and the user later finds a design that they did not choose. This skill puts each open decision to the user with its options and their costs, looks up the facts itself, and writes down only what must outlive the session.

It asks what changes for the people who use the system, and the choices about how it is built that are hard to reverse, such as which database an export reads. Every other choice about how it is built belongs to `super-plan`, which asks it after reading the code. When the user raises one, write it down under `Raised, not decided` and do not ask it.

It writes no code, no plan and no spec. The only notes it writes are the feature's decisions file, the glossary and a decision record.

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path, `layout` says where each kind of note goes, and `rules` lists what a note in this vault must follow. Read it with the file tool and pass the path as written, with the `~`. If the file has no `layout`, tell the user to run `maensk-setup`, go on, and write no file.

## Steps

1. Load the `domain-design` skill now, before you read anything else. It finds the unclear terms and keeps the glossary.
2. Gather the facts before you ask anything. Use subagents for the reading when you have them. Read the code that the idea touches, what the codebase already does for a similar case, and the project's notes in the vault: glossary, decision records, ADRs, specs. Run a small test when a fact needs one. When the session has a web search tool, search how other products or projects solve the same problem, and put what helps under `Looked up` with its link; with no such tool, write `Not searched: no web search tool.` there. In Claude Code, a session opened in the vault needs an allow rule before it reads a repo outside the settings file's `repos` folder: add `Edit(//absolute/path/of/the/repo/**)` to `permissions.allow` in the vault's `.claude/settings.local.json`, keep every other key, and say so in one line. Claude Code asks the user once to approve that write, and the rule works at once.
3. Ask one round, then stop and wait. A round has these parts in this order:
   - `Looked up, not asked:` the facts that the questions of this round rest on, one short line each with its source, and no raw output of a command. Mark a fact that you assume and did not check. What the user means by a word is not a fact: ask it.
   - One question for each unclear term that `domain-design` found, before the decisions that use the term.
   - Every decision that you can ask now, and in full every question of an earlier round that is still not answered. If the user asked for a `shallow` round, the whole round has four questions at most: the ones hardest to reverse or that change most for the people who use the system. The rest goes under `Left to the developer`.
   - `Next round:` the title of each decision that depends on an answer still open. Drop this part when there are none.
   - `Left to the developer:` the details that the person who writes the code can decide later.

   Each question is its own block, in the format of the example below: a heading with its number and a title of a few words, one or two plain sentences on what is decided and why it matters, then a table with one row per lettered option and the columns Option, Benefit and Cost. A cell is one short sentence. The user answers with the number and the letter, such as `1b`.

   When the options differ in a structure that the table cannot show, such as which part calls which or where the data goes, draw each option as a small ASCII diagram in a code block above the table. When a diagram does not fit in about ten lines, start `explainer` in the background with the question and its options instead, send the round without waiting, and give the page's link when it returns, with one line that says this skill started it. With no subagent tool, draw the ASCII diagram.
4. Read the answers. "Leave it to the developer" answers any question: record it and do not ask it again. When the user asks what you think of their own proposal, test it against the code or with a small experiment and report the result.

   Then write the feature's decisions file, and update it after each later round. Its path is the layout's `decisions` entry: `<feature>` is a short name of the feature in lowercase with hyphens, such as `csv-export`, and `<title>` its name. It holds the parts `Decided` (one line each, with the reason in the user's words when one was given), `Raised, not decided`, `Left to the developer` and `Open`, and follows `rules`. It is what `to-spec` and `super-plan` read when this chat is gone, so a decision that is only in the chat is lost. Write what this chat holds. When earlier answers are not in the chat, state in the report that they are missing, and do not ask for them. When the layout has no `decisions` entry, print the file in chat and tell the user to run `maensk-setup`.
5. Offer a decision record only for a decision that is hard to reverse, surprising without its context, and a real trade-off between options. Name the three reasons and write it after the user's yes. A decision record is frontmatter and three sentences: the context, the decision, and why. It is not an ADR: it has no sections and no list of options. It goes to the `path` of the layout's `decision-record` entry. When the layout has no such entry, print the record in chat and tell the user to run `maensk-setup`.
6. Repeat steps 3 to 5 until no decision is open. Then ask the user to confirm.
7. After the yes, end with a fixed report: each decision in one line with its reason, the items left to the developer, the items raised and not decided, the files written. Suggest `to-spec` on the decisions file as the next step.

## One round

```
Looked up, not asked:
- A project is deleted in one step today, with no undo (projects/service.py).
- Each invoice keeps a link to its project (billing/models.py).

### 1. Old invoices
An archived project still has invoices that link to it, so the archive needs a rule for them.

| Option | Benefit | Cost |
| --- | --- | --- |
| a. They stay visible | No change to billing. | An archived project still shows in the billing lists. |
| b. They are hidden with the project | The lists stay short. | A hidden invoice is hard to find later. |

### 2. Who can archive
An archive hides work from the whole team at once.

| Option | Benefit | Cost |
| --- | --- | --- |
| a. Every member | No new permission. | One member can hide the work of another. |
| b. Owners only | Fewer surprises. | A member must ask an owner. |

Next round:
- 3. Restore an archived project

Left to the developer: column name, place of the button.
```

## Red flags

| If you are about to | Then |
| --- | --- |
| Say which option you would pick, or mark one as default | Delete it. The options are equal. |
| Ask the user for a fact | Look it up or test it. Ask only for decisions. |
| Answer your own question and go on | Stop and wait. |
| Decide a point the user left to the developer | List it under `Left to the developer`. |
| Ask a choice about how it is built that is easy to reverse | Write it under `Raised, not decided` if the user raised it; otherwise leave it to `super-plan`. |
| Write a decision record that the user did not agree to | Stop. Offer it first. |
| Write code, a plan or a spec | Stop. This skill ends with a decision list. |
| Write "merge" for anything but a git merge | Say what happened: "picked onto the branch" for a cherry-pick, "combined" for findings or notes. |
