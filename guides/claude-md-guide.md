# CLAUDE.md Generation Guide

Rules for generating project-level CLAUDE.md files.

## Purpose

CLAUDE.md provides project-specific instructions that Claude Code loads at the start of every session. It's the first thing Claude reads about your project.

## Location

- `.claude/CLAUDE.md` — Current standard (under `.claude/` directory)
- `CLAUDE.md` in project root — Legacy, still supported

## What to Include

1. **Project overview** — What this project is
2. **Conventions** — Coding style, testing, naming, architecture patterns
3. **Rules** — Specific do's and don'ts for Claude
4. **Key commands** — Build, test, deploy commands

## Writing Style

- **Imperative**: "Run tests before committing" not "You should run tests"
- **Specific**: Reference actual file paths, package names, command syntax
- **Actionable**: Rules Claude can follow without interpretation
- **Concise**: Entire file loaded at startup — every token counts

## Good Examples

```
# User Service API

## Conventions
- Tests: Vitest, in `__tests__/` colocated with source
- Error handling: Return structured {error, code} objects
- Logging: Use the pino logger at info level

## Rules
- Run `pnpm test` before every commit
- Add JSDoc comments to all public API methods
- Never hardcode secrets — use environment variables
```

## Bad Examples

```
# Project

This is a project that does various things. Please help
me work on it. We should try to write good code and follow
best practices. Tests are important. Documentation matters.
```

(Too vague — no actionable instructions.)

## Template Structure

```markdown
# Project Name

Brief description.

## Conventions
- **Testing**: [framework, location, patterns]
- **Naming**: [file naming, variable naming]
- **Architecture**: [patterns, layers, structure]

## Rules for Claude
1. [Specific, actionable rule]
2. [Specific, actionable rule]

## Key commands
- `npm run test` — Run tests
- `npm run build` — Build project
```
