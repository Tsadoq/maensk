#!/usr/bin/env bash
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
"$here/plan-fixture.sh"
python3 -m pip install --user --break-system-packages -q --no-warn-script-location ${MAENSK_WHEELS:+--no-index --find-links "$MAENSK_WHEELS"} pytest mutmut
python3 - "$HOME/.config/maensk/config.json" <<'PY'
import json, sys
p = sys.argv[1]
c = json.load(open(p))
c["mutation"] = {"python": "python3 -m mutmut"}
json.dump(c, open(p, "w"), indent=2)
PY
cat >> reports-app/README.md <<'MD'

## Working on it

Run the tests with `python3 -m pytest` from the repo root. Push a branch with `git push -u origin <branch>`.
MD
printf '__pycache__/\n.pytest_cache/\n' > reports-app/.gitignore
git init -q --bare origin-repo
git -C reports-app config user.name "Eval"
git -C reports-app config user.email "eval@example.com"
git -C reports-app remote add origin "$PWD/origin-repo"
git -C reports-app add -A
git -C reports-app commit -qm "Reports page"
git -C reports-app branch -M main
git -C reports-app push -q origin HEAD:main
P=vault/projects/reports-app/plan/csv-export
mkdir -p "$P/tasks"
cat > "$P/plan.md" <<MD
---
title: "CSV export of the reports page"
tags:
  - project
  - plan
---

# CSV export of the reports page

Status: ready
Repo: $PWD/reports-app
Input: [[Reports CSV Export Spec]]
Goal: A member of a team gets the report rows of the team as one CSV file, read from the primary database.
Scope: in, the export, its limit of 50,000 report rows, and the flag that says the export stopped. Out, Excel files, exports on a schedule, and the message on the reports page.

## Requirements

