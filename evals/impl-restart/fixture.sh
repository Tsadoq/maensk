#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../impl-fixture.sh"
base=$(git -C reports-app rev-parse --short HEAD)
git -C reports-app worktree add -q -b csv-export "$PWD/reports-app-csv-export"
W=reports-app-csv-export
mkdir -p "$W/tests"
cat >> "$W/reports/queries.py" <<'PY'


EXPORT_LIMIT = 50_000


def export_rows(primary, team_id):
    return primary.execute(
        "SELECT day, shop, orders, revenue FROM report_rows"
        " WHERE team_id = ? ORDER BY day DESC LIMIT ?",
        (team_id, EXPORT_LIMIT + 1),
    ).fetchall()
PY
cat > "$W/tests/conftest.py" <<'PY'
import sqlite3

import pytest


@pytest.fixture
def db():
    conn = sqlite3.connect(":memory:")
    conn.execute("CREATE TABLE report_rows (team_id, day, shop, orders, revenue)")
    yield conn
    conn.close()


def add_rows(conn, team_id, n, start=0):
    conn.executemany(
        "INSERT INTO report_rows VALUES (?, ?, ?, ?, ?)",
        [(team_id, f"day-{start + i:06d}", f"shop {i}", i, i * 10) for i in range(n)],
    )
PY
cat > "$W/tests/test_export_rows.py" <<'PY'
from reports.queries import export_rows, report_rows
from tests.conftest import add_rows


def test_team_gets_own_rows_only(db):
    add_rows(db, 1, 3)
    add_rows(db, 2, 2, start=100)
    assert len(export_rows(db, 1)) == 3


def test_reads_one_row_past_the_limit(db):
    add_rows(db, 1, 50_005)
    assert len(export_rows(db, 1)) == 50_001


def test_order_is_that_of_report_rows(db):
    add_rows(db, 1, 5)
    assert export_rows(db, 1) == report_rows(db, 1, 0)
PY
touch "$W/tests/__init__.py"
git -C "$W" add -A
git -C "$W" commit -qm "Read the rows of an export"
c1=$(git -C "$W" rev-parse --short HEAD)
cat >> "$W/tests/conftest.py" <<'PY'


def parse(text):
    return list(csv.reader(io.StringIO(text, newline="")))
PY
sed -i '1i import csv\nimport io' "$W/tests/conftest.py"
cat > "$W/reports/csv_text.py" <<'PY'
import csv
import io

HEADER = ("day", "shop", "orders", "revenue")


def csv_text(rows):
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(HEADER)
    writer.writerows(rows)
    return out.getvalue()
PY
cat > "$W/tests/test_csv_text.py" <<'PY'
from reports.csv_text import csv_text
from tests.conftest import parse


def test_header_and_rows():
    rows = [("2026-01-01", "a", 1, 10), ("2026-01-02", "b", 2, 20)]
    assert parse(csv_text(rows)) == [
        ["day", "shop", "orders", "revenue"],
        ["2026-01-01", "a", "1", "10"],
        ["2026-01-02", "b", "2", "20"],
    ]


def test_shop_with_comma_quote_newline():
    shop = 'a, "b"\nc'
    parsed = parse(csv_text([("2026-01-01", shop, 1, 10)]))
    assert parsed[1] == ["2026-01-01", shop, "1", "10"]


def test_no_rows():
    assert parse(csv_text([])) == [["day", "shop", "orders", "revenue"]]
PY
git -C "$W" add -A
git -C "$W" commit -qm "Write report rows as CSV text"
c2=$(git -C "$W" rev-parse --short HEAD)
cat > vault/projects/reports-app/plan/csv-export/run.md <<MD
---
title: "Build - CSV export of the reports page"
tags:
  - project
  - plan
---

# Build: CSV export of the reports page

Branch: csv-export
Worktree: $PWD/$W
Started from: $base on main

## Log

- Start check: tests run with \`python3 -m pytest\`, mutation tool \`python3 -m mutmut\`, checkout clean.
- Round 1: tasks 1 and 2.
- Task 1 finished. Commit $c1. Tests red before the code, green after; each test failed on a break of the code; reviewers found nothing that stood.
- Task 2 finished. Commit $c2. Tests red before the code, green after; each test failed on a break of the code; reviewers found nothing that stood.
- The build stopped: the session ended before round 2.
MD
