#!/bin/bash
# Claude Code File Validator
# Called by PostToolUse hook after Write/Edit operations
# Parses $TOOL_INPUT to get file_path, detects type, runs validation
set -euo pipefail

# ---- Utility Functions ----

# Parse file path from tool input JSON
get_file_path() {
  local input="${1:-$TOOL_INPUT}"
  # Handle empty input
  if [ -z "$input" ]; then
    echo ""
    return
  fi
  # Extract file_path from JSON (handles both Write and Edit tool input)
  echo "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//'
}

# Detect file type from path
detect_type() {
  local path="$1"
  local filename
  filename=$(basename "$path")
  local dirname
  dirname=$(dirname "$path")

  case "$filename" in
    SKILL.md)
      echo "skill"
      ;;
    AGENT.md|agent.md)
      echo "agent"
      ;;
    .mcp.json|mcp.json)
      echo "mcp"
      ;;
    hooks.json)
      echo "hooks"
      ;;
    plugin.json)
      echo "plugin"
      ;;
    settings.json|settings.local.json)
      echo "settings"
      ;;
    CLAUDE.md|CLAUDE.md)
      echo "claude-md"
      ;;
    *.md)
      # Might be a command file
      case "$dirname" in
        *commands*|*/command*)
          echo "command"
          ;;
        *)
          echo "unknown"
          ;;
      esac
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Check if file is in a relevant path
is_relevant_path() {
  local path="$1"
  case "$path" in
    *.claude/*|*templates/*|*guides/*|*/skills/*/SKILL.md|*/agents/*.md|*/commands/*.md)
      return 0
      ;;
    SKILL.md|AGENT.md|agent.md|.mcp.json|hooks.json|plugin.json|settings.json|settings.local.json|CLAUDE.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# ---- Validators ----

# Validate YAML frontmatter exists and has required fields
validate_yaml_frontmatter() {
  local file="$1"
  local issues=0

  # Check --- delimiters
  if ! head -1 "$file" | grep -q '^---$'; then
    echo "  [ERROR] File must start with YAML frontmatter (---)"
    return 1
  fi

  # Extract frontmatter content (between first two ---)
  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null)

  if [ -z "$frontmatter" ]; then
    echo "  [ERROR] Empty YAML frontmatter"
    return 1
  fi

  # Check for name field
  if ! echo "$frontmatter" | grep -q '^name:'; then
    echo "  [ERROR] Missing required field: 'name'"
    issues=$((issues + 1))
  fi

  # Check for description field
  if ! echo "$frontmatter" | grep -q '^description:'; then
    echo "  [ERROR] Missing required field: 'description'"
    issues=$((issues + 1))
  fi

  return $issues
}

# Validate kebab-case name
validate_name_format() {
  local file="$1"
  local issues=0

  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null)

  local name
  name=$(echo "$frontmatter" | grep '^name:' | sed 's/^name:[[:space:]]*//' | sed 's/^"\(.*\)"$/\1/' | head -1)

  if [ -n "$name" ]; then
    # Check kebab-case: lowercase, numbers, hyphens only
    if ! echo "$name" | grep -qE '^[a-z0-9][a-z0-9-]*[a-z0-9]$' && ! echo "$name" | grep -qE '^[a-z0-9]$'; then
      echo "  [WARN] Name '$name' should be kebab-case (lowercase letters, numbers, hyphens only)"
      issues=$((issues + 1))
    fi

    # Check length <= 64
    if [ ${#name} -gt 64 ]; then
      echo "  [ERROR] Name exceeds 64 characters (${#name})"
      issues=$((issues + 1))
    fi

    # Check reserved words
    local lower_name
    lower_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    case "$lower_name" in
      *anthropic*|*claude*)
        echo "  [ERROR] Name contains reserved word 'anthropic' or 'claude'"
        issues=$((issues + 1))
        ;;
    esac
  fi

  return $issues
}

# Validate description field
validate_description() {
  local file="$1"
  local check_xml="$2"  # "true" to check for XML tags

  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null)

  local desc_line
  desc_line=$(echo "$frontmatter" | grep '^description:' | head -1)

  # Check description is not empty
  local desc_value
  desc_value=$(echo "$desc_line" | sed 's/^description:[[:space:]]*//' | sed 's/^"\(.*\)"$/\1/')
  if [ -z "$desc_value" ]; then
    echo "  [ERROR] 'description' field is empty"
    return 1
  fi

  # Check length <= 1024
  if [ ${#desc_value} -gt 1024 ]; then
    echo "  [WARN] 'description' exceeds 1024 characters (${#desc_value})"
  fi

  # Check for XML tags if needed
  if [ "$check_xml" = "true" ] && echo "$desc_value" | grep -qE '<[a-zA-Z/][^>]*>'; then
    echo "  [ERROR] 'description' contains XML tags (not allowed)"
    return 1
  fi

  return 0
}

# Validate JSON file
validate_json() {
  local file="$1"
  if ! jq . "$file" > /dev/null 2>&1; then
    echo "  [ERROR] Invalid JSON syntax"
    return 1
  fi
  return 0
}

# ---- Type-Specific Validators ----

validate_skill() {
  local file="$1"
  local issues=0

  echo "  [SKILL.md] Validating skill definition..."

  validate_yaml_frontmatter "$file" || issues=$((issues + $?))
  validate_name_format "$file" || true
  validate_description "$file" "true" || true

  # Check body is not empty
  local body
  body=$(sed -n '/^---$/,/^---$/!p' "$file" 2>/dev/null)
  local body_lines
  body_lines=$(echo "$body" | sed '/^$/d' | wc -l)
  if [ "$body_lines" -lt 2 ]; then
    echo "  [ERROR] SKILL.md body is empty or too short"
    issues=$((issues + 1))
  fi

  # Body length: keep under 500 lines per spec
  if [ "$body_lines" -gt 500 ]; then
    echo "  [WARN] Body is $body_lines lines (recommended: under 500). Split content into references/."
    issues=$((issues + 1))
  fi

  # Check for reserved words in name
  local name
  name=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null | grep '^name:' | sed 's/^name:[[:space:]]*//' | head -1)
  if echo "$name" | grep -qiE 'anthropic|claude'; then
    echo "  [ERROR] Name contains reserved word: 'anthropic' or 'claude'"
    issues=$((issues + 1))
  fi

  # Check name length
  if [ ${#name} -gt 64 ]; then
    echo "  [ERROR] Name exceeds 64 characters"
    issues=$((issues + 1))
  fi

  # ===== Body writing style checks =====

  # Anti-pattern 1: "You should" / "I recommend" (non-imperative)
  # Skip lines that are showing counterexamples (contain "not '" or are in tables)
  local imperatives
  imperatives=$(echo "$body" | grep -viE 'not ['\''"](you|i)' | grep -ciE '(you should|i recommend|you can|you need to|you will|you must)')
  if [ "$imperatives" -gt 0 ]; then
    echo "  [WARN] Body uses 'you should'/'I recommend' style. Use imperative: 'Extract text' not 'You should extract text'."
    issues=$((issues + 1))
  fi

  # Anti-pattern 2: Verbose explanation of basics
  local long_explanations
  long_explanations=$(echo "$body" | grep -cE '(is a (popular|common|powerful|widely-used)|is a (library|tool|framework|language|format) (that|which|used for))')
  if [ "$long_explanations" -gt 0 ]; then
    echo "  [WARN] Body explains concepts Claude already knows. Be concise."
    issues=$((issues + 1))
  fi

  # Anti-pattern 3: Multiple options without default
  if echo "$body" | grep -qiE '(you can use.*or|alternatives include|another option is|there are (many|several|multiple) (ways|options|libraries|tools))'; then
    echo "  [WARN] Body presents multiple options without a default. Pick one, mention alternatives after."
    issues=$((issues + 1))
  fi

  # Anti-pattern 4: Time-sensitive information
  if echo "$body" | grep -qiE '(before (january|february|march|april|may|june|july|august|september|october|november|december) [0-9]{4}|after [a-z]+ [0-9]{4})'; then
    echo "  [WARN] Body contains time-sensitive dates that may become outdated."
    issues=$((issues + 1))
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] SKILL.md validation passed"
  fi
  return $issues
}

validate_agent() {
  local file="$1"
  local issues=0

  echo "  [Agent.md] Validating agent definition..."

  validate_yaml_frontmatter "$file" || issues=$((issues + 1))

  # Check name: 3-50 chars
  local name
  name=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null | grep '^name:' | sed 's/^name:[[:space:]]*//' | head -1)
  if [ ${#name} -lt 3 ] || [ ${#name} -gt 50 ]; then
    echo "  [ERROR] Agent name must be 3-50 characters (current: ${#name})"
    issues=$((issues + 1))
  fi

  # Check description has <example> blocks
  local desc
  desc=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null)
  if ! echo "$desc" | grep -q '<example>'; then
    echo "  [ERROR] Agent description must include <example> blocks"
    issues=$((issues + 1))
  fi
  if ! echo "$desc" | grep -q '<commentary>'; then
    echo "  [WARN] Agent examples should include <commentary> sections"
  fi

  # Check model field
  if ! echo "$desc" | grep -qE '^model:[[:space:]]*(inherit|sonnet|opus|haiku)'; then
    echo "  [ERROR] Missing or invalid 'model' field (must be: inherit|sonnet|opus|haiku)"
    issues=$((issues + 1))
  fi

  # Check color field
  if ! echo "$desc" | grep -qE '^color:[[:space:]]*(blue|cyan|green|yellow|magenta|red)'; then
    echo "  [ERROR] Missing or invalid 'color' field"
    issues=$((issues + 1))
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] Agent.md validation passed"
  fi
  return $issues
}

validate_mcp() {
  local file="$1"
  local issues=0

  echo "  [.mcp.json] Validating MCP config..."

  validate_json "$file" || return 1

  local server_count
  server_count=$(jq 'keys | length' "$file")
  if [ "$server_count" -eq 0 ]; then
    echo "  [ERROR] .mcp.json must define at least one server"
    issues=$((issues + 1))
  fi

  # Check each server entry
  for server in $(jq -r 'keys[]' "$file" | tr -d '\r'); do
    local type
    type=$(jq -r ".[\"$server\"].type // \"stdio\"" "$file")
    case "$type" in
      stdio|"null")
        if ! jq -r ".[\"$server\"].command // \"\"" "$file" | grep -qE '.+'; then
          echo "  [ERROR] Server '$server': stdio type requires 'command' field"
          issues=$((issues + 1))
        fi
        ;;
      http|streamable-http|sse|ws)
        local url
        url=$(jq -r ".[\"$server\"].url // \"\"" "$file")
        if [ -z "$url" ]; then
          echo "  [ERROR] Server '$server': $type type requires 'url' field"
          issues=$((issues + 1))
        fi
        if echo "$url" | grep -qiE '^http://localhost' && [ "$type" = "http" ]; then
          echo "  [INFO] Server '$server': localhost URL detected"
        fi
        ;;
      *)
        echo "  [WARN] Server '$server': unknown type '$type'"
        ;;
    esac
  done

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] .mcp.json validation passed"
  fi
  return $issues
}

