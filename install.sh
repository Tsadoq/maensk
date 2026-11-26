#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX

REPO_URL="${MAENSK_REPO_URL:-https://github.com/Tsadoq/maensk.git}"
CLONE="${XDG_DATA_HOME:-$HOME/.local/share}/maensk"
CONFIG="$HOME/.config/maensk/config.json"
CLAUDE_SKILLS="$HOME/.claude/skills"
PI_SKILLS="$HOME/.agents/skills"
MARKER=".maensk"
LABEL="io.github.tsadoq.maensk-update"
PI_VIEWER="npm:@nicknisi/pi-artifacts"
PI_SUBAGENTS="npm:@tintinweb/pi-subagents"
LANGUAGES="python rust go javascript"
SERVICES=(
  "context7 https://mcp.context7.com/mcp CONTEXT7_API_KEY"
  "parallel https://mcp.parallel.ai/mcp PARALLEL_API_KEY"
)
REVIEWERS=(
  "https://github.com/anthropics/knowledge-work-plugins.git 5e504ae11498f2b8daa30d86b7dab97b2ecd8092 engineering/skills/code-review code-review"
  "https://github.com/getsentry/skills.git a582c51ee29d0f35e6ac321340796f77d43da733 skills/security-review security-review"
  "https://github.com/DietrichGebert/ponytail.git ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10 skills/ponytail-review ponytail-review"
)

usage() {
  cat <<'EOF'
Installs the maensk skills and keeps them updated.

  ./install.sh             ask what to set up
  ./install.sh --update    pull this clone and reinstall from it, ask nothing
                           (the daily timer runs this in the installer's own clone)
  curl -fsSL https://raw.githubusercontent.com/Tsadoq/maensk/main/install.sh | bash

Answers as flags, for a run with no questions:
  --claude       install for Claude Code (~/.claude/skills)
  --pi           install for pi (~/.agents/skills)
  --pi-viewer    with --pi: also install the pi package that shows explainer pages
                 in the browser (@nicknisi/pi-artifacts), and add the folder where
                 it keeps them, .pi/artifacts/, to your global git ignore file
  --mutation "LANGS"
                 install a mutation tool for each of these languages, which
                 super-implement runs on each task: python (mutmut), rust
                 (cargo-mutants), go (gremlins), javascript (Stryker)
  --review-tools copy the reviewer skills that super-review runs, each at a
                 pinned commit, into ~/.config/maensk/reviewers/, and add the
                 Context7 and Parallel MCP servers its web reviewer checks
                 claims with; their keys come from CONTEXT7_API_KEY and
                 PARALLEL_API_KEY, or are asked for when unset, and are kept
                 in ~/.config/maensk/keys. It also installs Patchright and the
                 page script the web reviewer reads pages with, in
                 ~/.config/maensk/read-page/; that needs Node 22.1 or later
                 and about 700 MB of disk for Patchright's Chromium
  --vault DIR    the Obsidian vault the skills keep their documents in (required)
  --repos DIR    the folder that holds your code repos; a session opened in the
                 vault may then write there. Without it, each repo is added when
                 a skill first needs it.
EOF
}

die() {
  echo "install.sh: $*" >&2
  exit 1
}

ask() {
  { : </dev/tty; } 2>/dev/null || die "no terminal to ask on; see --help for the flags"
  printf '%s ' "$1" >/dev/tty
  IFS= read -r ${2:+-s} REPLY </dev/tty || REPLY=""
  [ -z "${2:-}" ] || echo >/dev/tty
}

yes_no() {
  local hint="y/N"
  [ "$2" = n ] || hint="Y/n"
  ask "$1 [$hint]"
  case "${REPLY:-$2}" in [yY]*) return 0 ;; *) return 1 ;; esac
}

found() {
  if command -v "$1" >/dev/null; then echo y; else echo n; fi
}

