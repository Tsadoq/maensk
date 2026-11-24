#!/usr/bin/env bash
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
"$here/impl-fixture.sh"
sed -i 's/^Status: ready$/Status: done/' vault/projects/reports-app/plan/csv-export/plan.md

dest="$HOME/.config/maensk/reviewers"
mkdir -p "$dest"
if [ -n "${MAENSK_REVIEWER_CACHE:-}" ]; then
  cp -R "$MAENSK_REVIEWER_CACHE/." "$dest/"
else
  sed -n '/^REVIEWERS=(/,/^)/p' "$here/../install.sh" | grep -o '"[^"]*"' | tr -d '"' |
    while read -r url sha sub name; do
      c="$(mktemp -d)"
      git -C "$c" init -q
      git -C "$c" remote add origin "$url"
      git -C "$c" sparse-checkout set --no-cone "/$sub/" "/LICENSE*" >/dev/null
      git -C "$c" fetch -q --depth 1 --filter=blob:none origin "$sha"
      git -C "$c" checkout -q FETCH_HEAD
      mkdir -p "$dest/$name"
      cp -R "$c/$sub/." "$dest/$name/"
      [ -e "$dest/$name/LICENSE" ] || cp "$c"/LICENSE* "$dest/$name/" 2>/dev/null || true
    done
fi
for name in code-review security-review ponytail-review; do
  [ -f "$dest/$name/SKILL.md" ] || { echo "review-fixture.sh: no $name in $dest" >&2; exit 1; }
done

cd reports-app
git checkout -q -b csv-export
mkdir -p tests

cat >> reports/queries.py <<'PY'


EXPORT_LIMIT = 50_000


def export_rows(primary, team_id):
    return primary.execute(
        "SELECT day, shop, orders, revenue FROM report_rows"
        " WHERE team_id = ? ORDER BY day DESC LIMIT ?",
        (team_id, EXPORT_LIMIT + 1),
    ).fetchall()


def rows_to_dicts(rows):
    return [dict(zip(("day", "shop", "orders", "revenue"), row)) for row in rows]
PY
cat > tests/__init__.py <<'PY'
PY
cat > tests/conftest.py <<'PY'
import sqlite3

import pytest


@pytest.fixture
def db():
    con = sqlite3.connect(":memory:")
    con.execute("CREATE TABLE report_rows (team_id, day, shop, orders, revenue)")
    yield con
    con.close()


def add_rows(con, team_id, count, shop="Main street"):
    con.executemany(
        "INSERT INTO report_rows VALUES (?, ?, ?, ?, ?)",
        [(team_id, f"day-{i:06d}", shop, i, i * 10) for i in range(count)],
    )
PY
cat > tests/test_export_rows.py <<'PY'
from reports import queries
from reports.queries import export_rows

from .conftest import add_rows


def test_a_team_gets_its_own_rows_only(db):
    add_rows(db, 1, 3)
    add_rows(db, 2, 2)
    assert len(export_rows(db, 1)) == 3


def test_the_query_reads_one_row_past_the_limit(db):
    add_rows(db, 1, 50_005)
    assert len(export_rows(db, 1)) == 50_001


def test_the_order_is_that_of_report_rows(db):
    add_rows(db, 1, 5)
    assert export_rows(db, 1) == queries.report_rows(db, 1, 0)


def test_the_limit_is_fifty_thousand():
    assert queries.EXPORT_LIMIT == 50_000
PY
git add -A
git commit -qm "Read the rows of an export"

cat > reports/csv_text.py <<'PY'
import csv
import io


def csv_text(rows):
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(("day", "shop", "orders", "revenue"))
    writer.writerows(rows)
    return out.getvalue()
PY
cat > tests/test_csv_text.py <<'PY'
import csv
import io

from reports.csv_text import csv_text


def parse(text):
    return list(csv.reader(io.StringIO(text, newline="")))


def test_header_and_rows():
    text = csv_text([("2026-01-01", "Main street", 3, 30), ("2026-01-02", "Harbour", 4, 40)])
    assert parse(text) == [
        ["day", "shop", "orders", "revenue"],
        ["2026-01-01", "Main street", "3", "30"],
        ["2026-01-02", "Harbour", "4", "40"],
    ]


def test_a_shop_name_with_a_comma_a_quote_and_a_newline():
    name = 'Bob\'s, "best"\nshop'
    assert parse(csv_text([("2026-01-01", name, 1, 10)]))[1][1] == name


def test_no_rows():
    assert parse(csv_text([])) == [["day", "shop", "orders", "revenue"]]
PY
cat >> README.md <<'MD'

## Export

A member with `reports.view` can export the report rows of the team as one CSV file, up to 50,000 rows.
Every field of the file is in double quotes, because Python's `csv` module quotes every field by default.
MD
git add -A
git commit -qm "Write report rows as CSV text"

cat >> reports/views.py <<'PY'


def export_csv(request, primary):
    member = request.member
    if not permissions.allowed(member, permissions.VIEW):
        return 403, "forbidden"
    rows = queries.export_rows(primary, member.team_id)
    stopped = len(rows) >= queries.EXPORT_LIMIT
    return 200, {"csv": csv_text(rows[: queries.EXPORT_LIMIT]), "stopped": stopped}
PY
sed -i '1s/^/from .csv_text import csv_text\n/' reports/views.py
cat > tests/test_export_csv.py <<'PY'
import sqlite3
import types

from reports.models import Member
from reports.views import export_csv

from .conftest import add_rows


def request(team_id, permissions=frozenset({"reports.view"})):
    return types.SimpleNamespace(member=Member(1, team_id, "a@example.com", permissions))


def test_one_team(db):
    add_rows(db, 1, 3)
    add_rows(db, 2, 2)
    status, body = export_csv(request(1), db)
    assert status == 200
    assert len(body["csv"].splitlines()) == 4


def test_primary():
    a, b = sqlite3.connect(":memory:"), sqlite3.connect(":memory:")
    for con, shop in ((a, "A"), (b, "B")):
        con.execute("CREATE TABLE report_rows (team_id, day, shop, orders, revenue)")
        add_rows(con, 1, 1, shop)
    status, body = export_csv(request(1), a)
    assert ",A," in body["csv"] and ",B," not in body["csv"]


def test_permission(db):
    assert export_csv(request(1, frozenset({"reports.edit"})), db) == (403, "forbidden")


def test_an_export_past_the_limit_stops(db):
    add_rows(db, 1, 50_001)
    status, body = export_csv(request(1), db)
    assert len(body["csv"].splitlines()) == 50_001
    assert body["stopped"] is True
PY
git add -A
git commit -qm "Build the export view"
python3 -m pytest -q >/dev/null
git rev-parse HEAD > "$HOME/fixture-tip"
