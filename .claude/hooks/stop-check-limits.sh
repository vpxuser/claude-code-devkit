#!/bin/bash
# Claude Code Stop hook — check file line limits before turn ends
# Runs global scan of all artifacts. Blocks turn if violations found.
set -euo pipefail

log() { echo "[limits-hook] $1" >&2; }

VIOLATIONS=0
DETAILS=""

check_limit() {
  local FILE="$1" LIMIT="$2"
  [ -f "$FILE" ] || return 0
  local LINES
  LINES=$(wc -l < "$FILE")
  if [ "$LINES" -gt "$LIMIT" ]; then
    DETAILS="${DETAILS}- $FILE: $LINES lines (limit: $LIMIT)\n"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
}

# Skills
for f in $(find .claude/skills skills -name 'SKILL.md' 2>/dev/null); do
  check_limit "$f" 500
done

# CLAUDE.md
for f in CLAUDE.md CLAUDE.local.md; do
  check_limit "$f" 150
done

# Agents
for f in $(find .claude/agents -name '*.md' 2>/dev/null); do
  check_limit "$f" 500
done

# Commands
for f in $(find .claude/commands -name '*.md' 2>/dev/null); do
  check_limit "$f" 200
done

# Output styles
for f in $(find .claude/output-styles -name '*.md' 2>/dev/null); do
  check_limit "$f" 200
done

# Rules
for f in $(find .claude/rules -name '*.md' 2>/dev/null); do
  check_limit "$f" 150
done

# Workflows
for f in $(find .claude/workflows -name '*.js' 2>/dev/null); do
  check_limit "$f" 300
done

# Scripts
for f in $(find scripts .claude/hooks -name '*.sh' 2>/dev/null); do
  check_limit "$f" 150
done

if [ "$VIOLATIONS" -gt 0 ]; then
  log "LINE LIMIT VIOLATIONS: $VIOLATIONS file(s) over limit"
  echo -e "$DETAILS" >&2
  jq -n --arg details "$(echo -e "$DETAILS")" --arg count "$VIOLATIONS" '{
    hookSpecificOutput: {
      hookEventName: "Stop",
      permissionDecision: "deny",
      permissionDecisionReason: ($count + " file(s) exceed line limits:\n" + $details + "Split oversized files before continuing.")
    }
  }'
  exit 2
fi

exit 0
