# maensk

Matteo Engineering Skills: skills for coding agents. They keep their documents (glossary, decision records, design notes, specs, plans) in an Obsidian vault and not in the code repo.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Tsadoq/maensk/main/install.sh | bash
```

The script asks which agents you use (Claude Code, pi), where your vault is, and where your code repos are. It needs `git` and `python3`. It then does this:

- It copies the skills to `~/.claude/skills` and `~/.agents/skills`. It replaces only folders it installed before.
- It writes the vault path to `~/.config/maensk/config.json`.
- For Claude Code it adds two allow rules to `~/.claude/settings.json`, so that a session opened in any repo reads and writes the vault and the config folder without a question. If you name a repos folder, it adds one rule to the vault's `.claude/settings.local.json` for the other direction.
- It keeps a clone in `~/.local/share/maensk` and sets up a daily timer (systemd or launchd) that runs `install.sh --update` there.
- It asks for which languages to install a mutation tool, which `super-implement` runs on each task: `mutmut` for Python, `cargo-mutants` for Rust, `gremlins` for Go, Stryker for JavaScript. It writes the chosen ones to the same file.
- For pi it installs the pi package [`@tintinweb/pi-subagents`](https://www.npmjs.com/package/@tintinweb/pi-subagents), which gives pi the subagents that `super-implement` starts.
- For pi it offers to install the pi package [`@nicknisi/pi-artifacts`](https://github.com/nicknisi/pi-extensions/tree/main/packages/artifacts), which shows the pages of `explainer` in your browser and keeps them in `.pi/artifacts/` of the folder pi runs in. The script adds that folder to your global git ignore file. Without the package, `explainer` in pi only writes the page as a file.

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
| `maensk-setup` | Reads the vault's rules, shows where each kind of document goes, and saves that layout and a short digest of the rules after you agree. |
| `grill-with-docs` | Settles the open decisions of an idea or a plan with you before any code is written. It looks up the facts itself and gives each question its options with their costs and no recommended answer. It writes settled terms to the glossary and offers a three-sentence decision record for a decision that is hard to reverse. Say `shallow` for a round that asks only the large decisions. |
| `domain-design` | Settles one plain word for each thing in a project and keeps the project's glossary. `grill-with-docs` loads it. |
| `to-spec` | Turns decisions that are settled into a one-page spec in the vault, which a reader who was not in the conversation can follow. It adds no decision and marks each part that nothing decided. On request it publishes the spec to an issue tracker, after you have read it and said yes. |
| `probe` | Settles a claim with the smallest real run that could prove it wrong, in a background subagent, and reports what it ran, what it saw and what the run does not show. It also builds a throwaway version of a design to find what the design misses, and keeps that build until you delete it. |
| `super-plan` | Turns a spec, a brief or a finished discussion into a plan: a folder in the vault with one file for each small task, written so that an agent with no context can build it. It asks each choice about how to build as a question with options and costs, checks each pick with `probe`, has critic agents review the plan, shows it as an `explainer` page and waits for your approval. Say `autopilot` and it settles the choices itself and records each one. |
| `super-implement` | Builds a plan that `super-plan` wrote and you approved, in a new branch and worktree. For each task one agent writes the tests from the task file and another writes the code; the tests must fail before the code, and fail again when the code is broken on purpose or by the mutation tool. Reviewers with one concern each read every task, and the build ends with a few lines and `run.md` in the plan folder. Say `and push` to push the branch, or `autopilot` for a build that never stops for you. |
| `explainer` | Builds one visual page that shows how something works or compares options: one step at a time, on real example data, with little text. A subagent builds it and checks it in a headless Chrome or Chromium before you see it. Claude Code publishes it as a private claude.ai artifact; pi shows it through `@nicknisi/pi-artifacts`. |

### `probe` runs code

`probe` runs commands that the agent wrote a moment before, in a folder under the temp folder, and the deploy or test commands that your repo documents. Nothing confines them unless you turn on Claude Code's sandbox: run `/sandbox`, or set `"sandbox": {"enabled": true}` in `~/.claude/settings.json`. On macOS it needs nothing more. On Linux it needs `bubblewrap` and `socat`, and on Ubuntu also an AppArmor profile for `bwrap`; the [sandbox page](https://code.claude.com/docs/en/sandboxing) has the steps. pi has no sandbox.

## Working on this repo

```sh
git config core.hooksPath .githooks
```

The hooks run `tools/check-words` on the files and on the commit message. It fails on a session id and on a word from a private list, stored as hashes in `tools/forbidden-words.sha256`. CI runs the same check, the tests in `tests/`, and `claude plugin validate`.

## Evals

```sh
claude plugin eval . --scaffold --allow-tools Write Edit --no-publish
```

The cases in `evals/` run each skill against a toy repo and a toy vault, with and without the plugin. Each run is a model call on your account. The cases of `probe`, `explainer`, `super-plan` and `super-implement` need the shell: add `Bash` to `--allow-tools`. Where Claude Code's sandbox does not work, the eval then refuses every case, and without `Bash` the cases of `probe` and the `super-plan` cases that write a plan fail.

## Licence

MIT

`grill-with-docs`, `domain-design` and `to-spec` are based on the `grilling`, `domain-modeling` and `to-spec` skills of [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, Copyright (c) 2026 Matt Pocock). The three tests for a decision record are taken from there.
