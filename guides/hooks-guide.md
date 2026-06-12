# hooks.json Generation Guide

Rules for generating hook configurations.

## Hook Events

| Event | Timing | Typical Use |
|-------|--------|-------------|
| `PreToolUse` | Before tool runs | Approve/deny/modify tool calls |
| `PostToolUse` | After tool completes | React to results, log, validate |
| `Stop` | Agent considers stopping | Verify completeness |
| `SubagentStop` | Subagent finishes | Validate subagent output |
| `SessionStart` | Session begins | Load context, initialize state |
| `SessionEnd` | Session ends | Cleanup, log metrics |
| `UserPromptSubmit` | User sends message | Analyze/modify input |
| `PreCompact` | Before context compression | Save important state |

## Configuration Formats

### Plugin hooks (hooks/hooks.json)
```json
{
  "description": "Optional description",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Validate: $TOOL_INPUT",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Settings hooks (settings.json)
```json
{
  "hooks": {
    "PreToolUse": [...]
  }
}
```

## Hook Types

### Prompt-based (recommended)
Uses LLM decision-making. Context-aware, handles edge cases.
```json
{
  "type": "prompt",
  "prompt": "Evaluate this tool use: $TOOL_INPUT. Return 'approve' or 'deny'.",
  "timeout": 30
}
```

### Command-based
Bash scripts for deterministic checks. Fast, reliable.
```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
  "timeout": 60
}
```
Exit 0 = approve, non-zero = block.

## Matcher Tool Patterns

- `"Write"` — single tool
- `"Write|Edit"` — any of listed tools
- `"Bash(git:*)"` — Bash with git commands only
- `"*"` — all tools

## PreToolUse Output Format

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny|ask",
    "updatedInput": {"field": "modified_value"}
  },
  "systemMessage": "Explanation for Claude"
}
```

## Portability

Always use `${CLAUDE_PLUGIN_ROOT}` in plugin hooks instead of absolute paths:
```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/validate.sh"
}
```
