#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../impl-fixture.sh"
sed -i 's/^Status: ready$/Status: draft/' vault/projects/reports-app/features/csv-export/plans/csv-export/plan.md
