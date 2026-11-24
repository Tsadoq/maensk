#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export MAENSK_REPO_URL="$tmp/origin"
export PATH="$tmp/bin:$PATH"
origin="$tmp/origin"
clone="$XDG_DATA_HOME/maensk"
settings="$HOME/.claude/settings.json"
config="$XDG_CONFIG_HOME/maensk/config.json"
detach=()
if command -v setsid >/dev/null; then detach=(setsid -w); fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

commit() {
  git -C "$origin" add -A
  git -C "$origin" -c user.name=test -c user.email=test@example.invalid commit -q -m "$1"
}

mkdir -p "$HOME/.claude" "$tmp/vault" "$tmp/repos" "$tmp/bin" "$origin"
for stub in systemctl launchctl pi pipx cargo; do
  printf '#!/bin/sh\necho "$@" >>"%s/%s.log"\n' "$tmp" "$stub" >"$tmp/bin/$stub"
  chmod +x "$tmp/bin/$stub"
done
printf '#!/bin/sh\n[ -t 0 ] || cat >/dev/null\necho "$@" >>"%s/pi.log"\n' "$tmp" >"$tmp/bin/pi"
git init -q -b main "$origin"
cp -R "$root/install.sh" "$root/skills" "$origin/"
commit first
echo '{"model": "kept", "permissions": {"allow": ["Bash(ls *)"]}}' >"$settings"
chmod 600 "$settings"

bash -s -- --pi --vault "$tmp/vault" <"$origin/install.sh" >/dev/null
[ -f "$HOME/.agents/skills/maensk-setup/SKILL.md" ] || fail "piped install copied no skill"
[ ! -e "$HOME/.claude/skills" ] || fail "piped install for pi wrote Claude Code skills"
[ "$(cat "$tmp/pi.log")" = "install npm:@tintinweb/pi-subagents" ] || fail "a pi install did not install pi-subagents alone"

if script --version >/dev/null 2>&1; then
  printf 'y\ny\nn\n%s\n\n\n' "$tmp/vault" | script -qec "$origin/install.sh" /dev/null >/dev/null
  [ -f "$HOME/.claude/skills/maensk-setup/SKILL.md" ] || fail "answered install copied no skill"
  [ ! -e "$tmp/vault/.claude" ] || fail "an empty repos answer still wrote vault settings"
  grep -q '"repos": null' "$config" || fail "an empty repos answer was not recorded"
  ! grep -q pi-artifacts "$tmp/pi.log" || fail "installed the pi viewer after a no"
  ! grep -q mutation "$config" || fail "an empty languages answer wrote a mutation tool"
fi

mkdir -p "$XDG_CONFIG_HOME/git"
printf '*.swp' >"$XDG_CONFIG_HOME/git/ignore"
"$origin/install.sh" --pi --pi-viewer --vault "$tmp/vault" >/dev/null
"$origin/install.sh" --pi --pi-viewer --vault "$tmp/vault" >/dev/null
grep -qx "install npm:@nicknisi/pi-artifacts" "$tmp/pi.log" || fail "--pi-viewer did not install the pi viewer"
[ "$(cat "$XDG_CONFIG_HOME/git/ignore")" = "$(printf '*.swp\n.pi/artifacts/')" ] || fail "the pi pages folder is not in the git ignore file exactly once"
rm "$config"
bash -s -- --pi --pi-viewer --vault "$tmp/vault" <"$origin/install.sh" >/dev/null
[ -f "$config" ] || fail "a piped install with --pi-viewer stopped at pi install"

"$origin/install.sh" --claude --pi --vault "$tmp/vault" --repos "$tmp/repos" >/dev/null
python3 - "$tmp" <<'PY'
import json
import pathlib
import stat
import sys

tmp = pathlib.Path(sys.argv[1])
home = tmp / "home"
for skills in (home / ".claude/skills", home / ".agents/skills"):
    assert (skills / "maensk-setup/SKILL.md").is_file(), skills
    assert (skills / "maensk-setup/.maensk").is_file(), skills