| Id | Requirement | Tasks |
| --- | --- | --- |
| R1 | An export shall be one CSV file with the report rows of one team. | 1, 3 |
| R2 | An export shall stop at 50,000 report rows. | 1, 3 |
| R3 | The reports page shall say that an export stopped at its limit. This plan ends at the flag \`stopped\`. | 3 |
| R4 | An export shall read the primary database. | 1, 3 |
| R5 | The CSV file shall have one column for each field of a report row: day, shop, orders, revenue. | 2 |
| G1 | The export is tested with \`pytest\` against a SQLite database in memory. Nothing is replaced. | 1, 2, 3 |

## Tasks

| # | Task | After | File |
| --- | --- | --- | --- |
| 1 | Read the rows of an export | none | tasks/01-export-rows.md |
| 2 | Write report rows as CSV text | none | tasks/02-csv-text.md |
| 3 | Build the export view | 1, 2 | tasks/03-export-view.md |

## Rounds

1. Tasks 1, 2
2. Task 3
MD
cat > "$P/tasks/01-export-rows.md" <<'MD'
---
title: "Task 1 - Read the rows of an export"
tags:
  - project
  - plan
---

# Task 1: Read the rows of an export

Plan: CSV export of the reports page. A member of a team gets the report rows of the team as one CSV file.
Rests on: one query reads up to 50,001 rows in one statement, in the order of `report_rows`, and a 50,001st row means that the export stopped. It reads the primary database.

Add `export_rows(primary, team_id)` to `reports/queries.py`. It returns up to 50,001 rows (day, shop, orders, revenue) of the team, in the order of `report_rows`, in one statement.
Tests (`tests/test_export_rows.py`; a fixture `db` in `tests/conftest.py` gives a SQLite database in memory that has a `report_rows` table with `team_id`, `day`, `shop`, `orders`, `revenue`; every row on its own day):
- A team gets its own rows only. Asserts: with 3 rows of team 1 and 2 rows of team 2, `export_rows(db, 1)` returns the 3 rows of team 1. Level: component. Real: the query on SQLite in memory. Replaced: nothing.
- The query reads one row past the limit. Asserts: with 50,005 rows of team 1, `export_rows(db, 1)` returns exactly 50,001 rows. Level: component. Real: as above. Replaced: nothing.
- The order is that of `report_rows`. Asserts: with 5 rows of team 1, `export_rows(db, 1)` equals the 5 rows that `report_rows(db, 1, 0)` returns. Level: component. Real: both queries on SQLite in memory. Replaced: nothing.
Done when: `python3 -m pytest tests/test_export_rows.py` passes.
After: none
Touches: `reports/queries.py`, `tests/conftest.py`, `tests/test_export_rows.py`
Serves: R1, R2, R4, G1
MD
cat > "$P/tasks/02-csv-text.md" <<'MD'
---
title: "Task 2 - Write report rows as CSV text"
tags:
  - project
  - plan
---

# Task 2: Write report rows as CSV text

Plan: CSV export of the reports page. A member of a team gets the report rows of the team as one CSV file.
Rests on: the CSV text is built with Python's `csv` module, with the header `day,shop,orders,revenue`.

Add `csv_text(rows)` in a new module `reports/csv_text.py`. It returns the header and one line for each row of (day, shop, orders, revenue).
Tests (`tests/test_csv_text.py`; a helper `parse(text)` in `tests/conftest.py` parses the result with `csv.reader(io.StringIO(text, newline=""))`):
- Header and rows. Asserts: two rows give a header `day`, `shop`, `orders`, `revenue` and the two rows, each field as a string. Level: unit. Real: the `csv` module. Replaced: nothing.
- A shop name with a comma, a quote and a newline. Asserts: the row parses back to four fields and the shop name is unchanged. Level: unit. Real: as above. Replaced: nothing.
- No rows. Asserts: `csv_text([])` parses to the header alone. Level: unit. Real: as above. Replaced: nothing.
Done when: `python3 -m pytest tests/test_csv_text.py` passes.
After: none
Touches: `reports/csv_text.py`, `tests/conftest.py`, `tests/test_csv_text.py`
Serves: R5, G1
MD
cat > "$P/tasks/03-export-view.md" <<'MD'
---
title: "Task 3 - Build the export view"
tags:
  - project
  - plan
---

# Task 3: Build the export view

Plan: CSV export of the reports page. A member of a team gets the report rows of the team as one CSV file.
Rests on: `export_csv` sits beside `reports_page` and gets the primary database connection as an argument. A member with `reports.view` can export. A 50,001st row from `export_rows` means that the export stopped; the view returns the flag `stopped`.

Add `export_csv(request, primary)` to `reports/views.py`. It returns `403, "forbidden"` without `reports.view`. Otherwise it returns `200, {"csv": csv_text(rows), "stopped": stopped}` with at most 50,000 rows of `export_rows(primary, member.team_id)`.
Tests (`tests/test_export_csv.py`; SQLite in memory, every row on its own day; the request is `types.SimpleNamespace(member=Member(...))`):
- One team. Asserts: with 3 rows of team 1 and 2 of team 2, a member of team 1 gets 200 and the CSV holds the 3 rows of team 1. Level: component. Real: view, query, `csv` module. Replaced: nothing.
- Primary. Asserts: with one row only in database A and another only in database B, `export_csv(request, A)` holds the row of A only. Level: component. Real: two SQLite databases in memory. Replaced: nothing.
- Permission. Asserts: a member with only `reports.edit` gets `403, "forbidden"`. Level: component. Real: `permissions.allowed`. Replaced: nothing.
- Limit. Asserts: with 50,001 rows the CSV has 50,000 rows and `stopped` is true; with 50,000 rows, 50,000 rows and false. Level: component. Real: as above. Replaced: nothing.
Done when: `python3 -m pytest tests` passes.
After: 1, 2
Touches: `reports/views.py`, `tests/test_export_csv.py`
Serves: R1, R2, R3, R4, G1
MD
cat > "$P/record.md" <<'MD'
---
title: "Record - CSV export of the reports page"
tags:
  - project
  - plan
---

# Record: CSV export of the reports page

## Design choices

### 1. How the export reads its rows
Picked: one query with a limit of 50,001, in the order of `report_rows`. Picked by the user.
Refused: page by page with `report_rows`, which costs 250 queries for one export.
Why: one statement is one consistent read of the primary database.
Checked: a query with `LIMIT 50001` on SQLite in memory returned 50,001 of 50,005 rows.

### 2. Where the export lives
Picked: a view `export_csv` beside `reports_page` that gets the primary connection as an argument, and a module `reports/csv_text.py` for the CSV text. Picked by the user.
Refused: a method on a new class.
Why: it follows how `reports_page` gets the replica.
Checked: not verified: nothing to run.

### 3. Who can export
Picked: a member with `reports.view`. No new permission. Picked by the user.
Refused: a new permission `reports.export`.
Why: finance members already have `reports.view`.
Checked: not verified: nothing to run.

## Settled in planning

- G1. How the export is tested: `pytest` against SQLite in memory, nothing replaced. Answered by the user.

## Checks

- Claim: `LIMIT 50001` returns 50,001 rows when the team has more. Result: holds.

## Critics

- Task 3 named no file for its test. Fixed in task 3.
MD
