#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../impl-fixture.sh"
P=vault/projects/reports-app/plan/reports-overhaul
mkdir -p "$P/tasks" "$P/01-query-builder/tasks"
cat > "$P/plan.md" <<MD
---
title: "Reports overhaul"
tags:
  - project
  - plan
---

# Reports overhaul

Status: ready
Kind: parent
Repo: $PWD/reports-app
Input: the job as the user gave it
Goal: Finance gets CSV exports of its reports, on a query layer that the next features build on.
Scope: in, a query builder and the CSV export. Out, roles, an audit log and a public API.

## Requirements

| Id | Requirement | Tasks |
| --- | --- | --- |
| R1 | The queries of the reports page are built with a query builder. | 1 |
| R2 | A member gets the report rows of the team as one CSV file. | 2 |

## Tasks

| # | Task | After | File |
| --- | --- | --- | --- |
| 1 | A query builder for the report queries | none | tasks/01-query-builder.md |
| 2 | CSV export of the reports page | 1 | tasks/02-csv-export.md |

## Rounds

1. Task 1
2. Task 2

## Start each part

1. Use super-plan on $PWD/$P/tasks/01-query-builder.md
2. Use super-plan on $PWD/$P/tasks/02-csv-export.md
MD
cat > "$P/tasks/01-query-builder.md" <<'MD'
---
title: "Part 1 - A query builder for the report queries"
tags:
  - project
  - plan
---

# Part 1: A query builder for the report queries

The queries in `reports/queries.py` are built with a small query builder instead of SQL strings. The results of `report_rows` and `row_count` stay the same.
After: none
Serves: R1
MD
cat > "$P/tasks/02-csv-export.md" <<'MD'
---
title: "Part 2 - CSV export of the reports page"
tags:
  - project
  - plan
---

# Part 2: CSV export of the reports page

A member of a team gets the report rows of the team as one CSV file, as in [[Reports CSV Export Spec]], with its queries on the query builder of part 1.
After: 1
Serves: R2
MD
cat > "$P/01-query-builder/plan.md" <<'MD'
---
title: "A query builder for the report queries"
tags:
  - project
  - plan
---

# A query builder for the report queries

Status: done
Input: [[01-query-builder]]
Goal: The queries in `reports/queries.py` are built with a small query builder.
MD
