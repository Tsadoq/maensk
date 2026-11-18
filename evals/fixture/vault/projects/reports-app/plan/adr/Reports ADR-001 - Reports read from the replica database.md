---
title: "Reports ADR-001 - Reports read from the replica database"
tags:
  - project
  - adr
---

Report queries made the primary database slow for the shops. Every read of report rows now goes to the replica database, which can be up to five minutes behind. Reading report rows from the primary database is not allowed.
