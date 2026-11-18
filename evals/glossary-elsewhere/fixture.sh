#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../fixture.sh"
mkdir -p vault/projects/reports-app/research
mv "vault/projects/reports-app/Reports Glossary.md" vault/projects/reports-app/research/