validate_hooks() {
  local file="$1"
  local issues=0

  echo "  [hooks.json] Validating hooks config..."

  validate_json "$file" || return 1

  local valid_events="PreToolUse PostToolUse Stop SubagentStop SessionStart SessionEnd UserPromptSubmit PreCompact"

  # Check if it's plugin format (has "hooks" wrapper) or settings format
  if jq -e '.hooks' "$file" > /dev/null 2>&1; then
    # Plugin format
    local events
    events=$(jq -r '.hooks | keys[]' "$file" | tr -d '\r')
    for event in $events; do
      if ! echo "$valid_events" | grep -qE "(^| )$event( |$)"; then
        echo "  [WARN] Unknown hook event: '$event'"
      fi
    done

    # Check for valid hook structures
    local hook_count
    hook_count=$(jq '[.hooks[] | length] | add // 0' "$file" 2>/dev/null || echo 0)
    if [ "$hook_count" -eq 0 ]; then
      echo "  [WARN] No hook configurations found"
    fi
  else
    # Settings format - events at top level
    local events
    events=$(jq -r 'keys[]' "$file" | tr -d '\r')
    for event in $events; do
      if echo "$valid_events" | grep -qE "(^| )$event( |$)"; then
        local hooks_in_event
        hooks_in_event=$(jq ".[\"$event\"] | length" "$file")
        if [ "$hooks_in_event" -eq 0 ]; then
          echo "  [WARN] Event '$event' has no hook configurations"
        fi
      else
        echo "  [INFO] Skipping non-event key: '$event'"
      fi
    done
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] hooks.json validation passed"
  fi
  return $issues
}

