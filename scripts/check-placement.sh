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

  # Check .js files in .claude/ context — allowed in workflows/ and skills/<name>/scripts/
  if echo "$BASENAME" | grep -qE '\.js$' && echo "$FILE" | grep -qE '^\.claude/'; then
    if ! echo "$FILE" | grep -qE '^\.claude/(workflows/|skills/[^/]+/scripts/)'; then
      echo "❌ $FILE: .js in .claude/ must be in .claude/workflows/ or .claude/skills/<name>/scripts/"
      VIOLATED=1
    fi
  fi

  # Check .sh files in .claude/ context — allowed in hooks/ and skills/<name>/scripts/
  if echo "$BASENAME" | grep -qE '\.sh$' && echo "$FILE" | grep -qE '^\.claude/'; then
    if ! echo "$FILE" | grep -qE '^\.claude/(hooks/|skills/[^/]+/scripts/)'; then
      echo "❌ $FILE: .sh in .claude/ must be in .claude/hooks/ or .claude/skills/<name>/scripts/"
      VIOLATED=1
    fi
  fi

  # ── Skill subdirectory constraints ──
  # Files inside .claude/skills/<name>/ must be in the correct subdirectory.
  #
  # Allowed structure:
  #   .claude/skills/<name>/SKILL.md        (root — only SKILL.md)
  #   .claude/skills/<name>/scripts/*.sh    (scripts — .sh/.py/.js only)
  #   .claude/skills/<name>/references/*.md (references — .md only)
  #   .claude/skills/<name>/templates/*     (templates — any file)
  local SKILL_ROOT="\.claude/skills/[^/]+"
  if echo "$FILE" | grep -qE "^$SKILL_ROOT/"; then
    local REL_IN_SKILL
    REL_IN_SKILL=$(echo "$FILE" | sed -E "s|^\.claude/skills/[^/]+/||")

    # Root level: only SKILL.md allowed
    if ! echo "$REL_IN_SKILL" | grep -qE '/'; then
      if [ "$REL_IN_SKILL" != "SKILL.md" ]; then
        echo "❌ $FILE: only SKILL.md allowed at skill root (use scripts/, references/, or templates/)"
        VIOLATED=1
      fi
    else
      # Subdirectory: enforce file types
      local SUBDIR
      SUBDIR=$(echo "$REL_IN_SKILL" | cut -d'/' -f1)
      case "$SUBDIR" in
        scripts)
          if ! echo "$BASENAME" | grep -qE '\.(sh|py|js)$'; then
            echo "❌ $FILE: scripts/ only allows .sh/.py/.js files"
            VIOLATED=1
          fi
          ;;
        references)
          if ! echo "$BASENAME" | grep -qE '\.md$'; then
            echo "❌ $FILE: references/ only allows .md files"
            VIOLATED=1
          fi
          ;;
        templates)
          # templates/ allows any file type
          ;;
        *)
          echo "❌ $FILE: unknown skill subdirectory '$SUBDIR' (allowed: scripts/, references/, templates/)"
          VIOLATED=1
          ;;
      esac
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
