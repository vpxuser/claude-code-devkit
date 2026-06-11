# Plugin Generation Guide

Rules for generating Claude Code plugins.

## Plugin Directory Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Required: manifest
├── commands/                  # Slash commands (.md)
├── agents/                    # Agent definitions (.md)
├── skills/                    # Skill directories
│   └── skill-name/
│       └── SKILL.md
├── hooks/
│   └── hooks.json             # Hook configurations
├── .mcp.json                  # MCP server definitions
└── README.md                  # Plugin documentation
```

## Manifest (plugin.json)

### Required
```json
{
  "name": "plugin-name"
}
```

### Full
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief explanation",
  "author": {"name": "Author"},
  "commands": "./custom-commands",
  "agents": ["./agents", "./specialized-agents"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

## Component Rules

### Auto-discovery
Claude Code auto-discovers components from standard directories:
- `commands/*.md` → `/command-name` (namespaced as plugin-name if in plugin)
- `agents/*.md` → Agent definitions
- `skills/*/SKILL.md` → Skills
- `hooks/hooks.json` → Hook configurations
- `.mcp.json` → MCP servers (plugin root)

### Custom Paths
Custom paths in `plugin.json` supplement (not replace) defaults:
```json
{
  "agents": ["./agents", "./specialized-agents"]
}
```

### Portability
Always use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths — it resolves to the plugin's root directory.

### Naming
- Plugin name: kebab-case, no spaces, unique across installed plugins
- Component files: kebab-case
- Use namespaced commands for plugins: `plugin-name:command-name`

## Validation Checklist

- [ ] `.claude-plugin/plugin.json` exists with `name` field
- [ ] All component paths resolve correctly
- [ ] `${CLAUDE_PLUGIN_ROOT}` used instead of absolute paths
- [ ] Skill descriptions are third person with trigger phrases
- [ ] Agent descriptions include `<example>` blocks with `<commentary>`
- [ ] No hardcoded credentials or secrets
