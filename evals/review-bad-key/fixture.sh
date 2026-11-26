#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../review-fixture.sh"
sed -i 's/^CONTEXT7_API_KEY=.*/CONTEXT7_API_KEY=ctx7sk-wrong-key-for-the-eval/' "$HOME/.config/maensk/keys"
grep -q '^CONTEXT7_API_KEY=ctx7sk-wrong-key-for-the-eval$' "$HOME/.config/maensk/keys" || { echo "review-bad-key: the keys file holds no wrong Context7 key" >&2; exit 1; }
