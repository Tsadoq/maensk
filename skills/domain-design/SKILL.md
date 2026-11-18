---
name: domain-design
description: Use when the user asks to define or clean up the terms of a project, or to write or update the project's glossary.
---

# domain-design

When one thing has two names, or one name covers two things, the plan and the code drift apart and nobody sees it. This skill settles one plain word for each thing with the user and keeps the project's glossary.

The settings file is `~/.config/maensk/config.json`. Its `vault` key is the vault's path, `layout.glossary.path` is where the glossary goes, and `rules` lists what a note in this vault must follow. Read it with the file tool and pass the path as written, with the `~`. If the file has no `layout`, tell the user to run `maensk-setup`, go on, and write no file.

## Steps

1. Find the project's folder in the vault: match the repo's name and the topic against the project folders. One match: say which. None or several: ask. In the glossary path, `<project>` is the folder's name and `<name>` is the word that the titles of the notes in that folder start with. When those titles share no first word, ask the user for `<name>`.
2. Find the project's glossary. Search the whole project folder, every subfolder included, for a note with `Glossary` in its name, and read it. When it is not at the layout's path, ask the user whether to use that file before you write, and keep the columns it has. A vault must not hold two notes with one name.
3. Collect the terms that need work, from the user's words, from your own words and from the code:
   - a term that was never defined
   - a term that the glossary lists under Avoid, or defines in another way
   - two words for one thing, or one word for two things
   - jargon, a figure of speech, or a name that exists only in this conversation
4. Check each term against the code. Say where the code uses another word, or the same word for another thing.
5. Put the terms to the user as numbered questions, then stop and wait. Each question has:
   - the things the term could mean
   - one concrete case that tells them apart
   - the candidate words as lettered options, at least one of them a plain everyday word, each with what it costs. Mark none.
6. When the user settles a term, write it to the glossary at once. When the project has no glossary, create the file when the first term is settled, with the frontmatter that the project's other notes carry, and follow `rules`.
7. End with a fixed report: the glossary's path, the terms added or changed, the terms still open.

## The glossary

One table. A row holds the term, what it is in one or two sentences, and the words not to use for it.

```
| Term | Meaning | Avoid |
| --- | --- | --- |
| Team | The group of people that shares one set of reports. | account, customer |
```

Take terms from what the user or the caller of the system sees, not from the names of classes. Leave out general programming words. The glossary holds terms only: no decision, no limit, no implementation detail.

## Red flags

| If you are about to | Then |
| --- | --- |
| Pick the meaning of an unclear term yourself and go on | Stop. Ask which is meant. |
| Use a word the glossary lists under Avoid | Use the glossary's term. |
| Write a term the user has not settled | Stop. Ask first. |
| Write a decision or a number into the glossary | Stop. It holds terms only. |
| Coin a name for something | Look for its name in the glossary and the code first. |
