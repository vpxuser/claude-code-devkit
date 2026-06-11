# settings.json Generation Guide

Rules for generating Claude Code settings files.

## File Hierarchy

| File | Scope | Git | Overrides |
|------|-------|-----|-----------|
| `~/.claude/settings.json` | User (global) | N/A | Base config |
| `.claude/settings.json` | Project | Yes | User settings |
| `.claude/settings.local.json` | Local | No (gitignored) | All above |

## Structure

```json
{
  "permissions": {
    "allow": ["Read", "Write", "Edit", "Grep", "Glob", "Bash"]
  },
  "hooks": {
    "PreToolUse": [...]
  },
  "mcpServers": {
    "server-name": {...}
  }
}
```

## Permission Patterns

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "Bash",
      "Bash(git:*)",
      "Bash(curl --proxy ...)",
      "WebFetch(domain:example.com)"
    ]
  }
}
```

- Simple tool name: `"Read"`, `"Write"`
- Tool with pattern: `"Bash(git:*)"`
- URL with proxy: `"Bash(curl --proxy socks5h://127.0.0.1:10808 ...)"`
- Domain restriction: `"WebFetch(domain:docs.anthropic.com)"`

## Hooks in Settings

Uses the direct (non-wrapped) format:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Validate..."
          }
        ]
      }
    ]
  }
}
```

## MCP Servers in Settings

```json
{
  "mcpServers": {
    "db": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"]
    }
  }
}
```

## Local Settings

`.claude/settings.local.json` follows the same structure but is not committed to git. Use for personal overrides (proxy config, personal permissions, local MCP servers).