settings = home / ".claude/settings.json"
data = json.loads(settings.read_text())
assert data["model"] == "kept", data
assert data["permissions"]["allow"] == [
    "Bash(ls *)",
    f"Edit(/{tmp}/vault/**)",
    f"Edit(/{home}/.config/maensk/**)",
], data
assert stat.S_IMODE(settings.stat().st_mode) == 0o600
local = json.loads((tmp / "vault/.claude/settings.local.json").read_text())
assert local == {"permissions": {"allow": [f"Edit(/{tmp}/repos/**)"]}}, local
config = json.loads((home / ".config/maensk/config.json").read_text())
assert config == {"vault": f"{tmp}/vault", "repos": f"{tmp}/repos"}, config
PY
[ -x "$clone/install.sh" ] || fail "no clone for the updater"
case "$(uname -s)" in
  Linux)
    grep -qF "ExecStart=\"$clone/install.sh\" --update" "$XDG_CONFIG_HOME/systemd/user/maensk-update.service" ||
      fail "service does not run the updater"
    grep -qF -- "--user enable --now maensk-update.timer" "$tmp/systemctl.log" || fail "timer not enabled"
    ;;
  Darwin)
    plutil -lint "$HOME/Library/LaunchAgents/io.github.tsadoq.maensk-update.plist" >/dev/null ||
      fail "plist does not parse"
    grep -q bootstrap "$tmp/launchctl.log" || fail "agent not loaded"
    ;;
esac

"$origin/install.sh" --claude --vault "$tmp/vault" --repos "$tmp/repos" --mutation "python,rust" >/dev/null
grep -qx "install mutmut" "$tmp/pipx.log" || fail "--mutation python did not install mutmut"
grep -qx "install --locked cargo-mutants" "$tmp/cargo.log" || fail "--mutation rust did not install cargo-mutants"
python3 - "$config" <<'PY'
import json
import sys

config = json.loads(open(sys.argv[1]).read())
assert config.pop("mutation") == {"python": "mutmut", "rust": "cargo mutants"}, config
open(sys.argv[1], "w").write(json.dumps(config, indent=2) + "\n")
PY
if "$origin/install.sh" --claude --vault "$tmp/vault" --mutation cobol >/dev/null 2>&1; then fail "accepted a language with no mutation tool"; fi

cp "$settings" "$tmp/settings.before"
cp "$config" "$tmp/config.before"
"$origin/install.sh" --claude --pi --vault "$tmp/vault" --repos "$tmp/repos" >/dev/null
cmp -s "$settings" "$tmp/settings.before" || fail "a second install changed the Claude settings"
cmp -s "$config" "$tmp/config.before" || fail "a second install changed the config"

echo '{"vault": "/v", "repos": null, "layout": {"glossary": {"path": "g.md"}}}' >"$config"
cp "$config" "$tmp/config.before"
mkdir -p "$HOME/.claude/skills/mine" "$origin/skills/second"
echo keep >"$HOME/.claude/skills/mine/keep"
git -C "$origin" mv skills/maensk-setup skills/renamed
echo second >"$origin/skills/second/SKILL.md"
commit second
"${detach[@]}" "$clone/install.sh" --update </dev/null >/dev/null
for skills in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  [ -f "$skills/second/SKILL.md" ] || fail "update did not add a new skill in $skills"
  [ -f "$skills/renamed/.maensk" ] || fail "update did not add a renamed skill in $skills"
  [ ! -e "$skills/maensk-setup" ] || fail "update left a removed skill in $skills"
done
[ "$(cat "$HOME/.claude/skills/mine/keep")" = keep ] || fail "update touched a folder it does not own"
cmp -s "$config" "$tmp/config.before" || fail "update changed the config"

printf '{' >"$settings"
if "$origin/install.sh" --claude --vault "$tmp/vault" >/dev/null 2>&1; then fail "installed over broken settings"; fi
[ "$(cat "$settings")" = "{" ] || fail "broken settings were overwritten"

mkdir -p "$origin/skills/mine"
echo theirs >"$origin/skills/mine/SKILL.md"
commit clash
if "${detach[@]}" "$clone/install.sh" --update </dev/null >/dev/null 2>&1; then fail "update replaced a folder it does not own"; fi
[ "$(cat "$HOME/.claude/skills/mine/keep")" = keep ] || fail "a clashing folder was changed"
[ -f "$HOME/.claude/skills/second/SKILL.md" ] || fail "a refused update removed installed skills"

if "${detach[@]}" "$origin/install.sh" </dev/null >/dev/null 2>&1; then fail "asked questions with no terminal"; fi

echo "install.sh: all checks passed"
