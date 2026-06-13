# Claude Code DevKit

**A blueprint project that guides Claude Code to generate correct Claude Code configuration files following official design philosophy.**

This project serves as a living reference — it contains templates, guides, and a core design philosophy skill that Claude Code uses to generate files like `SKILL.md`, `Agent.md`, `.mcp.json`, `hooks.json`, `settings.json`, `plugin.json`, `commands/*.md`, and `CLAUDE.md`.

## How it works

Claude Code reads the project's `.claude/CLAUDE.md` and `.claude/skills/design-philosophy/SKILL.md` at startup. These files teach Claude Code the official design patterns for every file type it might need to generate. Template files in `templates/` serve as starting points, and guides in `guides/` provide detailed generation rules.

## File types covered

| File | Purpose | Official docs |
|------|---------|---------------|
| `SKILL.md` | Modular capabilities with progressive disclosure | [Skills Overview](https://docs.anthropic.com/en/docs/claude-code/skills) |
| `Agent.md` | Autonomous subprocess definitions | [Agents](https://docs.anthropic.com/en/docs/claude-code/agent) |
| `.mcp.json` | MCP server configuration | [MCP](https://code.claude.com/docs/en/mcp) |
| `hooks.json` | Event-driven automation hooks | [Hooks](https://code.claude.com/docs/en/hooks) |
| `settings.json` | Claude Code project/user settings | [Configuration](https://code.claude.com/docs/en/configuration) |
| `plugin.json` | Plugin manifest | [Plugins](https://code.claude.com/docs/en/plugins) |
| `commands/*.md` | Slash command definitions | Commands (in plugins guide) |
| `CLAUDE.md` | Project-level instructions | [Overview](https://docs.anthropic.com/en/docs/claude-code/overview) |
| `.local.md` | Plugin settings/state files | Plugin settings pattern |

## Quick start

To use this devkit, start a Claude Code session in this directory. Claude Code will automatically load the design philosophy skill and project instructions. Then ask:

- "Generate a SKILL.md for a PDF processing skill"
- "Create an Agent.md for a code reviewer"
- "Set up .mcp.json to connect to PostgreSQL"
- "Create a plugin for database migrations"

Or use the built-in command:
```
/generate-file <type> [description]
```

## Project structure

```
claude-code-devkit/
├── .claude/
│   ├── CLAUDE.md              # Project instructions for Claude Code
│   ├── settings.json          # Permissions, hooks config + auto-validation
│   ├── settings.local.json    # Local overrides (not in git)
│   ├── scripts/
│   │   └── validate.sh        # Post-write validation engine for all file types
│   ├── skills/
│   │   └── design-philosophy/
│   │       └── SKILL.md       # Core design philosophy skill
│   └── commands/
│       ├── generate-file.md   # /generate-file — scaffold any config file
│       └── validate.md        # /validate — manually validate all files
├── guides/
│   ├── design-philosophy.md   # Core design philosophy reference
│   ├── skill-guide.md         # SKILL.md generation rules
│   ├── agent-guide.md         # Agent.md generation rules
│   ├── mcp-guide.md           # .mcp.json generation rules
│   ├── hooks-guide.md         # hooks.json generation rules
│   ├── command-guide.md       # Command file generation rules
│   ├── settings-guide.md      # settings.json generation rules
│   ├── plugin-guide.md        # Plugin generation rules
│   └── claude-md-guide.md     # CLAUDE.md generation rules
├── templates/
│   ├── SKILL.md               # SKILL.md template
│   ├── AGENT.md               # Agent.md template
│   ├── mcp.json               # MCP config template
│   ├── hooks.json             # Hooks config template
│   ├── plugin.json            # Plugin manifest template
│   ├── settings.json          # Settings config template
│   ├── command.md             # Command file template
│   └── CLAUDE.md              # CLAUDE.md template
└── README.md                  # This file
```

## Design philosophy

Claude Code configuration files follow these core principles:

1. **Progressive disclosure** — Only load what's needed, when it's needed
2. **Conciseness** — Claude is already smart; only add context it doesn't have
3. **Filesystem-based** — Files exist on disk, Claude reads/executes them via bash
4. **YAML frontmatter** — Metadata in frontmatter, instructions in the body
5. **Third-person descriptions** — Descriptions are injected into the system prompt
6. **Kebab-case naming** — Lowercase letters, numbers, and hyphens only

See `guides/design-philosophy.md` and the core skill for full details.

## Auto-Validation

When you write or edit a Claude Code configuration file in this project, a `PostToolUse` hook automatically runs the validation script (`.claude/scripts/validate.sh`). It checks:

| Check | What it validates |
|-------|-------------------|
| **SKILL.md** | YAML frontmatter, kebab-case name, no reserved words, description rules, body non-empty, **body writing style (imperative, concise, no anti-patterns)**, body under 500 lines |
| **Agent.md** | Name length (3-50), `<example>` blocks with `<commentary>`, `model` and `color` fields |
| **.mcp.json** | Valid JSON, server type consistency, required fields per type (stdio/HTTP/SSE) |
| **hooks.json** | Valid JSON, valid event names, non-empty hook configurations |
| **plugin.json** | Valid JSON, required `name` field, kebab-case name |
| **settings.json** | Valid JSON, recognized top-level keys |
| **commands/*.md** | Writing style (must be TO Claude, not TO user), frontmatter |
| **CLAUDE.md** | Non-empty content, specific title |

Validation results appear in the Claude Code transcript. Use `/validate` to manually validate all files at once.

## Deploy to Other Projects

### Option 1: Deployment script (recommended)

```bash
# From the devkit directory:
bash deploy.sh /path/to/target-project          # Validation only
bash deploy.sh /path/to/target-project --full   # Full: validation + skill + commands
bash deploy.sh /path/to/target-project --dry-run  # Preview only
```

This copies the validation script, commands, and hooks into the target project's `.claude/` directory. The `--full` mode also installs the design philosophy skill, guides, and templates.

### Option 2: Plug and play (plugin install)

Use the devkit as a Claude Code Plugin for ad-hoc access to validation in any project:

```bash
# From a project where you want devkit features:
claude --plugin-dir /path/to/claude-code-devkit
```

This grants temporary access to all devkit commands (`/validate`, `/generate-file`) and the validation hook without installing into the project permanently.

### Option 3: Manual install

Copy only what you need:

| Component | Source | Destination |
|-----------|--------|-------------|
| Validation script | `.claude/scripts/validate.sh` | `<target>/.claude/scripts/` |
| Validate command | `.claude/commands/validate.md` | `<target>/.claude/commands/` |
| Generate command | `.claude/commands/generate-file.md` | `<target>/.claude/commands/` |
| PostToolUse hook | `hooks/hooks.json` → PostToolUse section | `<target>/.claude/settings.json` |
| Design skill | `.claude/skills/` | `<target>/.claude/skills/` |

## Reference

- [Official Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Skills Overview](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Claude Code GitHub Repository](https://github.com/anthropics/claude-code)
- [Agent Skills Specification](https://agentskills.io)
