---
description: "Review a CLAUDE.md file for best practices compliance"
argument-hint: "<path/to/CLAUDE.md>"
---

# CLAUDE.md Review Command

Review the CLAUDE.md file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Structure Completeness** — Are all required sections present:
   # PROJECT, Stack+Purpose, ALWAYS, NEVER, Format spec, Output checklist?

2. **Rule Quality** — Are rules clear and actionable? Do they start with ALWAYS or NEVER?
   Does every NEVER have an alternative?

3. **Reference Quality** — Are there references to other files? Are the references valid?
   Is the CLAUDE.md under 150 lines?

4. **Consistency** — Is the CLAUDE.md consistent with other rules files?
   Are there any contradictions?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **Markdown Compliance** — Run `npx markdownlint` on the file. Report every violation.

## Output Format

```markdown
## Review: [project-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Structure | ✅/❌ | [notes] |
| Rules | ✅/❌ | [notes] |
| References | ✅/❌ | [notes] |
| Consistency | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Markdown Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/claude-md-writing.md` — Content quality rules
- `.claude/rules/yaml-frontmatter.md` — Frontmatter field specifications
- `.claude/rules/markdown-output.md` — Markdown formatting rules
- `templates/CLAUDE.md.template` — Canonical template