absolute() {
  local dir="$1"
  case "$dir" in \~ | \~/*) dir="$HOME${dir#\~}" ;; esac
  [ -d "$dir" ] || die "not a folder: $1"
  (cd "$dir" && pwd -P)
}

fetch() {
  command -v git >/dev/null || die "git is required"
  if [ ! -d "$CLONE/.git" ]; then
    [ ! -e "$CLONE" ] || die "$CLONE exists and is not a git clone"
    git clone --quiet "$REPO_URL" "$CLONE"
    return
  fi
  local try
  for try in 1 2 3; do
    if git -C "$CLONE" pull --quiet --ff-only; then return; fi
    [ "$try" = 3 ] || sleep 30
  done
  die "could not update $CLONE"
}

install_skills() {
  local src="$1" dest="$2" dir name
  for dir in "$src"/skills/*/; do
    name="$(basename "$dir")"
    [ ! -e "$dest/$name" ] || [ -f "$dest/$name/$MARKER" ] ||
      die "$dest/$name exists and was not installed by maensk; move it away and run again"
  done
  mkdir -p "$dest"
  for dir in "$dest"/*/; do
    [ ! -f "$dir$MARKER" ] || rm -rf "$dir"
  done
  for dir in "$src"/skills/*/; do
    name="$(basename "$dir")"
    cp -R "${dir%/}" "$dest/$name"
    touch "$dest/$name/$MARKER"
  done
  echo "installed the skills in $dest"
}

install_reviewers() {
  local existing="$1" dest entry url sha sub name temp file
  dest="$(dirname "$CONFIG")/reviewers"
  for entry in "${REVIEWERS[@]}"; do
    read -r url sha sub name <<<"$entry"
    [ "$existing" = 0 ] || [ -d "$dest/$name" ] || continue
    temp="$(mktemp -d)"
    if ! { git -C "$temp" init -q &&
      git -C "$temp" remote add origin "$url" &&
      git -C "$temp" sparse-checkout set --no-cone "/$sub/" "/LICENSE*" >/dev/null &&
      git -C "$temp" fetch -q --depth 1 --filter=blob:none origin "$sha" &&
      git -C "$temp" checkout -q FETCH_HEAD &&
      [ -d "$temp/$sub" ]; }; then
      rm -rf "$temp"
      echo "could not fetch the reviewer skill $name from $url: run install.sh again with --review-tools later; super-review needs it"
      continue
    fi
    rm -rf "${dest:?}/$name"
    mkdir -p "$dest/$name"
    cp -R "$temp/$sub/." "$dest/$name/"
    if ! compgen -G "$dest/$name/LICENSE*" >/dev/null; then
      for file in "$temp"/LICENSE*; do cp "$file" "$dest/$name/"; done
    fi
    rm -rf "$temp"
    echo "installed the reviewer skill $name in $dest/$name"
  done
}

install_read_page() {
  local src="$1" dest version major minor
  local rerun="run install.sh again with --review-tools later; super-review needs Patchright to read web pages"
  dest="$(dirname "$CONFIG")/read-page"
  version="$(node --version 2>/dev/null || true)"
  IFS=. read -r major minor _ <<<"${version#v}"
  if ! [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ ]] || ((major < 22 || (major == 22 && minor < 1))); then
    echo "Patchright needs Node 22.1 or later, found ${version:-no node}: install it, then $rerun"
    return
  fi
  if (mkdir -p "$dest" && cp "$src/skills/super-review/read-page.mjs" "$src/skills/super-review/package.json" "$dest/" &&
    cd "$dest" && npm install --no-audit --no-fund >/dev/null && npx patchright install chromium >/dev/null); then
    echo "installed Patchright and the page script in $dest"
  else
    echo "could not install Patchright in $dest: $rerun"
  fi
}

