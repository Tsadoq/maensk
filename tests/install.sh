#!/usr/bin/env bash
set -euo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export MAENSK_REPO_URL="$tmp/origin"
no_claude="$tmp/bin"
IFS=: read -ra dirs <<<"$PATH"
for dir in "${dirs[@]}"; do [ -x "$dir/claude" ] || no_claude+=":$dir"; done
export PATH="$tmp/bin:$tmp/claude-bin:$PATH"
unset CONTEXT7_API_KEY PARALLEL_API_KEY
origin="$tmp/origin"
clone="$XDG_DATA_HOME/maensk"
settings="$HOME/.claude/settings.json"
config="$XDG_CONFIG_HOME/maensk/config.json"
reviewers="$XDG_CONFIG_HOME/maensk/reviewers"
keys="$XDG_CONFIG_HOME/maensk/keys"
mcp="$HOME/.pi/agent/mcp.json"
detach=()
if command -v setsid >/dev/null; then detach=(setsid -w); fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

commit() {
  git -C "${2:-$origin}" add -A
  git -C "${2:-$origin}" -c user.name=test -c user.email=test@example.invalid commit -q -m "$1"
}

pinned() {
  local name
  for name in code-review security-review ponytail-review; do
    [ "$(cd "$reviewers/$name" 2>/dev/null && find . -type f | LC_ALL=C sort | tr '\n' ' ')" = "./LICENSE ./SKILL.md ./references/guide.md " ] ||
      fail "$1: $name is not the pinned folder with one licence"
    [ "$(cat "$reviewers/$name/SKILL.md")" = "pinned $name" ] || fail "$1: $name is not at the pin"
    [ "$(cat "$reviewers/$name/references/guide.md")" = "nested $name" ] || fail "$1: $name lost its nested file"
  done
  [ "$(cat "$reviewers/code-review/LICENSE")" = "repo licence" ] || fail "$1: the repo licence was not copied"
  [ "$(cat "$reviewers/ponytail-review/LICENSE")" = "own licence" ] || fail "$1: a folder's own licence was replaced"
}

only_in_keys() {
  local found
  found="$(grep -rlF -e "$2" -e "$3" "$HOME" "$tmp/claude.log" 2>/dev/null | grep -vxF "$keys" || true)"
  [ -z "$found" ] || fail "$1: a key is written outside the key file, in $found"
}

finishes() {
  local label="$1"
  shift
  rm -rf "$config" "$XDG_CONFIG_HOME/systemd" "$HOME/Library/LaunchAgents"
  out="$("$@" 2>&1)" || fail "$label stopped the install"
  [ -f "$config" ] || fail "$label left no config"
  [ -f "$XDG_CONFIG_HOME/systemd/user/maensk-update.timer" ] || [ -f "$HOME/Library/LaunchAgents/io.github.tsadoq.maensk-update.plist" ] ||
    fail "$label left no timer"
}

rerun_line() {
  grep -F -- --review-tools <<<"$out" | grep -qF -- "$2" || fail "$1: no line says to run install.sh again for $2"
}

mkdir -p "$HOME/.claude" "$tmp/vault" "$tmp/repos" "$tmp/bin" "$tmp/claude-bin" "$origin"
for stub in systemctl launchctl pi pipx cargo; do
  printf '#!/bin/sh\necho "$@" >>"%s/%s.log"\n' "$tmp" "$stub" >"$tmp/bin/$stub"
  chmod +x "$tmp/bin/$stub"
done
printf '#!/bin/sh\n[ -t 0 ] || cat >/dev/null\necho "$@" >>"%s/pi.log"\n' "$tmp" >"$tmp/bin/pi"
cat >"$tmp/claude-bin/claude" <<EOF
#!/bin/sh
python3 -c "import json, sys; print(json.dumps(sys.argv[1:]))" "\$@" >>"$tmp/claude.log"
[ "\$2" != remove ] && { [ "\$2" != add-json ] || [ ! -e "$tmp/claude.fail" ]; }
EOF
chmod +x "$tmp/claude-bin/claude"
git init -q -b main "$origin"
cp -R "$root/install.sh" "$root/skills" "$origin/"
pins=""
for spec in "code-review engineering/skills/code-review" "security-review skills/security-review" "ponytail-review skills/ponytail-review"; do
  read -r name sub <<<"$spec"
  repo="$tmp/upstream/$name"
  git init -q -b main "$repo"
  git -C "$repo" config uploadpack.allowFilter true
  git -C "$repo" config uploadpack.allowAnySHA1InWant true
  mkdir -p "$repo/$sub/references"
  echo "repo licence" >"$repo/LICENSE"
  echo "pinned $name" >"$repo/$sub/SKILL.md"
  echo "nested $name" >"$repo/$sub/references/guide.md"
  [ "$name" != ponytail-review ] || echo "own licence" >"$repo/$sub/LICENSE"
  commit pin "$repo"
  pins+="  \"file://$repo $(git -C "$repo" rev-parse HEAD) $sub $name\""$'\n'
  echo "tip $name" >"$repo/$sub/SKILL.md"
  echo "tip $name" >"$repo/$sub/references/guide.md"
  commit tip "$repo"
