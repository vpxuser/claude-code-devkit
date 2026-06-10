#!/bin/bash
# Check line limits for all devkit artifacts
# Usage: bash scripts/check-limits.sh
# Exit: 0 = all within limits, 1 = violation found

set -euo pipefail

VIOLATIONS=0

# ── 工具函数 ──

check_limit() {
  local FILE="$1"
  local LIMIT="$2"
  local LINES=$(wc -l < "$FILE")

  if [ "$LINES" -gt "$LIMIT" ]; then
    echo "❌ $FILE: $LINES lines (limit: $LIMIT)"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $FILE: $LINES lines"
  fi
}

check_json() {
  local FILE="$1"
  local LIMIT="${2:-100}"

  if ! python -m json.tool "$FILE" > /dev/null 2>&1; then
    echo "❌ $FILE: invalid JSON syntax"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✅ $FILE: valid JSON"
  fi

  check_limit "$FILE" "$LIMIT"
}

# ── 检查函数 ──

check_skills() {
  for f in $(find skills .claude/skills -name 'SKILL.md' 2>/dev/null); do
    check_limit "$f" 500
  done
}

check_claude_md() {
  for f in $(find . -maxdepth 1 -name 'CLAUDE.md' -o -name 'CLAUDE.local.md' 2>/dev/null); do
    [ -f "$f" ] || continue
    check_limit "$f" 150
  done
}

check_agents() {
  for f in $(find .claude/agents -name '*.md' 2>/dev/null); do
    check_limit "$f" 500
  done
}

check_commands() {
  for f in $(find .claude/commands -name '*.md' 2>/dev/null); do
    check_limit "$f" 200
  done
}

check_output_styles() {
  for f in $(find .claude/output-styles -name '*.md' 2>/dev/null); do
    check_limit "$f" 200
  done
}

check_rules() {
  for f in $(find .claude/rules -name '*.md' 2>/dev/null); do
    check_limit "$f" 150
  done
}

check_workflows() {
  for f in $(find .claude/workflows -name '*.js' 2>/dev/null); do
    check_limit "$f" 300
  done
}

check_json_configs() {
  for f in $(find . -maxdepth 1 -name '.mcp.json' -o -name 'mcp.json' 2>/dev/null); do
    [ -f "$f" ] || continue
    check_json "$f" 100
  done

  for f in $(find .claude -name 'settings.json' -o -name 'settings.local.json' 2>/dev/null); do
    [ -f "$f" ] || continue
    check_json "$f" 100
  done
}

check_scripts() {
  for f in $(find scripts -name '*.sh' 2>/dev/null); do
    check_limit "$f" 150
  done
}

# ── 主流程 ──

main() {
  echo "=== Line Limit Check ==="
  echo ""

  check_skills
  check_claude_md
  check_agents
  check_commands
  check_output_styles
  check_rules
  check_workflows
  check_json_configs
  check_scripts

  echo ""
  bash scripts/check-placement.sh
  DIR_RESULT=$?

  echo ""
  TOTAL=$((VIOLATIONS + DIR_RESULT))
  if [ "$TOTAL" -gt 0 ]; then
    echo "❌ Violations found. Fix oversized files or directory placement."
    exit 1
  else
    echo "✅ All files within limits and correct locations"
    exit 0
  fi
}

main
