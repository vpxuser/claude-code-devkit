---
name: claude-code-design-philosophy
description: Teaches Claude Code the official design philosophy for every configuration file type it generates: skills (SKILL.md), agents (Agent.md), MCP servers (.mcp.json), hooks (hooks.json), settings (settings.json), plugins (plugin.json), commands (commands/*.md), and project instructions (CLAUDE.md). This skill should be used when the user asks to create, generate, scaffold, or edit any Claude Code file type, or references design decisions about these files.
version: 1.0.0
---

# Claude Code Design Philosophy

This skill contains the official Anthropic design philosophy for every Claude Code configuration file type. Use these specifications when generating or validating files. Everything here is distilled from [Claude Code official documentation](https://docs.anthropic.com/en/docs/claude-code/overview) and [Agent Skills specification](https://agentskills.io).

## Core Principles

### 1. Progressive Disclosure

Files load content in stages — only relevant content touches the context window:

| Level | When Loaded | Token Cost | Content |
|-------|------------|------------|---------|
| **Level 1: Metadata** | Always (startup) | ~100 tokens | `name` + `description` from YAML frontmatter |
| **Level 2: Body** | When triggered | Under 5k tokens | Main markdown body with instructions |
| **Level 3+: Resources** | As needed | Unlimited | Bundled files (scripts, references, examples) |

### 2. Filesystem-Based Access

Claude reads files via `bash` commands and executes scripts via `bash` — only outputs enter context, not script source code.

### 3. YAML Frontmatter Convention

Every file type uses YAML frontmatter between `---` delimiters for metadata. The body contains instructions.

### 4. Third-Person Descriptions

Descriptions are injected into the system prompt. Write in third person: "Processes PDF files" not "I can process PDFs" or "You can process PDFs".

### 5. Kebab-Case Naming

All file and directory names: lowercase letters, numbers, and hyphens only. No underscores, no spaces.

### 6. Concise = Kind

Claude is already smart. Only add context Claude doesn't have. Challenge every piece of information.

---

## File Type Specifications

## 1. SKILL.md — Skill Definitions

### Purpose
Modular, self-contained packages that extend Claude's capabilities with specialized knowledge and workflows.

### Directory Structure
```
skill-name/
├── SKILL.md           # Required. YAML frontmatter + instructions
├── references/        # Reference docs loaded as needed (optional)
├── scripts/           # Executable code run via bash (optional)
└── examples/          # Usage examples (optional)
```

### YAML Frontmatter
```yaml
---
name: skill-name
description: What this skill does and when to use it. Must be third person.
---
```

**Name rules:**
- Max 64 characters
- Lowercase letters, numbers, hyphens only
- No XML tags
- No reserved words: "anthropic", "claude"
- Use gerund form recommended: `processing-pdfs`, `analyzing-data`

**Description rules:**
- Max 1024 characters
- Must be non-empty
- No XML tags
- Third person: "Processes PDFs" not "You can process PDFs"
- Include both what it does AND when to trigger
- Be specific: "Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."

### Body Writing Rules (SKILL.md)

The body of SKILL.md is where procedural knowledge lives. Follow these official conventions.

#### 1. Be Concise — Claude Is Already Smart

Only add context Claude doesn't already have. Challenge every paragraph:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Good (~50 tokens):**
````markdown
## Extract PDF text
Use pdfplumber for text extraction:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````
**Bad (~150 tokens) — explains what Claude already knows:**
```markdown
PDF (Portable Document Format) files are a common file format that contains text,
images, and other content. To extract text from a PDF, you'll need to use a library...
```

#### 2. Use Imperative / Infinitive Form

Write instructions as commands TO Claude, not descriptions TO the user.

| Correct (imperative) | Incorrect |
|----------------------|-----------|
| "Extract text with pdfplumber" | "You should extract text using pdfplumber" |
| "Run the validation script" | "The user can run the validation script" |
| "Use pdfplumber for text extraction" | "I recommend using pdfplumber for text extraction" |

#### 3. Three Degrees of Freedom

Match specificity to task fragility:

| Degree | When | Format |
|--------|------|--------|
| **High** (text) | Multiple approaches valid, context-dependent | General steps, guidelines |
| **Medium** (pseudocode) | Preferred pattern exists, some variation OK | Templates with parameters |
| **Low** (exact) | Fragile ops, consistency critical | Exact commands, no deviation |

**High freedom** — trust Claude's judgment:
```markdown
## Code review process
1. Analyze code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability
```
**Medium freedom** — preferred pattern, adaptable:
````markdown
## Generate report
Use this template and customize as needed:
```python
def generate_report(data, format="markdown", include_charts=True):
    ...
```
````
**Low freedom** — exact instructions, no deviation:
````markdown
## Database migration
Run exactly this script:
```bash
python scripts/migrate.py --verify --backup
```
Do not modify the command or add additional flags.
````

#### 4. Body Structure Conventions

**Order of sections:**
```
# Skill Name
## Quick Start          ← Most common task first
## Core Workflows       ← Step-by-step procedures
## Advanced Usage       ← See references for depth
## Guidelines           ← Domain-specific rules
```

**Body length:** Keep under 500 lines. Split into reference files when approaching this limit.

**References must be flat** — all linked directly from SKILL.md, one level deep only. Don't nest references within references:
- Correct: `See [advanced.md](references/advanced.md)` from SKILL.md
- Wrong: SKILL.md → advanced.md → details.md (Claude may only `head -100` the middle file)

**Structure reference files with table of contents** so Claude can jump to sections:
```markdown
# Reference: Form Filling API
## Sections
- [Field extraction](#field-extraction)
- [Form validation](#form-validation)
## Field extraction
...
```

#### 5. Workflow Patterns

**Break complex operations into sequential steps.** For multi-step processes, provide a checklist:
```markdown
## PDF form filling workflow
Copy this checklist and track progress:
```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```
**Step 1: Analyze the form** — Run `python scripts/analyze_form.py input.pdf`
...
```

**Include validation loops** — act → validate → fix → proceed:
```markdown
1. Make edits to `document.xml`
2. **Validate immediately**: `python scripts/validate.py`
3. If validation fails: fix issues, run validation again
4. **Only proceed when validation passes**
```

#### 6. Examples Pattern

Provide input/output pairs:
````markdown
## Commit message format
**Example 1:** Added user auth with JWT
```
feat(auth): implement JWT-based authentication
- Add login endpoint
- Add token validation middleware
```
**Example 2:** Fixed date display bug
```
fix(ui): correct date formatting in reports
```
````

#### 7. Output Templates

For structured output, provide markdown templates:
```markdown
## Report format
Generate analysis in this format:
```markdown
# [Analysis Title]
## Executive summary
[One-paragraph overview]
## Key findings
- Finding 1 with supporting data
## Recommendations
1. Specific actionable recommendation
```
```

#### 8. Terminology & Consistency

Choose one term and use it throughout:
- **Good:** Always "API endpoint", always "field", always "extract"
- **Bad:** Mix "API endpoint", "URL", "API route", "path" interchangeably

#### 9. What to Avoid in Body

| Anti-pattern | Why | Fix |
|-------------|-----|-----|
| Explaining programming basics | Claude already knows | Delete or assume knowledge |
| Time-sensitive info (dates, versions) | Becomes outdated | Use `<details>` with "Legacy" section |
| Multiple options without default | Confusing | Pick one default, mention alternatives after |
| Deeply nested references (>1 level) | Claude may only partial-read | Link everything from SKILL.md |
| Verbose introductions | Wastes context | Start with the task, not background |
| Writing TO the user | Commands are instructions FOR Claude | Rewrite as directives |

#### 10. Agent Body (System Prompt)

Agent.md body follows unique conventions — it IS the system prompt:
- **Define role**: "You are a [specific role]..."
- **List responsibilities**: 3-5 core responsibilities as bullet list
- **Provide process**: Step-by-step workflow in imperative
- **Specify output format**: What the agent returns
- **Use sections with bold headers**: `**Core Responsibilities:**`, `**Analysis Process:**`, `**Output Format:**`

---

## 2. Agent.md — Agent Definitions

### Purpose
Agents are autonomous subprocesses that handle complex, multi-step tasks independently. **Agents are FOR autonomous work, commands are FOR user-initiated actions.**

### File Format
```markdown
---
name: agent-identifier
description: Use this agent when [conditions]. Examples:

<example>
Context: [Situation]
user: "[User request]"
assistant: "[Response using this agent]"
<commentary>
[Why this agent triggers]
</commentary>
</example>

model: inherit
color: blue
tools: ["Read", "Write", "Grep", "Bash"]
---

You are [role description]...

**Core Responsibilities:**
1. ...
**Process:**
[Step-by-step workflow]
**Output:**
[Expected return format]
```

### Frontmatter Fields

| Field | Required | Rules |
|-------|----------|-------|
| `name` | Yes | 3-50 chars, lowercase, numbers, hyphens. No underscores. |
| `description` | Yes | Critical field. Trigger conditions + 2-4 `<example>` blocks with `<commentary>`. |
| `model` | Yes | `inherit` (default), `sonnet`, `opus`, `haiku` |
| `color` | Yes | `blue`, `cyan`, `green`, `yellow`, `magenta`, `red` |
| `tools` | No | Array of tool names: `["Read", "Write", "Grep", "Bash", "Edit", "Glob"]` |

### Description Format Rules
1. Start with "Use this agent when [triggering conditions]."
2. Include 2-4 `<example>` blocks
3. Each example has: Context, user prompt, assistant response, and `<commentary>`
4. Show different phrasings of the same intent
5. Mention when NOT to use the agent

### System Prompt Design
- Define role clearly: "You are a [role]..."
- List core responsibilities
- Provide step-by-step analysis process
- Specify output format
- Use imperative: "Analyze...", "Review...", "Return..."

---

## 3. .mcp.json — MCP Server Configuration

### Purpose
Connects Claude Code to external tools and APIs via Model Context Protocol servers.

### Server Types

| Type | Best For | Config |
|------|----------|--------|
| **stdio** | Local processes, custom servers | `{"command": "npx", "args": [...]}` |
| **HTTP** | Remote REST APIs | `{"type": "http", "url": "...", "headers": {...}}` |
| **SSE** | Hosted servers (deprecated) | `{"type": "sse", "url": "..."}` |
| **WebSocket** | Real-time communication | `{"type": "ws", "url": "..."}` |

### Configuration Formats

**Standalone .mcp.json (recommended for plugins):**
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

**Inline in plugin.json:**
```json
{
  "name": "my-plugin",
  "mcpServers": {
    "server-name": {
      "command": "${CLAUDE_PLUGIN_ROOT}/server",
      "args": ["--port", "8080"]
    }
  }
}
```

### Key Rules
- Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths
- Use `"timeout": 600000` for per-server tool execution timeout (ms)
- Environment variables: `${VAR}` expands from Claude Code's environment
- For stdio with env vars needing defaults: `${CLAUDE_PROJECT_DIR:-.}`
- `type` field accepts `streamable-http` as alias for `http`

### Scope
- **project** (`.mcp.json` in project root)
- **user** (`~/.claude.json` or `~/.claude/mcp.json`)
- **local** (`.mcp.json` with `--scope local`)

---

## 4. hooks.json — Hook Configuration

### Purpose
Event-driven automation scripts that execute in response to Claude Code events.

### Configuration Formats

**Plugin hooks** (in `hooks/hooks.json`):
```json
{
  "description": "Optional description",
  "hooks": {
    "PreToolUse": [...],
    "Stop": [...]
  }
}
```

**Settings format** (in `settings.json`):
```json
{
  "PreToolUse": [...],
  "Stop": [...]
}
```

### Hook Events

| Event | When Fires | Use Case |
|-------|-----------|----------|
| `PreToolUse` | Before tool execution | Approve/deny/modify tool calls |
| `PostToolUse` | After tool completes | React to results, log, validate |
| `Stop` | When agent considers stopping | Verify completeness |
| `SubagentStop` | When subagent completes | Validate subagent output |
| `SessionStart` | At session beginning | Load context, init state |
| `SessionEnd` | At session end | Cleanup, log |
| `UserPromptSubmit` | When user sends message | Analyze/modify user input |
| `PreCompact` | Before context compression | Save state before compression |

### Hook Types

**Prompt-based (recommended):**
```json
{
  "type": "prompt",
  "prompt": "Evaluate: $TOOL_INPUT",
  "timeout": 30
}
```

**Command-based (deterministic):**
```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
  "timeout": 60
}
```

### Matcher Patterns
```json
{
  "matcher": "Write|Edit",
  "hooks": [{"type": "prompt", "prompt": "...", "timeout": 30}]
}
```

### PreToolUse Output
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny|ask",
    "updatedInput": {"field": "modified_value"}
  },
  "systemMessage": "Explanation for Claude"
}
```

---

## 5. settings.json — Project Configuration

### Purpose
Configures Claude Code behavior, permissions, hooks, and MCP servers at project or user level.

### File Locations
- **Project**: `.claude/settings.json` (shared with team, in git)
- **Local**: `.claude/settings.local.json` (personal overrides, not in git)
- **User**: `~/.claude/settings.json` (global across all projects)

### Structure
```json
{
  "permissions": {
    "allow": ["Read", "Write", "Bash(...)"]
  },
  "hooks": {
    "PreToolUse": [...]
  },
  "mcpServers": {
    "server-name": {...}
  }
}
```

### Permission Patterns
- Specific tool: `"Read"`
- Bash with pattern: `"Bash(git:*)"`
- URL with proxy: `"Bash(curl --proxy socks5h://127.0.0.1:10808 ...)"`
- Domain: `"WebFetch(domain:example.com)"`

### Local Settings Override
`settings.local.json` at the same path overrides `settings.json` fields. Use for personal permissions/proxy configs.

---

## 6. plugin.json — Plugin Manifest

### Purpose
Defines plugin metadata and configuration. Located at `.claude-plugin/plugin.json`.

### Required Fields
```json
{
  "name": "plugin-name"
}
```

### Full Structure
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief explanation of plugin purpose",
  "author": {"name": "Author", "email": "author@example.com"},
  "commands": "./custom-commands",
  "agents": ["./agents", "./specialized-agents"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### Plugin Directory Structure
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Required manifest
├── commands/                  # Slash commands (.md)
├── agents/                    # Agent definitions (.md)
├── skills/                    # Skill directories
│   └── skill-name/
│       └── SKILL.md
├── hooks/
│   └── hooks.json             # Hook configurations
├── .mcp.json                  # MCP server definitions
└── scripts/                   # Helper scripts
```

### Component Path Rules
- Custom paths in `plugin.json` supplement (don't replace) default directories
- Components in both default AND custom paths will load
- Always use `${CLAUDE_PLUGIN_ROOT}` for portable paths

---

## 7. Commands (.md) — Slash Commands

### Purpose
Frequently-used prompts defined as Markdown files. **Commands are instructions FOR Claude, not messages TO the user.**

### File Locations
- **Project**: `.claude/commands/command-name.md` (shared with team)
- **Personal**: `~/.claude/commands/command-name.md` (global)
- **Plugin**: `plugin-name/commands/command-name.md` (plugin-bundled)

### Basic Format (no frontmatter needed):
```markdown
Review this code for security vulnerabilities including:
- SQL injection
- XSS attacks
- Authentication bypass
```

### With YAML Frontmatter:
```markdown
---
description: Review code for security issues
allowed-tools: Read, Grep, Bash(git:*)
model: sonnet
---

Review this code for security vulnerabilities...
```

### Frontmatter Fields

| Field | Type | Purpose |
|-------|------|---------|
| `description` | String | Shown in `/help`, under 60 chars |
| `allowed-tools` | String/Array | Tool restrictions |
| `model` | String | `sonnet`, `opus`, `haiku` |
| `argument-hint` | String | Usage hint: `"Optional plugin description"` |

---

## 8. CLAUDE.md — Project Instructions

### Purpose
Project-specific instructions loaded at the start of every Claude Code session.

### Location
- `.claude/CLAUDE.md` (project root, under `.claude/` directory)

### Content Guidelines
- Start with a clear project overview
- List key conventions: naming, testing, architecture
- Specify rules Claude must follow
- Keep concise — loaded entirely at startup

### Writing Style
- Imperative: "Run tests before committing" not "You should run tests"
- Specific: reference file patterns and exact commands
- Actionable: rules Claude can follow without ambiguity

---

## 9. .local.md — Plugin Settings Files

### Pattern
`.claude/plugin-name.local.md` in project root. Contains YAML frontmatter + markdown body.

### Structure
```markdown
---
enabled: true
setting1: value1
---

# Context
Optional markdown body with instructions or notes.
```

### Usage
- Read from hooks via bash (sed/awk parsing)
- Store per-project plugin configuration
- Not in git (should be in `.gitignore`)
- User-managed state files

---

## Common Validation Rules

When generating ANY file, validate:

1. **Name**: Kebab-case? No reserved words? Correct length?
2. **Description**: Third person? Specific triggers? Max length?
3. **Structure**: YAML frontmatter correct? Body follows guidelines?
4. **Progressive disclosure**: Split large files? References accessible?
5. **Portability**: Using `CLAUDE_PLUGIN_ROOT` in plugins? Relative paths?

## Reference Sources

- Skills: https://docs.anthropic.com/en/docs/claude-code/skills and https://agentskills.io
- Agents: https://docs.anthropic.com/en/docs/claude-code/agent
- MCP: https://code.claude.com/docs/en/mcp
- Hooks: https://code.claude.com/docs/en/hooks
- Configuration: https://code.claude.com/docs/en/configuration
- Plugins: https://code.claude.com/docs/en/plugins
- Overview: https://docs.anthropic.com/en/docs/claude-code/overview
- Best Practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