done
awk -v pins="$pins" '/^REVIEWERS=\(/ { print; printf "%s", pins; skip = 1; next } skip && /^\)/ { skip = 0 } !skip' \
  "$root/install.sh" >"$origin/install.sh"
grep -q "file://$tmp/upstream" "$origin/install.sh" || fail "install.sh has no REVIEWERS array to point at the test repos"
commit first
echo '{"model": "kept", "permissions": {"allow": ["Bash(ls *)"]}}' >"$settings"
chmod 600 "$settings"

bash -s -- --pi --vault "$tmp/vault" <"$origin/install.sh" >/dev/null
[ -f "$HOME/.agents/skills/maensk-setup/SKILL.md" ] || fail "piped install copied no skill"
[ ! -e "$HOME/.claude/skills" ] || fail "piped install for pi wrote Claude Code skills"
[ "$(cat "$tmp/pi.log")" = "install npm:@tintinweb/pi-subagents" ] || fail "a pi install did not install pi-subagents alone"
[ ! -e "$reviewers" ] || fail "an install without --review-tools fetched the reviewers"
[ ! -e "$keys" ] || fail "an install without --review-tools wrote the key file"
[ ! -e "$mcp" ] || fail "an install without --review-tools added pi servers"

if script --version >/dev/null 2>&1; then
  printf 'y\ny\nn\n%s\n\n\ny\nctx7-typed\nparallel-typed\n' "$tmp/vault" | script -qec "$origin/install.sh" /dev/null >/dev/null
  pinned "a yes to the reviewers question"
  [ -n "$(find "$keys" -perm 600 2>/dev/null)" ] || fail "the typed keys are not in a file of mode 600"
  grep -qx "CONTEXT7_API_KEY=ctx7-typed" "$keys" || fail "the typed Context7 key is not in the key file"
  grep -qx "PARALLEL_API_KEY=parallel-typed" "$keys" || fail "the typed Parallel key is not in the key file"
  only_in_keys "typed keys" ctx7-typed parallel-typed
  printf 'ctx7-flag\nparallel-flag\n' | script -qec "$origin/install.sh --claude --review-tools --vault $tmp/vault" /dev/null >/dev/null
  grep -qx "CONTEXT7_API_KEY=ctx7-flag" "$keys" || fail "--review-tools with no key set did not ask for the Context7 key"
  grep -qx "PARALLEL_API_KEY=parallel-flag" "$keys" || fail "--review-tools with no key set did not ask for the Parallel key"
  cp "$keys" "$tmp/keys.before"
  cp "$config" "$tmp/config.before"
  rm -rf "$reviewers"
  if out="$(printf '\nparallel-flag\n' | script -qec "$origin/install.sh --claude --review-tools --vault $tmp/vault" /dev/null)"; then
    fail "an empty typed Context7 key was accepted"
  fi
  cmp -s "$keys" "$tmp/keys.before" || fail "an empty typed key changed the key file"
  cmp -s "$config" "$tmp/config.before" || fail "an empty typed key still wrote the config"
  [ ! -e "$reviewers" ] || fail "an empty typed key still fetched the reviewers"
  grep -q CONTEXT7_API_KEY <<<"$out" || fail "the error for an empty typed key does not name CONTEXT7_API_KEY"
  rm -rf "$reviewers"
  printf 'y\ny\nn\n%s\n\n\n\nctx7-typed\nparallel-typed\n' "$tmp/vault" | script -qec "$origin/install.sh" /dev/null >/dev/null
  [ ! -e "$reviewers" ] || fail "an empty answer to the reviewers question fetched the reviewers"
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

rm -f "$keys" "$mcp"
: >"$tmp/claude.log"
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
assert sorted(data["permissions"]["deny"]) == [
    f"Edit(/{home}/.config/maensk/key-header)",
    f"Edit(/{home}/.config/maensk/keys)",
], data
assert stat.S_IMODE(settings.stat().st_mode) == 0o600
local = json.loads((tmp / "vault/.claude/settings.local.json").read_text())
assert local == {"permissions": {"allow": [f"Edit(/{tmp}/repos/**)"]}}, local
config = json.loads((home / ".config/maensk/config.json").read_text())
assert config == {"vault": f"{tmp}/vault", "repos": f"{tmp}/repos"}, config
PY
[ ! -e "$reviewers" ] || fail "an install without --review-tools fetched the reviewers"
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
[ ! -e "$keys" ] || fail "an install without --review-tools wrote the key file"
[ ! -e "$mcp" ] || fail "an install without --review-tools added pi servers"
[ ! -s "$tmp/claude.log" ] || fail "an install without --review-tools added Claude Code servers"

