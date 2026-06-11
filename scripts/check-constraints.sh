#!/bin/bash
# Check deterministic constraints from L1-L4 rules
# Usage: bash scripts/check-constraints.sh [file_path]
# Exit: 0 = all pass, 1 = violations found
set -euo pipefail

VIOLATIONS=0
PASS_SYM="[PASS]"
FAIL_SYM="[FAIL]"

fail() { echo "$FAIL_SYM $1"; VIOLATIONS=$((VIOLATIONS + 1)); }
pass() { echo "$PASS_SYM $1"; }

fm_field() {
  local FILE="$1" FIELD="$2"
  sed -n '/^---$/,/^---$/p' "$FILE" | grep "^${FIELD}:" | sed "s/^${FIELD}:[[:space:]]*//"
}

check_fm_field() {
  local FILE="$1" FIELD="$2"
  if sed -n '/^---$/,/^---$/p' "$FILE" | grep -q "^${FIELD}:"; then
    pass "$FILE: frontmatter has '$FIELD'"
  else
    fail "$FILE: frontmatter missing '$FIELD'"
  fi
}

check_section() {
  local FILE="$1" SECTION="$2"
  if grep -q "^## ${SECTION}" "$FILE"; then
    pass "$FILE: has section '## ${SECTION}'"
  else
    fail "$FILE: missing section '## ${SECTION}'"
  fi
}

check_frontmatter() {
  local FILE="$1"
  local FIRST
  FIRST=$(head -1 "$FILE")
  if [ "$FIRST" != "---" ]; then
    fail "$FILE: must start with '---'"
    return
  fi
  local COUNT
  COUNT=$(grep -c "^---$" "$FILE" || true)
  if [ "$COUNT" -lt 2 ]; then
    fail "$FILE: frontmatter not closed"
  else
    pass "$FILE: frontmatter properly delimited"
  fi
}

check_single_h1() {
  local FILE="$1"
  local COUNT
  COUNT=$(grep -c "^# [^#]" "$FILE" || true)
  if [ "$COUNT" -ne 1 ]; then
    fail "$FILE: must have exactly 1 H1, found $COUNT"
  else
    pass "$FILE: has single H1"
  fi
}

check_no_bare_codeblocks() {
  local FILE="$1"
  local BARE
  BARE=$(awk '
    /^```/ {
      n++
      if (n % 2 == 1 && $0 ~ /^```[[:space:]]*$/) bare++
    }
    END { print bare+0 }
  ' "$FILE")
  if [ "$BARE" -gt 0 ]; then
    fail "$FILE: $BARE code blocks missing language tag"
  else
    pass "$FILE: all code blocks have language tags"
  fi
}

check_no_vague_words() {
  local FILE="$1"
  local FOUND
  FOUND=$(grep -n '应该\|建议\|考虑\|可以' "$FILE" 2>/dev/null | head -3 || true)
  if [ -n "$FOUND" ]; then
    fail "$FILE: contains vague words"
  else
    pass "$FILE: no vague words"
  fi
}

check_never_alternative() {
  local FILE="$1"
  local N_COUNT A_COUNT
  N_COUNT=$(grep -c "^- NEVER" "$FILE" 2>/dev/null || true)
  N_COUNT=${N_COUNT:-0}
  # Match both "-- " (double dash) and "—" (em dash) as alternative markers
  A_COUNT=$(grep -cE "(- |—)" "$FILE" 2>/dev/null || true)
  A_COUNT=${A_COUNT:-0}
  if [ "$N_COUNT" -gt 0 ] && [ "$A_COUNT" -lt "$N_COUNT" ]; then
    fail "$FILE: $N_COUNT NEVER rules but only $A_COUNT alternatives"
  elif [ "$N_COUNT" -gt 0 ]; then
    pass "$FILE: all NEVER rules have alternatives"
  fi
}

check_line_width() {
  local FILE="$1" LIMIT="${2:-120}"
  local WIDE
  WIDE=$(awk -v lim="$LIMIT" 'length > lim && !/^```/ && !/^    / && !/^\|/' "$FILE" | wc -l)
  if [ "$WIDE" -gt 0 ]; then
    fail "$FILE: $WIDE lines exceed $LIMIT chars"
  else
    pass "$FILE: line width OK"
  fi
}

# ── SKILL.md ──

check_skill() {
  local FILE="$1"
  echo ""; echo "=== SKILL.md: $FILE ==="
  check_frontmatter "$FILE"
  check_fm_field "$FILE" "description"
  check_single_h1 "$FILE"
  check_no_bare_codeblocks "$FILE"
  check_never_alternative "$FILE"
  check_line_width "$FILE"
  check_section "$FILE" "Purpose"
  check_section "$FILE" "Workflow"
  check_section "$FILE" "Constraints"
  check_section "$FILE" "Output Format"
  check_section "$FILE" "Examples"
  grep -q "OK_EMOJI" "$FILE" 2>/dev/null || true
  if ! grep -q "\xe2\x9c\x85" "$FILE" 2>/dev/null; then
    fail "$FILE: missing OK example"
  else
    pass "$FILE: has OK example"
  fi
  if ! grep -q "\xe2\x9d\x8c" "$FILE" 2>/dev/null; then
    fail "$FILE: missing FAIL example"
  else
    pass "$FILE: has FAIL example"
  fi
}

