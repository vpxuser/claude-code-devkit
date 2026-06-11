#!/bin/bash
# Claude Code PostToolUse hook — check file placement after Edit/Write
# Reads JSON from stdin, extracts file_path, runs placement check.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

log() { echo "[placement-hook] $1" >&2; }

if [ -z "$FILE_PATH" ]; then
  log "No file_path in tool_input, skipping"
  exit 0
fi

# Normalize path: strip leading ./ and convert to forward slashes
NORM=$(echo "$FILE_PATH" | sed 's|^\./||' | tr '\\' '/')

# Skip non-project files
case "$NORM" in
  .claude/devkit/*|node_modules/*|.git/*|evidence/*|data/*) exit 0 ;;
esac

BASENAME="$(basename "$NORM")"
VIOLATED=0
REASON=""

# File type checks
case "$BASENAME" in
  SKILL.md)
    echo "$NORM" | grep -qE '(^skills/|^\.claude/skills/)' || { VIOLATED=1; REASON="SKILL.md must be in skills/ or .claude/skills/"; }
    ;;
  AGENT.md)
    echo "$NORM" | grep -qE '^\.claude/agents/' || { VIOLATED=1; REASON="AGENT.md must be in .claude/agents/"; }
    ;;
  .mcp.json|mcp.json)
    [ "$(dirname "$NORM")" = "." ] || { VIOLATED=1; REASON="MCP config must be in project root"; }
    ;;
  plugin.json)
    echo "$NORM" | grep -qE '^\.claude-plugin/' || { VIOLATED=1; REASON="plugin.json must be in .claude-plugin/"; }
    ;;
esac

# .claude/ context checks
if [ "$VIOLATED" -eq 0 ] && echo "$NORM" | grep -qE '^\.claude/'; then
  case "$BASENAME" in
    *.md)
      echo "$NORM" | grep -qE '^\.claude/(agents/|commands/|rules/|output-styles/|skills/)' || { VIOLATED=1; REASON=".md must be in agents/, commands/, rules/, output-styles/, or skills/"; }
      ;;
    *.js)
      echo "$NORM" | grep -qE '^\.claude/(workflows/|skills/[^/]+/scripts/)' || { VIOLATED=1; REASON=".js must be in .claude/workflows/ or .claude/skills/<name>/scripts/"; }
      ;;
    *.sh)
      echo "$NORM" | grep -qE '^\.claude/(hooks/|skills/[^/]+/scripts/)' || { VIOLATED=1; REASON=".sh must be in .claude/hooks/ or .claude/skills/<name>/scripts/"; }
      ;;
  esac
fi

# Skill subdirectory constraints
if [ "$VIOLATED" -eq 0 ] && echo "$NORM" | grep -qE "^\.claude/skills/[^/]+/"; then
  REL=$(echo "$NORM" | sed -E "s|^\.claude/skills/[^/]+/||")
  if ! echo "$REL" | grep -qE '/'; then
    [ "$REL" = "SKILL.md" ] || { VIOLATED=1; REASON="only SKILL.md allowed at skill root"; }
  else
    SUBDIR=$(echo "$REL" | cut -d'/' -f1)
    case "$SUBDIR" in
      scripts)
        echo "$BASENAME" | grep -qE '\.(sh|py|js)$' || { VIOLATED=1; REASON="scripts/ only allows .sh/.py/.js"; }
        ;;
      references)
        echo "$BASENAME" | grep -qE '\.(md|txt)$' || { VIOLATED=1; REASON="references/ only allows .md/.txt"; }
        ;;
      data)
        echo "$BASENAME" | grep -qE '\.(txt|json|yaml|yml|csv|xml|dat)$' || { VIOLATED=1; REASON="data/ only allows .txt/.json/.yaml/.yml/.csv/.xml/.dat"; }
        ;;
      templates) ;;
      *)
        VIOLATED=1; REASON="unknown subdirectory '$SUBDIR'"
        ;;
    esac
  fi
fi

if [ "$VIOLATED" -gt 0 ]; then
  log "PLACEMENT VIOLATION: $NORM — $REASON"
  jq -n --arg reason "$REASON" --arg file "$NORM" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("Placement violation: " + $file + " — " + $reason)
    }
  }'
  exit 2
fi

exit 0