: >"$tmp/pi.log"
: >"$tmp/claude.log"
mkdir -p "$(dirname "$keys")" "$(dirname "$mcp")"
echo "CONTEXT7_API_KEY=stale" >"$keys"
chmod 644 "$keys"
echo '{"mcpServers": {"mine": {"command": "mine"}}}' >"$mcp"
chmod 640 "$mcp"
export CONTEXT7_API_KEY=ctx7-fake PARALLEL_API_KEY=parallel-fake
"$origin/install.sh" --claude --pi --review-tools --vault "$tmp/vault" --repos "$tmp/repos" >/dev/null
pinned "--review-tools"
! grep -q pi-web-search "$tmp/pi.log" || fail "--pi --review-tools installed pi-web-search"
only_in_keys "keys from the environment" ctx7-fake parallel-fake
python3 - "$tmp" <<'PY'
import json
import os
import pathlib
import stat
import subprocess
import sys

tmp = pathlib.Path(sys.argv[1])
home = tmp / "home"
keys = home / ".config/maensk/keys"
mcp = home / ".pi/agent/mcp.json"
urls = {"context7": "https://mcp.context7.com/mcp", "parallel": "https://mcp.parallel.ai/mcp"}

assert stat.S_IMODE(keys.stat().st_mode) == 0o600, oct(keys.stat().st_mode)
lines = keys.read_text().splitlines()
assert sorted(lines) == ["CONTEXT7_API_KEY=ctx7-fake", "PARALLEL_API_KEY=parallel-fake"], lines
keys.write_text("CONTEXT7_API_KEY=ctx7-from-file\nPARALLEL_API_KEY=parallel-from-file\n")
from_file = {"context7": "ctx7-from-file", "parallel": "parallel-from-file"}
env = {k: v for k, v in os.environ.items() if k not in ("CONTEXT7_API_KEY", "PARALLEL_API_KEY")}


def run(command):
    return subprocess.run(command, shell=True, env=env, capture_output=True, text=True, check=True).stdout


def user_scope(call):
    return call[call.index("--scope") + 1 :][:1] == ["user"] if "--scope" in call else False


calls = [json.loads(line) for line in (tmp / "claude.log").read_text().splitlines()]
for name, url in urls.items():
    removes = [i for i, c in enumerate(calls) if c[:2] == ["mcp", "remove"] and name in c and user_scope(c)]
    adds = [(i, c) for i, c in enumerate(calls) if c[:2] == ["mcp", "add-json"] and name in c and user_scope(c)]
    assert len(adds) == 1, (name, calls)
    at, call = adds[0]
    assert removes and removes[0] < at, (name, calls)
    server = json.loads(next(arg for arg in call if arg.startswith("{")))
    assert server["type"] == "http" and server["url"] == url, server
    assert json.loads(run(server["headersHelper"])) == {"Authorization": f"Bearer {from_file[name]}"}, name

pi = json.loads(mcp.read_text())
assert pi["mcpServers"]["mine"] == {"command": "mine"}, pi
assert stat.S_IMODE(mcp.stat().st_mode) == 0o640, oct(mcp.stat().st_mode)
for name, url in urls.items():
    server = pi["mcpServers"][name]
    assert server["url"] == url and server["exposure"] == "direct", server
    header = server["headers"]["Authorization"]
    assert header.startswith("!"), header
    assert run(header[1:]).strip() == f"Bearer {from_file[name]}", name
PY
git init -q "$tmp/decoy"
cp "$tmp/decoy/.git/config" "$tmp/decoy.config"
echo '{"mcpServers": {}}' >"$mcp"
cp "$mcp" "$tmp/mcp.before"
GIT_DIR="$tmp/decoy/.git" GIT_WORK_TREE="$tmp/decoy" "$origin/install.sh" --claude --review-tools --vault "$tmp/vault" --repos "$tmp/repos" >/dev/null
cmp -s "$tmp/decoy/.git/config" "$tmp/decoy.config" || fail "an install with GIT_DIR set changed that repo's git config"
pinned "GIT_DIR set"
cmp -s "$mcp" "$tmp/mcp.before" || fail "--review-tools without --pi changed the pi servers"
cp "$keys" "$tmp/keys.before"
for bad in 'ctx7"bad' 'ctx7\bad' 'ctx7 bad' $'ctx7\tbad' $'ctx7\x01bad'; do
  shown="$(printf %q "$bad")"
  if out="$(CONTEXT7_API_KEY="$bad" "$origin/install.sh" --claude --review-tools --vault "$tmp/vault" 2>&1)"; then
    fail "accepted the Context7 key $shown"
  fi
  cmp -s "$keys" "$tmp/keys.before" || fail "the Context7 key $shown changed the key file"
  grep -q CONTEXT7_API_KEY <<<"$out" || fail "the error for the Context7 key $shown does not name CONTEXT7_API_KEY"
  ! grep -qF "$bad" <<<"$out" || fail "the error prints the Context7 key $shown"