# ── AGENT.md ──

check_agent() {
  local FILE="$1"
  echo ""; echo "=== AGENT.md: $FILE ==="
  check_frontmatter "$FILE"
  check_fm_field "$FILE" "name"
  check_fm_field "$FILE" "description"
  check_fm_field "$FILE" "tools"
  check_fm_field "$FILE" "model"
  check_single_h1 "$FILE"
  check_no_bare_codeblocks "$FILE"
  check_never_alternative "$FILE"
  check_line_width "$FILE"
  check_section "$FILE" "Output Format"
  check_section "$FILE" "Constraints"
  check_section "$FILE" "Edge Cases"
  local CC
  CC=$(grep -c "^- ALWAYS\|^- NEVER" "$FILE" 2>/dev/null || echo 0)
  if [ "$CC" -lt 3 ]; then
    fail "$FILE: only $CC constraints, need 3+"
  else
    pass "$FILE: has $CC constraints"
  fi
}

# ── CLAUDE.md ──

check_claude_md() {
  local FILE="$1"
  echo ""; echo "=== CLAUDE.md: $FILE ==="
  check_single_h1 "$FILE"
  check_no_bare_codeblocks "$FILE"
  check_line_width "$FILE"
  check_never_alternative "$FILE"
  if grep -q "^# PROJECT:" "$FILE"; then
    pass "$FILE: starts with '# PROJECT:'"
  else
    fail "$FILE: must start with '# PROJECT:'"
  fi
  check_section "$FILE" "ALWAYS"
  check_section "$FILE" "NEVER"
}

# ── COMMAND.md ──

check_command() {
  local FILE="$1"
  echo ""; echo "=== COMMAND.md: $FILE ==="
  check_frontmatter "$FILE"
  check_fm_field "$FILE" "description"
  check_single_h1 "$FILE"
  check_no_bare_codeblocks "$FILE"
  check_line_width "$FILE"
  check_section "$FILE" "Purpose"
  check_section "$FILE" "Workflow"
}

# ── OUTPUT-STYLE.md ──

check_output_style() {
  local FILE="$1"
  echo ""; echo "=== OUTPUT-STYLE.md: $FILE ==="
  check_frontmatter "$FILE"
  check_fm_field "$FILE" "name"
  check_fm_field "$FILE" "description"
  check_fm_field "$FILE" "keep-coding-instructions"
  check_single_h1 "$FILE"
  check_section "$FILE" "Tone"
  check_section "$FILE" "Format"
  check_section "$FILE" "Content Rules"
}

# ── RULE.md ──

check_rule() {
  local FILE="$1"
  echo ""; echo "=== RULE.md: $FILE ==="
  check_frontmatter "$FILE"
  check_fm_field "$FILE" "description"
  check_single_h1 "$FILE"
  check_no_bare_codeblocks "$FILE"
  check_no_vague_words "$FILE"
  check_never_alternative "$FILE"
  check_line_width "$FILE"
  local H1_LINE
  H1_LINE=$(grep -n "^# [^#]" "$FILE" | head -1 | cut -d: -f1)
  if [ -n "$H1_LINE" ]; then
    # Check next non-blank line after H1 is a blockquote
    local NEXT_LINE
    NEXT_LINE=$(awk -v start="$H1_LINE" 'NR > start && NF > 0 {print; exit}' "$FILE")
    if echo "$NEXT_LINE" | grep -q "^>"; then
      pass "$FILE: H1 followed by blockquote"
    else
      fail "$FILE: H1 not followed by blockquote"
    fi
  fi
}

# ── JSON ──

check_json() {
  local FILE="$1"
  echo ""; echo "=== JSON: $FILE ==="
  if command -v python >/dev/null 2>&1; then
    if python -m json.tool "$FILE" > /dev/null 2>&1; then
      pass "$FILE: valid JSON"
    else
      fail "$FILE: invalid JSON"
    fi
  fi
  if echo "$FILE" | grep -q "plugin.json"; then
    grep -q '"name"' "$FILE" && pass "$FILE: has name" || fail "$FILE: missing name"
    grep -q '"description"' "$FILE" && pass "$FILE: has description" || fail "$FILE: missing description"
  fi
  if echo "$FILE" | grep -q "settings"; then
    grep -q '"\$schema"' "$FILE" && pass "$FILE: has schema" || fail "$FILE: missing schema"
    # Check hook paths use ${CLAUDE_PROJECT_DIR}
    if grep -q '"command"' "$FILE"; then
      if grep -q 'CLAUDE_PROJECT_DIR' "$FILE"; then
        pass "$FILE: hooks use \${CLAUDE_PROJECT_DIR} paths"
      else
        fail "$FILE: hooks missing \${CLAUDE_PROJECT_DIR} path variable"
      fi
      # Check no $CLAUDE_FILE_PATH in hook commands
      if grep -q 'CLAUDE_FILE_PATH' "$FILE"; then
        fail "$FILE: uses \$CLAUDE_FILE_PATH in hook — use \${CLAUDE_PROJECT_DIR} instead"
      fi
    fi
    # Check timeout fields
    if grep -q '"hooks"' "$FILE"; then
      if grep -q '"timeout"' "$FILE"; then
        pass "$FILE: hooks have timeout field"
      else
        fail "$FILE: hooks missing timeout field"
      fi
    fi
  fi
}

