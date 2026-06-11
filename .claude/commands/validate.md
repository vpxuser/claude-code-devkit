---
description: Validate Claude Code configuration files in the project
allowed-tools: Read, Grep, Glob, Bash
---

# Validate Claude Code Files

Run validation on all or specific Claude Code configuration files in this project.

## Steps

1. If user specified a specific file, validate only that file
2. Otherwise, discover all Claude Code config files:

```bash
find . -name "SKILL.md" -o -name "AGENT.md" -o -name "agent.md" -o -name ".mcp.json" -o -name "hooks.json" -o -name "plugin.json" -o -name "settings.json" -o -name "CLAUDE.md" | grep -v node_modules | sort
```

3. For each file, determine type and run validation:
   - Call `bash .claude/scripts/validate.sh <filepath>` for each file
4. Report a summary:
   - Total files checked
   - Passed / Failed
   - Any issues found with file:line references

## Usage

```
/validate                — Validate all config files
/validate path/to/file   — Validate specific file
```
