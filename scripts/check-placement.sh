#!/bin/bash
# Check file placement against devkit directory conventions
# Usage: bash scripts/check-placement.sh [file_path]
# If file_path given, check single file (PostToolUse mode).
# Otherwise scan all project files (integration mode).

set -euo pipefail

VIOLATIONS=0

# ── 工具函数 ──

is_skip_path() {
  echo "$1" | grep -qE '(\.claude/devkit/|node_modules/|\.git/|^evidence/|^data/)'
}

# ── 主检查函数 ──

check_file() {
  local FILE="$1"
  local BASENAME="$(basename "$FILE")"
  local VIOLATED=0

  is_skip_path "$FILE" && return 0

  # File type checks
  case "$BASENAME" in
    SKILL.md)
      echo "$FILE" | grep -qE '(^skills/|^\.claude/skills/)' || { echo "❌ $FILE: SKILL.md must be in skills/ or .claude/skills/"; VIOLATED=1; }
      ;;
    AGENT.md)
      echo "$FILE" | grep -qE '^\.claude/agents/' || { echo "❌ $FILE: AGENT.md must be in .claude/agents/"; VIOLATED=1; }
      ;;
    .mcp.json|mcp.json)
      [ "$(dirname "$FILE")" = "." ] || { echo "❌ $FILE: MCP config must be in project root"; VIOLATED=1; }
      ;;
    plugin.json)
      echo "$FILE" | grep -qE '^\.claude-plugin/' || { echo "❌ $FILE: plugin.json must be in .claude-plugin/"; VIOLATED=1; }
      ;;
  esac

  # .claude/ context checks
  if echo "$FILE" | grep -qE '^\.claude/'; then
    case "$BASENAME" in
      *.md)
        echo "$FILE" | grep -qE '^\.claude/(agents/|commands/|rules/|output-styles/|skills/)' || { echo "❌ $FILE: .md must be in agents/, commands/, rules/, output-styles/, or skills/"; VIOLATED=1; }
        ;;
      *.js)
        echo "$FILE" | grep -qE '^\.claude/(workflows/|skills/[^/]+/scripts/)' || { echo "❌ $FILE: .js must be in .claude/workflows/ or .claude/skills/<name>/scripts/"; VIOLATED=1; }
        ;;
      *.sh)
        echo "$FILE" | grep -qE '^\.claude/(hooks/|skills/[^/]+/scripts/)' || { echo "❌ $FILE: .sh must be in .claude/hooks/ or .claude/skills/<name>/scripts/"; VIOLATED=1; }
        ;;
    esac
  fi

  # Skill subdirectory constraints
  if echo "$FILE" | grep -qE "^\.claude/skills/[^/]+/"; then
    local REL=$(echo "$FILE" | sed -E "s|^\.claude/skills/[^/]+/||")
    if ! echo "$REL" | grep -qE '/'; then
      [ "$REL" = "SKILL.md" ] || { echo "❌ $FILE: only SKILL.md allowed at skill root"; VIOLATED=1; }
    else
      local SUBDIR=$(echo "$REL" | cut -d'/' -f1)
      case "$SUBDIR" in
        scripts)
          echo "$BASENAME" | grep -qE '\.(sh|py|js)$' || { echo "❌ $FILE: scripts/ only allows .sh/.py/.js"; VIOLATED=1; }
          ;;
        references)
          echo "$BASENAME" | grep -qE '\.(md|txt)$' || { echo "❌ $FILE: references/ only allows .md/.txt"; VIOLATED=1; }
          ;;
        data)
          echo "$BASENAME" | grep -qE '\.(txt|json|yaml|yml|csv|xml|dat)$' || { echo "❌ $FILE: data/ only allows .txt/.json/.yaml/.yml/.csv/.xml/.dat"; VIOLATED=1; }
          ;;
        templates) ;;
        *)
          echo "❌ $FILE: unknown subdirectory '$SUBDIR'"; VIOLATED=1
          ;;
      esac
    fi
  fi

  return $VIOLATED
}

# ── 主流程 ──

if [ -n "${1:-}" ]; then
  check_file "$1"
  exit $?
else
  echo "=== Directory Structure Check ==="
  echo ""

  for f in $(find . -type f \( -name '*.md' -o -name '*.js' -o -name '*.sh' -o -name '*.json' \) \
    -not -path './.claude/devkit/*' -not -path './node_modules/*' -not -path './.git/*' \
    -not -path './evidence/*' -not -path './data/*' 2>/dev/null); do
    NORM=$(echo "$f" | sed 's|^\./||')
    check_file "$NORM" || VIOLATIONS=$((VIOLATIONS + 1))
  done

  echo ""
  if [ "$VIOLATIONS" -gt 0 ]; then
    echo "❌ $VIOLATIONS placement violation(s) found."
    exit 1
  else
    echo "✅ All files in correct locations"
    exit 0
  fi
fi
