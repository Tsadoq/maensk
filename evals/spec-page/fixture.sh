#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../fixture.sh"
mkdir -p vault/projects/reports-app/plan/decisions
cat > "vault/projects/reports-app/plan/decisions/Reports Decision Record - Exports read from the primary database.md" <<'MD'
---
title: "Reports Decision Record - Exports read from the primary database"
tags:
  - project
---

ADR-001 sends every read of report rows to the replica database. An export reads the primary database instead, as the one exception. Finance compares an export with the bank in the same minute, and rows that are five minutes old make the totals wrong.
MD
