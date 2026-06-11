#!/bin/bash
# Claude Code PostToolUse hook — check L1-L4 constraints after Edit/Write
# Reads JSON from stdin, extracts file_path, runs constraint checks.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

log() { echo "[constraints-hook] $1" >&2; }

if [ -z "$FILE_PATH" ]; then
  log "No file_path in tool_input, skipping"
  exit 0
fi

# Normalize path
NORM=$(echo "$FILE_PATH" | sed 's|^\./||' | tr '\\' '/')

# Only check .claude/ artifacts
case "$NORM" in
  .claude/skills/*/SKILL.md) ;;
  .claude/agents/*.md) ;;
  .claude/commands/*.md) ;;
  .claude/output-styles/*.md) ;;
  .claude/rules/*.md) ;;
  .claude/workflows/*.js) ;;
  .claude/hooks/*.sh) ;;
  *.json)
    case "$NORM" in
      .mcp.json|package.json|.claude/settings.json|.claude/settings.local.json) ;;
      *) exit 0 ;;
    esac
    ;;
  CLAUDE.md) ;;
  *) exit 0 ;;
esac

# Skip if file doesn't exist (e.g., delete operations)
[ -f "$NORM" ] || exit 0

VIOLATIONS=0
REASONS=""

fail() { REASONS="${REASONS}- $1\n"; VIOLATIONS=$((VIOLATIONS + 1)); }

# Frontmatter checks (for .md files)
if [[ "$NORM" == *.md ]]; then
  FIRST=$(head -1 "$NORM" 2>/dev/null || echo "")
  if [ "$FIRST" != "---" ]; then
    fail "must start with '---'"
  fi

  H1_COUNT=$(grep -c "^# [^#]" "$NORM" 2>/dev/null || echo 0)
  if [ "$H1_COUNT" -ne 1 ]; then
    fail "must have exactly 1 H1, found $H1_COUNT"
  fi

  # Check for bare code blocks
  BARE=$(awk '/^```/ { n++; if (n % 2 == 1 && $0 ~ /^```[[:space:]]*$/) bare++ } END { print bare+0 }' "$NORM")
  if [ "$BARE" -gt 0 ]; then
    fail "$BARE code blocks missing language tag"
  fi

  # Check for vague words
  FOUND=$(grep -n '应该\|建议\|考虑\|可以' "$NORM" 2>/dev/null | head -1 || true)
  if [ -n "$FOUND" ]; then
    fail "contains vague words (应该/建议/考虑/可以)"
  fi

  # Check NEVER has alternatives
  N_COUNT=$(grep -c "^- NEVER" "$NORM" 2>/dev/null || echo 0)
  N_COUNT=${N_COUNT:-0}
  A_COUNT=$(grep -c "\-\- " "$NORM" 2>/dev/null || echo 0)
  A_COUNT=${A_COUNT:-0}
  if [ "$N_COUNT" -gt 0 ] && [ "$A_COUNT" -lt "$N_COUNT" ]; then
    fail "$N_COUNT NEVER rules but only $A_COUNT alternatives"
  fi

  # Type-specific checks
  case "$NORM" in
    */SKILL.md)
      grep -q "description" "$NORM" 2>/dev/null || fail "SKILL.md missing description in frontmatter"
      grep -q "\xe2\x9c\x85" "$NORM" 2>/dev/null || fail "SKILL.md missing ✅ example"
      grep -q "\xe2\x9d\x8c" "$NORM" 2>/dev/null || fail "SKILL.md missing ❌ example"
      ;;
    */AGENT.md)
      for field in name description tools model; do
        grep -q "$field" "$NORM" 2>/dev/null || fail "AGENT.md missing '$field' in frontmatter"
      done
      ;;
    *rules/*.md)
      H1_LINE=$(grep -n "^# [^#]" "$NORM" | head -1 | cut -d: -f1)
      if [ -n "$H1_LINE" ]; then
        NEXT=$((H1_LINE + 1))
        sed -n "${NEXT}p" "$NORM" | grep -q "^>" || fail "Rule H1 not followed by blockquote"
      fi
      ;;
  esac
fi

# JSON checks
if [[ "$NORM" == *.json ]]; then
  if command -v python >/dev/null 2>&1; then
    python -m json.tool "$NORM" > /dev/null 2>&1 || fail "invalid JSON syntax"
  fi
fi

# Workflow checks
if [[ "$NORM" == *.js ]]; then
  grep -q "export const meta" "$NORM" 2>/dev/null || fail "WORKFLOW.js missing 'export const meta'"
  grep -q "phase(" "$NORM" 2>/dev/null || fail "WORKFLOW.js missing phase() calls"
  grep -q "Date.now()" "$NORM" 2>/dev/null && fail "WORKFLOW.js uses forbidden Date.now()"
  grep -q "Math.random()" "$NORM" 2>/dev/null && fail "WORKFLOW.js uses forbidden Math.random()"
fi

# Hook checks
if [[ "$NORM" == .claude/hooks/*.sh ]]; then
  grep -q "set -euo pipefail" "$NORM" 2>/dev/null || fail "Hook missing 'set -euo pipefail'"
  grep -q "jq" "$NORM" 2>/dev/null || fail "Hook missing jq usage"
  grep -q ">&2" "$NORM" 2>/dev/null || fail "Hook missing stderr logging"
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  log "CONSTRAINT VIOLATIONS in $NORM: $VIOLATIONS"
  echo -e "$REASONS" >&2
  jq -n --arg reasons "$(echo -e "$REASONS")" --arg file "$NORM" --arg count "$VIOLATIONS" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ($count + " constraint violation(s) in " + $file + ":\n" + $reasons)
    }
  }'
  exit 2
fi

exit 0
