---
name: to-spec
description: Use when the decisions about an idea or a plan are settled and the user asks to write them up as a spec, or to publish that spec to an issue tracker.
---

# to-spec

A spec that fills a gap with a guess, or that only the people in the conversation can follow, gets built wrong. This skill writes down what was decided, on one page that a reader who was not there can follow, and marks what was not decided.

It asks nothing about the feature and adds no decision. It writes one file, the spec, and publishes it only after the user's yes.

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path, `layout` says where each kind of note goes, and `rules` lists what a note in this vault must follow. Read it with the file tool and pass the path as written, with the `~`. If the file has no `layout`, tell the user to run `maensk-setup`, print the spec in chat, and write no file.

## Steps

1. Collect what was decided: the feature's decisions file, which `grill-with-docs` writes to the layout's `decisions` path, then the conversation and the notes the user names. If nothing was decided, say so, suggest `grill-with-docs`, and stop without writing.
2. Find the project folder in the vault. Match the repo's name and the topic against the project folders, and read `<name>` off the titles of the notes there. State one match; ask when there is none or several. Read the project's glossary, decision records and ADRs.
3. Write the spec with the parts below to the `path` of the layout's `spec` entry, from its `template` when it has one. `<feature>` is the folder of the decisions file; with none, a short name of the feature in lowercase with hyphens, such as `csv-export`. If a spec on this topic exists, ask before you replace it.
4. End with the report below and nothing else.
5. Publish only on request, and only after the user has read the file and said yes. Use the tracker the session has a tool for. Ask which one when there are several or it is not clear.

## The spec

- Problem: what the people who use the system cannot do today.
- Solution: what changes, in two or three sentences, and not how the code does it.
- Requirements: few, numbered R1, R2 and so on, one sentence each with one "shall", on behaviour a person can see, each with its acceptance criterion in bold. Each one restates a decision; a decision with two behaviours gives two requirements. A criterion uses no number or limit that was not decided.
- Decisions: one line each. Leave out the choices about how the code works that are easy to reverse, and the items under `Raised, not decided`: `super-plan` reads them from the decisions file. Add a reason only when one was given; never write one yourself. Name the ADR or decision record that a decision follows or overrides.
- Testing: how it will be tested, as decided.
- Out of scope.
- Left to the developer: the items the user left open on purpose. No other part decides them. Drop this part when there are none.

A part with nothing decided stays, with `Not decided.` and one line on what is missing. Name who does something only where that was decided. The whole spec fits on one page: cut words, not information. A reader who was not in the conversation must follow every line, so name each thing in full and use the glossary's terms. The spec names no file path, file name, command or setting key, also not under Left to the developer: those belong to the plan.

## The report

```
Spec: <the file's full path from the vault root>
Not decided: Testing (no test approach was settled), Out of scope.
To publish it to an issue tracker, read it first, then say yes and name the tracker.
```

After an edit of an existing spec, add a line `Changed:` with the items that changed.

## Red flags

| If you are about to | Then |
| --- | --- |
| Write something into a part that nobody decided | Write `Not decided.` and what is missing. |
| Give a reason or a requirement that nobody stated | Leave it out. |
| Ask the user how the feature should work | Stop. Mark it `Not decided` and suggest `grill-with-docs`. |
| Write "as discussed", "the session" or a question number | Name the thing itself. |
| Use a word from the glossary's Avoid column, also one the user used | Use the glossary's term. |
| Write a long list of user stories | Write the few requirements. |
| Publish before the user said yes to the file | Stop and ask. |
| Write "merge" for anything but a git merge | Say what happened: "picked onto the branch" for a cherry-pick, "combined" for findings or notes. |
| Write how the code does something that is no hard-to-reverse decision | Leave it out. `super-plan` decides it. |
