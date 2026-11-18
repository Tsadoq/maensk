from dataclasses import dataclass


@dataclass
class Team:
    id: int
    name: str


@dataclass
class Member:
    id: int
    team_id: int
    email: str
    permissions: frozenset[str]
