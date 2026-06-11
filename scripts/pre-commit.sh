#!/bin/bash
# Git pre-commit hook — install with:
#   cp scripts/pre-commit.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit

set -e

echo "=== Pre-commit: Markdown Lint ==="
STAGED_MD=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)

if [ -z "$STAGED_MD" ]; then
  echo "No staged .md files. Skipping lint."
  exit 0
fi

echo "$STAGED_MD" | while read -r f; do
  npx markdownlint "$f" 2>&1
done

echo ""
echo "=== Pre-commit: Line Limits ==="
bash .claude/hooks/stop-check-limits.sh

echo ""
echo "=== Pre-commit: Directory Structure ==="
bash scripts/check-placement.sh

echo ""
echo "=== Pre-commit: Constraints ==="
bash scripts/check-constraints.sh

echo ""
echo "✅ Pre-commit checks passed"
