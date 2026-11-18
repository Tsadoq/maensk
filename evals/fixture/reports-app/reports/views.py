from . import permissions, queries


def reports_page(request, replica):
    member = request.member
    if not permissions.allowed(member, permissions.VIEW):
        return 403, "forbidden"
    page = int(request.args.get("page", 0))
    return 200, {
        "rows": queries.report_rows(replica, member.team_id, page),
        "page": page,
        "total": queries.row_count(replica, member.team_id),
    }
