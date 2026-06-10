#!/bin/bash
# Check file placement against devkit directory conventions
# Usage: bash scripts/check-placement.sh [file_path]
# If file_path given, check single file (PostToolUse mode).
# Otherwise scan all project files (integration mode).
#
# Only checks files that are clearly devkit artifacts.
# Skips: devkit submodule, node_modules, .git, evidence/, data/

check_file() {
  local FILE="$1"
  local BASENAME="$(basename "$FILE")"
  local VIOLATED=0

  # Skip non-project directories
  echo "$FILE" | grep -qE '(\.claude/devkit/|node_modules/|\.git/|^evidence/|^data/)' && return 0

  case "$BASENAME" in
    SKILL.md)
      if ! echo "$FILE" | grep -qE '(^skills/|^\.claude/skills/)'; then
        echo "❌ $FILE: SKILL.md must be in skills/ or .claude/skills/"
        VIOLATED=1
      fi
      ;;
    AGENT.md)
      if ! echo "$FILE" | grep -qE '^\.claude/agents/'; then
        echo "❌ $FILE: AGENT.md must be in .claude/agents/"
        VIOLATED=1
      fi
      ;;
    .mcp.json|mcp.json)
      # MCP config must be in project root (not in subdirectories)
      local DIR=$(dirname "$FILE")
      if [ "$DIR" != "." ]; then
        echo "❌ $FILE: MCP config must be in project root"
        VIOLATED=1
      fi
      ;;
    plugin.json)
      if ! echo "$FILE" | grep -qE '^\.claude-plugin/'; then
        echo "❌ $FILE: plugin.json must be in .claude-plugin/"
        VIOLATED=1
      fi
      ;;
  esac

  # Check .js files ONLY in .claude/ context (not evidence/, data/, etc.)
  if echo "$BASENAME" | grep -qE '\.js$' && echo "$FILE" | grep -qE '^\.claude/'; then
    if ! echo "$FILE" | grep -qE '^\.claude/workflows/'; then
      echo "❌ $FILE: .js in .claude/ must be in .claude/workflows/"
      VIOLATED=1
    fi
  fi

  # Check .sh files ONLY in .claude/ context (not scripts/, etc.)
  if echo "$BASENAME" | grep -qE '\.sh$' && echo "$FILE" | grep -qE '^\.claude/'; then
    if ! echo "$FILE" | grep -qE '^\.claude/hooks/'; then
      echo "❌ $FILE: .sh in .claude/ must be in .claude/hooks/"
      VIOLATED=1
    fi
  fi

  return $VIOLATED
}

# Main
if [ -n "$1" ]; then
  # Single file mode (for PostToolUse hook)
  check_file "$1"
  exit $?
else
  # Scan mode (for check-limits.sh integration)
  echo "=== Directory Structure Check ==="
  echo ""

  TOTAL_VIOLATIONS=0

  # Find all relevant files, skip devkit/node_modules/git/evidence/data
  for f in $(find . -type f \( -name '*.md' -o -name '*.js' -o -name '*.sh' -o -name '*.json' \) \
    -not -path './.claude/devkit/*' -not -path './node_modules/*' -not -path './.git/*' \
    -not -path './evidence/*' -not -path './data/*' 2>/dev/null); do
    NORM=$(echo "$f" | sed 's|^\./||')
    check_file "$NORM"
    if [ $? -ne 0 ]; then
      TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
    fi
  done

  echo ""
  if [ "$TOTAL_VIOLATIONS" -gt 0 ]; then
    echo "❌ $TOTAL_VIOLATIONS placement violation(s) found."
    exit 1
  else
    echo "✅ All files in correct locations"
    exit 0
  fi
fi
