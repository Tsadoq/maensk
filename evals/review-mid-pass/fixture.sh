#!/usr/bin/env bash
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
"$here/../review-fixture.sh"
claude mcp remove --scope user context7
claude mcp add-json --scope user context7 "$(python3 -c 'import json, sys; print(json.dumps({"type": "stdio", "command": "python3", "args": [sys.argv[1]]}))' "$here/../stub-context7.py")"
claude mcp get context7 | grep -q stub-context7.py || { echo "review-mid-pass: context7 is not the stub" >&2; exit 1; }
