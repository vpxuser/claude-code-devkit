# Agent.md Generation Guide

Rules for generating Agent.md files — autonomous subprocess definitions.

## Key Distinction

- **Agents** = FOR autonomous background work (triggered by conditions)
- **Commands** = FOR user-initiated actions (invoked via `/command`)

## Structure

```markdown
---
name: agent-identifier
description: Use this agent when [conditions]. Examples:

<example>
Context: [Scenario]
user: "[User request]"
assistant: "[How Claude responds, triggering the agent]"
<commentary>
[Why this agent is appropriate]
</commentary>
</example>

[More examples...]

model: inherit
color: blue
tools: ["Read", "Write", "Grep"]
---

You are [role description]...

**Core Responsibilities:**
1. ...
**Process:**
[Step-by-step workflow]
**Output:**
[Expected return format]
```

## Frontmatter Fields

### name (required)
- 3-50 characters
- Lowercase, numbers, hyphens only
- No underscores
- Must start and end with alphanumeric

### description (required) — The most critical field
- Start with "Use this agent when [triggering conditions]."
- Include 2-4 `<example>` blocks
- Each example has: `Context:`, `user:`, `assistant:`, and `<commentary>` sections
- Show different phrasings of the same intent
- Mention when NOT to use

### model (required)
- `inherit` — recommended default (same as parent)
- `sonnet` — balanced
- `opus` — most capable
- `haiku` — fast, cheap

### color (required)
- `blue`/`cyan` — analysis, review
- `green` — success-oriented
- `yellow` — caution, validation
- `red` — critical, security
- `magenta` — creative, generation

### tools (optional)
Array of tool names: `["Read", "Write", "Grep", "Bash", "Edit", "Glob"]`

## System Prompt Design

1. **Define role**: "You are a [specific role]..."
2. **List responsibilities**: 3-5 core responsibilities
3. **Provide process**: Step-by-step workflow
4. **Specify output format**: What the agent returns
5. **Use imperative**: "Analyze...", "Review...", "Return..."

## Example Agent Prompt

```
You are a senior code reviewer specializing in security analysis.

**Your Core Responsibilities:**
1. Identify security vulnerabilities in code changes
2. Verify compliance with project security guidelines
3. Provide actionable fix recommendations

**Analysis Process:**
1. Review diff for injection vulnerabilities
2. Check authentication and authorization logic
3. Validate input sanitization patterns
4. Assess data exposure risks

**Output Format:**
- Issue description with file:line reference
- Severity: critical/high/medium/low
- Confidence score: 0-100
- Fix recommendation
```
