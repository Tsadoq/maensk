---
name: maensk-setup
description: Agrees where the maensk skills keep their documents in an Obsidian vault and saves that layout. Use once on each device after installing maensk, or again after the vault's folders or rules change.
disable-model-invocation: true
---

# maensk-setup

Without a saved layout each maensk skill guesses where a document goes, and the guess breaks the vault's rules. This skill reads the vault once, agrees the layout with the user, and saves it for the other skills.

The settings file is `~/.config/maensk/config.json`. It is the only file this skill writes, except in step 8. Read files with the file tools: a shell command can ask the user for permission.

## Steps

1. Read the settings file. Its `vault` key is the vault's path. If the file or the key is missing, use the current folder when it has an `.obsidian` folder; otherwise ask for the path. If the session was not opened inside the vault, say so and stop: the vault's own rules load only there.
2. Read the vault's rules yourself, without subagents: `AGENTS.md` and `CLAUDE.md` at the root, each file they import or name as the authority for paths, naming, templates or wording, and the folder tree two levels deep. Then list the files of the two projects that changed most recently. Do not survey the other projects.
3. Decide where each kind of document goes.

   | Kind | What it is |
   | --- | --- |
   | `glossary` | The terms of one project, in one file |
   | `adr` | Architecture decision records, one file each |
   | `decision-record` | A short record of one decision that is hard to reverse: three sentences, no template, one file each |
   | `design-note` | A short note on how one part is built |
   | `spec` | What to build, written before the code |
   | `plan` | The tasks that build one job, in a folder with one file for each task |
   | `research` | Findings from research, one file per source or topic |
   | `lessons` | What was learned in one project, in one file |

   Each kind gets a path from the vault root that ends in a file name, and the vault's template for that kind when it has one. The path of `plan` ends in a folder, `<title>/`, and goes beside the spec. Use `<project>` for the project's folder name, `<name>` for the name the project's notes carry in their titles, and `<title>`, `<number>` and `<date>` where the file name needs them. A stated rule of the vault comes first. Where the rules say nothing, do what the existing projects do. Where they also show nothing, put the glossary beside the project's main note and each other kind in its own folder under the project. Never choose a folder the rules close to agents.
4. Write the rules digest: what a skill must follow when it writes a note in this vault. Cover each of these topics: file names, frontmatter, links, wording, abbreviations, language, and what the vault requires after a write. One sentence for each rule, with the file it comes from in brackets, twenty rules at most. Leave out where notes go; the layout holds that. The other skills read this digest and not the vault's rule files.
5. Show the layout in one table: kind, path, template, and the rule or the example each row comes from. Under it show the digest, then the kinds and the digest topics you found no rule for. Then stop and wait.
6. Change the layout and the digest as the user asks and show them again. Repeat until the user says yes.
7. Write the settings file. Keep every key it already has and set these:

   ```json
   {
     "vault": "/absolute/path/of/the/vault",
     "rules": ["File names have no colon, slash or pipe. (AGENTS.md)"],
     "layout": {
       "glossary": { "path": "projects/<project>/<name> Glossary.md", "template": null },
       "adr": { "path": "projects/<project>/adr/ADR-<number> - <title>.md", "template": "templates/ADR.md" }
     }
   }
   ```

   Every `path` and `template` is relative to the vault root. `layout` has one entry for each of the eight kinds. The values above only show the format.
8. Only when the user asks for it, add the layout to the vault's own rules. Ask first which file and which kinds. Use only file names that exist as examples.
9. End with a fixed report: the settings file's path, the layout table, the kinds that rest on no rule, and each line added to the vault in step 8.

## Red flags

| If you are about to | Then |
| --- | --- |
| Write the settings file before the user said yes | Stop. Show the table and wait. |
| Create, move or edit a file in the vault | Stop, unless it is step 8 and the user asked for it. |
| Copy a layout or a rule from another vault or from the example above | Stop. Read this vault. |
| Drop a key that the settings file already has | Stop. Other tools own those keys. |
