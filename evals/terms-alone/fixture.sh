#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../fixture.sh"
rm "vault/projects/reports-app/Reports Glossary.md"
