---
description: Generate a Claude Code configuration file from a template. Asks clarifying questions to fill in the file correctly.
argument-hint: "<type> [description] — type: skill|agent|mcp|hooks|settings|plugin|command|claude-md"
allowed-tools: Read, Write, Grep, Glob
---

# Generate Claude Code File

You are generating a Claude Code configuration file based on the user's request. Follow these steps:

## Step 1: Understand the request

Parse the requested file type from the first argument.

| Argument | File to generate | Template |
|----------|-----------------|----------|
| `skill` | A new SKILL.md | `templates/SKILL.md` |
| `agent` | A new Agent.md | `templates/AGENT.md` |
| `mcp` | A new .mcp.json | `templates/mcp.json` |
| `hooks` | A new hooks.json | `templates/hooks.json` |
| `settings` | A new settings.json | `templates/settings.json` |
| `plugin` | A new plugin.json | `templates/plugin.json` |
| `command` | A new command .md file | `templates/command.md` |
| `claude-md` | A new CLAUDE.md | `templates/CLAUDE.md` |

## Step 2: Load the design philosophy

Read the skill at `.claude/skills/design-philosophy/SKILL.md` for the full specification of this file type.

## Step 3: Read the template

Load the corresponding template from `templates/`.

## Step 4: Ask clarifying questions

If the user hasn't provided enough detail, ask 1-3 specific questions:
- For skills: What domain? What specific tasks? What triggers?
- For agents: What role? What output? When should it trigger?
- For MCP: What service? stdio or HTTP? Authentication needed?

## Step 5: Generate the file

Create the file with the correct content, validating:
1. YAML frontmatter is correct
2. Name is kebab-case
3. Description is third person
4. For Agent.md: includes `<example>` blocks with `<commentary>`
5. For skills: follows progressive disclosure
6. For commands: written as instructions TO Claude

Output the generated file path and a brief summary of what was created.
