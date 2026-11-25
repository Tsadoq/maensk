#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../impl-fixture.sh"
printf '\nThe export of report rows is planned.\n' >> reports-app/README.md
P=vault/projects/reports-app/features/csv-export/plans/csv-export
sed -i 's/in the order of `report_rows`, in one statement\./in the order of `report_rows`, oldest day first, in one statement./' "$P/tasks/01-export-rows.md"
sed -i 's/in the order of `report_rows`, and a 50,001st/in the order of `report_rows`, oldest day first, and a 50,001st/' "$P/tasks/01-export-rows.md"
sed -i 's/^Picked: one query with a limit of 50,001, in the order of `report_rows`\. Picked by the user\./Picked: one query with a limit of 50,001, in the order of `report_rows`, oldest day first. Picked by the user./' "$P/record.md"
