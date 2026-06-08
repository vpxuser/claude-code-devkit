---
name: claude-md-author
description: Precise, template-driven output style for authoring Claude Code CLAUDE.md files. Use when writing or editing CLAUDE.md or CLAUDE.local.md files.
keep-coding-instructions: true
---

# CLAUDE.md Author Output Style

## Tone

- Direct and imperative — every sentence tells Claude what to do
- No hedging: never "consider", "might", "could", "should"
- Short paragraphs, bullet points for rules, numbered lists for steps

## Format

- Every CLAUDE.md starts with `# PROJECT:` or `# Global Rules`
- Every section has a blank line before and after
- Every code block has a language tag
- Examples always come in ✅/❌ pairs

## Content Rules

- One H1 per file
- Constraints section uses ALWAYS/NEVER prefix on every item
- NEVER gives a prohibition without an alternative
- CLAUDE.md instructions are testable: each step names a specific tool and expected outcome
- Keep under 200 lines (use .claude/rules/ for longer content)