validate_plugin() {
  local file="$1"
  local issues=0

  echo "  [plugin.json] Validating plugin manifest..."

  validate_json "$file" || return 1

  # Check required name field
  if ! jq -e '.name' "$file" > /dev/null 2>&1; then
    echo "  [ERROR] 'name' field is required"
    issues=$((issues + 1))
  else
    local name
    name=$(jq -r '.name' "$file")
    if ! echo "$name" | grep -qE '^[a-z0-9][a-z0-9-]*[a-z0-9]$' && ! echo "$name" | grep -qE '^[a-z0-9]$'; then
      echo "  [WARN] Plugin name '$name' should be kebab-case"
    fi
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] plugin.json validation passed"
  fi
  return $issues
}

validate_settings() {
  local file="$1"
  local issues=0

  echo "  [settings.json] Validating settings..."

  validate_json "$file" || return 1

  # Check known top-level keys
  local keys
  keys=$(jq -r 'keys[]' "$file" 2>/dev/null | tr -d '\r' || echo "")
  for key in $keys; do
    case "$key" in
      permissions|hooks|mcpServers)
        # Valid keys
        ;;
      *)
        echo "  [INFO] Unknown top-level key: '$key'"
        ;;
    esac
  done

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] settings.json validation passed"
  fi
  return $issues
}

