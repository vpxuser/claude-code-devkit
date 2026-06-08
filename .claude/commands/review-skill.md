---
description: "Review a SKILL.md file for best practices compliance"
argument-hint: "<path/to/SKILL.md>"
---

# Skill Review Command

Review the SKILL.md file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Frontmatter Completeness** — Are `name` and `description` present and well-formed?
   Is the description "pushy" with trigger phrases?

2. **Section Completeness** — Are all required sections present:
   Purpose, Trigger Conditions, Inputs, Workflow, Constraints, Output Format,
   Examples, Quality Checklist?

3. **Instruction Quality** — Are instructions imperative and testable?
   Does each step name a specific tool? Are there error-handling paths?

4. **Constraint Quality** — Does every constraint start with ALWAYS or NEVER? Does every NEVER have an alternative?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **Markdown Compliance** — Run `npx markdownlint` on the file. Report every violation.

## Output Format

```markdown
## Review: [skill-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Frontmatter | ✅/❌ | [notes] |
| Sections | ✅/❌ | [notes] |
| Instructions | ✅/❌ | [notes] |
| Constraints | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| Markdown Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/skill-writing.md` — Content quality rules
- `.claude/rules/yaml-frontmatter.md` — Frontmatter field specifications
- `.claude/rules/markdown-output.md` — Markdown formatting rules
- `templates/SKILL.md.template` — Canonical template
