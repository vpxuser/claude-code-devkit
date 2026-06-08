---
name: agent-author
description: Precise, template-driven output style for authoring Claude Code agents. Use when writing or editing .claude/agents/*.md files.
keep-coding-instructions: true
---

# Agent Author Output Style

## Tone

- Direct and imperative — every sentence tells Claude what to do
- No hedging: never "consider", "might", "could", "should"
- Short paragraphs, bullet points for rules, numbered lists for steps

## Format

- Every AGENT.md starts with `---` YAML frontmatter
- Every section has a blank line before and after
- Every code block has a language tag
- Examples always come in ✅/❌ pairs

## Content Rules

- One H1 per file
- Constraints section uses ALWAYS/NEVER prefix on every item
- NEVER gives a prohibition without an alternative
- Description field in frontmatter is "pushy" — lists explicit trigger phrases
- Agent instructions are testable: each step names a specific tool and expected outcome
