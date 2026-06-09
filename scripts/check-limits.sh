#!/bin/bash
# Check line limits for all devkit artifacts
# Usage: bash scripts/check-limits.sh
# Exit: 0 = all within limits, 1 = violation found

VIOLATIONS=0

echo "=== Line Limit Check ==="
echo ""

# Check all SKILL.md files (≤ 500 lines)
for f in $(find skills .claude/skills -name 'SKILL.md' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 500 ]; then
    echo "❌ $f: $LINES lines (limit: 500)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all CLAUDE.md files (≤ 150 lines)
for f in $(find . -maxdepth 1 -name 'CLAUDE.md' -o -name 'CLAUDE.local.md' 2>/dev/null); do
  [ -f "$f" ] || continue
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 150 ]; then
    echo "❌ $f: $LINES lines (limit: 150)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all Agent files (≤ 500 lines)
for f in $(find .claude/agents -name '*.md' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 500 ]; then
    echo "❌ $f: $LINES lines (limit: 500)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all Command files (≤ 200 lines)
for f in $(find .claude/commands -name '*.md' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 200 ]; then
    echo "❌ $f: $LINES lines (limit: 200)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all Output Style files (≤ 200 lines)
for f in $(find .claude/output-styles -name '*.md' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 200 ]; then
    echo "❌ $f: $LINES lines (limit: 200)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all Rule files (≤ 200 lines)
for f in $(find .claude/rules -name '*.md' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 200 ]; then
    echo "❌ $f: $LINES lines (limit: 200)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

# Check all Workflow files (≤ 300 lines)
for f in $(find .claude/workflows -name '*.js' 2>/dev/null); do
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 300 ]; then
    echo "❌ $f: $LINES lines (limit: 300)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $f: $LINES lines"
  fi
done

echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌ $VIOLATIONS violation(s) found. Split oversized files."
  exit 1
else
  echo "✅ All files within line limits"
  exit 0
fi
