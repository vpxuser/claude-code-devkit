---
description: "Review a OUTPUT-STYLE.md file for best practices compliance"
argument-hint: "<path/to/OUTPUT-STYLE.md>"
---

# Output Style Review Command

Review the OUTPUT-STYLE.md file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Frontmatter Completeness** — Are `name` and `description` present and well-formed?
   Is the description clear and concise?

2. **Section Completeness** — Are all required sections present:
   Tone, Format, Content Rules?

3. **Tone Quality** — Is the tone clearly defined? Are there specific guidelines?
   Are there examples of good and bad tone?

4. **Format Quality** — Are formatting rules clear? Are there specific examples?
   Are there ✅/❌ pairs for formatting?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **Markdown Compliance** — Run `npx markdownlint` on the file. Report every violation.

## Output Format

```markdown
## Review: [style-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Frontmatter | ✅/❌ | [notes] |
| Sections | ✅/❌ | [notes] |
| Tone | ✅/❌ | [notes] |
| Format | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Markdown Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/output-style-writing.md` — Content quality rules
- `.claude/rules/yaml-frontmatter.md` — Frontmatter field specifications
- `.claude/rules/markdown-output.md` — Markdown formatting rules
- `templates/OUTPUT-STYLE.md.template` — Canonical template
