VIEW = "reports.view"
EDIT = "reports.edit"
ALL = frozenset({VIEW, EDIT})


def allowed(member, permission):
    return permission in member.permissions
