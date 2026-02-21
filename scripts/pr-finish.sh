#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-}"
if [ -z "$TITLE" ]; then
  echo "Usage: ./scripts/pr-finish.sh \"feat: ...\""
  exit 1
fi

# Ensure there are changes
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

git add -A
git commit -m "$TITLE"
git push -u origin HEAD

# Create PR; label is best-effort
pr_url="$(gh pr create --title "$TITLE" --fill || true)"
if [ -n "${pr_url}" ]; then
  echo "PR created: ${pr_url}"
  gh pr edit "${pr_url}" --add-label "feat" >/dev/null 2>&1 || true
else
  echo "PR creation may have failed. You can retry with:"
  echo "  gh pr create --title \"$TITLE\" --fill"
fi

echo "Done."
