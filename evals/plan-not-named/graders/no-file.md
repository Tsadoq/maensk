---
type: regex
target: files
pattern: '^(vault|reports-app)/(?!.*__pycache__/).+'
flags: m
match: not_contains
---
