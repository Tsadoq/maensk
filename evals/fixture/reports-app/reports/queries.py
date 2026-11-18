PAGE_SIZE = 200


def report_rows(replica, team_id, page):
    return replica.execute(
        "SELECT day, shop, orders, revenue FROM report_rows"
        " WHERE team_id = ? ORDER BY day DESC LIMIT ? OFFSET ?",
        (team_id, PAGE_SIZE, page * PAGE_SIZE),
    ).fetchall()


def row_count(replica, team_id):
    return replica.execute(
        "SELECT count(*) FROM report_rows WHERE team_id = ?", (team_id,)
    ).fetchone()[0]
