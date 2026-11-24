#!/usr/bin/env bash
cd reports-app || exit 0
echo "Branch checked out: $(git branch --show-current)"
echo "Commits on top of main, oldest first:"
git log --reverse --format='  %h %s' main..HEAD
for c in $(git rev-list --reverse main..HEAD); do
  echo "Files of the commit \"$(git log -1 --format=%s "$c")\":"
  git show --stat --format= "$c" | sed 's/^/  /'
done
echo "Uncommitted changes:"
git status --short | sed 's/^/  /'
echo "Tests at the tip:"
python3 -m pytest -q 2>&1 | tail -n 3 | sed 's/^/  /'
echo "Diff of the branch since the fixture built it:"
git diff "$(cat "$HOME/fixture-tip")" HEAD
