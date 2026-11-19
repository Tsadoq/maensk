#!/usr/bin/env bash
set -eu
"$(dirname "$0")/../fixture.sh"
mkdir tracker
printf '# Show the revenue of each shop\n\nThe reports page shows the revenue of each shop for one day.\n' > "tracker/1 - Show the revenue of each shop.md"
