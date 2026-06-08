---
description: "Review a WORKFLOW.js file for best practices compliance"
argument-hint: "<path/to/WORKFLOW.js>"
---

# Workflow Review Command

Review the WORKFLOW.js file at `$ARGUMENTS` against the project's quality standards.

## Review Dimensions

1. **Structure Completeness** — Are all required sections present:
   JSDoc header, phases, helper functions?

2. **Phase Quality** — Are phases clearly separated? Does each phase have JSDoc comments?
   Are there more than 7 phases (should be split)?

3. **Error Handling** — Does the workflow handle errors gracefully?
   Are there try-catch blocks? Are error messages meaningful?

4. **Global Variable Usage** — Does the workflow use `args` global variable correctly?
   Is it NOT using `export default`?

5. **Example Quality** — Is there a ✅/❌ pair? Are the examples complete and copyable? Does the ❌ example have an error explanation?

6. **JavaScript Compliance** — Run `npx eslint` on the file. Report every violation.

## Output Format

```markdown
## Review: [workflow-name]

### Score: X/6

| Dimension | Pass | Notes |
|-----------|------|-------|
| Structure | ✅/❌ | [notes] |
| Phases | ✅/❌ | [notes] |
| Error Handling | ✅/❌ | [notes] |
| Global Variables | ✅/❌ | [notes] |
| Examples | ✅/❌ | [notes] |
| JavaScript Lint | ✅/❌ | [N violations] |

### Required Fixes

1. [Fix 1]
2. [Fix 2]
```

## References

- `CLAUDE.md` — Project-level rules
- `.claude/rules/workflow-writing.md` — Content quality rules
- `templates/WORKFLOW.js.template` — Canonical template
