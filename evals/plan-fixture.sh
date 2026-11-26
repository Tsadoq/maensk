#!/usr/bin/env bash
set -eu
"$(cd "$(dirname "$0")" && pwd)/fixture.sh"
mkdir -p vault/projects/reports-app/plan/decisions vault/projects/reports-app/features/csv-export
cat > "vault/projects/reports-app/plan/decisions/Reports Decision Record - Exports read from the primary database.md" <<'MD'
---
title: "Reports Decision Record - Exports read from the primary database"
tags:
  - project
---

ADR-001 sends every read of report rows to the replica database. An export reads the primary database instead, as the one exception. Finance compares an export with the bank in the same minute, and rows that are five minutes old make the totals wrong.
MD
cat > "vault/projects/reports-app/features/csv-export/Reports CSV Export Spec.md" <<'MD'
---
title: "Reports CSV Export Spec"
tags:
  - project
  - spec
---

Project: [[reports-app]]. Terms follow [[Reports Glossary]].

## Problem

The finance team checks the report rows of its team against the bank once a day. Today a member copies the report rows from the reports page by hand, 200 rows at a time.

## Solution

The reports page offers an export: one CSV file with the report rows of one team. An export stops at 50,000 report rows and the page says so. An export reads the primary database, so its totals match the bank in the same minute.

## Requirements

- R1. An export shall be one CSV file with the report rows of one team. **Done when an export produces one CSV file and every report row in it belongs to that team.**
- R2. An export shall stop at 50,000 report rows. **Done when a team with more than 50,000 report rows gets a CSV file of exactly 50,000 report rows.**
- R3. The reports page shall say that an export stopped at its limit. **Done when the page shows that message after an export that stopped at 50,000 report rows, and shows none after an export that did not.**
- R4. An export shall read the primary database. **Done when a report row written to the primary database but not yet on the replica database is in the next export.**
- R5. The CSV file shall have one column for each field of a report row: day, shop, orders, revenue. **Done when the CSV file has exactly these four columns and each report row fills them.**

## Decisions

- An "export" is one CSV file with the report rows of one team. The word "dump" and the word "download" are not used for it.
- An export stops at 50,000 report rows, and the page says so when it stops.
- An export reads the primary database. This overrides [[Reports ADR-001 - Reports read from the replica database]] for exports only; see [[Reports Decision Record - Exports read from the primary database]]. Reason: finance compares an export with the bank in the same minute, and rows that are five minutes old make the totals wrong.
- The CSV file has one column for each field of a report row: day, shop, orders, revenue.

## Testing

Not decided. No test approach was settled.

## Out of scope

- Excel files.
- Exports on a schedule.

## Left to the developer

- Which members can export.
- Where the export button goes on the reports page.
MD
