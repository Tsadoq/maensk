#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../review-fixture.sh"
printf '\nThe export is done.\n' >> reports-app/README.md
