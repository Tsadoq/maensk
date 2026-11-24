#!/usr/bin/env bash
set -u
minutes="${1:-15}"
root="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
while :; do
  for d in "$root"/*/"${CLAUDE_CODE_SESSION_ID:-none}"/subagents; do
    for m in "$d"/agent-*.meta.json; do
      [ -e "$m" ] || continue
      if grep -q '"finished":true' "$m"; then continue; fi
      id="$(basename "$m" .meta.json)"
      id="${id#agent-}"
      files=("$d/agent-$id.jsonl")
      while IFS= read -r c; do files+=("${c%.meta.json}.jsonl"); done < <(grep -l "\"parentAgentId\":\"$id\"" "$d"/agent-*.meta.json)
      if [ -z "$(find "${files[@]}" -mmin "-$minutes" 2>/dev/null)" ]; then
        echo "stalled: $id"
        exit 0
      fi
    done
  done
  sleep 60
done