check_key() {
  case "$2" in
    "" | *[[:space:][:cntrl:]\"\\]*) die "$1 is empty or holds a quote, a backslash, whitespace or a control character" ;;
  esac
}

write_keys() {
  local dir
  dir="$(dirname "$CONFIG")"
  mkdir -p "$dir"
  (umask 077 && touch "$dir/keys" && chmod 600 "$dir/keys" &&
    printf 'CONTEXT7_API_KEY=%s\nPARALLEL_API_KEY=%s\n' "$1" "$2" >"$dir/keys")
  cat >"$dir/key-header" <<'EOF'
#!/bin/sh
key="$(sed -n "s/^$1=//p" "$(dirname "$0")/keys")"
if [ "${2:-}" = json ]; then
  printf '{"Authorization": "Bearer %s"}\n' "$key"
else
  printf 'Bearer %s\n' "$key"
fi
EOF
  chmod 755 "$dir/key-header"
  echo "wrote the keys to $dir/keys"
}

add_claude_servers() {
  local entry name url var server
  for entry in "${SERVICES[@]}"; do
    read -r name url var <<<"$entry"
    server="$(python3 -c 'import json, shlex, sys; print(json.dumps({"type": "http", "url": sys.argv[1], "headersHelper": shlex.join(sys.argv[2:])}))' \
      "$url" "$(dirname "$CONFIG")/key-header" "$var" json)"
    claude mcp remove --scope user "$name" >/dev/null 2>&1 || true
    if command -v claude >/dev/null && claude mcp add-json --scope user "$name" "$server" >/dev/null; then
      echo "added the MCP server $name to Claude Code"
    else
      echo "could not add the MCP server $name to Claude Code: run install.sh again with --claude --review-tools later; super-review needs it to check claims on the web"
    fi
  done
}

add_pi_servers() {
  if ! edit_json servers "$HOME/.pi/agent/mcp.json" "$(dirname "$CONFIG")/key-header" "${SERVICES[@]}"; then
    echo "could not add the MCP servers for pi: run install.sh again with --pi --review-tools later; super-review needs them to check claims on the web"
  fi
}

edit_json() {
  python3 - "$@" <<'PY'
import json
import os
import pathlib
import shlex
import shutil
import sys

action, path, args = sys.argv[1], pathlib.Path(sys.argv[2]).resolve(), sys.argv[3:]
try:
    data = json.loads(path.read_text()) if path.exists() else {}
    if action in ("allow", "deny"):
        rules = data.setdefault("permissions", {}).setdefault(action, [])
        if args[0] in rules:
            sys.exit()
        rules.append(args[0])
        done = f"added {args[0]} to the {action} rules in {path}"
    else:
        servers = data.setdefault("mcpServers", {})
        for entry in args[1:]:
            name, url, var = entry.split()
            servers[name] = {"url": url, "exposure": "direct", "headers": {"Authorization": "!" + shlex.join([args[0], var])}}
        done = f"added the MCP servers context7 and parallel to {path}"
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + ".maensk-tmp")
    temp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    if path.exists():
        shutil.copymode(path, temp)
    os.replace(temp, path)
    print(done)
except (ValueError, AttributeError, TypeError):
    sys.exit(f"install.sh: {path} is not the JSON this script expects; it was left as it is")
PY
}

mutation_tool() {
  case "$1" in
    python) echo "mutmut" ;;
    rust) echo "cargo mutants" ;;
    go) echo "gremlins unleash" ;;
    javascript) echo "stryker run" ;;
    *) return 1 ;;
  esac
}

install_mutation() {
  case "$1" in
    python)
      if command -v pipx >/dev/null; then pipx install mutmut; else python3 -m pip install --user mutmut; fi
      ;;
    rust) cargo install --locked cargo-mutants ;;
    go) go install github.com/go-gremlins/gremlins/cmd/gremlins@latest ;;
    javascript) npm install --global @stryker-mutator/core ;;
  esac
}

write_config() {
  mkdir -p "$(dirname "$CONFIG")"
  python3 - "$CONFIG" "$@" <<'PY'
import json
import pathlib
import sys

path, vault, repos = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
data = json.loads(path.read_text()) if path.exists() else {}
data.update(vault=vault, repos=repos or None)
tools = dict(pair.split("=", 1) for pair in sys.argv[4:])
if tools:
    data.setdefault("mutation", {}).update(tools)
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
PY
  echo "wrote $CONFIG"
}

