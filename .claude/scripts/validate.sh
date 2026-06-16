#!/bin/bash
# Claude Code File Validator
# Called by:
#   - PostToolUse hook (no argument): scans all .claude/ config files
#   - /validate command (file path): validates that specific file
set -euo pipefail

# Auto-detect project root: validate.sh lives at .claude/scripts/validate.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# ---- Utility Functions ----

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
      # Might be a command or agent file
      case "$dirname" in
        *commands*|*/command*)
          echo "command"
          ;;
        *agents*|*/agent*)
          echo "agent"
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
    *.claude/*|*.claude-plugin/*|*hooks/*|*templates/*|*guides/*|*/skills/*/SKILL.md|*/agents/*.md|*/commands/*.md)
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
      echo "  [ERROR] Name '$name' should be kebab-case (lowercase letters, numbers, hyphens only)"
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
    echo "  [ERROR] 'description' exceeds 1024 characters (${#desc_value})"
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
  validate_name_format "$file" || issues=$((issues + $?))
  validate_description "$file" "true" || issues=$((issues + $?))

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
    echo "  [ERROR] Body is $body_lines lines (recommended: under 500). Split content into references/."
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
    echo "  [ERROR] Body uses 'you should'/'I recommend' style. Use imperative: 'Extract text' not 'You should extract text'."
    issues=$((issues + 1))
  fi

  # Anti-pattern 2: Verbose explanation of basics
  local long_explanations
  long_explanations=$(echo "$body" | grep -cE '(is a (popular|common|powerful|widely-used)|is a (library|tool|framework|language|format) (that|which|used for))')
  if [ "$long_explanations" -gt 0 ]; then
    echo "  [ERROR] Body explains concepts Claude already knows. Be concise."
    issues=$((issues + 1))
  fi

  # Anti-pattern 3: Multiple options without default
  if echo "$body" | grep -qiE '(you can use.*or|alternatives include|another option is|there are (many|several|multiple) (ways|options|libraries|tools))'; then
    echo "  [ERROR] Body presents multiple options without a default. Pick one, mention alternatives after."
    issues=$((issues + 1))
  fi

  # Anti-pattern 4: Time-sensitive information
  if echo "$body" | grep -qiE '(before (january|february|march|april|may|june|july|august|september|october|november|december) [0-9]{4}|after [a-z]+ [0-9]{4})'; then
    echo "  [ERROR] Body contains time-sensitive dates that may become outdated."
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
    echo "  [ERROR] Agent examples should include <commentary> sections"
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
        echo "  [ERROR] Server '$server': unknown type '$type'"
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

  local events
  local prefix=""

  # Check if it's plugin format (has "hooks" wrapper) or settings format
  if jq -e '.hooks' "$file" > /dev/null 2>&1; then
    # Plugin format: events under .hooks
    events=$(jq -r '.hooks | keys[]' "$file" | tr -d '\r')
    prefix='.hooks'
  else
    # Settings format: events at top level
    events=$(jq -r 'keys[]' "$file" | tr -d '\r')
    prefix='.'
  fi

  for event in $events; do
    local event_path="${prefix}[\"$event\"]"

    # Skip non-event keys (settings format may have description, etc.)
    if ! echo "$valid_events" | grep -qE "(^| )$event( |$)"; then
      if [ "$prefix" = "." ]; then
        echo "  [INFO] Skipping non-event key: '$event'"
      else
        echo "  [ERROR] Unknown hook event: '$event'"
        issues=$((issues + 1))
      fi
      continue
    fi

    # Count matcher entries for this event
    local matcher_count
    matcher_count=$(jq "$event_path | length" "$file" 2>/dev/null || echo 0)
    if [ "$matcher_count" -eq 0 ]; then
      echo "  [ERROR] Event '$event' has no hook configurations"
      issues=$((issues + 1))
      continue
    fi

    # Validate each matcher entry and its nested hooks
    for i in $(seq 0 $((matcher_count - 1))); do
      local hooks_in_entry
      hooks_in_entry=$(jq -r "$event_path[$i].hooks | length" "$file" 2>/dev/null || echo 0)

      if [ "$hooks_in_entry" -eq 0 ] || [ "$hooks_in_entry" = "null" ]; then
        echo "  [ERROR] $event_path[$i]: missing 'hooks' array"
        issues=$((issues + 1))
        continue
      fi

      for j in $(seq 0 $((hooks_in_entry - 1))); do
        local hook_type
        hook_type=$(jq -r "$event_path[$i].hooks[$j].type // \"\"" "$file" 2>/dev/null || echo "")

        case "$hook_type" in
          command)
            local cmd
            cmd=$(jq -r "$event_path[$i].hooks[$j].command // \"\"" "$file")
            if [ -z "$cmd" ]; then
              echo "  [ERROR] $event_path[$i].hooks[$j]: command type requires 'command' field"
              issues=$((issues + 1))
            fi
            ;;
          prompt)
            if [ "$event" = "SessionStart" ] || [ "$event" = "Setup" ] || [ "$event" = "SubagentStart" ]; then
              echo "  [ERROR] $event_path[$i].hooks[$j]: prompt-type hooks are not supported for $event (no conversation context). Use command-type instead."
              issues=$((issues + 1))
            fi
            local prompt_text
            prompt_text=$(jq -r "$event_path[$i].hooks[$j].prompt // \"\"" "$file")
            if [ -z "$prompt_text" ]; then
              echo "  [ERROR] $event_path[$i].hooks[$j]: prompt type requires 'prompt' field"
              issues=$((issues + 1))
            fi
            ;;
          agent)
            if [ "$event" = "SessionStart" ] || [ "$event" = "Setup" ] || [ "$event" = "SubagentStart" ]; then
              echo "  [ERROR] $event_path[$i].hooks[$j]: agent-type hooks are not supported for $event. Use command-type instead."
              issues=$((issues + 1))
            fi
            ;;
          ""|null)
            echo "  [ERROR] $event_path[$i].hooks[$j]: missing 'type' field (must be command|prompt|agent)"
            issues=$((issues + 1))
            ;;
          *)
            echo "  [ERROR] $event_path[$i].hooks[$j]: unknown hook type '$hook_type'"
            issues=$((issues + 1))
            ;;
        esac
      done
    done
  done

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
      echo "  [ERROR] Plugin name '$name' should be kebab-case"
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

  local valid_top_keys="permissions hooks mcpServers model theme env includeCoAuthoredBy"
  local keys
  keys=$(jq -r 'keys[]' "$file" 2>/dev/null | tr -d '\r' || echo "")
  for key in $keys; do
    case " $valid_top_keys " in
      *" $key "*)
        ;;
      *)
        echo "  [INFO] Unknown top-level key: '$key'"
        ;;
    esac
  done

  # ---- permissions ----
  if jq -e '.permissions' "$file" > /dev/null 2>&1; then
    if jq -e '.permissions | has("allow")' "$file" > /dev/null 2>&1; then
      local allow_count
      allow_count=$(jq '.permissions.allow | length' "$file")
      echo "  [INFO] permissions.allow: $allow_count entries"
    fi
    if jq -e '.permissions | has("block")' "$file" > /dev/null 2>&1; then
      local block_count
      block_count=$(jq '.permissions.block | length' "$file")
      echo "  [INFO] permissions.block: $block_count entries"
    fi
  fi

  # ---- hooks ----
  if jq -e '.hooks' "$file" > /dev/null 2>&1; then
    local valid_events="PreToolUse PostToolUse Stop SubagentStop SessionStart SessionEnd UserPromptSubmit PreCompact"
    local hook_events
    hook_events=$(jq -r '.hooks | keys[]' "$file" | tr -d '\r')
    for event in $hook_events; do
      if ! echo "$valid_events" | grep -qE "(^| )$event( |$)"; then
        echo "  [ERROR] Unknown hook event: '$event'"
        issues=$((issues + 1))
        continue
      fi

      # For each event, check nested hook entries
      local entries
      entries=$(jq -r ".hooks[\"$event\"] | length" "$file")
      for i in $(seq 0 $((entries - 1))); do
        local matcher
        matcher=$(jq -r ".hooks[\"$event\"][$i].matcher // \"*\"" "$file")
        local hooks_in_entry
        hooks_in_entry=$(jq -r ".hooks[\"$event\"][$i].hooks | length" "$file")
        for j in $(seq 0 $((hooks_in_entry - 1))); do
          local hook_type
          hook_type=$(jq -r ".hooks[\"$event\"][$i].hooks[$j].type" "$file" 2>/dev/null || echo "null")

          case "$hook_type" in
            command)
              local cmd
              cmd=$(jq -r ".hooks[\"$event\"][$i].hooks[$j].command // \"\"" "$file")
              if [ -z "$cmd" ]; then
                echo "  [ERROR] hooks.$event[$i].hooks[$j]: command type requires 'command' field"
                issues=$((issues + 1))
              fi
              ;;
            prompt)
              if [ "$event" = "SessionStart" ] || [ "$event" = "Setup" ] || [ "$event" = "SubagentStart" ]; then
                echo "  [ERROR] hooks.$event[$i].hooks[$j]: prompt-type hooks are not supported for $event (no conversation context). Use command-type instead."
                issues=$((issues + 1))
              fi
              local prompt_text
              prompt_text=$(jq -r ".hooks[\"$event\"][$i].hooks[$j].prompt // \"\"" "$file")
              if [ -z "$prompt_text" ]; then
                echo "  [ERROR] hooks.$event[$i].hooks[$j]: prompt type requires 'prompt' field"
                issues=$((issues + 1))
              fi
              ;;
            agent)
              if [ "$event" = "SessionStart" ] || [ "$event" = "Setup" ] || [ "$event" = "SubagentStart" ]; then
                echo "  [ERROR] hooks.$event[$i].hooks[$j]: agent-type hooks are not supported for $event. Use command-type instead."
                issues=$((issues + 1))
              fi
              ;;
            null|"")
              echo "  [ERROR] hooks.$event[$i].hooks[$j]: missing 'type' field (must be command|prompt|agent)"
              issues=$((issues + 1))
              ;;
            *)
              echo "  [ERROR] hooks.$event[$i].hooks[$j]: unknown hook type '$hook_type'"
              ;;
          esac
        done
      done
    done
  fi

  # ---- mcpServers ----
  if jq -e '.mcpServers' "$file" > /dev/null 2>&1; then
    local server_count
    server_count=$(jq '.mcpServers | length' "$file")
    if [ "$server_count" -eq 0 ]; then
      echo "  [ERROR] mcpServers is empty"
      issues=$((issues + 1))
    else
      echo "  [INFO] mcpServers: $server_count server(s)"
      local servers
      servers=$(jq -r '.mcpServers | keys[]' "$file" | tr -d '\r')
      for server in $servers; do
        local srv_type
        srv_type=$(jq -r ".mcpServers[\"$server\"].type // \"stdio\"" "$file")
        case "$srv_type" in
          stdio)
            local cmd
            cmd=$(jq -r ".mcpServers[\"$server\"].command // \"\"" "$file")
            if [ -z "$cmd" ]; then
              echo "  [ERROR] mcpServers.$server: stdio type requires 'command'"
              issues=$((issues + 1))
            fi
            ;;
          http|streamable-http|sse)
            local url
            url=$(jq -r ".mcpServers[\"$server\"].url // \"\"" "$file")
            if [ -z "$url" ]; then
              echo "  [ERROR] mcpServers.$server: $srv_type requires 'url' field"
              issues=$((issues + 1))
            fi
            ;;
          *)
            echo "  [ERROR] mcpServers.$server: unknown type '$srv_type'"
            ;;
        esac
      done
    fi
  fi

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
    echo "  [ERROR] Command appears to be written TO the user instead of instructions FOR Claude"
    echo "   -> Write commands as directives: 'Review...', 'Analyze...', 'Create...'"
    issues=$((issues + 1))
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
    echo "  [ERROR] CLAUDE.md seems too short ($line_count lines)"
    issues=$((issues + 1))
  fi

  # Check for vague content
  if grep -qiE '^# Project$|^# My Project$|^# (A|An|The) ' "$file" | head -1 > /dev/null 2>&1; then
    echo "  [ERROR] Title seems generic — consider a more specific project description"
    issues=$((issues + 1))
  fi

  if [ "$issues" -eq 0 ]; then
    echo "  [PASS] CLAUDE.md validation passed"
  fi
  return $issues
}

# ---- Main ----

main() {
  local arg="${1:-}"

  # File path given (via /validate command) → validate that file
  if [ -n "$arg" ]; then
    arg=$(echo "$arg" | sed 's|\\|/|g')
    if [ -f "$arg" ] && is_relevant_path "$arg"; then
      validate_one "$arg"
      local rc=$?
      exit $rc
    fi
    exit 0
  fi

  # No argument → scan all known Claude Code config directories
  scan_all
  local rc=$?
  exit $rc
}

scan_all() {
  echo "=== Scanning all Claude Code config files ==="
  echo ""

  local found=0
  local issues=0

  # Skills: .claude/skills/*/SKILL.md
  while IFS= read -r -d '' f; do
    validate_one "$f" || issues=$((issues + $?))
    found=1
  done < <(find .claude/skills -name "SKILL.md" -type f 2>/dev/null -print0 || true)

  # Agents: .claude/agents/*.md
  while IFS= read -r -d '' f; do
    validate_one "$f" || issues=$((issues + $?))
    found=1
  done < <(find .claude/agents -maxdepth 1 -name "*.md" -type f 2>/dev/null -print0 || true)

  # Commands: .claude/commands/*.md
  while IFS= read -r -d '' f; do
    validate_one "$f" || issues=$((issues + $?))
    found=1
  done < <(find .claude/commands -maxdepth 1 -name "*.md" -type f 2>/dev/null -print0 || true)

  # Settings files
  for f in .claude/settings.json .claude/settings.local.json; do
    if [ -f "$f" ]; then
      validate_one "$f" || issues=$((issues + $?))
      found=1
    fi
  done

  # Project instructions
  if [ -f .claude/CLAUDE.md ]; then
    validate_one .claude/CLAUDE.md || issues=$((issues + $?))
    found=1
  fi

  # Plugin manifest
  if [ -f .claude-plugin/plugin.json ]; then
    validate_one .claude-plugin/plugin.json || issues=$((issues + $?))
    found=1
  fi

  # Hooks config
  if [ -f hooks/hooks.json ]; then
    validate_one hooks/hooks.json || issues=$((issues + $?))
    found=1
  fi

  # MCP config
  if [ -f .mcp.json ]; then
    validate_one .mcp.json || issues=$((issues + $?))
    found=1
  fi

  if [ "$found" -eq 0 ]; then
    echo "No Claude Code config files found."
    exit 0
  fi

  return $issues
}

