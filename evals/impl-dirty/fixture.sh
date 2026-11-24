#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../impl-fixture.sh"
printf '\nThe export of report rows is planned.\n' >> reports-app/README.md