# ── WORKFLOW.js ──

check_workflow() {
  local FILE="$1"
  echo ""; echo "=== WORKFLOW.js: $FILE ==="

  # Must have export const meta
  if grep -q "export const meta" "$FILE"; then
    pass "$FILE: has export const meta"
  else
    fail "$FILE: missing export const meta"
  fi

  # meta must have name, description, phases
  if grep -q '"name"' "$FILE" || grep -q "name:" "$FILE"; then
    pass "$FILE: meta has name"
  else
    fail "$FILE: meta missing name"
  fi
  if grep -q '"description"' "$FILE" || grep -q "description:" "$FILE"; then
    pass "$FILE: meta has description"
  else
    fail "$FILE: meta missing description"
  fi
  if grep -q '"phases"' "$FILE" || grep -q "phases:" "$FILE"; then
    pass "$FILE: meta has phases"
  else
    fail "$FILE: meta missing phases"
  fi

  # Must use phase() calls
  if grep -q "phase(" "$FILE"; then
    pass "$FILE: uses phase()"
  else
    fail "$FILE: missing phase() calls"
  fi

  # Must not use forbidden APIs
  if grep -q "Date.now()" "$FILE"; then
    fail "$FILE: uses forbidden Date.now()"
  fi
  if grep -q "Math.random()" "$FILE"; then
    fail "$FILE: uses forbidden Math.random()"
  fi
}

# ── HOOK.sh ──

check_hook() {
  local FILE="$1"
  echo ""; echo "=== HOOK.sh: $FILE ==="

  # Must be in .claude/hooks/ directory
  if echo "$FILE" | grep -qE '^\.claude/hooks/'; then
    pass "$FILE: in .claude/hooks/ directory"
  else
    fail "$FILE: not in .claude/hooks/ — move from scripts/ to .claude/hooks/"
  fi

  # Must have set -euo pipefail
  if grep -q "set -euo pipefail" "$FILE"; then
    pass "$FILE: has set -euo pipefail"
  else
    fail "$FILE: missing set -euo pipefail"
  fi

  # Must use jq for JSON
  if grep -q "jq" "$FILE"; then
    pass "$FILE: uses jq for JSON"
  else
    fail "$FILE: missing jq usage"
  fi

  # Must use stderr for logs
  if grep -q ">&2" "$FILE" || grep -q "console.error" "$FILE"; then
    pass "$FILE: uses stderr for logs"
  else
    fail "$FILE: missing stderr logging"
  fi

  # Must use hookSpecificOutput for decisions
  if grep -q "hookSpecificOutput" "$FILE"; then
    pass "$FILE: uses hookSpecificOutput format"
  else
    fail "$FILE: missing hookSpecificOutput format"
  fi
}

# ── Main ──

echo "=== L1-L4 Constraint Check ==="

if [ -n "${1:-}" ]; then
  case "$1" in
    */SKILL.md) check_skill "$1" ;;
    */AGENT.md) check_agent "$1" ;;
    */CLAUDE.md) check_claude_md "$1" ;;
    *commands/*.md) check_command "$1" ;;
    *output-styles/*.md) check_output_style "$1" ;;
    *rules/*.md) check_rule "$1" ;;
    *workflows/*.js) check_workflow "$1" ;;
    *hooks/*.sh) check_hook "$1" ;;
    *.json) check_json "$1" ;;
    *) echo "No specific checks for: $1" ;;
  esac
else
  for f in $(find .claude/skills skills -name 'SKILL.md' 2>/dev/null); do check_skill "$f"; done
  for f in $(find .claude/agents -name '*.md' 2>/dev/null); do check_agent "$f"; done
  for f in $(find . -maxdepth 1 -name 'CLAUDE.md' 2>/dev/null); do check_claude_md "$f"; done
  for f in $(find .claude/commands -name '*.md' 2>/dev/null); do check_command "$f"; done
  for f in $(find .claude/output-styles -name '*.md' 2>/dev/null); do check_output_style "$f"; done
  for f in $(find .claude/rules -name '*.md' 2>/dev/null); do check_rule "$f"; done
  for f in $(find .claude/workflows -name '*.js' 2>/dev/null); do check_workflow "$f"; done
  for f in $(find .claude/hooks -name '*.sh' 2>/dev/null); do check_hook "$f"; done
  for f in $(find . -maxdepth 2 -name '*.json' -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null); do check_json "$f"; done
fi

echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "$FAIL_SYM $VIOLATIONS constraint violations found."
  exit 1
else
  echo "$PASS_SYM All constraints satisfied."
  exit 0
fi
