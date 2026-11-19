#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../fixture.sh"
printf 'def key_works(key):\n    return key.startswith("repkey_") and len(key) == 39\n' > reports-app/reports/client.py
printf 'REPORTS_API_KEY=repkey_UIYZGaAjylEp2FPfZzfG2sQgWqRlAkut\n' > reports-app/.env
