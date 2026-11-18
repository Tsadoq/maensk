# maensk

Matteo Engineering Skills: skills for coding agents. They keep their documents (glossary, decision records, design notes, specs) in an Obsidian vault and not in the code repo.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Tsadoq/maensk/main/install.sh | bash
```

The script asks which agents you use (Claude Code, pi), where your vault is, and where your code repos are. It needs `git` and `python3`. It then does this:

- It copies the skills to `~/.claude/skills` and `~/.agents/skills`. It replaces only folders it installed before.
- It writes the vault path to `~/.config/maensk/config.json`.
- For Claude Code it adds two allow rules to `~/.claude/settings.json`, so that a session opened in any repo reads and writes the vault and the config folder without a question. If you name a repos folder, it adds one rule to the vault's `.claude/settings.local.json` for the other direction.
- It keeps a clone in `~/.local/share/maensk` and sets up a daily timer (systemd or launchd) that runs `install.sh --update` there.

Then open your agent in the vault and run `/maensk-setup`. In pi the command is `/skill:maensk-setup`.

`./install.sh --help` lists the flags for a run with no questions.

### Claude Code plugin

```
/plugin install maensk --marketplace Tsadoq/maensk
```

This route installs the skills only, with no timer and no allow rules. The skills are then named `/maensk:<name>`.

## Skills

| Skill | What it does |
| --- | --- |
| `maensk-setup` | Reads the vault's rules, shows where each kind of document goes, and saves that layout after you agree. |

## Working on this repo

```sh
git config core.hooksPath .githooks
```

The hooks run `tools/check-words` on the files and on the commit message. It fails on a session id and on a word from a private list, stored as hashes in `tools/forbidden-words.sha256`. CI runs the same check, the tests in `tests/`, and `claude plugin validate`.

## Licence

MIT
