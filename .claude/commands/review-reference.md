---
description: "Review a REFERENCE.md file for best practices compliance"
argument-hint: "<path/to/REFERENCE.md>"
---

# Reference Review Command

Review the REFERENCE.md file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Frontmatter Completeness** — Are `name` and `description` present and well-formed?
   Is the description clear and concise?

2. **Section Completeness** — Are all required sections present:
   Purpose, Content, Examples, References?

3. **Content Quality** — Is the content well-organized? Are there clear headings?
   Is the content complete and accurate?

4. **Cross-Reference Quality** — Are there references to other files?
   Are the references valid and up-to-date?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **Markdown Compliance** — Run `npx markdownlint` on the file. Report every violation.

## Output Format

```markdown
## Review: [reference-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Frontmatter | ✅/❌ | [notes] |
| Sections | ✅/❌ | [notes] |
| Content | ✅/❌ | [notes] |
| Cross-References | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Markdown Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/reference-writing.md` — Content quality rules
- `.claude/rules/yaml-frontmatter.md` — Frontmatter field specifications
- `.claude/rules/markdown-output.md` — Markdown formatting rules
- `templates/REFERENCE.md.template` — Canonical template
