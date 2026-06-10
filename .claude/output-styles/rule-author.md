---
name: rule-author
description: Precise, template-driven output style for authoring Claude Code rules. Use when writing or editing .claude/rules/*.md files.
keep-coding-instructions: true
---

# Rule Author Output Style

## Tone

- Direct and imperative — every sentence tells Claude what to do
- No hedging: never "consider", "might", "could", "should"
- Short paragraphs, bullet points for rules, numbered lists for steps

## Format

- Every rule starts with `---` YAML frontmatter (`paths` + `description`)
- Every section has a blank line before and after
- Every code block has a language tag
- Examples always come in ✅/❌ pairs

## Content Rules

- One H1 per file
- H1 followed by `>` blockquote defining scope
- Constraints section uses ALWAYS/NEVER prefix on every item
- NEVER gives a prohibition without an alternative (`— 改为 [correct做法]`)
- Sections ordered by importance (most critical first)
- File ≤ 150 lines; split if longer