validate_one() {
  local file_path="$1"
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
      return 0
      ;;
  esac

  echo ""

  # Guidance: when issues found, point Claude to specific sections
  if [ "$exit_code" -gt 0 ]; then
    local guide=""
    local section=""
    case "$file_type" in
      skill)
        guide="skill-guide.md"
        section="Body Writing Rules + Frontmatter"
        ;;
      agent)
        guide="agent-guide.md"
        section="Frontmatter Fields + Structure"
        ;;
      mcp)
        guide="mcp-guide.md"
        section="Server Type Selection + Configurations"
        ;;
      hooks)
        guide="hooks-guide.md"
        section="Configuration Formats + Hook Events"
        ;;
      plugin)
        guide="plugin-guide.md"
        section="Manifest (plugin.json) + Component Rules"
        ;;
      settings)
        guide="settings-guide.md"
        section="Structure + Permission Patterns"
        ;;
      command)
        guide="command-guide.md"
        section="Key Rule + Format + Writing Style"
        ;;
      claude-md)
        guide="claude-md-guide.md"
        section="Writing Style + What to Include"
        ;;
    esac
    echo "━━━ Guidance ━━━" >&2
    echo "Issues found. Review the errors above and fix each one." >&2
    echo "" >&2
    echo "  Reference specs:" >&2
    echo "    .claude/skills/design-philosophy/SKILL.md" >&2
    if [ -n "$guide" ]; then
      echo "    $guide" >&2
      echo "    → Key sections: $section" >&2
    fi
    echo "" >&2
    echo "  Quick fixes by type:" >&2
    case "$file_type" in
      skill)
        echo "    • Names: kebab-case only — 'my-skill' not 'My_Skill'" >&2
        echo "    • Description: third person, no XML, be specific" >&2
        echo "    • Body: imperative style — 'Extract text' not 'You should extract text'" >&2
        echo "    • Pick one default approach, mention alternatives after" >&2
        echo "    • No time-sensitive dates in body" >&2
        ;;
      agent)
        echo "    • Name: 3-50 chars, kebab-case" >&2
        echo "    • Description: must include <example> blocks with <commentary>" >&2
        echo "    • Model: inherit|sonnet|opus|haiku" >&2
        echo "    • Color: blue|cyan|green|yellow|magenta|red" >&2
        ;;
      settings)
        echo "    • Hooks need: type (command|prompt|agent) + matching field (command|prompt)" >&2
        echo "    • Hook events: PreToolUse, PostToolUse, Stop, etc." >&2
        echo "    • Empty command field is invalid" >&2
        ;;
      hooks)
        echo "    • Events: PreToolUse, PostToolUse, Stop, SubagentStop, SessionStart/End, etc." >&2
        echo "    • Each hook entry needs: type (command|prompt|agent) + matching field" >&2
        echo "    • SessionStart/Setup/SubagentStart: command-type only (no prompt)" >&2
        ;;
      mcp)
        echo "    • Must be valid JSON syntax" >&2
        echo "    • stdio server: needs 'command' field" >&2
        echo "    • http/sse server: needs 'url' field" >&2
        ;;
      command)
        echo "    • Write as instructions FOR Claude, not messages TO the user" >&2
        echo "    • Start with action verbs: 'Review...', 'Analyze...', 'Create...'" >&2
        ;;
      plugin)
        echo "    • Name must be kebab-case: 'my-plugin' not 'My_Plugin'" >&2
        ;;
      claude-md)
        echo "    • CLAUDE.md must be at least 3 lines with project info" >&2
        echo "    • Include: project purpose, conventions, key rules" >&2
        ;;
    esac
    echo "━━━━━━━━━━━━━━" >&2
    echo "[RESULT] $exit_code issue(s) found — see Quick fixes above for how to resolve." >&2
    return 2
  else
    echo "[RESULT] All checks passed."
    return 0
  fi
}

main "$@"