done
if out="$(PARALLEL_API_KEY='parallel"bad' "$origin/install.sh" --pi --review-tools --vault "$tmp/vault" 2>&1)"; then
  fail "accepted a Parallel key with a quote"
fi
cmp -s "$keys" "$tmp/keys.before" || fail "a Parallel key with a quote changed the key file"
grep -q PARALLEL_API_KEY <<<"$out" || fail "the error for a Parallel key with a quote does not name PARALLEL_API_KEY"
! grep -qF 'parallel"bad' <<<"$out" || fail "the error prints the Parallel key"

sed "s|file://$tmp/upstream/security-review |file://$tmp/upstream/missing |" "$origin/install.sh" >"$tmp/missing.sh"
rm -rf "$reviewers" "$config" "$XDG_CONFIG_HOME/systemd" "$HOME/Library/LaunchAgents"
mkdir -p "$tmp/scratch"
out="$(TMPDIR="$tmp/scratch" bash "$tmp/missing.sh" --claude --review-tools --vault "$tmp/vault" --repos "$tmp/repos" 2>&1)" ||
  fail "a reviewer that could not be fetched stopped the install"
[ -f "$config" ] || fail "a reviewer that could not be fetched left no config"
[ -f "$XDG_CONFIG_HOME/systemd/user/maensk-update.timer" ] || [ -f "$HOME/Library/LaunchAgents/io.github.tsadoq.maensk-update.plist" ] ||
  fail "a reviewer that could not be fetched left no timer"
[ "$(cat "$reviewers/code-review/SKILL.md")" = "pinned code-review" ] || fail "a reviewer that could not be fetched stopped the others"
[ "$(cat "$reviewers/ponytail-review/SKILL.md")" = "pinned ponytail-review" ] || fail "a reviewer that could not be fetched stopped the others"
grep security-review <<<"$out" | grep -qv '^installed' || fail "no line names the reviewer that could not be installed"
[ -z "$(ls -A "$tmp/scratch")" ] || fail "a reviewer that could not be fetched left its temp folder"

touch "$tmp/claude.fail"
finishes "a failed claude mcp add-json" "$origin/install.sh" --claude --review-tools --vault "$tmp/vault"
rm "$tmp/claude.fail"
rerun_line "a failed claude mcp add-json" context7
rerun_line "a failed claude mcp add-json" parallel
finishes "a missing claude" env PATH="$no_claude" "$origin/install.sh" --claude --review-tools --vault "$tmp/vault"
rerun_line "a missing claude" context7
rerun_line "a missing claude" parallel
printf '{' >"$mcp"
: >"$tmp/claude.log"
finishes "a malformed mcp.json" "$origin/install.sh" --pi --review-tools --vault "$tmp/vault"
rerun_line "a malformed mcp.json" "--pi"
[ "$(cat "$mcp")" = "{" ] || fail "a malformed mcp.json was overwritten"
[ ! -s "$tmp/claude.log" ] || fail "an install without --claude added Claude Code servers"
echo changed >"$reviewers/code-review/SKILL.md"
echo stray >"$reviewers/code-review/stray"
rm -rf "$reviewers/security-review"

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
[ "$(cat "$reviewers/code-review/SKILL.md")" = "pinned code-review" ] || fail "update did not restore a changed reviewer folder"
[ ! -e "$reviewers/code-review/stray" ] || fail "update left a file that is not in the pinned folder"
[ ! -e "$reviewers/security-review" ] || fail "update created a reviewer folder that was not there"
rm -rf "$reviewers"
"${detach[@]}" "$clone/install.sh" --update </dev/null >/dev/null
[ ! -e "$reviewers" ] || fail "update created the reviewers folder"

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

sed -n '/^REVIEWERS=(/,/^)/p' "$root/install.sh" | grep -o '"[^"]*"' | tr -d '"' |
  awk 'NF == 4 { n++ } END { exit !(n == 3 && NR == 3) }' ||
  fail "the REVIEWERS array does not read as three entries of four fields"

echo "install.sh: all checks passed"
