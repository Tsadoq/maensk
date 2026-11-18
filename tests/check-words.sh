#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cp "$root/tools/check-words" "$tmp/"
printf 'Acme Corp\nwidgetco\n\n' >"$tmp/list"
"$tmp/check-words" --hash "$tmp/list" >/dev/null

printf 'we use acme_corp tools\n' >"$tmp/phrase"
printf 'host build.WidgetCo.example\n' >"$tmp/word"
printf 'id 01234567-89ab-%s\n' 'cdef-0123-456789abcdef' >"$tmp/session"
printf 'acme alone is fine, and so is a corp\n' >"$tmp/clean"

for bad in phrase word session; do
  if "$tmp/check-words" "$tmp/$bad" >/dev/null; then
    echo "FAIL: $bad was not reported" >&2
    exit 1
  fi
done
"$tmp/check-words" "$tmp/clean" || {
  echo "FAIL: clean text was reported" >&2
  exit 1
}
if printf 'one two three four\n' >"$tmp/long" && "$tmp/check-words" --hash "$tmp/long" 2>/dev/null; then
  echo "FAIL: an entry of four words was accepted" >&2
  exit 1
fi

echo "check-words: all checks passed"
