# .mcp.json Generation Guide

Rules for generating MCP server configurations.

## Server Type Selection

| Type | Use When | Config Pattern |
|------|----------|---------------|
| **stdio** | Local processes, custom servers, npm packages | `{"command": "npx", "args": [...]}` |
| **HTTP** | RESTful remote APIs, cloud services | `{"type": "http", "url": "...", "headers": {...}}` |
| **SSE** | Hosted MCP servers (deprecated, prefer HTTP) | `{"type": "sse", "url": "..."}` |
| **WebSocket** | Real-time bidirectional communication | `{"type": "ws", "url": "..."}` |

## Configurations

### Standalone .mcp.json (recommended for plugins)
```json
{
  "server-name": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"],
    "env": {
      "API_KEY": "${API_KEY}"
    }
  }
}
```

### HTTP Server
```json
{
  "api-service": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}"
    }
  }
}
```

### stdio with node
```json
{
  "server": {
    "command": "node",
    "args": ["${CLAUDE_PLUGIN_ROOT}/server/index.js"],
    "env": {
      "NODE_ENV": "production"
    }
  }
}
```

## Environment Variables

- `${VAR}` expands from Claude Code's environment
- `${CLAUDE_PLUGIN_ROOT}` — plugin root directory
- `${CLAUDE_PROJECT_DIR}` — project root (use with `:-` default for user-scoped)
- `${CLAUDE_PROJECT_DIR:-.}` — falls back to current dir

## Timeout Configuration

Per-server tool execution timeout:
```json
{
  "server": {
    "command": "...",
    "timeout": 600000
  }
}
```
Values below 1000 are ignored. Default is ~28 hours.

## Scope

- **project**: `.mcp.json` in project root (shared)
- **user**: `~/.claude.json` or `~/.claude/mcp.json`
- **local**: `.mcp.json` with `--scope local`

## Validation Checklist

- [ ] Server name is a valid JSON key
- [ ] stdio servers have both `command` and `args`
- [ ] HTTP/SSE servers have `type` and `url`
- [ ] Plugin paths use `${CLAUDE_PLUGIN_ROOT}`
- [ ] Sensitive values use env vars, not hardcoded
- [ ] Timeout is in milliseconds
