#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../review-fixture.sh"
claude mcp remove --scope user parallel
