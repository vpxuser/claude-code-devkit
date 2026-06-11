# Command File Generation Guide

Rules for generating slash command files.

## Key Rule

**Commands are instructions FOR Claude, not messages TO the user.**

✓ Correct: "Review this code for SQL injection vulnerabilities."
✗ Incorrect: "This command will review your code."

## File Locations

| Scope | Path | Visibility |
|-------|------|------------|
| Project | `.claude/commands/command-name.md` | Team (in git) |
| Personal | `~/.claude/commands/command-name.md` | Global |
| Plugin | `plugin-name/commands/command-name.md` | Plugin users |

## Format

### Simple (no frontmatter)
```markdown
Review this code for security vulnerabilities:
- SQL injection
- XSS attacks
- Authentication bypass
```

### With YAML Frontmatter
```markdown
---
description: Review code for security issues
allowed-tools: Read, Grep, Bash(git:*)
model: sonnet
---

Review this code for security vulnerabilities...
```
## Frontmatter Fields

| Field | Type | Purpose |
|-------|------|---------|
| `description` | String | Shown in `/help`, under 60 chars |
| `allowed-tools` | String/Array | Tool restrictions: `"Read, Write"` or `["Read", "Write"]` |
| `model` | String | `sonnet`, `opus`, `haiku` |
| `argument-hint` | String | Usage hint shown in `/help`: `"<PR number>"` |

## Writing Style

1. **Start with action verbs**: "Review...", "Create...", "Analyze..."
2. **Be specific**: include exact steps, file patterns, output expectations
3. **Reference relevant skills** if applicable: "Use the security-review skill"
4. **Provide examples** for complex commands

## Good vs Bad

### Good (instructions TO Claude)
```markdown
Analyze the git diff for potential issues:
1. Check for security vulnerabilities
2. Verify error handling patterns
3. Confirm logging coverage
```

### Bad (messages TO the user)
```markdown
This command will analyze your git diff. It checks for
security issues, error handling, and logging. You'll
receive a detailed report.
```
