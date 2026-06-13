# Claude Code DevKit Project Instructions

This project is a blueprint/reference for generating correct Claude Code configuration files. When working here, follow these rules:

## Core behavior

1. When asked to generate any Claude Code file (SKILL.md, Agent.md, .mcp.json, hooks.json, settings.json, plugin.json, commands/*.md, CLAUDE.md), load the `design-philosophy` skill for authoritative specifications.
2. Use the templates in `templates/` as starting points and fill in requested specifics.
3. Reference the guides in `guides/` for detailed generation rules when the user needs depth on a specific file type.
4. Use `/generate-file <type> [description]` for quick file generation.

## Design principles to follow

- **Progressive disclosure** — Start lean, add detail only when needed
- **Third-person descriptions** — All YAML descriptions in third person
- **Kebab-case naming** — Lowercase, hyphens, no underscores
- **Concise instructions** — Claude is already smart; only add context it doesn't have
- **Commands are for Claude** — Write commands as instructions TO Claude, not messages TO the user

## When generating files

1. Ask clarifying questions if the request is underspecified
2. Present the generated file with a brief explanation
3. Validate against the specifications in the design philosophy skill

## File scope conventions

- Project-level files go in `.claude/` directory
- User-level files go in `~/.claude/`
- Plugin files use `.claude-plugin/` directory for manifest
- Skills in plugins go in `skills/skill-name/SKILL.md`
- Commands in plugins go in `commands/command-name.md`

Do not browse outside this project directory unless the user explicitly asks.