validate_command() {
  local file="$1"
  local issues=0

  echo "  [Command] Validating command file..."

  # Extract body
  local body
  body=$(sed -n '/^---$/,/^---$/!p' "$file" 2>/dev/null)

  # Check first non-frontmatter, non-empty line for writing style
  local first_line
  first_line=$(echo "$body" | grep -v '^[[:space:]]*$' | head -1)

  if echo "$first_line" | grep -qiE '^this command will|^this will|^this command is|this command helps'; then
    echo "  [WARN] Command appears to be written TO the user instead of instructions FOR Claude"
    echo "   -> Write commands as directives: 'Review...', 'Analyze...', 'Create...'"
  fi

  # Check for YAML frontmatter
  if head -1 "$file" | grep -q '^---$'; then
    local frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' 2>/dev/null)

    # Validate allowed-tools if present
    if echo "$frontmatter" | grep -q '^allowed-tools:'; then
      echo "  [INFO] Command has tool restrictions"
    fi
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] Command validation passed"
  fi
  return $issues
}

validate_claude_md() {
  local file="$1"
  local issues=0

  echo "  [CLAUDE.md] Validating project instructions..."

  local line_count
  line_count=$(wc -l < "$file")

  if [ "$line_count" -lt 3 ]; then
    echo "  [WARN] CLAUDE.md seems too short ($line_count lines)"
    issues=$((issues + 1))
  fi

  # Check for vague content
  if grep -qiE '^# Project$|^# My Project$|^# (A|An|The) ' "$file" | head -1 > /dev/null 2>&1; then
    echo "  [WARN] Title seems generic — consider a more specific project description"
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] CLAUDE.md validation passed"
  fi
  return $issues
}

# ---- Main ----

main() {
  local file_path="${1:-}"

  # If no argument, try to get from $TOOL_INPUT (PostToolUse hook)
  if [ -z "$file_path" ]; then
    file_path=$(get_file_path)
  fi

  # If still no path or not a relevant file, exit cleanly
  if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    exit 0
  fi

  # Normalize path separators (handle Windows paths in Git Bash)
  file_path=$(echo "$file_path" | sed 's|\\|/|g')

  # Only validate if it's a relevant file
  if ! is_relevant_path "$file_path"; then
    exit 0
  fi

  local file_type
  file_type=$(detect_type "$file_path")

  echo ""
  echo "=== Claude Code File Validator ==="
  echo "File: $file_path"
  echo "Type: $file_type"
  echo ""

  local exit_code=0

  case "$file_type" in
    skill)
      validate_skill "$file_path" || exit_code=$?
      ;;
    agent)
      validate_agent "$file_path" || exit_code=$?
      ;;
    mcp)
      validate_mcp "$file_path" || exit_code=$?
      ;;
    hooks)
      validate_hooks "$file_path" || exit_code=$?
      ;;
    plugin)
      validate_plugin "$file_path" || exit_code=$?
      ;;
    settings)
      validate_settings "$file_path" || exit_code=$?
      ;;
    command)
      validate_command "$file_path" || exit_code=$?
      ;;
    claude-md)
      validate_claude_md "$file_path" || exit_code=$?
      ;;
    *)
      exit 0
      ;;
  esac

  echo ""

  # Exit 2 means stderr is fed back to Claude (issues found)
  if [ "$exit_code" -gt 0 ]; then
    echo "[RESULT] $exit_code issue(s) found — review suggested fixes above."
    exit 2
  else
    echo "[RESULT] All checks passed."
    exit 0
  fi
}

main "$@"
