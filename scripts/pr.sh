#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-}"
if [ -z "$TITLE" ]; then
  echo "Usage: ./scripts/pr.sh \"feat: ...\""
  exit 1
fi

# Require clean working tree (avoid accidental context switches)
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean. Commit/stash your changes first."
  git status --porcelain
  exit 1
fi

# Determine default branch via GitHub (fallback: main)
default_branch="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || true)"
if [ -z "${default_branch}" ]; then
  default_branch="main"
fi

# Update default branch safely
git checkout "$default_branch"
git pull --rebase

# Create feature branch name
slug=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')
branch="feat/${slug}-$(date +%Y%m%d%H%M%S)"
git checkout -b "$branch"

echo "Now implement your changes, then run:"
echo "  ./scripts/pr.sh --finish \"${TITLE}\""
echo ""
echo "Tip: If you want one-shot (commit+push+PR) after implementation, rerun with --finish."
