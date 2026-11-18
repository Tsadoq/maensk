---
name: grill-with-docs
description: Use when the user brings an idea, a ticket or a plan and wants its open decisions settled before any code is written, or says "grill me".
---

# grill-with-docs

An agent that recommends an answer gets a yes, and the user later finds a design that they did not choose. This skill puts each open decision to the user with its options and their costs, looks up the facts itself, and writes down only what must outlive the session.

It writes no code, no plan and no spec. The only notes it writes are the glossary and a decision record.

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path, `layout` says where each kind of note goes, and `rules` lists what a note in this vault must follow. Read it with the file tool and pass the path as written, with the `~`. If the file has no `layout`, tell the user to run `maensk-setup`, go on, and write no file.

## Steps

1. Load the `domain-design` skill now, before you read anything else. It finds the unclear terms and keeps the glossary.
2. Gather the facts before you ask anything. Use subagents for the reading when you have them. Read the code that the idea touches, what the codebase already does for a similar case, and the project's notes in the vault: glossary, decision records, ADRs, specs. Run a small test when a fact needs one. In Claude Code, a session opened in the vault needs an allow rule before it reads a repo outside the settings file's `repos` folder: add `Edit(//absolute/path/of/the/repo/**)` to `permissions.allow` in the vault's `.claude/settings.local.json`, keep every other key, and say so in one line. Claude Code asks the user once to approve that write, and the rule works at once.
3. Ask one round, then stop and wait. A round has these parts in this order:
   - `Looked up, not asked:` the facts you found, each with its source. Mark a fact that you assume and did not check. What the user means by a word is not a fact: ask it.
   - One numbered question for each unclear term that `domain-design` found, before the decisions that use the term.
   - Every decision that you can ask now, as numbered questions. A decision that depends on an open answer waits for a later round. If the user asked for a `shallow` round, the whole round has four questions at most: only the decisions that change what the user of the system gets or that are hard to reverse. The rest goes under `Left to the developer`.
   - For each question: one or two plain sentences on what is decided and why it matters, then lettered options. Each option has one benefit and one cost.
   - `Left to the developer:` the details that the person who writes the code can decide later.
4. Read the answers. "Leave it to the developer" answers any question: record it and do not ask it again. When the user asks what you think of their own proposal, test it against the code or with a small experiment and report the result.
5. Offer a decision record only for a decision that is hard to reverse, surprising without its context, and a real trade-off between options. Name the three reasons and write it after the user's yes. A decision record is frontmatter and three sentences: the context, the decision, and why. It is not an ADR: it has no sections and no list of options. It goes to the `path` of the layout's `decision-record` entry. When the layout has no such entry, print the record in chat and tell the user to run `maensk-setup`.
6. Repeat steps 3 to 5 until no decision is open. Then ask the user to confirm.
7. After the yes, end with a fixed report: each decision in one line with its reason, the items left to the developer, the files written. Suggest `to-spec` as the next step.

## One round

```
Looked up, not asked:
- A project is deleted in one step today, with no undo (projects/service.py).
- Each invoice keeps a link to its project (billing/models.py).

Q1 Old invoices. An archived project still has invoices that link to it, so the archive needs a rule for them.
  a. They stay visible. No change to billing. An archived project still shows in the billing lists.
  b. They are hidden with the project. The lists stay short. A hidden invoice is hard to find later.

Q2 Who can archive. An archive hides work from the whole team at once.
  a. Every member. No new permission. One member can hide the work of another.
  b. Owners only. Fewer surprises. A member must ask an owner.

Left to the developer: column name, place of the button.
```

## Red flags

| If you are about to | Then |
| --- | --- |
| Say which option you would pick, or mark one as default | Delete it. The options are equal. |
| Ask the user for a fact | Look it up or test it. Ask only for decisions. |
| Answer your own question and go on | Stop and wait. |
| Decide a point the user left to the developer | List it under `Left to the developer`. |
| Write a decision record that the user did not agree to | Stop. Offer it first. |
| Write code, a plan or a spec | Stop. This skill ends with a decision list. |