ignore_pages() {
  local file
  file="$(git config --global core.excludesFile || true)"
  case "$file" in
    "") file="${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore" ;;
    \~/*) file="$HOME/${file#\~/}" ;;
  esac
  if grep -qxF ".pi/artifacts/" "$file" 2>/dev/null; then return; fi
  mkdir -p "$(dirname "$file")"
  if [ -s "$file" ] && [ -n "$(tail -c1 "$file")" ]; then echo >>"$file"; fi
  echo ".pi/artifacts/" >>"$file"
  echo "added .pi/artifacts/ to $file"
}

install_timer() {
  local units="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  local plist="$HOME/Library/LaunchAgents/$LABEL.plist"
  local by_hand="no timer was set up: run $CLONE/install.sh --update to update the skills"
  case "$(uname -s)" in
    Linux)
      if ! command -v systemctl >/dev/null; then
        echo "$by_hand"
        return
      fi
      mkdir -p "$units"
      cat >"$units/maensk-update.service" <<EOF
[Unit]
Description=Update the maensk skills

[Service]
Type=oneshot
ExecStart="$CLONE/install.sh" --update
EOF
      cat >"$units/maensk-update.timer" <<EOF
[Unit]
Description=Update the maensk skills once a day

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF
      systemctl --user daemon-reload
      systemctl --user enable --now maensk-update.timer
      echo "set up the daily update: maensk-update.timer"
      ;;
    Darwin)
      mkdir -p "$(dirname "$plist")"
      cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$CLONE/install.sh</string>
    <string>--update</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>12</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
</dict>
</plist>
EOF
      launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$plist"
      echo "set up the daily update: $plist"
      ;;
    *)
      echo "$by_hand"
      ;;
  esac
}

main() {
  local here="" update=0 claude=0 pi=0 viewer=0 review=0 vault="" repos="" languages="" questions=0 dest src lang
  local context7="${CONTEXT7_API_KEY:-}" parallel="${PARALLEL_API_KEY:-}"
  local tools=()
  if [ -f "${BASH_SOURCE[0]:-}" ]; then
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi
  [ $# -gt 0 ] || questions=1
  while [ $# -gt 0 ]; do
    case "$1" in
      --update) update=1 ;;
      --claude) claude=1 ;;
      --pi) pi=1 ;;
      --pi-viewer) viewer=1 ;;
      --review-tools) review=1 ;;
      --mutation)
        [ $# -ge 2 ] || die "$1 needs a list of languages"
        languages="$2"
        shift
        ;;
      --vault | --repos)
        [ $# -ge 2 ] || die "$1 needs a folder"
        if [ "$1" = --vault ]; then vault="$2"; else repos="$2"; fi
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
  done

  if [ "$update" = 1 ]; then
    if [ -z "$here" ] || [ ! -d "$here/.git" ]; then
      die "--update runs from a clone: $CLONE/install.sh --update"
    fi
    CLONE="$here"
    fetch
    for dest in "$CLAUDE_SKILLS" "$PI_SKILLS"; do
      if compgen -G "$dest/*/$MARKER" >/dev/null; then install_skills "$CLONE" "$dest"; fi
    done
    install_reviewers 1
    exit 0
  fi

  command -v python3 >/dev/null || die "python3 is required"
  if [ "$questions" = 1 ]; then
    if yes_no "Install for Claude Code?" "$(found claude)"; then claude=1; fi
    if yes_no "Install for pi?" "$(found pi)"; then pi=1; fi
    if [ "$pi" = 1 ]; then
      echo "explainer shows its pages in pi through the package @nicknisi/pi-artifacts. It keeps them in .pi/artifacts/, which this script adds to your global git ignore file. Without it, explainer only writes the page as a file." >/dev/tty
      if yes_no "Install that package?" y; then viewer=1; fi
    fi
    ask "Path of your Obsidian vault:"
    vault="$REPLY"
    if [ "$claude" = 1 ]; then
      echo "A session opened in the vault can be allowed to write to your code repos." >/dev/tty
      ask "Folder that holds your repos (empty: add each repo when a skill first needs it):"
      repos="$REPLY"
    fi
    echo "super-implement runs a mutation tool on each task, to see that its tests fail on broken code." >/dev/tty
    ask "Languages to install one for ($LANGUAGES; empty: none):"
    languages="$REPLY"
    echo "super-review runs three reviewer skills from GitHub, each at a pinned commit, and checks claims on the web through the Context7 and Parallel MCP servers, which need an API key each (CONTEXT7_API_KEY, PARALLEL_API_KEY)." >/dev/tty
    if yes_no "Install the skills and add the servers?" n; then review=1; fi
  fi
  if [ "$review" = 1 ]; then
    if [ -z "$context7" ]; then
      ask "Context7 API key:" hidden
      context7="$REPLY"
    fi
    if [ -z "$parallel" ]; then
      ask "Parallel API key:" hidden
      parallel="$REPLY"
    fi
    check_key CONTEXT7_API_KEY "$context7"
    check_key PARALLEL_API_KEY "$parallel"
  fi
  languages="${languages//,/ }"
  for lang in $languages; do
    mutation_tool "$lang" >/dev/null || die "no mutation tool for $lang; choose from: $LANGUAGES"
  done
  [ "$claude$pi" != 00 ] || die "nothing to install for: choose Claude Code or pi"
  vault="$(absolute "$vault")"
  [ -z "$repos" ] || repos="$(absolute "$repos")"

  fetch
  src="$CLONE"
  [ -z "$here" ] || [ ! -d "$here/skills" ] || src="$here"
  if [ "$claude" = 1 ]; then
    install_skills "$src" "$CLAUDE_SKILLS"
    edit_json allow "$HOME/.claude/settings.json" "Edit(/$vault/**)"
    edit_json allow "$HOME/.claude/settings.json" "Edit(/$(dirname "$CONFIG")/**)"
    edit_json deny "$HOME/.claude/settings.json" "Edit(/$(dirname "$CONFIG")/keys)"
    edit_json deny "$HOME/.claude/settings.json" "Edit(/$(dirname "$CONFIG")/key-header)"
    [ -z "$repos" ] || edit_json allow "$vault/.claude/settings.local.json" "Edit(/$repos/**)"
  fi
  if [ "$pi" = 1 ]; then
    install_skills "$src" "$PI_SKILLS"
    if command -v pi >/dev/null && pi install "$PI_SUBAGENTS"; then
      echo "installed the pi package $PI_SUBAGENTS"
    else
      echo "could not install $PI_SUBAGENTS: run 'pi install $PI_SUBAGENTS' later; super-implement in pi needs it"
    fi
  fi
  if [ "$pi$viewer" = 11 ]; then
    if command -v pi >/dev/null && pi install "$PI_VIEWER"; then
      echo "installed the pi package $PI_VIEWER"
      ignore_pages
    else
      echo "could not install $PI_VIEWER: run 'pi install $PI_VIEWER' later and add .pi/artifacts/ to your global git ignore file; until then explainer in pi only writes files"
    fi
  fi
  if [ "$review" = 1 ]; then
    install_reviewers 0
    install_read_page "$src"
    write_keys "$context7" "$parallel"
    [ "$claude" = 0 ] || add_claude_servers
    [ "$pi" = 0 ] || add_pi_servers
  fi
  for lang in $languages; do
    if install_mutation "$lang" >/dev/null 2>&1; then
      tools+=("$lang=$(mutation_tool "$lang")")
      echo "installed the mutation tool for $lang: $(mutation_tool "$lang")"
    else
      echo "could not install the mutation tool for $lang; super-implement goes on without one for $lang"
    fi
  done
  write_config "$vault" "$repos" ${tools[@]+"${tools[@]}"}
  install_timer
  echo "Next: open your agent in $vault and run /maensk-setup (in pi: /skill:maensk-setup)."
}

main "$@"
