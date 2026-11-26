#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../review-fixture.sh"
rm -rf "$HOME/.config/maensk/reviewers/security-review"
