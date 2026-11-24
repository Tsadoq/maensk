#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

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
  IFS= read -r REPLY </dev/tty || REPLY=""
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

allow() {
  python3 - "$1" "$2" <<'PY'
import json
import os
import pathlib
import shutil
import sys

path, rule = pathlib.Path(sys.argv[1]).resolve(), sys.argv[2]
try:
    data = json.loads(path.read_text()) if path.exists() else {}
    rules = data.setdefault("permissions", {}).setdefault("allow", [])
    if rule not in rules:
        rules.append(rule)
        path.parent.mkdir(parents=True, exist_ok=True)
        temp = path.with_name(path.name + ".maensk-tmp")
        temp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
        if path.exists():
            shutil.copymode(path, temp)
        os.replace(temp, path)
        print(f"allowed {rule} in {path}")
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
  local here="" update=0 claude=0 pi=0 viewer=0 vault="" repos="" languages="" questions=0 dest src lang
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
    allow "$HOME/.claude/settings.json" "Edit(/$vault/**)"
    allow "$HOME/.claude/settings.json" "Edit(/$(dirname "$CONFIG")/**)"
    [ -z "$repos" ] || allow "$vault/.claude/settings.local.json" "Edit(/$repos/**)"
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
