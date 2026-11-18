#!/usr/bin/env bash
# Builds the workspace of every case: a toy code repo, a toy vault and a settings file.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
[ -d "$here/fixture" ] || here="$(dirname "$here")"
cp -R "$here/fixture/." .
git -C reports-app init -q
mkdir -p "$HOME/.config/maensk"
cat > "$HOME/.config/maensk/config.json" <<JSON
{
  "vault": "$PWD/vault",
  "repos": "$PWD",
  "rules": [
    "File names have no colon, slash or pipe. (AGENTS.md)",
    "Every note starts with frontmatter that has a title and tags. (AGENTS.md)",
    "Link notes as [[Note Title]]. (AGENTS.md)"
  ],
  "layout": {
    "glossary": { "path": "projects/<project>/<name> Glossary.md", "template": null },
    "adr": { "path": "projects/<project>/plan/adr/<name> ADR-<number> - <title>.md", "template": null },
    "decision-record": { "path": "projects/<project>/plan/decisions/<name> Decision Record - <title>.md", "template": null },
    "design-note": { "path": "projects/<project>/design/<name> <title>.md", "template": null },
    "spec": { "path": "projects/<project>/plan/<name> <title> Spec.md", "template": null },
    "research": { "path": "projects/<project>/research/<name> Findings - <title>.md", "template": null },
    "lessons": { "path": "projects/<project>/research/<name> Lessons.md", "template": null }
  }
}
JSON
