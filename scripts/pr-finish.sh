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

# --- Label auto-detection from title prefix ---
label=""
case "$TITLE" in
  feat:*|feat\(*) label="feat" ;;
  fix:*|fix\(*)   label="fix" ;;
  docs:*|docs\(*) label="docs" ;;
  refactor:*|refactor\(*) label="refactor" ;;
  test:*|test\(*) label="test" ;;
  chore:*|chore\(*) label="chore" ;;
esac

# --- Commit with Co-Authored-By ---
git add -A
git commit -m "$TITLE

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin HEAD

# --- Build PR body from template ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="${REPO_ROOT}/.github/PULL_REQUEST_TEMPLATE.md"

pr_body_args=()
if [ -f "$TEMPLATE" ]; then
  pr_body_args=(--body-file "$TEMPLATE")
else
  pr_body_args=(--fill)
fi

# --- Create PR ---
pr_url="$(gh pr create --title "$TITLE" "${pr_body_args[@]}" 2>&1 || true)"
if [ -n "$pr_url" ]; then
  echo "PR created: ${pr_url}"

  # Apply detected label
  if [ -n "$label" ]; then
    gh pr edit "$pr_url" --add-label "$label" >/dev/null 2>&1 || true
  fi

  # Always add ai-review label for automated review
  gh pr edit "$pr_url" --add-label "ai-review" >/dev/null 2>&1 || true
else
  echo "PR creation may have failed. You can retry with:"
  echo "  gh pr create --title \"$TITLE\" --body-file .github/PULL_REQUEST_TEMPLATE.md"
fi

echo "Done."
